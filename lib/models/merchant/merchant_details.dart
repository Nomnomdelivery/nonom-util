// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/models/location_model.dart';
import 'package:nomnom_util/models/merchant/current_schedule.dart';
import 'package:nomnom_util/models/merchant/merchant_with_city.dart';
import 'package:nomnom_util/models/merchant/operating_day.dart';
import 'package:nomnom_util/models/merchant/rating.dart';

class MerchantDetails extends MerchantWithCity {
  final String email;
  final String phoneNumber;
  final String municipality;
  final String address;
  final String landmark;
  final int type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int status;
  final String street;
  final bool isClose;
  final String country;
  final int adminId;

  MerchantDetails({
    required super.id,
    required super.operatingDays,
    required super.name,
    required this.email,
    required this.phoneNumber,
    required super.description,
    required this.municipality,
    required this.address,
    required this.landmark,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.isClose,
    required super.state,
    required this.street,
    required super.city,
    required this.country,
    required this.adminId,
    required super.displayAddressString,
    required super.currentSchedule,
    required super.photoUrl,
    required super.coverPhotoUrl,
    required super.brgy,
    required super.coordinates,
    required super.acceptanceRating,
    required super.completeOrderRating,
    required super.timelinessRating,
    required super.feedbackRating,
    required super.overallRating,
    required super.merchantFee,
    required super.rating,
    required super.isTestAccount,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'operatingDays': operatingDays.map((x) => x.toJson()).toList(),
      'email': email,
      'phoneNumber': phoneNumber,
      'description': description,
      'municipality': municipality,
      'is_close': isClose,
      'address': address,
      'landmark': landmark,
      'type': type,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'status': status,
      'street': street,
      'coordinates': coordinates,
      'country': country,
      'city': city,
      'merchantFee': merchantFee,
      'isTestAccount': isTestAccount,
    };
  }

  factory MerchantDetails.fromMap(Map<String, dynamic> map) {
    final List ops = map['operating_days'] ?? [];
    final LocationModel mState = LocationModel.fromJson(map['map_state']);
    final LocationModel mCity = LocationModel.fromJson(map['map_city']);
    final LocationModel mBrgy = LocationModel.fromJson(map['map_barangay']);
    return MerchantDetails(
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
      displayAddressString: "${mBrgy.name},${mCity.name},${mState.name}",
      isClose: map['is_close'] == 1,
      operatingDays: ops.map((e) => OperatingDay.fromJson(e)).toList(),
      email: map['email'] as String,
      phoneNumber: map['phone_number'] as String,
      description: map['description'] as String,
      municipality: map['municipality'] as String,
      address: map['address'] as String,
      landmark: map['landmark'] as String,
      type: map['type'] as int,
      createdAt: DateTime.parse(map['created_at'].toString()),
      updatedAt: DateTime.parse(map['updated_at'].toString()),
      status: map['status'] as int,
      street: map['street'] as String,
      coordinates: map['coordinates'].toString().toGeopoint(),
      country: map['country'] as String,
      id: map['id'],
      name: map['name'],
      state: mState,
      city: mCity,
      brgy: mBrgy,
      adminId: map['admin_id'] as int,
      currentSchedule: CurrentSchedule.fromJson(map['current_schedule']),
      photoUrl:
          map['photo_url'] ??
          "https://back.nomnomdelivery.com/images/no_image_placeholder.jpg",
      coverPhotoUrl:
          map['cover_photo_url'] ??
          "https://back.nomnomdelivery.com/images/no_image_placeholder.jpg",
    );
  }
  @override
  String toString() => "${toMap()}";

  factory MerchantDetails.fromJson(String source) =>
      MerchantDetails.fromMap(json.decode(source) as Map<String, dynamic>);
}
