import 'dart:ui';

extension ColorOpacityExtension on Color {
  Color hasOpacity(double value) {
    assert(value >= 0.0 && value <= 1.0, 'Opacity must be between 0.0 and 1.0');
    return withAlpha((value * 255).toInt());
  }
}
