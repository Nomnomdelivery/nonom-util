import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_util/extensions/string_parser.dart';

class FireDestination {
  final String address;
  final String city;
  final GeoPoint coordinates;
  final String addressId;

  FireDestination({
    required this.address,
    required this.city,
    required this.coordinates,
    required this.addressId,
  });

  // Factory method to create an instance from Firestore document data
  factory FireDestination.fromFirestore(Map<String, dynamic> data) {
    return FireDestination(
      addressId: data['id'] as String? ?? "",
      address: data['address'] as String,
      city: data['city'] as String,
      coordinates: data['coordinates'].toString().toGeopoint(),
    );
  }
}
