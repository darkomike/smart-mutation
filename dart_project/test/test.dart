import 'package:test/test.dart';
import 'dart:math' as math;

import '../lib/calculate.dart';

void main() {
  group('Basic Arithmetic Operations', () {
    test('add', () {
      expect(Calculator.add(6, 7), 13);
      expect(Calculator.add(-5, 3), -2);
      expect(Calculator.add(0, 0), 0);
      expect(Calculator.add(1.5, 2.3), closeTo(3.8, 0.001));
    });

    test('subtract', () {
      expect(Calculator.subtract(10, 5), 5);
      expect(Calculator.subtract(-5, 3), -8);
      expect(Calculator.subtract(0, 0), 0);
      expect(Calculator.subtract(1.5, 0.3), closeTo(1.2, 0.001));
    });

    test('multiply', () {
      expect(Calculator.multiply(6, 7), 42);
      expect(Calculator.multiply(-5, 3), -15);
      expect(Calculator.multiply(0, 100), 0);
      expect(Calculator.multiply(1.5, 2), 3);
    });

    test('divide', () {
      expect(Calculator.divide(10, 2), 5);
      expect(Calculator.divide(-15, 3), -5);
      expect(Calculator.divide(7, 2), 3.5);
      expect(() => Calculator.divide(5, 0), throwsArgumentError);
    });

    test('modulo', () {
      expect(Calculator.modulo(10, 3), 1);
      expect(Calculator.modulo(15, 5), 0);
      expect(Calculator.modulo(-7, 3), -1);
      expect(() => Calculator.modulo(5, 0), throwsArgumentError);
    });
  });

  group('Power and Root Operations', () {
    test('power', () {
      expect(Calculator.power(2, 3), 8);
      expect(Calculator.power(5, 0), 1);
      expect(Calculator.power(3, -2), closeTo(0.111, 0.001));
      expect(Calculator.power(9, 0.5), closeTo(3, 0.001));
    });

    test('squareRoot', () {
      expect(Calculator.squareRoot(9), 3);
      expect(Calculator.squareRoot(0), 0);
      expect(Calculator.squareRoot(2), closeTo(1.414, 0.001));
      expect(() => Calculator.squareRoot(-1), throwsArgumentError);
    });

    test('cubeRoot', () {
      expect(Calculator.cubeRoot(8), closeTo(2, 0.001));
      expect(Calculator.cubeRoot(27), closeTo(3, 0.001));
      expect(Calculator.cubeRoot(-8), closeTo(-2, 0.001));
    });

    test('nthRoot', () {
      expect(Calculator.nthRoot(16, 4), closeTo(2, 0.001));
      expect(Calculator.nthRoot(32, 5), closeTo(2, 0.001));
      expect(Calculator.nthRoot(1, 10), closeTo(1, 0.001));
    });
  });

  group('Trigonometric Functions', () {
    test('sin', () {
      expect(Calculator.sin(0), closeTo(0, 0.001));
      expect(Calculator.sin(math.pi / 2), closeTo(1, 0.001));
      expect(Calculator.sin(math.pi), closeTo(0, 0.001));
    });

    test('cos', () {
      expect(Calculator.cos(0), closeTo(1, 0.001));
      expect(Calculator.cos(math.pi / 2), closeTo(0, 0.001));
      expect(Calculator.cos(math.pi), closeTo(-1, 0.001));
    });

    test('tan', () {
      expect(Calculator.tan(0), closeTo(0, 0.001));
      expect(Calculator.tan(math.pi / 4), closeTo(1, 0.001));
      expect(Calculator.tan(math.pi), closeTo(0, 0.001));
    });

    test('asin', () {
      expect(Calculator.asin(0), closeTo(0, 0.001));
      expect(Calculator.asin(1), closeTo(math.pi / 2, 0.001));
      expect(Calculator.asin(-1), closeTo(-math.pi / 2, 0.001));
    });

    test('acos', () {
      expect(Calculator.acos(1), closeTo(0, 0.001));
      expect(Calculator.acos(0), closeTo(math.pi / 2, 0.001));
      expect(Calculator.acos(-1), closeTo(math.pi, 0.001));
    });

    test('atan', () {
      expect(Calculator.atan(0), closeTo(0, 0.001));
      expect(Calculator.atan(1), closeTo(math.pi / 4, 0.001));
      expect(Calculator.atan(-1), closeTo(-math.pi / 4, 0.001));
    });

    test('atan2', () {
      expect(Calculator.atan2(1, 1), closeTo(math.pi / 4, 0.001));
      expect(Calculator.atan2(1, 0), closeTo(math.pi / 2, 0.001));
      expect(Calculator.atan2(0, 1), closeTo(0, 0.001));
    });
  });

  group('Logarithmic Functions', () {
    test('naturalLog', () {
      expect(Calculator.naturalLog(1), closeTo(0, 0.001));
      expect(Calculator.naturalLog(math.e), closeTo(1, 0.001));
      expect(Calculator.naturalLog(math.e * math.e), closeTo(2, 0.001));
      expect(() => Calculator.naturalLog(0), throwsArgumentError);
      expect(() => Calculator.naturalLog(-1), throwsArgumentError);
    });

    test('log10', () {
      expect(Calculator.log10(1), closeTo(0, 0.001));
      expect(Calculator.log10(10), closeTo(1, 0.001));
      expect(Calculator.log10(100), closeTo(2, 0.001));
      expect(() => Calculator.log10(0), throwsArgumentError);
      expect(() => Calculator.log10(-1), throwsArgumentError);
    });

    test('logBase', () {
      expect(Calculator.logBase(8, 2), closeTo(3, 0.001));
      expect(Calculator.logBase(125, 5), closeTo(3, 0.001));
      expect(Calculator.logBase(1, 10), closeTo(0, 0.001));
      expect(() => Calculator.logBase(0, 2), throwsArgumentError);
      expect(() => Calculator.logBase(8, 1), throwsArgumentError);
    });

    test('exp', () {
      expect(Calculator.exp(0), closeTo(1, 0.001));
      expect(Calculator.exp(1), closeTo(math.e, 0.001));
      expect(Calculator.exp(2), closeTo(math.e * math.e, 0.001));
    });
  });

  group('Utility Functions', () {
    test('abs', () {
      expect(Calculator.abs(5), 5);
      expect(Calculator.abs(-5), 5);
      expect(Calculator.abs(0), 0);
      expect(Calculator.abs(3.14), 3.14);
      expect(Calculator.abs(-3.14), 3.14);
    });

    test('ceiling', () {
      expect(Calculator.ceiling(4.3), 5);
      expect(Calculator.ceiling(-4.3), -4);
      expect(Calculator.ceiling(5.0), 5);
    });

    test('floor', () {
      expect(Calculator.floor(4.7), 4);
      expect(Calculator.floor(-4.7), -5);
      expect(Calculator.floor(5.0), 5);
    });

    test('round', () {
      expect(Calculator.round(4.3), 4);
      expect(Calculator.round(4.7), 5);
      expect(Calculator.round(-4.3), -4);
      expect(Calculator.round(-4.7), -5);
    });

    test('roundToDecimalPlaces', () {
      expect(Calculator.roundToDecimalPlaces(3.14159, 2), 3.14);
      expect(Calculator.roundToDecimalPlaces(3.14159, 4), 3.1416);
      expect(Calculator.roundToDecimalPlaces(123.456, 1), 123.5);
    });

    test('min', () {
      expect(Calculator.min(5, 3), 3);
      expect(Calculator.min(-5, -3), -5);
      expect(Calculator.min(0, 0), 0);
    });

    test('max', () {
      expect(Calculator.max(5, 3), 5);
      expect(Calculator.max(-5, -3), -3);
      expect(Calculator.max(0, 0), 0);
    });
  });

  group('Statistical Functions', () {
    test('average', () {
      expect(Calculator.average([1, 2, 3, 4, 5]), 3);
      expect(Calculator.average([10, 20, 30]), 20);
      expect(Calculator.average([5]), 5);
      expect(() => Calculator.average([]), throwsArgumentError);
    });

    test('median', () {
      expect(Calculator.median([1, 2, 3, 4, 5]), 3);
      expect(Calculator.median([1, 2, 3, 4]), 2.5);
      expect(Calculator.median([5, 1, 3, 2, 4]), 3);
      expect(Calculator.median([5]), 5);
      expect(() => Calculator.median([]), throwsArgumentError);
    });
  });

  group('Constants', () {
    test('pi', () {
      expect(Calculator.pi, closeTo(3.14159, 0.001));
      expect(Calculator.pi, math.pi);
    });

    test('e', () {
      expect(Calculator.e, closeTo(2.71828, 0.001));
      expect(Calculator.e, math.e);
    });
  });

  group('Degree/Radian Conversion', () {
    test('degreesToRadians', () {
      expect(Calculator.degreesToRadians(0), 0);
      expect(Calculator.degreesToRadians(90), closeTo(math.pi / 2, 0.001));
      expect(Calculator.degreesToRadians(180), closeTo(math.pi, 0.001));
      expect(Calculator.degreesToRadians(360), closeTo(2 * math.pi, 0.001));
    });

    test('radiansToDegrees', () {
      expect(Calculator.radiansToDegrees(0), 0);
      expect(Calculator.radiansToDegrees(math.pi / 2), closeTo(90, 0.001));
      expect(Calculator.radiansToDegrees(math.pi), closeTo(180, 0.001));
      expect(Calculator.radiansToDegrees(2 * math.pi), closeTo(360, 0.001));
    });
  });

  group('Number Theory', () {
    test('factorial', () {
      expect(Calculator.factorial(0), 1);
      expect(Calculator.factorial(1), 1);
      expect(Calculator.factorial(5), 120);
      expect(Calculator.factorial(6), 720);
      expect(() => Calculator.factorial(-1), throwsArgumentError);
    });

    test('gcd', () {
      expect(Calculator.gcd(12, 8), 4);
      expect(Calculator.gcd(15, 25), 5);
      expect(Calculator.gcd(7, 13), 1);
      expect(Calculator.gcd(-12, 8), 4);
      expect(Calculator.gcd(12, -8), 4);
    });

    test('lcm', () {
      expect(Calculator.lcm(12, 8), 24);
      expect(Calculator.lcm(15, 25), 75);
      expect(Calculator.lcm(7, 13), 91);
      expect(Calculator.lcm(-12, 8), 24);
    });

    test('isPrime', () {
      expect(Calculator.isPrime(2), true);
      expect(Calculator.isPrime(3), true);
      expect(Calculator.isPrime(17), true);
      expect(Calculator.isPrime(97), true);
      expect(Calculator.isPrime(4), false);
      expect(Calculator.isPrime(15), false);
      expect(Calculator.isPrime(1), false);
      expect(Calculator.isPrime(0), false);
      expect(Calculator.isPrime(-5), false);
    });
  });

  group('Percentage Calculations', () {
    test('percentage', () {
      expect(Calculator.percentage(25, 100), 25);
      expect(Calculator.percentage(30, 150), 20);
      expect(Calculator.percentage(0, 100), 0);
      expect(() => Calculator.percentage(25, 0), throwsArgumentError);
    });

    test('percentageOf', () {
      expect(Calculator.percentageOf(25, 100), 25);
      expect(Calculator.percentageOf(50, 200), 100);
      expect(Calculator.percentageOf(0, 100), 0);
      expect(Calculator.percentageOf(10, 0), 0);
    });
  });
}
