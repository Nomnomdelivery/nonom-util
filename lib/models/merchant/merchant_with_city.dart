import 'package:flutter/material.dart';
import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/extensions/time_of_day_parser.dart';
import 'package:nomnom_util/models/location_model.dart';
import 'package:nomnom_util/models/merchant/current_schedule.dart';
import 'package:nomnom_util/models/merchant/merchant.dart';
import 'package:nomnom_util/models/merchant/operating_day.dart';
import 'package:nomnom_util/models/merchant/rating.dart';

class MerchantWithCity extends Merchant {
  final String displayAddressString;
  final LocationModel state, city, brgy;
  const MerchantWithCity({
    required super.id,
    required super.acceptanceRating,
    required super.completeOrderRating,
    required super.timelinessRating,
    required super.feedbackRating,
    required super.overallRating,
    required super.rating,
    required super.coordinates,
    required super.name,
    required super.photoUrl,
    required super.currentSchedule,
    required this.state,
    required super.description,
    required this.brgy,
    required this.displayAddressString,
    required this.city,
    required super.operatingDays,
    required super.coverPhotoUrl,
    required super.merchantFee,
    required super.isTestAccount,
  });
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'coverPhoto': coverPhotoUrl,
      'currentSchedule': currentSchedule.toJson(),
      'merchantFee': merchantFee,
      'isTestAccount': isTestAccount,
    };
  }

  factory MerchantWithCity.fromJson(Map<String, dynamic> map) {
    final List ops = map['operating_days'] ?? [];
    final LocationModel mState = LocationModel.fromJson(map['map_state']);
    final LocationModel mCity = LocationModel.fromJson(map['map_city']);
    final LocationModel mBrgy = LocationModel.fromJson(map['map_barangay']);
    return MerchantWithCity(
      isTestAccount: map['is_test_account'] ?? 0,
      merchantFee: map['merchant_fee'] == null
          ? 0.0
          : double.parse(map['merchant_fee'].toString()),
      acceptanceRating: map['acceptance_rating'] == null
          ? 0.0
          : double.parse(map['acceptance_rating'].toString()),
      completeOrderRating:
          double.tryParse(map['complete_order_rating'].toString()) ?? 0,
      timelinessRating:
          double.tryParse(map['timeliness_rating'].toString()) ?? 0,
      feedbackRating: double.tryParse(map['feedback_rating'].toString()) ?? 0,
      overallRating: double.tryParse(map['overall_rating'].toString()) ?? 0,
      rating: map['rating'] == null
          ? Rating(averageRating: 0, count: 0, feedbacks: [])
          : Rating.fromJson(map['rating']),
      description: map['description'] ?? "",
      displayAddressString: "${mBrgy.name}, ${mCity.name}, ${mState.name}",
      operatingDays: ops.map((e) => OperatingDay.fromJson(e)).toList(),
      coordinates: map['coordinates'].toString().toGeopoint(),
      coverPhotoUrl:
          (map['cover_photo_url'] ??
                  "https://back.nomnomdelivery.com/images/no_image_placeholder.jpg")
              .toString()
              .replaceFirst("customer.", 'back.'),
      state: mState,
      city: mCity,
      brgy: mBrgy,
      id: map['id'] as int,
      name: map['name'],
      currentSchedule: CurrentSchedule.fromJson(map['current_schedule']),
      photoUrl: map['photo_url'] ?? "",
    );
  }
  // static final StoreApi _api = StoreApi();
  // Future<MerchantDetails> details({required bool isPublic}) async =>
  //     await _api.getDetails(id, isPublic: isPublic);

  int determineOrderTime({
    DateTime? dateTime,
    required Map<String, dynamic>? ffStoreSchedule,
  }) {
    if (ffStoreSchedule != null) {
      final schedule =
          ffStoreSchedule['current_schedule'] as Map<String, dynamic>? ?? {};
      final overrideStatus = ffStoreSchedule['override_status'] as String?;
      final now = DateTime.now();
      final isOpen = _computeStoreOpenStatus(
        overrideStatus: overrideStatus,
        schedule: schedule,
        now: now,
      );

      return isOpen;
    }

    final now = dateTime ?? DateTime.now();
    final startTime = currentSchedule.startTime.toTimeOfDay.toDateTime();
    final endTime = currentSchedule.endTime.toTimeOfDay.toDateTime();
    if (now.isAfter(startTime) && now.isBefore(endTime)) {
      return 0; // now
    } else if (now.isBefore(startTime)) {
      return 1; // later
    } else if (now.isAfter(endTime)) {
      return 2; // tomorrow
    }

    return 2;
  }

  int _computeStoreOpenStatus({
    required String? overrideStatus,
    required Map schedule,
    required DateTime now,
  }) {
    // Handle override first
    if (overrideStatus == "open") return 0;
    final String openTimeStr = schedule['open'] ?? "00:00:00";
    final String closeTimeStr = schedule['close'] ?? "00:00:00";
    if (overrideStatus == "closed") {
      final DateTime open = openTimeStr.toTimeOfDay.toDateTime();
      if (now.isBefore(open)) {
        return 1; // later
      } else if (now.isAfter(closeTimeStr.toTimeOfDay.toDateTime())) {
        return 2; // tomorrow
      }
      return 2;
    }

    final String? dateStr = schedule['date'];

    if (dateStr == null) return 2; // no valid date

    try {
      final DateTime date = DateTime.parse(dateStr);

      // Parse open and close time based on the given date
      final openParts = openTimeStr
          .split(':')
          .map(int.parse)
          .toList(); // [08,00,00]
      final closeParts = closeTimeStr.split(':').map(int.parse).toList();

      final open = DateTime(
        date.year,
        date.month,
        date.day,
        openParts[0],
        openParts[1],
      );
      final close = DateTime(
        date.year,
        date.month,
        date.day,
        closeParts[0],
        closeParts[1],
      );
      if (now.isAfter(open) && now.isBefore(close)) {
        return 0; // now
      } else if (now.isBefore(open)) {
        return 1; // later
      } else if (now.isAfter(close)) {
        return 2; // tomorrow
      }
      return 2;
      // return now.isAfter(open) && now.isBefore(close);
    } catch (e) {
      final now = DateTime.now();
      final startTime = currentSchedule.startTime.toTimeOfDay.toDateTime();
      final endTime = currentSchedule.endTime.toTimeOfDay.toDateTime();
      debugPrint("Invalid schedule format: $e");
      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        return 0; // now
      } else if (now.isBefore(startTime)) {
        return 1; // later
      } else if (now.isAfter(endTime)) {
        return 2; // tomorrow
      }
      return 2;
    }
  }
}
