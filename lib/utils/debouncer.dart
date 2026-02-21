import 'dart:async';

class Debouncer {
  final Duration delay;
  void Function(int value)? onValueChanged;

  int _value = 0;
  Timer? _timer;

  Debouncer({required this.delay});

  int get value => _value;

  void updateValue(int newValue) {
    _value = newValue;

    // Cancel the previous timer if it exists
    _timer?.cancel();

    // Start a new timer
    _timer = Timer(delay, () {
      if (onValueChanged != null) {
        onValueChanged!(_value);
      }
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}
