#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/CFG.h"

#include "llvm/Pass.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"

#include "llvm/Analysis/LoopAnalysisManager.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/LoopPass.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Analysis/ValueTracking.h"

#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/LoopUtils.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

using namespace llvm;

struct SimpleLICM : public PassInfoMixin<SimpleLICM> {
  PreservedAnalyses run(Loop &L, LoopAnalysisManager &AM,
                        LoopStandardAnalysisResults &AR,
                        LPMUpdater &) {
    DominatorTree &DT = AR.DT;

    BasicBlock *Preheader = L.getLoopPreheader();
    if (!Preheader) {
      errs() << "No preheader, skipping loop\n";
      return PreservedAnalyses::all();
    }

    SmallPtrSet<Instruction *, 8> InvariantSet;
    bool Change = true;

    // Worklist algorithm to identify loop invariant instructions
    /*************************************/
    /* Implementation:
     * - Repeatedly scan instructions in the loop until no new invariants found.
     * - Only consider register-to-register computations:
     *    - skip PHI nodes
     *    - skip instructions that may read/write memory
     *    - skip Call/Invoke instructions (conservative)
     * - An instruction is invariant if all its operands are
     *    - constants,
     *    - function arguments / globals, or
     *    - instructions defined outside the loop, or
     *    - already in the InvariantSet
     */
    SmallVector<Instruction *, 64> Insts;
    Insts.clear();
    for (BasicBlock *BB : L.getBlocks()) {
      for (Instruction &I : *BB)
        Insts.push_back(&I);
    }

    while (Change) {
      Change = false;
      for (Instruction *I : Insts) {
        // skip if already considered invariant
        if (InvariantSet.count(I))
          continue;

        // skip phi nodes
        if (isa<PHINode>(I))
          continue;

        // Skip anything that may read/write memory or is a call/invoke
        if (I->mayReadOrWriteMemory())
          continue;
        if (isa<CallInst>(I) || isa<InvokeInst>(I))
          continue;

        // Conservative: don't hoist terminators or certain other instructions
        if (I->isTerminator())
          continue;

        // Check all operands
        bool AllOperandsInvariant = true;
        for (Use &U : I->operands()) {
          Value *V = U.get();

          if (isa<Constant>(V))
            continue; // constants are invariant

          if (isa<Argument>(V))
            continue; // function args are invariant

          if (Instruction *OpI = dyn_cast<Instruction>(V)) {
            BasicBlock *OpBB = OpI->getParent();
            // If operand defined outside loop, it's OK
            if (!L.contains(OpBB))
              continue;
            // If operand is inside loop, it must already be in InvariantSet
            if (InvariantSet.count(OpI))
              continue;
            // Otherwise not invariant (yet)
            AllOperandsInvariant = false;
            break;
          }

          // If it's some other weird value (e.g., inline asm result?), be conservative
          AllOperandsInvariant = false;
          break;
        }

        if (AllOperandsInvariant) {
          InvariantSet.insert(I);
          Change = true;
        }
      }
    }

    // Actually hoist the instructions
    // We should hoist in a stable order (e.g., preserve original order)
    for (Instruction *I : Insts) {
      if (!InvariantSet.count(I))
        continue;

      if (isSafeToSpeculativelyExecute(I) && dominatesAllLoopExits(I, &L, DT)) {
        errs() << "Hoisting: " << *I << "\n";
        // Move before the terminator of the preheader (end of block)
        I->moveBefore(Preheader->getTerminator());
      }
    }

    return PreservedAnalyses::none();
  }

  bool dominatesAllLoopExits(Instruction *I, Loop *L, DominatorTree &DT) {
    BasicBlock *BB = I->getParent();
    SmallVector<BasicBlock *, 8> ExitBlocks;
    L->getExitBlocks(ExitBlocks);
    
    // Check if the instruction's block dominates all exit blocks
    for (BasicBlock *EB : ExitBlocks) {
      if (!DT.dominates(BB, EB))
        return false;
    }
    return true;
  }
};

llvm::PassPluginLibraryInfo getSimpleLICMPluginInfo() {
  errs() << "SimpleLICM plugin: getSimpleLICMPluginInfo() called\n";
  return {LLVM_PLUGIN_API_VERSION, "simple-licm", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, LoopPassManager &LPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "simple-licm") {
                    LPM.addPass(SimpleLICM());
                    return true;
                  }
                  return false;
                });
          }};
}

extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  errs() << "SimpleLICM plugin: llvmGetPassPluginInfo() called\n";
  return getSimpleLICMPluginInfo();
}