void nested_simple(int n, int m, int *arr) {
    // Outer loop IV: i = {0,+,1}
    // Inner loop IV: j = {0,+,1}
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            arr[i * m + j] = i + j;
        }
    }
}

void nested_derived_iv(int n, int m, int *arr) {
    // Inner loop has derived IVs
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            int idx = j * 4;  // derived IV in inner loop
            arr[i * m + idx] = i + j;
        }
    }
}

void nested_invariant(int n, int m, int *arr, int x, int y) {
    // x * y is invariant in both loops
    for (int i = 0; i < n; i++) {
        int outer_inv = x * y;  // invariant to outer loop
        for (int j = 0; j < m; j++) {
            int inner_inv = outer_inv + 10;  // invariant to inner loop
            arr[i * m + j] = inner_inv + i + j;
        }
    }
}

void triple_nested(int n, int *arr) {
    // Three levels of nesting
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            for (int k = 0; k < n; k++) {
                arr[i * n * n + j * n + k] = i + j + k;
            }
        }
    }
}