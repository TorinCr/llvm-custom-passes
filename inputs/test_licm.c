// inputs/test_licm.c
void test_licm(int n, int* arr) {
    int a = 5;
    int b = 10;
    int c;
    int z = a + b;   // invariant
    for (int i = 0; i < n; i++) {
        c = z + arr[i]; // uses loop-dependent value
    }
}
