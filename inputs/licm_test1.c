// licm_test1.c
void licm_test1(int *a, int n) {
    int i;
    int x = 5;
    int y = 10;
    for (i = 0; i < n; i++) {
        int z = x + y;   // invariant, should be hoisted
        a[i] = z + i;    // depends on loop index, stays inside loop
    }
}
