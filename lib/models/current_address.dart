import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/models/user_address.dart';

class CurrentAddress {
  final GeoPoint coordinates;
  final String pinned,
      city,
      countryCode,
      locality,
      country,
      addressLine,
      barangay,
      state,
      region;
  final bool isForSomeone;

  const CurrentAddress({
    required this.pinned,
    required this.city,
    required this.coordinates,
    required this.locality,
    required this.country,
    required this.countryCode,
    required this.barangay,
    required this.region,
    required this.state,
    required this.addressLine,
    this.isForSomeone = false,
  });

  factory CurrentAddress.fromBackend(Map<String, dynamic> json) {
    debugPrint("📍 CurrentAddress.fromBackend: $json");
    return CurrentAddress(
      pinned: json['address'] ?? "",
      state: json['state'] ?? "",
      barangay: json['barangay'] ?? "",
      region: json['region'] ?? "",
      addressLine: json['street'],
      city: json['city'].toString().capitalizeWords(),
      coordinates: json['coordinates'].toString().toGeopoint(),
      locality: json['state'].toString().capitalizeWords(),
      countryCode: json['country_code'] ?? "PH",
      country: json['country'].toString().capitalizeWords(),
      isForSomeone: json['is_for_someone'] == 1,
    );
  }

  UserAddress toUserAddress({int? cityID, int? brgyID}) => UserAddress(
    brgyID: brgyID ?? -1,
    cityID: cityID ?? -1,
    stateID: -1,
    landmark: '',
    addressLine: addressLine,
    city: city,
    coordinates: coordinates,
    locality: locality,
    countryCode: countryCode,
    id: 0,
    title: 'Current Location',
    country: country,
    barangay: barangay,
    region: region,
    state: state,
    pinned: pinned,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isForSomeone: isForSomeone,
  );
}
