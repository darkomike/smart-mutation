import 'dart:math' as math;

/// A class for calculating areas of various geometric shapes
class AreaCalculator {
  /// Calculates the area of a rectangle
  /// [width] and [height] must be positive numbers
  static double rectangle(double width, double height) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Width and height must be positive');
    }
    return width * height;
  }

  /// Calculates the area of a square
  /// [side] must be a positive number
  static double square(double side) {
    if (side <= 0) {
      throw ArgumentError('Side length must be positive');
    }
    return side * side;
  }

  /// Calculates the area of a circle
  /// [radius] must be a positive number
  static double circle(double radius) {
    if (radius <= 0) {
      throw ArgumentError('Radius must be positive');
    }
    return math.pi * radius * radius;
  }

  /// Calculates the area of a triangle using base and height
  /// [base] and [height] must be positive numbers
  static double triangle(double base, double height) {
    if (base <= 0 || height <= 0) {
      throw ArgumentError('Base and height must be positive');
    }
    return 0.5 * base * height;
  }

  /// Calculates the area of a triangle using Heron's formula
  /// [a], [b], and [c] are the side lengths
  static double triangleHeron(double a, double b, double c) {
    if (a <= 0 || b <= 0 || c <= 0) {
      throw ArgumentError('All side lengths must be positive');
    }
    
    // Check triangle inequality
    if (a + b <= c || a + c <= b || b + c <= a) {
      throw ArgumentError('Invalid triangle: triangle inequality not satisfied');
    }
    
    double s = (a + b + c) / 2; // semi-perimeter
    return math.sqrt(s * (s - a) * (s - b) * (s - c));
  }

  /// Calculates the area of a parallelogram
  /// [base] and [height] must be positive numbers
  static double parallelogram(double base, double height) {
    if (base <= 0 || height <= 0) {
      throw ArgumentError('Base and height must be positive');
    }
    return base * height;
  }

  /// Calculates the area of a trapezoid
  /// [base1], [base2], and [height] must be positive numbers
  static double trapezoid(double base1, double base2, double height) {
    if (base1 <= 0 || base2 <= 0 || height <= 0) {
      throw ArgumentError('All measurements must be positive');
    }
    return 0.5 * (base1 + base2) * height;
  }

  /// Calculates the area of an ellipse
  /// [a] and [b] are the semi-major and semi-minor axes
  static double ellipse(double a, double b) {
    if (a <= 0 || b <= 0) {
      throw ArgumentError('Both axes must be positive');
    }
    return math.pi * a * b;
  }

  /// Calculates the area of a rhombus
  /// [diagonal1] and [diagonal2] are the lengths of the diagonals
  static double rhombus(double diagonal1, double diagonal2) {
    if (diagonal1 <= 0 || diagonal2 <= 0) {
      throw ArgumentError('Both diagonals must be positive');
    }
    return 0.5 * diagonal1 * diagonal2;
  }

  /// Calculates the area of a regular polygon
  /// [sides] is the number of sides, [length] is the side length
  static double regularPolygon(int sides, double length) {
    if (sides < 3) {
      throw ArgumentError('A polygon must have at least 3 sides');
    }
    if (length <= 0) {
      throw ArgumentError('Side length must be positive');
    }
    
    double apothem = length / (2 * math.tan(math.pi / sides));
    double perimeter = sides * length;
    return 0.5 * perimeter * apothem;
  }

  /// Calculates the surface area of a sphere
  /// [radius] must be a positive number
  static double sphereSurface(double radius) {
    if (radius <= 0) {
      throw ArgumentError('Radius must be positive');
    }
    return 4 * math.pi * radius * radius;
  }

  /// Calculates the surface area of a cylinder
  /// [radius] and [height] must be positive numbers
  static double cylinderSurface(double radius, double height) {
    if (radius <= 0 || height <= 0) {
      throw ArgumentError('Radius and height must be positive');
    }
    return 2 * math.pi * radius * (radius + height);
  }

  /// Calculates the surface area of a cone
  /// [radius] and [slantHeight] must be positive numbers
  static double coneSurface(double radius, double slantHeight) {
    if (radius <= 0 || slantHeight <= 0) {
      throw ArgumentError('Radius and slant height must be positive');
    }
    return math.pi * radius * (radius + slantHeight);
  }
}