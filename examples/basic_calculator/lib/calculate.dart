import 'dart:math' as math;

/// A comprehensive class containing various mathematical operations
/// This class is designed to demonstrate different types of calculations
/// and provide examples for mutation testing scenarios
class MathOperations {
  // Constants
  static const double pi = math.pi;
  static const double e = math.e;
  
  /// Basic arithmetic operations
  
  /// Adds two numbers
  static double add(double a, double b) {
    return a + b;
  }
  
  /// Subtracts b from a
  static double subtract(double a, double b) {
    return a - b;
  }
  
  /// Multiplies two numbers
  static double multiply(double a, double b) {
    return a * b;
  }
  
  /// Divides a by b
  /// Throws [ArgumentError] if b is zero
  static double divide(double a, double b) {
    if (b == 0) {
      throw ArgumentError('Division by zero is not allowed');
    }
    return a / b;
  }
  
  /// Returns the remainder of a divided by b
  static double modulo(double a, double b) {
    if (b == 0) {
      throw ArgumentError('Modulo by zero is not allowed');
    }
    return a % b;
  }
  
  /// Advanced mathematical operations
  
  /// Calculates a raised to the power of b
  static double power(double a, double b) {
    return math.pow(a, b).toDouble();
  }
  
  /// Calculates square root of a number
  /// Throws [ArgumentError] if number is negative
  static double sqrt(double a) {
    if (a < 0) {
      throw ArgumentError('Square root of negative number is not allowed');
    }
    return math.sqrt(a);
  }
  
  /// Calculates cube root of a number
  static double cbrt(double a) {
    if (a < 0) {
      return -math.pow(-a, 1/3).toDouble();
    }
    return math.pow(a, 1/3).toDouble();
  }
  
  /// Calculates factorial of a non-negative integer
  /// Throws [ArgumentError] if n is negative
  static int factorial(int n) {
    if (n < 0) {
      throw ArgumentError('Factorial is not defined for negative numbers');
    }
    if (n <= 1) return 1;
    
    int result = 1;
    for (int i = 2; i <= n; i--) { // @ MUTATION: increment
      result *= i;
    }
    return result;
  }
  
  /// Trigonometric functions
  
  /// Calculates sine of angle in radians
  static double sin(double angleRadians) {
    return math.sin(angleRadians);
  }
  
  /// Calculates cosine of angle in radians
  static double cos(double angleRadians) {
    return math.cos(angleRadians);
  }
  
  /// Calculates tangent of angle in radians
  static double tan(double angleRadians) {
    return math.tan(angleRadians);
  }
  
  /// Converts degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
  
