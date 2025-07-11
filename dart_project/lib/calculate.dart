


import 'dart:math' as math;

class Calculator {
  // Basic arithmetic operations
  static double add(double a, double b) {
    return a + b;
  }

  static double subtract(double a, double b) {
    return a - b;
  }

  static double multiply(double a, double b) {
    return a * b;
  }

  static double divide(double a, double b) {
    if (b == 0) {
      throw ArgumentError('Division by zero is not allowed');
    }
    return a / b;
  }

  static int modulo(int a, int b) {
    if (b == 0) {
      throw ArgumentError('Modulo by zero is not allowed');
    }
    return a % b;
  }

  // Power and root operations
  static double power(double base, double exponent) {
    return math.pow(base, exponent).toDouble();
  }

  static double squareRoot(double number) {
    if (number < 0) {
      throw ArgumentError('Square root of negative number is not allowed');
    }
    return math.sqrt(number);
  }

  static double cubeRoot(double number) {
    return math.pow(number, 1/3).toDouble();
  }

  static double nthRoot(double number, double n) {
    return math.pow(number, 1/n).toDouble();
  }

  // Trigonometric functions (angles in radians)
  static double sin(double angle) {
    return math.sin(angle);
  }

  static double cos(double angle) {
    return math.cos(angle);
  }

  static double tan(double angle) {
    return math.tan(angle);
  }

  static double asin(double value) {
    return math.asin(value);
  }

  static double acos(double value) {
    return math.acos(value);
  }

  static double atan(double value) {
    return math.atan(value);
  }

  static double atan2(double y, double x) {
    return math.atan2(y, x);
  }

  // Logarithmic functions
  static double naturalLog(double number) {
    if (number <= 0) {
      throw ArgumentError('Logarithm of non-positive number is not allowed');
    }
    return math.log(number);
  }

  static double log10(double number) {
    if (number <= 0) {
      throw ArgumentError('Logarithm of non-positive number is not allowed');
    }
    return math.log(number) / math.log(10);
  }

  static double logBase(double number, double base) {
    if (number <= 0 || base <= 0 || base == 1) {
      throw ArgumentError('Invalid arguments for logarithm');
    }
    return math.log(number) / math.log(base);
  }

  // Exponential functions
  static double exp(double exponent) {
    return math.exp(exponent);
  }

  // Utility functions
  static double abs(double number) {
    return number.abs();
  }

  static double ceiling(double number) {
    return number.ceilToDouble();
  }

  static double floor(double number) {
    return number.floorToDouble();
  }

  static double round(double number) {
    return number.roundToDouble();
  }

  static double roundToDecimalPlaces(double number, int decimalPlaces) {
    double factor = math.pow(10, decimalPlaces).toDouble();
    return (number * factor).round() / factor;
  }

  // Statistical functions
  static double min(double a, double b) {
    return math.min(a, b);
  }

  static double max(double a, double b) {
    return math.max(a, b);
  }

  static double average(List<double> numbers) {
    if (numbers.isEmpty) {
      throw ArgumentError('Cannot calculate average of empty list');
    }
    return numbers.reduce((a, b) => a + b) / numbers.length;
  }

  static double median(List<double> numbers) {
    if (numbers.isEmpty) {
      throw ArgumentError('Cannot calculate median of empty list');
    }
    List<double> sorted = List.from(numbers)..sort();
    int length = sorted.length;
    if (length % 2 == 0) {
      return (sorted[length ~/ 2 - 1] + sorted[length ~/ 2]) / 2;
    } else {
      return sorted[length ~/ 2];
    }
  }

  // Constants
  static double get pi => math.pi;
  static double get e => math.e;

  // Degree/Radian conversion
  static double degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  static double radiansToDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  // Factorial
  static int factorial(int n) {
    if (n < 0) {
      throw ArgumentError('Factorial of negative number is not allowed');
    }
    if (n == 0 || n == 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  // Greatest Common Divisor
  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  // Least Common Multiple
  static int lcm(int a, int b) {
    return (a.abs() * b.abs()) ~/ gcd(a, b);
  }

  // Check if number is prime
  static bool isPrime(int number) {
    if (number < 2) return false;
    if (number == 2) return true;
    if (number % 2 == 0) return false;
    
    for (int i = 3; i <= math.sqrt(number); i += 2) {
      if (number % i == 0) return false;
    }
    return true;
  }

  // Percentage calculations
  static double percentage(double value, double total) {
    if (total == 0) {
      throw ArgumentError('Total cannot be zero for percentage calculation');
    }
    return (value / total) * 100;
  }

  static double percentageOf(double percentage, double total) {
    return (percentage / 100) * total;
  }
}