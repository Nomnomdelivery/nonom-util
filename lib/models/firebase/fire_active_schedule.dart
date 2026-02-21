import 'package:flutter/material.dart';
import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/extensions/time_of_day_parser.dart';

class FireActiveSchedule {
  final int scheduleID;
  final DateTime date;
  final int cityID;
  final String city;
  final TimeOfDay startTime, endTime;
  final DateTime activatedOn;
  final int riderID;
  final List<int> mergedCityIds;
  final int? isTestAccount;
  FireActiveSchedule({
    required this.scheduleID,
    required this.date,
    required this.activatedOn,
    required this.endTime,
    required this.startTime,
    required this.city,
    required this.cityID,
    required this.riderID,
    required this.mergedCityIds,
    this.isTestAccount = 0,
  });

  // Factory method to create an instance from Firestore document data
  factory FireActiveSchedule.fromFirestore(
    Map<String, dynamic> data,
    String riderID,
  ) {
    final List ddd = (data['merged_city'] ?? [riderID]);
    return FireActiveSchedule(
      mergedCityIds: ddd.map((e) => int.parse(e.toString())).toList(),
      city: data['city'] ?? "",
      cityID: int.parse(data['city_id'].toString()),
      scheduleID: data['schedule_id'],
      date: DateTime.parse(data['date'].toString()),
      activatedOn: DateTime.parse(data['activated_on']),
      endTime: data['end_time'].toString().toTimeOfDay,
      riderID: int.tryParse(riderID) ?? -1,
      startTime: data['start_time'].toString().toTimeOfDay,
      isTestAccount: data['is_test_account'] ?? 0,
    );
  }

  // Method to convert the instance to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      "activated_on": activatedOn.toIso8601String(),
      "schedule_id": scheduleID,
      'date': date.toIso8601String(),
      'start_time': startTime.toStringPayload(),
      'end_time': endTime.toStringPayload(),
      'rider_id': "$riderID",
      'is_test_account': isTestAccount ?? 0,
    };
  }
}
