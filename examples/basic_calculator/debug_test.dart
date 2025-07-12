import 'lib/calculus.dart';

void main() {
  // Test secondDerivative
  double cubic(double x) => x * x * x;
  print('f(x) = x^3');
  print('f(2) = ${cubic(2)}');
  print('First derivative at x=2: ${Calculus.derivative(cubic, 2)}');
  print('Second derivative at x=2: ${Calculus.secondDerivative(cubic, 2)}');
  print('Expected second derivative: 12');
  
  // Test step size sensitivity
  print('\nTesting different step sizes:');
  print('h=1e-4: ${Calculus.secondDerivative(cubic, 2, h: 1e-4)}');
  print('h=1e-6: ${Calculus.secondDerivative(cubic, 2, h: 1e-6)}');
  print('h=1e-8: ${Calculus.secondDerivative(cubic, 2, h: 1e-8)}');
}
