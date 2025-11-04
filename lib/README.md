# LLVM Custom Passes

Three LLVM optimization passes for loop analysis and transformation, compatible with the New Pass Manager.

## Passes

### AffineRecurrence
**Type:** Analysis pass (read-only)  
**Purpose:** Detects affine recurrence relations in loops using ScalarEvolution

Analyzes loops to identify affine AddRec expressions of the form `{start,+,step}<loop>`. Useful for understanding induction variable evolution and as prerequisite analysis for loop optimizations.

**Output Example:**
```
Analyzing loop in function foo:
  Affine recurrence: i = {0,+,1}<for.body>
  Affine recurrence: sum = {0,+,2}<for.body>
```

### DerivedInductionVar
**Type:** Transformation pass  
**Purpose:** Identifies and eliminates derived induction variables

Detects a canonical primary IV (start=0, step=1) and derived IVs with constant start/step values. Replaces derived IVs with expressions computed from the primary IV: `derived = start + (primary * step)`. Only transforms innermost loops and replaces uses inside the loop.

**Transformation Example:**
```c
// Before
for (int i = 0; i < n; i++) {
    int j = 0 + i * 4;  // j is computed but not a PHI
}

// After (when j is a PHI node)
for (int i = 0; i < n; i++) {
    int j_ive = 0 + (i * 4);  // computed from primary IV
}
```

### SimpleLICM
**Type:** Transformation pass  
**Purpose:** Hoists loop-invariant code to loop preheaders

Identifies instructions whose operands don't change within the loop and hoists them to the preheader when safe. Uses a worklist algorithm to iteratively find invariants.

**Hoisting Criteria:**
- All operands are loop-invariant
- Safe to speculatively execute
- Dominates all loop exits
- Doesn't read/write memory
- Not a PHI, call, invoke, or terminator

## Building

Requires the llvm-tutor project structure.

```bash
cd llvm-tutor
mkdir -p build && cd build
cmake -DLT_LLVM_INSTALL_DIR=/opt/homebrew/opt/llvm ..
make
```

## Usage

### Generating LLVM IR

For best results with transformation passes, use `-O0` with `-Xclang -disable-O0-optnone` and apply `mem2reg` and `loop-simplify`:

```bash
# Generate IR
/opt/homebrew/opt/llvm/bin/clang -O0 -Xclang -disable-O0-optnone -S -emit-llvm example.c -o example.ll

# Apply mem2reg and loop-simplify to get proper SSA form with loops
opt -passes="mem2reg,loop-simplify" -S example.ll -o example_ssa.ll
```

For AffineRecurrence (analysis only), `-O1` often works better:
```bash
/opt/homebrew/opt/llvm/bin/clang -O1 -S -emit-llvm example.c -o example.ll
```

### Running Passes

**Note:** Output goes to stderr, so use `2>&1` to see it.

```bash
# AffineRecurrence (prints analysis to stderr)
opt -load-pass-plugin=./build/lib/libAffineRecurrence.dylib \
    -passes="affine-recurrence" \
    -disable-output example.ll 2>&1

# DerivedInductionVar (transforms IR)
opt -load-pass-plugin=./build/lib/libDerivedInductionVar.dylib \
    -passes="derived-iv" \
    -S example_ssa.ll -o example_opt.ll 2>&1

# SimpleLICM (transforms IR)
opt -load-pass-plugin=./build/lib/libSimpleLICM.dylib \
    -passes="loop(simple-licm)" \
    -S example_ssa.ll -o example_opt.ll 2>&1
```

## Examples

### Example 1: Derived Induction Variables

**Input C code:**
```c
void test_derived(int n, int *arr) {
    int i = 0;
    int j = 0;  // Will become a derived IV PHI node
    
    while (i < n) {
        arr[j] = i;
        i++;    // Primary IV: {0,+,1}
        j += 4; // Derived IV: {0,+,4}
    }
}
```

**Generate and run:**
```bash
/opt/homebrew/opt/llvm/bin/clang -O0 -Xclang -disable-O0-optnone -S -emit-llvm test.c -o test.ll
opt -passes="mem2reg,loop-simplify" -S test.ll -o test_ssa.ll
opt -load-pass-plugin=./build/lib/libDerivedInductionVar.dylib \
    -passes="derived-iv" \
    -S test_ssa.ll -o test_opt.ll 2>&1
```

**Expected output:**
```
Analyzing inner loop in function test_derived:
  Found candidate primary IV: i
  Derived induction variable: j = {0,+,4}<...>
  Replaced uses of j inside loop with (0) + (i)*(4)
```

### Example 2: Affine Recurrence Detection

**Input C code:**
```c
void test_affine(int n, int *arr) {
    for (int i = 0; i < n; i += 2) {
        arr[i] = i;
    }
}
```

**Generate and run:**
```bash
/opt/homebrew/opt/llvm/bin/clang -O1 -S -emit-llvm test.c -o test.ll
opt -load-pass-plugin=./build/lib/libAffineRecurrence.dylib \
    -passes="affine-recurrence" \
    -disable-output test.ll 2>&1
```

**Expected output:**
```
Analyzing loop in function test_affine:
  Affine recurrence: i = {0,+,2}<for.cond>
```

## Test Files

The project includes test files:
- `test1_affine.c` - Basic affine recurrence patterns
- `test_2_derived_iv.c` - Derived induction variable patterns
- `test_3_licm.c` - Loop-invariant code motion patterns
- `test_4_nested.c` - Nested loop scenarios

## Requirements

- LLVM 13+ (tested with LLVM 21)
- CMake 3.13+
- C++17 compiler
- macOS, Linux, or compatible Unix system

## Important Notes

- **Pass output goes to stderr** - always use `2>&1` to see output
- **Use `-Xclang -disable-O0-optnone`** when compiling with `-O0` to allow optimization passes to run
- **Apply `mem2reg` and `loop-simplify`** before transformation passes for best results
- **DerivedInductionVar** only detects derived IVs that are PHI nodes (not computed values like `j = i * 4`)
- **SimpleLICM** may not hoist code if dominance or safety checks fail

## Known Issues

- DerivedInductionVar: Use-after-free bug when erasing PHI nodes (collect to-erase list separately)
- SimpleLICM: Conservative dominance checks may miss valid hoisting opportunities. Had trouble implementing this so many not fully work
- Modern compilers optimize aggressively, so test cases may not generate expected IR patterns

## Troubleshooting

**No output from passes?**
- Make sure you're using `2>&1` to redirect stderr
- Check that loops exist in the IR: `opt -passes=print-loops -disable-output file.ll 2>&1`
- Verify PHI nodes exist: `grep "phi" file.ll`

**No transformations happening?**
- Ensure `-Xclang -disable-O0-optnone` is used during compilation
- Apply `mem2reg` and `loop-simplify` before running transformation passes
- Check that the IR has the patterns the passes look for (PHI nodes for derived IVs, etc.)