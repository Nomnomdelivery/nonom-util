import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_util/extensions/string_parser.dart';

class RiderLocationData {
  final int riderId;
  final GeoPoint coordinates;
  final double speed, heading;
  const RiderLocationData({
    required this.coordinates,
    required this.heading,
    required this.riderId,
    required this.speed,
  });

  factory RiderLocationData.fromJson(
    Map<String, dynamic> json,
  ) => RiderLocationData(
    coordinates:
        "${double.parse(json['latitude'].toString())},${double.parse(json['longitude'].toString())}"
            .toGeopoint(),
    heading: double.parse(json['heading'].toString()),
    riderId: json['rider_id'],
    speed: double.parse(json['speed'].toString()),
  );
  Map<String, dynamic> toJson() => {
    'rider_id': riderId,
    'latitude': coordinates.latitude,
    'longitude': coordinates.longitude,
    'speed': speed,
    'heading': heading,
  };
  @override
  String toString() => "${toJson()}";
}

class RiderOpinion {
  final int riderId;
  final double distance;
  const RiderOpinion({required this.distance, required this.riderId});

  factory RiderOpinion.fromJson(Map<String, dynamic> json) {
    return RiderOpinion(
      distance: double.parse(json['distance'].toString()),
      riderId: json['rider_id'],
    );
  }

  Map<String, dynamic> toJson() => {"rider_id": riderId, "distance": distance};
  @override
  String toString() => "${toJson()}";
}
