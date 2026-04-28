import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/models/firebase/fire_rating.dart';

class FireMerchant {
  final String name, photoUrl;
  final GeoPoint coordinates;
  final FireRating? rate;
  final double merchantFee;
  final int acceptanceWindowMinutes;
  final String? contactNumber;
  const FireMerchant({
    required this.name,
    required this.photoUrl,
    required this.coordinates,
    required this.rate,
    required this.merchantFee,
    required this.acceptanceWindowMinutes,
    required this.contactNumber,
  });

  factory FireMerchant.fromJson(Map<String, dynamic> json) => FireMerchant(
    acceptanceWindowMinutes: int.parse(json['acceptance_date_time'].toString()),
    rate: json['rate'] == null ? null : FireRating.fromJson(json['rate']),
    name: json['name'],
    coordinates: json['coordinates'].toString().toGeopoint(),
    photoUrl: json['photo'],
    merchantFee: json['merchant_fee'] ?? 0.0,
    contactNumber: json['contact_number'],
  );
}
