// ive_test2.c
void ive_test2(int n, int m, int arr[n][m]) {
    int i, j;
    for (i = 0; i < n; i++) {
        for (j = 0; j < m; j++) {
            int k = i + 2*j;   // derived induction variable
            arr[i][j] = k;
        }
    }
}
