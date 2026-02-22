import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/models/firebase/fire_rating.dart';

class FireMerchant {
  final String name, photoUrl;
  final GeoPoint coordinates;
  final FireRating? rate;
  final double merchantFee;
  const FireMerchant({
    required this.name,
    required this.photoUrl,
    required this.coordinates,
    required this.rate,
    required this.merchantFee,
  });

  factory FireMerchant.fromJson(Map<String, dynamic> json) => FireMerchant(
    rate: json['rate'] == null ? null : FireRating.fromJson(json['rate']),
    name: json['name'],
    coordinates: json['coordinates'].toString().toGeopoint(),
    photoUrl: json['photo'],
    merchantFee: json['merchant_fee'] ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "rate": rate?.toJson(),
    "name": name,
    "photo_url": photoUrl,
    "coordinates": "${coordinates.latitude},${coordinates.longitude}",
    "merchant_fee": merchantFee,
  };
}
