// licm_test2.c
void licm_test2(int *a, int n, int *b) {
    int i;
    for (i = 0; i < n; i++) {
        int x = a[i] + b[i]; // reads memory, should NOT be hoisted
        a[i] = x * 2;
    }
}