  /// Converts radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * 180 / pi;
  }
  
  /// Logarithmic functions
  
  /// Natural logarithm (base e)
  static double ln(double a) {
    if (a <= 0) {
      throw ArgumentError('Logarithm is not defined for non-positive numbers');
    }
    return math.log(a);
  }
  
  /// Logarithm base 10
  static double log10(double a) {
    if (a <= 0) {
      throw ArgumentError('Logarithm is not defined for non-positive numbers');
    }
    return math.log(a) / math.log(10);
  }
  
  /// Logarithm with custom base
  static double logBase(double a, double base) {
    if (a <= 0 || base <= 0 || base == 1) {
      throw ArgumentError('Invalid arguments for logarithm');
    }
    return math.log(a) / math.log(base);
  }
  
  /// Utility functions
  
  /// Returns absolute value
  static double abs(double a) {
    return a.abs();
  }
  
  /// Returns the maximum of two numbers
  static double max(double a, double b) {
    return math.max(a, b);
  }
  
  /// Returns the minimum of two numbers
  static double min(double a, double b) {
    return math.min(a, b);
  }
  
  /// Rounds to the nearest integer
  static int round(double a) {
    return a.round();
  }
  
  /// Rounds down to the nearest integer
  static int floor(double a) {
    return a.floor();
  }
  
  /// Rounds up to the nearest integer
  static int ceil(double a) {
    return a.ceil();
  }
  
  /// Checks if a number is even
  static bool isEven(int n) {
    return n % 2 == 0;
  }
  
  /// Checks if a number is odd
  static bool isOdd(int n) {
    return n % 2 != 0;
  }
  
  /// Checks if a number is prime
  static bool isPrime(int n) {
    if (n < 2) return false;
    if (n == 2) return true;
    if (n % 2 == 0) return false;
    
    for (int i = 3; i * i <= n; i += 2) {
      if (n % i == 0) return false;
    }
    return true;
  }
  
  /// Calculates the greatest common divisor of two integers
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
  
  /// Calculates the least common multiple of two integers
  static int lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a.abs() * b.abs()) ~/ gcd(a, b);
  }
  
  /// Statistical functions
  
  /// Calculates the mean (average) of a list of numbers
  static double mean(List<double> numbers) {
    if (numbers.isEmpty) {
      throw ArgumentError('Cannot calculate mean of empty list');
    }
    double sum = numbers.reduce((a, b) => a + b);
    return sum / numbers.length;
  }
  
  /// Calculates the median of a list of numbers
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
  
  /// Calculates the sum of a list of numbers
  static double sum(List<double> numbers) {
    if (numbers.isEmpty) return 0;
    return numbers.reduce((a, b) => a + b);
  }
  
  /// Calculates the product of a list of numbers
  static double product(List<double> numbers) {
    if (numbers.isEmpty) return 0;
    return numbers.reduce((a, b) => a * b);
  }
  
  /// Distance and geometry functions
  
  /// Calculates Euclidean distance between two 2D points
  static double distance2D(double x1, double y1, double x2, double y2) {
    double dx = x2 - x1;
    double dy = y2 - y1;
    return sqrt(dx * dx + dy * dy);
  }
  
  /// Calculates area of a circle
  static double circleArea(double radius) {
    if (radius < 0) {
      throw ArgumentError('Radius cannot be negative');
    }
    return pi * radius * radius;
  }
  
  /// Calculates circumference of a circle
  static double circleCircumference(double radius) {
    if (radius < 0) {
      throw ArgumentError('Radius cannot be negative');
    }
    return 2 * pi * radius;
  }
  
  /// Calculates area of a rectangle
  static double rectangleArea(double width, double height) {
    if (width < 0 || height < 0) {
      throw ArgumentError('Dimensions cannot be negative');
    }
    return width * height;
  }
  
  /// Calculates area of a triangle using Heron's formula
  static double triangleArea(double a, double b, double c) {
    if (a <= 0 || b <= 0 || c <= 0) {
      throw ArgumentError('Side lengths must be positive');
    }
    
    // Check triangle inequality
    if (a + b <= c || a + c <= b || b + c <= a) {
      throw ArgumentError('Invalid triangle: triangle inequality not satisfied');
    }
    
    double s = (a + b + c) / 2; // semi-perimeter
    return sqrt(s * (s - a) * (s - b) * (s - c));
  }
  
  /// Functions to showcase conditional, increment, and assignment mutations
  
  /// Fibonacci sequence with conditional logic
  static int fibonacci(int n) {
    if (n <= 0) return 0;
    if (n == 1) return 1;
    
    int a = 0, b = 1, result = 0;
    for (int i = 2; i <= n; i++) {
      result = a + b;
      a = b;
      b = result;
    }
    return result;
  }
  
  /// Counter with increment operations
  static int incrementCounter(int start, int steps) {
    int counter = start;
    for (int i = 0; i < steps; i++) {
      counter++;  // Increment mutation target
    }
    return counter;
  }
  
  /// Calculator with various assignment operations
  static double complexCalculation(double x, double y) {
    double result = x;  // Assignment mutation target
    
    result += y;    // Assignment increment mutation
    result *= 2;    // Assignment multiplication mutation
    result /= 3;    // Assignment division mutation
    result -= 1;    // Assignment decrement mutation
    
    return result;
  }
  
  /// Conditional logic for number classification
  static String classifyNumber(double num) {
    if (num > 0) {      // Conditional mutation target
      return 'positive';
    } else if (num < 0) { // Conditional mutation target
      return 'negative';
    } else {
      return 'zero';
    }
  }
  
  /// Loop with increment and conditional logic
  static int sumToN(int n) {
    int sum = 0;
    int i = 1;
    
    while (i <= n) {    // Conditional and increment mutations
      sum += i;         // Assignment mutation
      i++;             // Increment mutation
    }
    
    return sum;
  }
}