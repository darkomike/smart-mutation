class Calculator {
  int add(int a, int b) {
    return a + b;
  }

  int subtract(int a, int b) {
    return a - b;
  }

  int multiply(int a, int b) {
    return a * b;
  }

  double divide(double a, double b) {
    return a / b;
  }

  int increment(int value) {
    value++;
    return value;
  }

  int calculate(int x, int y, int z) {
    int result = x + y * z;
    result--;
    return result % 10;
  }
}
