/* DerivedInductionVar.cpp
 *
 * This pass detects derived induction variables using ScalarEvolution.
 * It also performs a conservative Induction Variable Elimination (IVE)
 * transformation for inner loops when a canonical primary IV (step 1)
 * is present and a derived IV is an affine AddRec with constant start & step.
 *
 * Compatible with New Pass Manager
*/

#include "llvm/IR/PassManager.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/Analysis/ScalarEvolutionExpressions.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"

using namespace llvm;

namespace {

class DerivedInductionVar : public PassInfoMixin<DerivedInductionVar> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM) {
    auto &LI = AM.getResult<LoopAnalysis>(F);
    auto &SE = AM.getResult<ScalarEvolutionAnalysis>(F);

    // Iterate all top-level loops (LoopAnalysis returns loop forest)
    for (Loop *TopL : LI) {
      processLoopAndSubloops(TopL, SE);
    }

    // We transform the IR in some cases -> cannot claim everything preserved.
    return PreservedAnalyses::none();
  }

private:
  void processLoopAndSubloops(Loop *L, ScalarEvolution &SE) {
    for (Loop *Sub : L->getSubLoops())
      processLoopAndSubloops(Sub, SE);

    if (!L->isInnermost())
      return;

    Function *F = L->getHeader()->getParent();
    errs() << "Analyzing inner loop in function " << F->getName() << " (header: "
           << L->getHeader()->getName() << ")\n";

    // Identify a canonical primary IV if present:
    // find a PHI in header that's an affine AddRec with step == 1 and start == 0 (integers)
    PHINode *PrimaryIV = nullptr;
    for (PHINode &PN : L->getHeader()->phis()) {
      if (!PN.getType()->isIntegerTy())
        continue;
      const SCEV *S = SE.getSCEV(&PN);
      if (auto *AR = dyn_cast<SCEVAddRecExpr>(S)) {
        if (AR->isAffine()) {
          const SCEV *Step = AR->getStepRecurrence(SE);
          const SCEV *Start = AR->getStart();
          if (auto *CStep = dyn_cast<SCEVConstant>(Step)) {
            if (auto *CStart = dyn_cast<SCEVConstant>(Start)) {
              const APInt &stepVal = CStep->getValue()->getValue();
              const APInt &startVal = CStart->getValue()->getValue();
              // Primary IV: start == 0 and step == 1 (conservative canonical)
              if (stepVal == 1 && startVal == 0) {
                PrimaryIV = &PN;
                errs() << "  Found candidate primary IV: " << PN.getName() << "\n";
                break;
              }
            }
          }
        }
      }
    }

    // Scan header PHIs for derived induction variables (AR affine)
    SmallVector<PHINode *, 8> DerivedPHIs;
    for (PHINode &PN : L->getHeader()->phis()) {
      if (!PN.getType()->isIntegerTy())
        continue;
      // skip the primary if we found one
      if (&PN == PrimaryIV)
        continue;
      const SCEV *S = SE.getSCEV(&PN);
      if (auto *AR = dyn_cast<SCEVAddRecExpr>(S)) {
        if (AR->isAffine()) {
          const SCEV *Step = AR->getStepRecurrence(SE);
          const SCEV *Start = AR->getStart();
          errs() << "  Derived induction variable: " << PN.getName()
                 << " = {" << *Start << ",+," << *Step << "}<"
                 << L->getHeader()->getName() << ">\n";
          DerivedPHIs.push_back(&PN);
        }
      }
    }

    // If we have a primary IV and some derived IVs, attempt conservative elimination
    if (!PrimaryIV || DerivedPHIs.empty())
      return;

    // Make transformations: for each derived PHI that has constant Start and Step,
    // replace uses inside the loop by Start + Primary * Step (compute once in header).
    // Conservative: require Start and Step be SCEVConstant and fit Primary's type.
    SmallVector<PHINode *, 8> ToErase;
    for (PHINode *DPN : DerivedPHIs) {
      const SCEV *S = SE.getSCEV(DPN);
      auto *AR = dyn_cast<SCEVAddRecExpr>(S);
      if (!AR) // should not happen
        continue;

      const SCEV *Start = AR->getStart();
      const SCEV *Step = AR->getStepRecurrence(SE);

      auto *CStart = dyn_cast<SCEVConstant>(Start);
      auto *CStep = dyn_cast<SCEVConstant>(Step);
      if (!CStart || !CStep) {
        errs() << "    Skipping transformation for " << DPN->getName()
               << " because start/step are not constant\n";
        continue;
      }

      // Types
      Type *Ty = DPN->getType();
      if (!Ty->isIntegerTy()) {
        errs() << "    Skipping non-integer derived IV " << DPN->getName() << "\n";
        continue;
      }

      // Build constants of the same width as the primary/derived
      const APInt &startVal = CStart->getValue()->getValue();
      const APInt &stepVal = CStep->getValue()->getValue();

      // If constant widths don't match target type, extend/truncate to target width
      unsigned targetWidth = Ty->getIntegerBitWidth();
      APInt startAP = startVal;
      APInt stepAP = stepVal;
      if ((unsigned)startAP.getBitWidth() != targetWidth)
        startAP = APInt(targetWidth, startAP.getSExtValue());
      if ((unsigned)stepAP.getBitWidth() != targetWidth)
        stepAP = APInt(targetWidth, stepAP.getSExtValue());

      ConstantInt *StartC = ConstantInt::get(Ty->getContext(), startAP);
      ConstantInt *StepC = ConstantInt::get(Ty->getContext(), stepAP);

      // Insert multiplication and add in header after PHIs, before first non-phi
      BasicBlock *Header = L->getHeader();
      Instruction *InsertPt = Header->getFirstNonPHI();
      if (!InsertPt) {
        errs() << "    Header has no non-PHI instruction, skipping " << DPN->getName() << "\n";
        continue;
      }

      IRBuilder<> Builder(InsertPt);
      // Ensure PrimaryIV and DPN are of same bitwidth as Ty: we'll cast Primary if necessary
      Value *PrimaryVal = PrimaryIV;
      if (PrimaryIV->getType() != Ty) {
        // sign-extend or truncate conservatively (signed assumed)
        if (PrimaryIV->getType()->getIntegerBitWidth() < Ty->getIntegerBitWidth())
          PrimaryVal = Builder.CreateSExt(PrimaryIV, Ty, PrimaryIV->getName() + ".sext");
        else if (PrimaryIV->getType()->getIntegerBitWidth() > Ty->getIntegerBitWidth())
          PrimaryVal = Builder.CreateTrunc(PrimaryIV, Ty, PrimaryIV->getName() + ".trunc");
      }

      // mul = primary * step
      Value *Mul = Builder.CreateMul(PrimaryVal, StepC, DPN->getName() + ".ive.mul");
      // add = start + mul
      Value *NewVal = Builder.CreateAdd(StartC, Mul, DPN->getName() + ".ive");

      // Replace uses inside the loop only
      SmallVector<Use *, 8> UsesToReplace;
      for (Use &U : DPN->uses()) {
        Instruction *UseI = dyn_cast<Instruction>(U.getUser());
        if (!UseI) continue;
        if (L->contains(UseI->getParent())) {
          UsesToReplace.push_back(&U);
        }
      }

      if (UsesToReplace.empty()) {
        errs() << "    No uses inside loop for " << DPN->getName() << ", skipping\n";
        continue;
      }

      for (Use *U : UsesToReplace) {
        U->set(NewVal);
      }

      errs() << "    Replaced uses of " << DPN->getName()
             << " inside loop with (" << *StartC << ") + (" << PrimaryIV->getName()
             << ")*(" << *StepC << ")\n";

      // If the PHI now has no uses at all, remove it.
      if (DPN->use_empty()) {
        ToErase.push_back(DPN);
      }
    }
    for (PHINode *DPN : ToErase){
      errs() << "    Erasing unused PHI " << DPN->getName() << "\n";
      DPN->eraseFromParent();
    }
  }
};

} // namespace

// Register the pass
llvm::PassPluginLibraryInfo getDerivedInductionVarPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "DerivedInductionVar", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "derived-iv") {
                    FPM.addPass(DerivedInductionVar());
                    return true;
                  }
                  return false;
                });
          }};
}

extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  return getDerivedInductionVarPluginInfo();
}
