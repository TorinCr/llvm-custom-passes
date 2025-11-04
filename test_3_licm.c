void simple_invariant(int n, int *arr, int x, int y) {
    // x * y is loop-invariant, should be hoisted
    for (int i = 0; i < n; i++) {
        int temp = x * y;
        arr[i] = temp + i;
    }
}

void multiple_invariants(int n, int *arr, int a, int b, int c) {
    // All of these are loop-invariant
    for (int i = 0; i < n; i++) {
        int t1 = a + b;
        int t2 = t1 * c;
        int t3 = t2 + 100;
        arr[i] = t3 + i;
    }
}

void mixed_code(int n, int *arr, int x) {
    // Some invariant, some variant
    for (int i = 0; i < n; i++) {
        int inv = x * 2 + 10;  // invariant
        int var = i * 3;       // variant (depends on i)
        arr[i] = inv + var;
    }
}

void nested_computation(int n, int *arr, int p, int q) {
    // Complex invariant expression
    for (int i = 0; i < n; i++) {
        int temp = (p + q) * (p - q) + 42;
        arr[i] = temp + i * i;
    }
}

void no_side_effects(int n, int *arr, int x) {
    // Only pure computations should be hoisted
    for (int i = 0; i < n; i++) {
        int a = x + 5;
        int b = a * 2;
        int c = b - 3;
        arr[i] = c + i;
    }
}