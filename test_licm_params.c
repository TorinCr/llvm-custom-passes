// test_licm_params.c - Uses parameters so constant folding can't happen

void test_with_params(int n, int *arr, int a, int b) {
    int i = 0;
    while (i < n) {
        int x = a + b;  // This CANNOT be constant folded
        arr[i] = x;
        i++;
    }
}

int main() {
    int arr[100];
    test_with_params(10, arr, 5, 3);
    return 0;
}