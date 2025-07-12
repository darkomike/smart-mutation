import 'dart:math' as math;

/// A class for calculus operations including derivatives, integrals, limits, and series
class Calculus {
  
  // DERIVATIVE FUNCTIONS
  
  /// Numerical derivative using central difference method
  /// f(x+h) - f(x-h) / 2h
  static double derivative(double Function(double) f, double x, {double h = 1e-8}) {
    return (f(x + h) - f(x - h)) / (2 * h);
  }
  
  /// Second derivative using numerical differentiation
  static double secondDerivative(double Function(double) f, double x, {double h = 1e-8}) {
    return (f(x + h) - 2 * f(x) + f(x - h)) / (h * h);
  }
  
  /// Partial derivative with respect to x (keeping y constant)
  static double partialX(double Function(double, double) f, double x, double y, {double h = 1e-8}) {
    return (f(x + h, y) - f(x - h, y)) / (2 * h);
  }
  
  /// Partial derivative with respect to y (keeping x constant)
  static double partialY(double Function(double, double) f, double x, double y, {double h = 1e-8}) {
    return (f(x, y + h) - f(x, y - h)) / (2 * h);
  }
  
  // INTEGRAL FUNCTIONS
  
  /// Numerical integration using Simpson's rule
  static double simpsonsRule(double Function(double) f, double a, double b, {int n = 1000}) {
    if (n % 2 != 0) n++; // Ensure n is even
    
    double h = (b - a) / n;
    double sum = f(a) + f(b);
    
    for (int i = 1; i < n; i++) {
      double x = a + i * h;
      sum += (i % 2 == 0) ? 2 * f(x) : 4 * f(x);
    }
    
    return sum * h / 3;
  }
  
  /// Numerical integration using trapezoidal rule
  static double trapezoidalRule(double Function(double) f, double a, double b, {int n = 1000}) {
    double h = (b - a) / n;
    double sum = 0.5 * (f(a) + f(b));
    
    for (int i = 1; i < n; i++) {
      sum += f(a + i * h);
    }
    
    return sum * h;
  }
  
  /// Monte Carlo integration
  static double monteCarloIntegration(double Function(double) f, double a, double b, {int samples = 10000}) {
    double sum = 0;
    math.Random random = math.Random();
    
    for (int i = 0; i < samples; i++) {
      double x = a + random.nextDouble() * (b - a);
      sum += f(x);
    }
    
    return (b - a) * sum / samples;
  }
  
  // LIMIT FUNCTIONS
  
  /// Calculate limit as x approaches a value
  static double limit(double Function(double) f, double a, {double epsilon = 1e-10}) {
    double left = f(a - epsilon);
    double right = f(a + epsilon);
    double center = f(a);
    
    // Check if function is continuous at the point
    if ((left - center).abs() < 1e-6 && (right - center).abs() < 1e-6) {
      return center;
    }
    
    // Check if left and right limits exist and are equal
    if ((left - right).abs() < 1e-6) {
      return (left + right) / 2;
    }
    
    throw ArgumentError('Limit does not exist or is not continuous at x = $a');
  }
  
  /// L'Hôpital's rule for 0/0 indeterminate forms
  static double lhopitalsRule(double Function(double) numerator, double Function(double) denominator, double a) {
    double numDeriv = derivative(numerator, a);
    double denDeriv = derivative(denominator, a);
    
    if (denDeriv.abs() < 1e-15) {
      throw ArgumentError('Denominator derivative is zero, cannot apply L\'Hôpital\'s rule');
    }
    
    return numDeriv / denDeriv;
  }
  
  // SERIES FUNCTIONS
  
  /// Taylor series expansion around point a
  static double taylorSeries(double Function(double) f, double a, double x, {int terms = 10}) {
    double result = 0;
    
    for (int n = 0; n < terms; n++) {
      double factorial = 1;
      for (int i = 1; i <= n; i++) {
        factorial *= i;
      }
      
      double derivative_n = _nthDerivative(f, a, n);
      result += derivative_n * math.pow(x - a, n) / factorial;
    }
    
    return result;
  }
  
  /// Maclaurin series (Taylor series around 0)
  static double maclaurinSeries(double Function(double) f, double x, {int terms = 10}) {
    return taylorSeries(f, 0, x, terms: terms);
  }
  
  /// Power series convergence test (ratio test)
  static bool powerSeriesConverges(List<double> coefficients, double x) {
    if (coefficients.length < 2) return true;
    
    double ratio = 0;
    for (int i = 1; i < coefficients.length; i++) {
      if (coefficients[i - 1].abs() > 1e-15) {
        ratio = math.max(ratio, (coefficients[i] / coefficients[i - 1]).abs());
      }
    }
    
    return x.abs() * ratio < 1;
  }
  
  // OPTIMIZATION FUNCTIONS
  
