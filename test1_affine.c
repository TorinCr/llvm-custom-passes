void simple_counter(int n) {
    int i = 0;
    for (i = 0; i < n; i++) {
        // i is an affine recurrence: {0,+,1}
    }
}

void step_by_two(int n, int *arr) {
    for (int i = 0; i < n; i += 2) {
        // i is an affine recurrence: {0,+,2}
        arr[i] = i;
    }
}

void accumulator(int n) {
    int sum = 0;
    for (int i = 0; i < n; i++) {
        sum += i;  // sum is an affine recurrence
    }
}

void multiple_ivs(int n, int *arr) {
    int a = 0, b = 10;
    for (int i = 0; i < n; i++) {
        a += 1;    // a: {0,+,1}
        b += 3;    // b: {10,+,3}
        arr[i] = a + b;
    }
}