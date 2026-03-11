import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/models/current_address.dart';

class UserAddress extends CurrentAddress {
  final int id;
  final String title;
  final String? landmark;
  final int stateID;
  final int cityID;
  final int brgyID;
  final bool isDraft;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isForSomeone;
  UserAddress({
    required super.pinned,
    required super.city,
    required super.coordinates,
    required super.locality,
    required super.countryCode,
    required this.id,
    required this.title,
    required super.country,
    required super.barangay,
    required super.region,
    required super.state,
    this.landmark,
    required this.brgyID,
    required this.cityID,
    required this.stateID,
    required super.addressLine,
    this.isDraft = false,
    required this.createdAt,
    required this.updatedAt,
    required this.isForSomeone,
  });
  factory UserAddress.fromJson(Map<String, dynamic> json) {
    debugPrint("user address $json");
    final List<double> c = json['coordinates']
        .toString()
        .split(',')
        .map((e) => double.parse(e))
        .toList();

    final brgyID = json['barangay_id'] == null
        ? -1
        : int.parse(json['barangay_id'].toString());
    final barangay = json['barangay'] ?? "";

    return UserAddress(
      brgyID: brgyID,
      stateID: json['state_id'] == null
          ? -1
          : int.parse(json['state_id'].toString()),
      cityID: json['city_id'] == null
          ? -1
          : int.parse(json['city_id'].toString()),
      landmark: json['landmark'] ?? '',
      barangay: barangay,
      state: json['state'],
      pinned: json['street'] ?? "",
      region: json['region'] ?? "",
      addressLine: json['address'] ?? "",
      city: json['city'],
      coordinates: GeoPoint(c.first, c.last),
      locality: json['state'],
      countryCode: json['country'],
      id: json['id'],
      title: json['title'] ?? "UNSET",
      country: json['country'].toString().capitalize(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isForSomeone: json['is_for_someone'] == null
          ? false
          : json['is_for_someone'].toString() == "1",
    );
  }

  @override
  String toString() => "${toJson()}";

  Map<String, dynamic> toJson() => {
    'landmark': landmark,
    "title": title,
    'id': id,
    "barangay_id": brgyID,
    "barangay": barangay,
    "city": city,
    "city_id": cityID,
    "state_id": stateID,
    "state": state,
    "street": pinned,
    "region": region,
    "address": addressLine,
    "country": countryCode,
    "coordinates": "${coordinates.latitude},${coordinates.longitude}",
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
  UserAddress copyWith({
    String? addressLine,
    String? city,
    GeoPoint? coordinates,
    String? locality,
    String? countryCode,
    int? id,
    int? cityID,
    int? stateID,
    int? brgyID,
    String? title,
    String? country,
    String? barangay,
    String? region,
    String? state,
    String? pinned,
    String? landmark,
    bool? isDraft,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isForSomeone,
  }) {
    return UserAddress(
      cityID: cityID ?? this.cityID,
      stateID: stateID ?? this.stateID,
      brgyID: brgyID ?? this.brgyID,
      landmark: landmark ?? this.landmark,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      coordinates: coordinates ?? this.coordinates,
      locality: locality ?? this.locality,
      countryCode: countryCode ?? this.countryCode,
      id: id ?? this.id,
      title: title ?? this.title,
      country: country ?? this.country,
      barangay: barangay ?? this.barangay,
      region: region ?? this.region,
      state: state ?? this.state,
      pinned: pinned ?? this.pinned,
      isDraft: isDraft ?? false,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isForSomeone: isForSomeone ?? this.isForSomeone,
    );
  }

  String stringify() =>
      "${addressLine.isEmpty ? "" : "$addressLine, "}$barangay, $city, $state"
          .capitalizeWords();

  CurrentAddress toAddress() => CurrentAddress(
    addressLine: addressLine,
    city: city,
    coordinates: coordinates,
    locality: locality,
    countryCode: countryCode,
    country: country,
    barangay: barangay,
    region: region,
    state: state,
    pinned: pinned,
  );
}
