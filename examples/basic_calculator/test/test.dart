import 'package:test/test.dart';
import '../lib/calculate.dart';
import '../lib/area.dart';
import '../lib/calculus.dart';
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

  // AreaCalculator Tests
  group('AreaCalculator Tests', () {
    group('2D Shape Areas', () {
      test('rectangle should calculate correct area', () {
        expect(AreaCalculator.rectangle(5, 3), equals(15));
        expect(AreaCalculator.rectangle(2.5, 4), equals(10));
        expect(AreaCalculator.rectangle(1, 1), equals(1));
        expect(AreaCalculator.rectangle(0.5, 0.5), equals(0.25));
      });

      test('rectangle should throw error for non-positive dimensions', () {
        expect(() => AreaCalculator.rectangle(0, 5), throwsArgumentError);
        expect(() => AreaCalculator.rectangle(-1, 5), throwsArgumentError);
        expect(() => AreaCalculator.rectangle(5, 0), throwsArgumentError);
        expect(() => AreaCalculator.rectangle(5, -1), throwsArgumentError);
      });

      test('square should calculate correct area', () {
        expect(AreaCalculator.square(4), equals(16));
        expect(AreaCalculator.square(2.5), equals(6.25));
        expect(AreaCalculator.square(1), equals(1));
        expect(AreaCalculator.square(0.1), closeTo(0.01, 0.001));
      });

      test('square should throw error for non-positive side', () {
        expect(() => AreaCalculator.square(0), throwsArgumentError);
        expect(() => AreaCalculator.square(-5), throwsArgumentError);
      });

      test('circle should calculate correct area', () {
        expect(AreaCalculator.circle(1), closeTo(math.pi, 0.001));
        expect(AreaCalculator.circle(2), closeTo(4 * math.pi, 0.001));
        expect(AreaCalculator.circle(0.5), closeTo(0.25 * math.pi, 0.001));
        expect(AreaCalculator.circle(3), closeTo(9 * math.pi, 0.001));
      });

      test('circle should throw error for non-positive radius', () {
        expect(() => AreaCalculator.circle(0), throwsArgumentError);
        expect(() => AreaCalculator.circle(-1), throwsArgumentError);
      });

      test('triangle should calculate correct area', () {
        expect(AreaCalculator.triangle(6, 4), equals(12));
        expect(AreaCalculator.triangle(10, 5), equals(25));
        expect(AreaCalculator.triangle(1, 1), equals(0.5));
        expect(AreaCalculator.triangle(2.5, 3.2), equals(4));
      });

      test('triangle should throw error for non-positive dimensions', () {
        expect(() => AreaCalculator.triangle(0, 5), throwsArgumentError);
        expect(() => AreaCalculator.triangle(5, 0), throwsArgumentError);
        expect(() => AreaCalculator.triangle(-1, 5), throwsArgumentError);
      });

      test('triangleHeron should calculate correct area using side lengths', () {
        // Right triangle 3-4-5
        expect(AreaCalculator.triangleHeron(3, 4, 5), closeTo(6, 0.001));
        // Equilateral triangle with side 2
        expect(AreaCalculator.triangleHeron(2, 2, 2), closeTo(1.732, 0.001));
        // Isosceles triangle
        expect(AreaCalculator.triangleHeron(5, 5, 6), closeTo(12, 0.001));
        // Another valid triangle
        expect(AreaCalculator.triangleHeron(13, 14, 15), closeTo(84, 0.001));
      });

      test('triangleHeron should throw error for invalid triangles', () {
        // Triangle inequality violations
        expect(() => AreaCalculator.triangleHeron(1, 1, 5), throwsArgumentError);
        expect(() => AreaCalculator.triangleHeron(2, 3, 10), throwsArgumentError);
        // Non-positive sides
        expect(() => AreaCalculator.triangleHeron(0, 4, 5), throwsArgumentError);
        expect(() => AreaCalculator.triangleHeron(-1, 4, 5), throwsArgumentError);
      });

      test('parallelogram should calculate correct area', () {
        expect(AreaCalculator.parallelogram(8, 5), equals(40));
        expect(AreaCalculator.parallelogram(3, 2), equals(6));
        expect(AreaCalculator.parallelogram(1.5, 4), equals(6));
      });

      test('parallelogram should throw error for non-positive dimensions', () {
        expect(() => AreaCalculator.parallelogram(0, 5), throwsArgumentError);
        expect(() => AreaCalculator.parallelogram(5, 0), throwsArgumentError);
        expect(() => AreaCalculator.parallelogram(-1, 5), throwsArgumentError);
      });

      test('trapezoid should calculate correct area', () {
        expect(AreaCalculator.trapezoid(5, 3, 4), equals(16));
        expect(AreaCalculator.trapezoid(6, 4, 3), equals(15));
        expect(AreaCalculator.trapezoid(2, 8, 5), equals(25));
      });

      test('trapezoid should throw error for non-positive dimensions', () {
        expect(() => AreaCalculator.trapezoid(0, 5, 3), throwsArgumentError);
        expect(() => AreaCalculator.trapezoid(5, 0, 3), throwsArgumentError);
        expect(() => AreaCalculator.trapezoid(5, 3, 0), throwsArgumentError);
        expect(() => AreaCalculator.trapezoid(-1, 5, 3), throwsArgumentError);
      });

      test('ellipse should calculate correct area', () {
        expect(AreaCalculator.ellipse(3, 2), closeTo(6 * math.pi, 0.001));
        expect(AreaCalculator.ellipse(1, 1), closeTo(math.pi, 0.001)); // Circle case
        expect(AreaCalculator.ellipse(4, 1), closeTo(4 * math.pi, 0.001));
      });

      test('ellipse should throw error for non-positive axes', () {
        expect(() => AreaCalculator.ellipse(0, 2), throwsArgumentError);
        expect(() => AreaCalculator.ellipse(2, 0), throwsArgumentError);
        expect(() => AreaCalculator.ellipse(-1, 2), throwsArgumentError);
      });

      test('rhombus should calculate correct area', () {
        expect(AreaCalculator.rhombus(6, 8), equals(24));
        expect(AreaCalculator.rhombus(4, 5), equals(10));
        expect(AreaCalculator.rhombus(2, 2), equals(2));
      });

      test('rhombus should throw error for non-positive diagonals', () {
        expect(() => AreaCalculator.rhombus(0, 5), throwsArgumentError);
        expect(() => AreaCalculator.rhombus(5, 0), throwsArgumentError);
        expect(() => AreaCalculator.rhombus(-1, 5), throwsArgumentError);
      });

      test('regularPolygon should calculate correct area', () {
        // Square (4 sides, length 2)
        expect(AreaCalculator.regularPolygon(4, 2), closeTo(4, 0.001));
        // Pentagon
        expect(AreaCalculator.regularPolygon(5, 2), closeTo(6.881, 0.001));
        // Hexagon
        expect(AreaCalculator.regularPolygon(6, 2), closeTo(10.392, 0.001));
        // Triangle
        expect(AreaCalculator.regularPolygon(3, 2), closeTo(1.732, 0.001));
      });

      test('regularPolygon should throw error for invalid input', () {
        expect(() => AreaCalculator.regularPolygon(2, 5), throwsArgumentError);
        expect(() => AreaCalculator.regularPolygon(1, 5), throwsArgumentError);
        expect(() => AreaCalculator.regularPolygon(5, 0), throwsArgumentError);
        expect(() => AreaCalculator.regularPolygon(5, -1), throwsArgumentError);
      });
    });

    group('3D Surface Areas', () {
      test('sphereSurface should calculate correct surface area', () {
        expect(AreaCalculator.sphereSurface(1), closeTo(4 * math.pi, 0.001));
        expect(AreaCalculator.sphereSurface(2), closeTo(16 * math.pi, 0.001));
        expect(AreaCalculator.sphereSurface(0.5), closeTo(math.pi, 0.001));
      });

      test('sphereSurface should throw error for non-positive radius', () {
        expect(() => AreaCalculator.sphereSurface(0), throwsArgumentError);
        expect(() => AreaCalculator.sphereSurface(-1), throwsArgumentError);
      });

      test('cylinderSurface should calculate correct surface area', () {
        expect(AreaCalculator.cylinderSurface(1, 2), closeTo(6 * math.pi, 0.001));
        expect(AreaCalculator.cylinderSurface(2, 3), closeTo(20 * math.pi, 0.001));
        expect(AreaCalculator.cylinderSurface(0.5, 1), closeTo(1.5 * math.pi, 0.001));
      });

      test('cylinderSurface should throw error for non-positive dimensions', () {
        expect(() => AreaCalculator.cylinderSurface(0, 2), throwsArgumentError);
        expect(() => AreaCalculator.cylinderSurface(2, 0), throwsArgumentError);
        expect(() => AreaCalculator.cylinderSurface(-1, 2), throwsArgumentError);
      });

      test('coneSurface should calculate correct surface area', () {
        expect(AreaCalculator.coneSurface(1, 2), closeTo(3 * math.pi, 0.001));
        expect(AreaCalculator.coneSurface(2, 3), closeTo(10 * math.pi, 0.001));
        expect(AreaCalculator.coneSurface(0.5, 1), closeTo(0.75 * math.pi, 0.001));
      });

      test('coneSurface should throw error for non-positive dimensions', () {
        expect(() => AreaCalculator.coneSurface(0, 2), throwsArgumentError);
        expect(() => AreaCalculator.coneSurface(2, 0), throwsArgumentError);
        expect(() => AreaCalculator.coneSurface(-1, 2), throwsArgumentError);
      });
    });
  });

  // Calculus Tests
  group('Calculus Tests', () {
    group('Derivative Functions', () {
      test('derivative should calculate correct numerical derivatives', () {
        // Test with simple polynomial: f(x) = x^2, f'(x) = 2x
        double polynomial(double x) => x * x;
        expect(Calculus.derivative(polynomial, 2), closeTo(4, 0.001));
        expect(Calculus.derivative(polynomial, 3), closeTo(6, 0.001));
        expect(Calculus.derivative(polynomial, 0), closeTo(0, 0.001));

        // Test with sin(x), derivative is cos(x)
        expect(Calculus.derivative(math.sin, 0), closeTo(1, 0.001));
        expect(Calculus.derivative(math.sin, math.pi / 2), closeTo(0, 0.001));
      });

      test('secondDerivative should calculate correct second derivatives', () {
        // Test with f(x) = x^3, f''(x) = 6x
        double cubic(double x) => x * x * x;
        expect(Calculus.secondDerivative(cubic, 2), closeTo(12, 0.01));
        expect(Calculus.secondDerivative(cubic, 1), closeTo(6, 0.01));
        expect(Calculus.secondDerivative(cubic, 0), closeTo(0, 0.01));
      });

      test('partialX should calculate correct partial derivatives', () {
        // Test with f(x,y) = x^2 + y, ∂f/∂x = 2x
        double func(double x, double y) => x * x + y;
        expect(Calculus.partialX(func, 2, 3), closeTo(4, 0.001));
        expect(Calculus.partialX(func, 1, 5), closeTo(2, 0.001));
        expect(Calculus.partialX(func, 0, 1), closeTo(0, 0.001));
      });

      test('partialY should calculate correct partial derivatives', () {
        // Test with f(x,y) = x + y^2, ∂f/∂y = 2y
        double func(double x, double y) => x + y * y;
        expect(Calculus.partialY(func, 1, 2), closeTo(4, 0.001));
        expect(Calculus.partialY(func, 5, 3), closeTo(6, 0.001));
        expect(Calculus.partialY(func, 2, 0), closeTo(0, 0.001));
      });
    });

    group('Integration Functions', () {
      test('simpsonsRule should calculate correct definite integrals', () {
        // Test with f(x) = x^2, integral from 0 to 2 should be 8/3
        double polynomial(double x) => x * x;
        expect(Calculus.simpsonsRule(polynomial, 0, 2), closeTo(8/3, 0.01));
        
        // Test with f(x) = 1, integral from 0 to 5 should be 5
        double constant(double x) => 1;
        expect(Calculus.simpsonsRule(constant, 0, 5), closeTo(5, 0.001));
      });

      test('trapezoidalRule should calculate correct definite integrals', () {
        // Test with f(x) = x, integral from 0 to 4 should be 8
        double linear(double x) => x;
        expect(Calculus.trapezoidalRule(linear, 0, 4), closeTo(8, 0.01));
        
        // Test with constant function
        double constant(double x) => 3;
        expect(Calculus.trapezoidalRule(constant, 1, 4), closeTo(9, 0.001));
      });

      test('monteCarloIntegration should approximate integrals', () {
        // Test with f(x) = 1, integral from 0 to 1 should be 1
        double constant(double x) => 1;
        double result = Calculus.monteCarloIntegration(constant, 0, 1);
        expect(result, closeTo(1, 0.1)); // Monte Carlo has more variance
        
        // Test with f(x) = x, integral from 0 to 2 should be 2
        double linear(double x) => x;
        result = Calculus.monteCarloIntegration(linear, 0, 2);
        expect(result, closeTo(2, 0.2));
      });
    });

    group('Limit Functions', () {
      test('limit should calculate correct limits', () {
        // Test with continuous function f(x) = x^2 at x = 2
        double polynomial(double x) => x * x;
        expect(Calculus.limit(polynomial, 2), closeTo(4, 0.001));
        
        // Test with f(x) = sin(x) at x = 0
        expect(Calculus.limit(math.sin, 0), closeTo(0, 0.001));
      });

      test('lhopitalsRule should resolve indeterminate forms', () {
        // Test with limit of sin(x)/x as x approaches 0 (should be 1)
        double numerator(double x) => math.sin(x);
        double denominator(double x) => x;
        expect(Calculus.lhopitalsRule(numerator, denominator, 0), closeTo(1, 0.001));
      });

      test('lhopitalsRule should throw error when denominator derivative is zero', () {
        double numerator(double x) => x;
        double denominator(double x) => 1; // derivative is 0
        expect(() => Calculus.lhopitalsRule(numerator, denominator, 0), throwsArgumentError);
      });
    });

    group('Series Functions', () {
      test('taylorSeries should approximate functions correctly', () {
        // Test e^x Taylor series around x=0 (Maclaurin series)
        double expFunc(double x) => math.exp(x);
        expect(Calculus.taylorSeries(expFunc, 0, 1, terms: 10), closeTo(math.e, 0.01));
        expect(Calculus.taylorSeries(expFunc, 0, 0.5, terms: 8), closeTo(math.exp(0.5), 0.001));
      });

      test('maclaurinSeries should approximate functions around zero', () {
        // Test sin(x) Maclaurin series
        expect(Calculus.maclaurinSeries(math.sin, math.pi / 6, terms: 10), closeTo(0.5, 0.001));
        expect(Calculus.maclaurinSeries(math.sin, 0, terms: 5), closeTo(0, 0.001));
      });

      test('powerSeriesConverges should test convergence correctly', () {
        // Geometric series 1 + x + x^2 + x^3 + ... (converges for |x| < 1)
        List<double> geometric = [1, 1, 1, 1, 1];
        expect(Calculus.powerSeriesConverges(geometric, 0.5), isTrue);
        expect(Calculus.powerSeriesConverges(geometric, 1.5), isFalse);
        
        // Rapidly decreasing coefficients should converge for larger x
        List<double> decreasing = [1, 0.1, 0.01, 0.001, 0.0001];
        expect(Calculus.powerSeriesConverges(decreasing, 2), isTrue);
      });
    });

    group('Optimization Functions', () {
      test('newtonMethod should find roots correctly', () {
        // Find root of f(x) = x^2 - 4 (roots at ±2)
        double polynomial(double x) => x * x - 4;
        expect(Calculus.newtonMethod(polynomial, 1), closeTo(2, 0.001));
        expect(Calculus.newtonMethod(polynomial, -1), closeTo(-2, 0.001));
      });

      test('newtonMethod should throw error when derivative is zero', () {
        // Function with zero derivative
        double constant(double x) => 5;
        expect(() => Calculus.newtonMethod(constant, 1), throwsArgumentError);
      });

      test('newtonMethod should throw error when not converging', () {
        // Function that might not converge from certain starting points
        double problematic(double x) => x * x + 1; // No real roots
        expect(() => Calculus.newtonMethod(problematic, 0, maxIterations: 5), throwsArgumentError);
      });

      test('goldenSectionMinimum should find minimum correctly', () {
        // Find minimum of f(x) = (x-2)^2 (minimum at x=2)
        double parabola(double x) => (x - 2) * (x - 2);
        expect(Calculus.goldenSectionMinimum(parabola, 0, 4), closeTo(2, 0.01));
        
        // Find minimum of f(x) = x^2 + 2x + 1 = (x+1)^2 (minimum at x=-1)
        double quadratic(double x) => x * x + 2 * x + 1;
        expect(Calculus.goldenSectionMinimum(quadratic, -3, 1), closeTo(-1, 0.01));
      });
    });

    group('Vector Calculus Functions', () {
      test('gradient2D should calculate correct gradient', () {
        // Test with f(x,y) = x^2 + y^2, gradient = [2x, 2y]
        double func(double x, double y) => x * x + y * y;
        List<double> grad = Calculus.gradient2D(func, 2, 3);
        expect(grad[0], closeTo(4, 0.001)); // ∂f/∂x = 2x = 4 at x=2
        expect(grad[1], closeTo(6, 0.001)); // ∂f/∂y = 2y = 6 at y=3
      });

      test('divergence2D should calculate correct divergence', () {
        // Test with vector field F = [x, y], div F = 1 + 1 = 2
        double fx(double x, double y) => x;
        double fy(double x, double y) => y;
        expect(Calculus.divergence2D(fx, fy, 1, 1), closeTo(2, 0.001));
        expect(Calculus.divergence2D(fx, fy, 5, 3), closeTo(2, 0.001));
      });

      test('curl2D should calculate correct curl z-component', () {
        // Test with vector field F = [y, -x], curl F = -1 - 1 = -2
        double fx(double x, double y) => y;
        double fy(double x, double y) => -x;
        expect(Calculus.curl2D(fx, fy, 1, 1), closeTo(-2, 0.001));
        expect(Calculus.curl2D(fx, fy, 2, 3), closeTo(-2, 0.001));
      });
    });

    group('Differential Equations', () {
      test('eulerMethod should solve simple ODEs', () {
        // Test with dy/dx = y (solution is y = Ce^x)
        double dydx(double x, double y) => y;
        List<List<double>> solution = Calculus.eulerMethod(dydx, 0, 1, 0.1, 10);
        
        expect(solution.length, equals(11)); // 0 to 10 steps inclusive
        expect(solution[0][0], equals(0)); // x0 = 0
        expect(solution[0][1], equals(1)); // y0 = 1
        expect(solution[10][0], closeTo(1, 0.001)); // x = 1 after 10 steps
        // y(1) should be approximately e ≈ 2.718
        expect(solution[10][1], closeTo(math.e, 0.15));
      });

      test('rungeKutta4 should solve ODEs more accurately', () {
        // Test with dy/dx = y (solution is y = Ce^x)
        double dydx(double x, double y) => y;
        List<List<double>> solution = Calculus.rungeKutta4(dydx, 0, 1, 0.1, 10);
        
        expect(solution.length, equals(11));
        expect(solution[0][0], equals(0));
        expect(solution[0][1], equals(1));
        expect(solution[10][0], closeTo(1, 0.001));
        // RK4 should be more accurate than Euler's method
        expect(solution[10][1], closeTo(math.e, 0.01));
      });
    });

    group('Fourier Analysis', () {
      test('fourierCoefficients should analyze simple signals', () {
        // Test with constant signal
        List<double> constantSignal = [1, 1, 1, 1];
        List<double> coeffs = Calculus.fourierCoefficients(constantSignal, 4);
        expect(coeffs[0], closeTo(1, 0.001)); // DC component
        expect(coeffs[1], closeTo(0, 0.001)); // No fundamental frequency
        expect(coeffs[2], closeTo(0, 0.001)); // No second harmonic
        
        // Test with alternating signal
        List<double> alternating = [1, -1, 1, -1];
        coeffs = Calculus.fourierCoefficients(alternating, 4);
        expect(coeffs[0], closeTo(0, 0.001)); // No DC component
        expect(coeffs[2], closeTo(1, 0.001)); // Strong second harmonic
      });
    });

    group('Helper Functions', () {
      test('factorial should calculate correctly', () {
        expect(Calculus.factorial(0), equals(1));
        expect(Calculus.factorial(1), equals(1));
        expect(Calculus.factorial(5), equals(120));
        expect(Calculus.factorial(3), equals(6));
        expect(Calculus.factorial(4), equals(24));
      });

      test('factorial should throw error for negative numbers', () {
        expect(() => Calculus.factorial(-1), throwsArgumentError);
        expect(() => Calculus.factorial(-5), throwsArgumentError);
      });

      test('gamma should approximate gamma function', () {
        // For integers, gamma(n) = (n-1)!
        expect(Calculus.gamma(1), equals(1)); // gamma(1) = 0! = 1
        expect(Calculus.gamma(2), equals(1)); // gamma(2) = 1! = 1
        expect(Calculus.gamma(3), equals(2)); // gamma(3) = 2! = 2
        expect(Calculus.gamma(4), equals(6)); // gamma(4) = 3! = 6
        expect(Calculus.gamma(5), equals(24)); // gamma(5) = 4! = 24
      });

      test('gamma should throw error for invalid arguments', () {
        expect(() => Calculus.gamma(0), throwsArgumentError);
        expect(() => Calculus.gamma(-1), throwsArgumentError);
        expect(() => Calculus.gamma(-5), throwsArgumentError);
      });
    });
  });
}