import 'package:flutter/material.dart';

extension PARSER on TimeOfDay {
  String toStringPayload() {
    String addLeadingZeroIfNeeded(int value) {
      if (value < 10) {
        return '0$value';
      }
      return value.toString();
    }

    final String hourLabel = addLeadingZeroIfNeeded(hour);
    final String minuteLabel = addLeadingZeroIfNeeded(minute);
    return '$hourLabel:$minuteLabel';
  }

  bool isAfter(TimeOfDay t) {
    final totalMinutes1 = hour * 60 + minute;
    final totalMinutes2 = t.hour * 60 + t.minute;
    return totalMinutes1 > totalMinutes2;
  }

  bool isBefore(TimeOfDay t) {
    final totalMinutes1 = hour * 60 + minute;
    final totalMinutes2 = t.hour * 60 + t.minute;
    return totalMinutes1 < totalMinutes2;
  }

  bool isSameTime(TimeOfDay t) {
    final totalMinutes1 = hour * 60 + minute;
    final totalMinutes2 = t.hour * 60 + t.minute;
    return totalMinutes1 == totalMinutes2;
  }

  Duration difference(TimeOfDay t) {
    final totalMinutes1 = hour * 60 + minute;
    final totalMinutes2 = t.hour * 60 + t.minute;
    final diff = totalMinutes2 - totalMinutes1;
    return Duration(minutes: diff);
  }

  TimeOfDay addMinutes(int minutesToAdd) {
    final now = DateTime.now();
    final timeAsDateTime = DateTime(now.year, now.month, now.day, hour, minute);
    final updatedTime = timeAsDateTime.add(Duration(minutes: minutesToAdd));
    return TimeOfDay(hour: updatedTime.hour, minute: updatedTime.minute);
  }

  DateTime toDateTime({DateTime? date}) {
    date ??= DateTime.now();
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  bool isWithinTimeRange({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final now = this;

    // Check if the current time is within the range
    final currentTime = now;
    final start = TimeOfDay.fromDateTime(startTime);
    final end = TimeOfDay.fromDateTime(endTime);

    bool isWithinTime = false;

    if (start.hour < end.hour ||
        (start.hour == end.hour && start.minute <= end.minute)) {
      // Normal range
      isWithinTime =
          (currentTime.hour > start.hour ||
              (currentTime.hour == start.hour &&
                  currentTime.minute >= start.minute)) &&
          (currentTime.hour < end.hour ||
              (currentTime.hour == end.hour &&
                  currentTime.minute <= end.minute));
    } else {
      // Time range spans midnight
      isWithinTime =
          (currentTime.hour > start.hour ||
              (currentTime.hour == start.hour &&
                  currentTime.minute >= start.minute)) ||
          (currentTime.hour < end.hour ||
              (currentTime.hour == end.hour &&
                  currentTime.minute <= end.minute));
    }

    return isWithinTime;
  }
}
