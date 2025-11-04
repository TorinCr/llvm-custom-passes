void test_derived_phi_explicit(int n, int *arr) {
    int i = 0;
    int j = 0;  // Will become PHI {0,+,4}
    
    while (i < n) {
        arr[j] = i;
        i++;    // Primary IV: {0,+,1}
        j += 4; // Derived IV: {0,+,4}
    }
}

// Multiple derived IVs
void test_multiple_derived_phi(int n, int *arr) {
    int i = 0;
    int a = 0;   // {0,+,2}
    int b = 10;  // {10,+,3}
    int c = 5;   // {5,+,1}
    
    while (i < n) {
        arr[i] = a + b + c;
        i++;
        a += 2;
        b += 3;
        c += 1;
    }
}

// Derived IV with different start
void test_derived_with_offset(int n, int *arr) {
    int i = 0;
    int idx = 100;  // {100,+,1}
    
    while (i < n) {
        arr[i] = idx;
        i++;
        idx++;
    }
}

int main() {
    int arr[1000];
    test_derived_phi_explicit(10, arr);
    test_multiple_derived_phi(10, arr);
    test_derived_with_offset(10, arr);
    return 0;
}