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

  factory OperatingDay.fromJson(Map<String, dynamic> json) {
    return OperatingDay(
      id: json['id'],
      merchantId: json['merchant_id'],
      startTime: json['start_time'].toString().toTimeOfDay,
      endTime: json['end_time'].toString().toTimeOfDay,
      day: json['day'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      enable: json['enable'] == 1,
      label: json['label'],
      order: json['order'],
      text: json['text'],
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
