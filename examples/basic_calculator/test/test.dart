import 'package:test/test.dart';
import '../lib/calculate.dart';
import 'dart:math' as math;

void main() {
  group('MathOperations Tests', () {
    
    // Basic Arithmetic Operations Tests
    group('Basic Arithmetic Operations', () {
      test('add should return correct sum', () {
        expect(MathOperations.add(5, 3), equals(8));
        expect(MathOperations.add(-5, 3), equals(-2));
        expect(MathOperations.add(0, 0), equals(0));
        expect(MathOperations.add(1.5, 2.5), equals(4.0));
      });

      test('subtract should return correct difference', () {
        expect(MathOperations.subtract(5, 3), equals(2));
        expect(MathOperations.subtract(-5, 3), equals(-8));
        expect(MathOperations.subtract(0, 0), equals(0));
        expect(MathOperations.subtract(1.5, 0.5), equals(1.0));
      });

      test('multiply should return correct product', () {
        expect(MathOperations.multiply(5, 3), equals(15));
        expect(MathOperations.multiply(-5, 3), equals(-15));
        expect(MathOperations.multiply(0, 100), equals(0));
        expect(MathOperations.multiply(1.5, 2), equals(3.0));
      });

      test('divide should return correct quotient', () {
        expect(MathOperations.divide(6, 3), equals(2));
        expect(MathOperations.divide(-6, 3), equals(-2));
        expect(MathOperations.divide(7, 2), equals(3.5));
        expect(MathOperations.divide(0, 5), equals(0));
      });

      test('divide should throw error for division by zero', () {
        expect(() => MathOperations.divide(5, 0), throwsArgumentError);
      });

      test('modulo should return correct remainder', () {
        expect(MathOperations.modulo(7, 3), equals(1));
        expect(MathOperations.modulo(10, 5), equals(0));
        expect(MathOperations.modulo(-7, 3), equals(2)); // In Dart, -7 % 3 = 2
      });

      test('modulo should throw error for modulo by zero', () {
        expect(() => MathOperations.modulo(5, 0), throwsArgumentError);
      });
    });

    // Advanced Mathematical Operations Tests
    group('Advanced Mathematical Operations', () {
      test('power should return correct result', () {
        expect(MathOperations.power(2, 3), equals(8));
        expect(MathOperations.power(5, 0), equals(1));
        expect(MathOperations.power(4, 0.5), equals(2));
        expect(MathOperations.power(-2, 2), equals(4));
      });

      test('sqrt should return correct square root', () {
        expect(MathOperations.sqrt(4), equals(2));
        expect(MathOperations.sqrt(9), equals(3));
        expect(MathOperations.sqrt(0), equals(0));
        expect(MathOperations.sqrt(2), closeTo(1.414, 0.001));
      });

      test('sqrt should throw error for negative numbers', () {
        expect(() => MathOperations.sqrt(-1), throwsArgumentError);
      });

      test('cbrt should return correct cube root', () {
        expect(MathOperations.cbrt(8), closeTo(2, 0.001));
        expect(MathOperations.cbrt(27), closeTo(3, 0.001));
        expect(MathOperations.cbrt(0), equals(0));
        expect(MathOperations.cbrt(-8), closeTo(-2, 0.001));
      });

      test('factorial should return correct factorial', () {
        expect(MathOperations.factorial(0), equals(1));
        expect(MathOperations.factorial(1), equals(1));
        expect(MathOperations.factorial(5), equals(120));
        expect(MathOperations.factorial(3), equals(6));
      });

      test('factorial should throw error for negative numbers', () {
        expect(() => MathOperations.factorial(-1), throwsArgumentError);
      });
    });

    // Trigonometric Functions Tests
    group('Trigonometric Functions', () {
      test('sin should return correct sine values', () {
        expect(MathOperations.sin(0), equals(0));
        expect(MathOperations.sin(math.pi / 2), closeTo(1, 0.001));
        expect(MathOperations.sin(math.pi), closeTo(0, 0.001));
      });

      test('cos should return correct cosine values', () {
        expect(MathOperations.cos(0), equals(1));
        expect(MathOperations.cos(math.pi / 2), closeTo(0, 0.001));
        expect(MathOperations.cos(math.pi), closeTo(-1, 0.001));
      });

      test('tan should return correct tangent values', () {
        expect(MathOperations.tan(0), equals(0));
        expect(MathOperations.tan(math.pi / 4), closeTo(1, 0.001));
      });

      test('degreesToRadians should convert correctly', () {
        expect(MathOperations.degreesToRadians(0), equals(0));
        expect(MathOperations.degreesToRadians(90), closeTo(math.pi / 2, 0.001));
        expect(MathOperations.degreesToRadians(180), closeTo(math.pi, 0.001));
        expect(MathOperations.degreesToRadians(360), closeTo(2 * math.pi, 0.001));
      });

      test('radiansToDegrees should convert correctly', () {
        expect(MathOperations.radiansToDegrees(0), equals(0));
        expect(MathOperations.radiansToDegrees(math.pi / 2), closeTo(90, 0.001));
        expect(MathOperations.radiansToDegrees(math.pi), closeTo(180, 0.001));
        expect(MathOperations.radiansToDegrees(2 * math.pi), closeTo(360, 0.001));
      });
    });

    // Logarithmic Functions Tests
    group('Logarithmic Functions', () {
      test('ln should return correct natural logarithm', () {
        expect(MathOperations.ln(1), equals(0));
        expect(MathOperations.ln(math.e), closeTo(1, 0.001));
        expect(MathOperations.ln(10), closeTo(2.303, 0.001));
      });

      test('ln should throw error for non-positive numbers', () {
        expect(() => MathOperations.ln(0), throwsArgumentError);
        expect(() => MathOperations.ln(-1), throwsArgumentError);
      });

      test('log10 should return correct base-10 logarithm', () {
        expect(MathOperations.log10(1), equals(0));
        expect(MathOperations.log10(10), closeTo(1, 0.001));
        expect(MathOperations.log10(100), closeTo(2, 0.001));
      });

      test('log10 should throw error for non-positive numbers', () {
        expect(() => MathOperations.log10(0), throwsArgumentError);
        expect(() => MathOperations.log10(-1), throwsArgumentError);
      });

      test('logBase should return correct logarithm with custom base', () {
        expect(MathOperations.logBase(8, 2), closeTo(3, 0.001));
        expect(MathOperations.logBase(125, 5), closeTo(3, 0.001));
        expect(MathOperations.logBase(1, 10), equals(0));
      });

      test('logBase should throw error for invalid arguments', () {
        expect(() => MathOperations.logBase(0, 2), throwsArgumentError);
        expect(() => MathOperations.logBase(5, 0), throwsArgumentError);
        expect(() => MathOperations.logBase(5, 1), throwsArgumentError);
        expect(() => MathOperations.logBase(-1, 2), throwsArgumentError);
      });
    });

    // Utility Functions Tests
    group('Utility Functions', () {
      test('abs should return absolute value', () {
        expect(MathOperations.abs(5), equals(5));
        expect(MathOperations.abs(-5), equals(5));
        expect(MathOperations.abs(0), equals(0));
        expect(MathOperations.abs(-3.14), equals(3.14));
      });

      test('max should return maximum value', () {
        expect(MathOperations.max(5, 3), equals(5));
        expect(MathOperations.max(-5, -3), equals(-3));
        expect(MathOperations.max(0, 0), equals(0));
        expect(MathOperations.max(1.5, 1.2), equals(1.5));
      });

      test('min should return minimum value', () {
        expect(MathOperations.min(5, 3), equals(3));
        expect(MathOperations.min(-5, -3), equals(-5));
        expect(MathOperations.min(0, 0), equals(0));
        expect(MathOperations.min(1.5, 1.2), equals(1.2));
      });

      test('round should round to nearest integer', () {
        expect(MathOperations.round(3.4), equals(3));
        expect(MathOperations.round(3.6), equals(4));
        expect(MathOperations.round(-3.4), equals(-3));
        expect(MathOperations.round(-3.6), equals(-4));
      });

      test('floor should round down', () {
        expect(MathOperations.floor(3.9), equals(3));
        expect(MathOperations.floor(-3.1), equals(-4));
        expect(MathOperations.floor(5.0), equals(5));
      });

      test('ceil should round up', () {
        expect(MathOperations.ceil(3.1), equals(4));
        expect(MathOperations.ceil(-3.9), equals(-3));
        expect(MathOperations.ceil(5.0), equals(5));
      });

      test('isEven should identify even numbers', () {
        expect(MathOperations.isEven(2), isTrue);
        expect(MathOperations.isEven(4), isTrue);
        expect(MathOperations.isEven(0), isTrue);
        expect(MathOperations.isEven(-2), isTrue);
        expect(MathOperations.isEven(3), isFalse);
        expect(MathOperations.isEven(-3), isFalse);
      });

      test('isOdd should identify odd numbers', () {
        expect(MathOperations.isOdd(3), isTrue);
        expect(MathOperations.isOdd(5), isTrue);
        expect(MathOperations.isOdd(-3), isTrue);
        expect(MathOperations.isOdd(2), isFalse);
        expect(MathOperations.isOdd(0), isFalse);
        expect(MathOperations.isOdd(-2), isFalse);
      });

      test('isPrime should identify prime numbers', () {
        expect(MathOperations.isPrime(2), isTrue);
        expect(MathOperations.isPrime(3), isTrue);
        expect(MathOperations.isPrime(5), isTrue);
        expect(MathOperations.isPrime(7), isTrue);
        expect(MathOperations.isPrime(11), isTrue);
        expect(MathOperations.isPrime(13), isTrue);
        expect(MathOperations.isPrime(1), isFalse);
        expect(MathOperations.isPrime(4), isFalse);
        expect(MathOperations.isPrime(6), isFalse);
        expect(MathOperations.isPrime(8), isFalse);
        expect(MathOperations.isPrime(9), isFalse);
        expect(MathOperations.isPrime(-5), isFalse);
      });

      test('gcd should return greatest common divisor', () {
        expect(MathOperations.gcd(12, 8), equals(4));
        expect(MathOperations.gcd(15, 10), equals(5));
        expect(MathOperations.gcd(7, 5), equals(1));
        expect(MathOperations.gcd(-12, 8), equals(4));
        expect(MathOperations.gcd(0, 5), equals(5));
      });

      test('lcm should return least common multiple', () {
        expect(MathOperations.lcm(4, 6), equals(12));
        expect(MathOperations.lcm(3, 5), equals(15));
        expect(MathOperations.lcm(12, 8), equals(24));
        expect(MathOperations.lcm(0, 5), equals(0));
        expect(MathOperations.lcm(-4, 6), equals(12));
      });
    });

    // Statistical Functions Tests
    group('Statistical Functions', () {
      test('mean should calculate correct average', () {
        expect(MathOperations.mean([1, 2, 3, 4, 5]), equals(3));
        expect(MathOperations.mean([2, 4, 6]), equals(4));
        expect(MathOperations.mean([10]), equals(10));
        expect(MathOperations.mean([-1, 0, 1]), equals(0));
      });

      test('mean should throw error for empty list', () {
        expect(() => MathOperations.mean([]), throwsArgumentError);
      });

      test('median should calculate correct median', () {
        expect(MathOperations.median([1, 2, 3, 4, 5]), equals(3));
        expect(MathOperations.median([1, 2, 3, 4]), equals(2.5));
        expect(MathOperations.median([5, 1, 3, 2, 4]), equals(3));
        expect(MathOperations.median([10]), equals(10));
      });

      test('median should throw error for empty list', () {
        expect(() => MathOperations.median([]), throwsArgumentError);
      });

      test('sum should calculate correct sum', () {
        expect(MathOperations.sum([1, 2, 3, 4, 5]), equals(15));
        expect(MathOperations.sum([]), equals(0));
        expect(MathOperations.sum([10]), equals(10));
        expect(MathOperations.sum([-1, -2, -3]), equals(-6));
      });

      test('product should calculate correct product', () {
        expect(MathOperations.product([1, 2, 3, 4]), equals(24));
        expect(MathOperations.product([]), equals(0));
        expect(MathOperations.product([5]), equals(5));
        expect(MathOperations.product([2, -3]), equals(-6));
        expect(MathOperations.product([0, 5, 10]), equals(0));
      });
    });

    // Distance and Geometry Functions Tests
    group('Distance and Geometry Functions', () {
      test('distance2D should calculate correct distance', () {
        expect(MathOperations.distance2D(0, 0, 3, 4), equals(5));
        expect(MathOperations.distance2D(1, 1, 4, 5), equals(5));
        expect(MathOperations.distance2D(0, 0, 0, 0), equals(0));
        expect(MathOperations.distance2D(-1, -1, 2, 3), equals(5));
      });

      test('circleArea should calculate correct area', () {
        expect(MathOperations.circleArea(1), closeTo(math.pi, 0.001));
        expect(MathOperations.circleArea(2), closeTo(4 * math.pi, 0.001));
        expect(MathOperations.circleArea(0), equals(0));
      });

      test('circleArea should throw error for negative radius', () {
        expect(() => MathOperations.circleArea(-1), throwsArgumentError);
      });

      test('circleCircumference should calculate correct circumference', () {
        expect(MathOperations.circleCircumference(1), closeTo(2 * math.pi, 0.001));
        expect(MathOperations.circleCircumference(2), closeTo(4 * math.pi, 0.001));
        expect(MathOperations.circleCircumference(0), equals(0));
      });

      test('circleCircumference should throw error for negative radius', () {
        expect(() => MathOperations.circleCircumference(-1), throwsArgumentError);
      });

      test('rectangleArea should calculate correct area', () {
        expect(MathOperations.rectangleArea(5, 3), equals(15));
        expect(MathOperations.rectangleArea(0, 5), equals(0));
        expect(MathOperations.rectangleArea(2.5, 4), equals(10));
      });

      test('rectangleArea should throw error for negative dimensions', () {
        expect(() => MathOperations.rectangleArea(-1, 5), throwsArgumentError);
        expect(() => MathOperations.rectangleArea(5, -1), throwsArgumentError);
      });

      test('triangleArea should calculate correct area using Herons formula', () {
        // Right triangle 3-4-5
        expect(MathOperations.triangleArea(3, 4, 5), closeTo(6, 0.001));
        // Equilateral triangle
        expect(MathOperations.triangleArea(2, 2, 2), closeTo(1.732, 0.001));
        // Another valid triangle
        expect(MathOperations.triangleArea(5, 12, 13), closeTo(30, 0.001));
      });

      test('triangleArea should throw error for invalid triangles', () {
        // Triangle inequality violation
        expect(() => MathOperations.triangleArea(1, 1, 3), throwsArgumentError);
        expect(() => MathOperations.triangleArea(5, 2, 2), throwsArgumentError);
        // Non-positive sides
        expect(() => MathOperations.triangleArea(0, 4, 5), throwsArgumentError);
        expect(() => MathOperations.triangleArea(-1, 4, 5), throwsArgumentError);
      });
    });

    // Enhanced Mutation Testing Functions Tests
    group('Enhanced Mutation Testing Functions', () {
      test('fibonacci should return correct sequence values', () {
        expect(MathOperations.fibonacci(0), equals(0));
        expect(MathOperations.fibonacci(1), equals(1));
        expect(MathOperations.fibonacci(2), equals(1));
        expect(MathOperations.fibonacci(3), equals(2));
        expect(MathOperations.fibonacci(4), equals(3));
        expect(MathOperations.fibonacci(5), equals(5));
        expect(MathOperations.fibonacci(10), equals(55));
      });

      test('incrementCounter should increment correctly', () {
        expect(MathOperations.incrementCounter(0, 5), equals(5));
        expect(MathOperations.incrementCounter(10, 3), equals(13));
        expect(MathOperations.incrementCounter(-5, 10), equals(5));
        expect(MathOperations.incrementCounter(100, 0), equals(100));
      });

      test('complexCalculation should perform assignment operations correctly', () {
        expect(MathOperations.complexCalculation(6, 3), closeTo(5.0, 0.001)); // (6+3)*2/3-1 = 5
        expect(MathOperations.complexCalculation(0, 0), closeTo(-1.0, 0.001)); // (0+0)*2/3-1 = -1
        expect(MathOperations.complexCalculation(3, 6), closeTo(5.0, 0.001)); // (3+6)*2/3-1 = 5
      });

      test('classifyNumber should classify numbers correctly', () {
        expect(MathOperations.classifyNumber(5), equals('positive'));
        expect(MathOperations.classifyNumber(-3), equals('negative'));
        expect(MathOperations.classifyNumber(0), equals('zero'));
        expect(MathOperations.classifyNumber(0.1), equals('positive'));
        expect(MathOperations.classifyNumber(-0.1), equals('negative'));
      });

      test('sumToN should calculate sum correctly', () {
        expect(MathOperations.sumToN(1), equals(1));
        expect(MathOperations.sumToN(3), equals(6)); // 1+2+3
        expect(MathOperations.sumToN(5), equals(15)); // 1+2+3+4+5
        expect(MathOperations.sumToN(10), equals(55)); // sum from 1 to 10
        expect(MathOperations.sumToN(0), equals(0));
      });
    });

    // Constants Tests
    group('Constants', () {
      test('pi constant should be correct', () {
        expect(MathOperations.pi, equals(math.pi));
      });

      test('e constant should be correct', () {
        expect(MathOperations.e, equals(math.e));
      });
    });
  });
}