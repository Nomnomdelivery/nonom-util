import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/models/merchant/current_schedule.dart';
import 'package:nomnom_util/models/merchant/operating_day.dart';
import 'package:nomnom_util/models/merchant/rating.dart';

class Merchant {
  final double acceptanceRating;
  final double completeOrderRating;
  final double timelinessRating;
  final double feedbackRating;
  final double overallRating;
  final Rating rating;
  final List<OperatingDay> operatingDays;
  final int id;
  final String name, photoUrl, coverPhotoUrl, description;
  final CurrentSchedule currentSchedule;
  final GeoPoint coordinates;
  final double merchantFee;
  final int? isTestAccount;
  final bool? isNewStore;
  final DateTime? approvedAt;
  const Merchant({
    required this.operatingDays,
    required this.coverPhotoUrl,
    required this.description,
    required this.id,
    required this.acceptanceRating,
    required this.completeOrderRating,
    required this.timelinessRating,
    required this.feedbackRating,
    required this.overallRating,
    required this.rating,
    required this.coordinates,
    required this.name,
    required this.photoUrl,
    required this.currentSchedule,
    required this.merchantFee,
    this.isTestAccount,
    this.isNewStore,
    this.approvedAt,
  });

  bool shouldShowNewStoreBadge({required Set<int> qaMerchantIds}) {
    if (isNewStore == true) return true;
    if (qaMerchantIds.contains(id)) return true;
    return false;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'coverPhoto': coverPhotoUrl,
      'currentSchedule': currentSchedule.toJson(),
      "merchantFee": merchantFee,
    };
  }

  factory Merchant.fromJson(Map<String, dynamic> map) {
    final List ops = map['operating_days'] ?? [];
    return Merchant(
      merchantFee: map['merchant_fee'] == null
          ? 0.0
          : double.parse(map['merchant_fee'].toString()),
      isTestAccount: map['is_test_account'] ?? false,
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
      operatingDays: ops.map((e) => OperatingDay.fromJson(e)).toList(),
      coordinates: map['coordinates'].toString().toGeopoint(),
      coverPhotoUrl: map['cover_photo_url'],
      id: map['id'] as int,
      name: map['name'],
      currentSchedule: CurrentSchedule.fromJson(map['current_schedule']),
      photoUrl: map['photo_url'],
      isNewStore: map['is_new_store'] == true || map['is_new_store'] == 1,
      approvedAt: map['approved_at'] == null
          ? null
          : DateTime.tryParse(map['approved_at'].toString()),
    );
  }
}
