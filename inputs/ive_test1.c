// ive_test1.c
void ive_test1(int *a, int n) {
    int i;
    for (i = 0; i < n; i++) {
        int j = 2 * i;   // derived induction variable
        a[i] = j + 1;
    }
}
