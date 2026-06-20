import 'package:flutter/material.dart';
import 'package:nomnom_util/extensions/string_parser.dart';

class OperatingDay {
  final int id;
  final int merchantId;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int day;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool enable;
  final String label;
  final int order;
  final String text;

  OperatingDay({
    required this.id,
    required this.merchantId,
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.createdAt,
    required this.updatedAt,
    required this.enable,
    required this.label,
    required this.order,
    required this.text,
  });

  factory OperatingDay.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return OperatingDay(
        id: 0,
        merchantId: 0,
        startTime: const TimeOfDay(hour: 0, minute: 0),
        endTime: const TimeOfDay(hour: 0, minute: 0),
        day: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        enable: false,
        label: '',
        order: 0,
        text: '',
      );
    }
    return OperatingDay(
      id: json['id'] ?? 0,
      merchantId: json['merchant_id'] ?? 0,
      startTime:
          json['start_time']?.toString().toTimeOfDay ??
          const TimeOfDay(hour: 0, minute: 0),
      endTime:
          json['end_time']?.toString().toTimeOfDay ??
          const TimeOfDay(hour: 0, minute: 0),
      day: json['day'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      enable: json['enable'] == 1,
      label: json['label'] ?? '',
      order: json['order'] ?? 0,
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'merchant_id': merchantId,
    'start_time': startTime,
    'end_time': endTime,
    'day': day,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'enable': enable ? 1 : 0,
    'label': label,
    'order': order,
    'text': text,
  };
  @override
  String toString() => "${toJson()}";
}