  /// Find critical points using Newton's method
  static double newtonMethod(double Function(double) f, double x0, {int maxIterations = 100, double tolerance = 1e-10}) {
    double x = x0;
    
    for (int i = 0; i < maxIterations; i++) {
      double fx = f(x);
      double fpx = derivative(f, x);
      
      if (fpx.abs() < tolerance) {
        throw ArgumentError('Derivative is zero, cannot continue Newton\'s method');
      }
      
      double xNew = x - fx / fpx;
      
      if ((xNew - x).abs() < tolerance) {
        return xNew;
      }
      
      x = xNew;
    }
    
    throw ArgumentError('Newton\'s method did not converge after $maxIterations iterations');
  }
  
  /// Find minimum using golden section search
  static double goldenSectionMinimum(double Function(double) f, double a, double b, {double tolerance = 1e-8}) {
    double phi = (1 + math.sqrt(5)) / 2;
    double resphi = 2 - phi;
    
    double x1 = a + resphi * (b - a);
    double x2 = b - resphi * (b - a);
    double f1 = f(x1);
    double f2 = f(x2);
    
    while ((b - a).abs() > tolerance) {
      if (f1 > f2) {
        a = x1;
        x1 = x2;
        f1 = f2;
        x2 = b - resphi * (b - a);
        f2 = f(x2);
      } else {
        b = x2;
        x2 = x1;
        f2 = f1;
        x1 = a + resphi * (b - a);
        f1 = f(x1);
      }
    }
    
    return (a + b) / 2;
  }
  
  // VECTOR CALCULUS
  
  /// Gradient of a 2D function
  static List<double> gradient2D(double Function(double, double) f, double x, double y) {
    return [
      partialX(f, x, y),
      partialY(f, x, y)
    ];
  }
  
  /// Divergence of a 2D vector field
  static double divergence2D(
    double Function(double, double) fx,
    double Function(double, double) fy,
    double x,
    double y
  ) {
    return partialX(fx, x, y) + partialY(fy, x, y);
  }
  
  /// Curl of a 2D vector field (returns z-component)
  static double curl2D(
    double Function(double, double) fx,
    double Function(double, double) fy,
    double x,
    double y
  ) {
    return partialX(fy, x, y) - partialY(fx, x, y);
  }
  
  // DIFFERENTIAL EQUATIONS
  
  /// Euler's method for solving ODEs
  static List<List<double>> eulerMethod(
    double Function(double, double) dydx,
    double x0,
    double y0,
    double h,
    int steps
  ) {
    List<List<double>> result = [];
    double x = x0;
    double y = y0;
    
    for (int i = 0; i <= steps; i++) {
      result.add([x, y]);
      y += h * dydx(x, y);
      x += h;
    }
    
    return result;
  }
  
  /// Runge-Kutta 4th order method
  static List<List<double>> rungeKutta4(
    double Function(double, double) dydx,
    double x0,
    double y0,
    double h,
    int steps
  ) {
    List<List<double>> result = [];
    double x = x0;
    double y = y0;
    
    for (int i = 0; i <= steps; i++) {
      result.add([x, y]);
      
      double k1 = h * dydx(x, y);
      double k2 = h * dydx(x + h / 2, y + k1 / 2);
      double k3 = h * dydx(x + h / 2, y + k2 / 2);
      double k4 = h * dydx(x + h, y + k3);
      
      y += (k1 + 2 * k2 + 2 * k3 + k4) / 6;
      x += h;
    }
    
    return result;
  }
  
  // FOURIER ANALYSIS
  
  /// Discrete Fourier Transform coefficient
  static List<double> fourierCoefficients(List<double> signal, int harmonics) {
    int n = signal.length;
    List<double> coefficients = [];
    
    for (int k = 0; k < harmonics; k++) {
      double real = 0;
      double imag = 0;
      
      for (int j = 0; j < n; j++) {
        double angle = -2 * math.pi * k * j / n;
        real += signal[j] * math.cos(angle);
        imag += signal[j] * math.sin(angle);
      }
      
      coefficients.add(math.sqrt(real * real + imag * imag) / n);
    }
    
    return coefficients;
  }
  
  // HELPER FUNCTIONS
  
  /// Calculate nth derivative numerically
  static double _nthDerivative(double Function(double) f, double x, int n, {double h = 1e-8}) {
    if (n == 0) return f(x);
    if (n == 1) return derivative(f, x, h: h);
    
    // Recursive approach for higher order derivatives
    return _nthDerivative((double x) => derivative(f, x, h: h), x, n - 1, h: h);
  }
  
  /// Factorial function
  static double factorial(int n) {
    if (n < 0) throw ArgumentError('Factorial not defined for negative numbers');
    if (n <= 1) return 1;
    
    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
  
  /// Gamma function approximation (Stirling's approximation)
  static double gamma(double x) {
    if (x < 0) throw ArgumentError('Gamma function not defined for negative numbers');
    if (x == 0) throw ArgumentError('Gamma function has a pole at x = 0');
    
    // For integers, gamma(n) = (n-1)!
    if (x == x.round() && x > 0) {
      return factorial((x - 1).round());
    }
    
    // Stirling's approximation for non-integers
    return math.sqrt(2 * math.pi / x) * math.pow(x / math.e, x);
  }
}