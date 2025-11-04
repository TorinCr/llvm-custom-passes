void array_stride(int n, int *arr) {
    // Primary IV: i = {0,+,1}
    // Derived IV: j = {0,+,4}
    for (int i = 0; i < n; i++) {
        int j = i * 4;
        arr[j] = i;
    }
}

void multiple_derived(int n, int *arr) {
    // Primary IV: i = {0,+,1}
    // Derived IVs: j = {0,+,4}, k = {10,+,2}, m = {5,+,3}
    for (int i = 0; i < n; i++) {
        int j = i * 4;
        int k = 10 + i * 2;
        int m = 5 + i * 3;
        arr[i] = j + k + m;
    }
}

void offset_pattern(int n, int *arr) {
    // Primary IV: i = {0,+,1}
    // Derived IV: idx = {100,+,1}
    for (int i = 0; i < n; i++) {
        int idx = 100 + i;
        arr[idx] = i;
    }
}

void negative_step(int n, int *arr) {
    // Primary IV: i = {0,+,1}
    // Derived IV: j = {100,+,-2} (negative step)
    for (int i = 0; i < n; i++) {
        int j = 100 - i * 2;
        if (j >= 0)
            arr[j] = i;
    }
}

void complex_derived(int n, int *arr) {
    // Primary IV: i = {0,+,1}
    // Derived IVs with different patterns
    for (int i = 0; i < n; i++) {
        int a = i * 8;       // {0,+,8}
        int b = 50 + i * 5;  // {50,+,5}
        arr[a] = b;
    }
}

void test_explicit_increment(int n, int *arr) {
    int i = 0;
    int j = 0;
    while (i < n) {
        arr[j] = i;
        i++;
        j += 4;  // Derived IV: {0,+,4}
    }
}

void test_three_derived(int n, int *arr) {
    int i = 0;
    int a = 0;   // {0,+,2}
    int b = 10;  // {10,+,5}
    int c = 50;  // {50,+,10}
    
    while (i < n) {
        arr[i] = a + b + c;
        i++;
        a += 2;
        b += 5;
        c += 10;
    }
}

void test_backward_derived(int n, int *arr) {
    int i = 0;
    int j = 100;
    
    while (i < n && j > 0) {
        arr[i] = j;
        i++;
        j -= 2;  // {100,+,-2}
    }
}

void test_mixed_steps(int n, int *arr) {
    int i = 0;
    int fast = 0;   // {0,+,8}
    int slow = 0;   // {0,+,1}
    
    while (i < n) {
        arr[i] = fast + slow;
        i++;
        fast += 8;
        slow += 1;
    }
}