// licm_test3.c
void licm_test3(int n) {
    int i = 0;
    int x = 0;
    while (i < n) {
        x = x + 1; // phi in LLVM IR, should NOT be hoisted
        i++;
    }
}
