extension FORMATTTER on int {
  String formatTime() {
    int minutes = this ~/ 60;
    int remainingSeconds = this % 60;
    String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
    String secondsStr = (remainingSeconds < 10)
        ? '0$remainingSeconds'
        : '$remainingSeconds';
    return '$minutesStr:$secondsStr';
  }

  String toMinutes() {
    int minutes = this ~/ 60; // Integer division
    int seconds = this % 60; // remainder
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Duration toDuration() {
    return Duration(minutes: this);
  }
}
