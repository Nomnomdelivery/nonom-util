import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nomnom_util/extensions/string_parser.dart';

class WhitelistLocationModel {
  final int id;
  final int mapCityId;
  final String gid3;
  final String name;
  final List<LatLng> coordinates;
  final bool isOpen;
  final String startTime;
  final String endTime;
  final String? displayStartTime;
  final String? displayEndTime;

  WhitelistLocationModel({
    required this.id,
    required this.mapCityId,
    required this.gid3,
    required this.name,
    required this.coordinates,
    required this.isOpen,
    required this.startTime,
    required this.endTime,
    required this.displayStartTime,
    required this.displayEndTime,
  });
  factory WhitelistLocationModel.fromJson(Map<String, dynamic> json) {
    final mapBarangay = json['map_barangay'] as Map<String, dynamic>?;
    List<LatLng> extractedCoords = [];

    if (mapBarangay != null) {
      final geometry = mapBarangay['geometry'];
      if (geometry != null && geometry['coordinates'] != null) {
        final List coordinates = geometry['coordinates'];
        extractedCoords = coordinates.first.first.map<LatLng>((point) {
          return LatLng(point[1], point[0]); // GeoJSON format is [lng, lat]
        }).toList();
      }
    }

    final id = mapBarangay?['id'] ?? 0;
    final name = (mapBarangay?['name'] ?? '').toString().pascalToNormal();
    final isOpen = json['is_open'] ?? true;
    final startTime = json['start_time'] ?? '';
    final endTime = json['end_time'] ?? '';
    final displayStartTime = json['display_start_time'] as String? ?? '';
    final displayEndTime = json['display_end_time'] as String? ?? '';

    return WhitelistLocationModel(
      id: id,
      mapCityId: mapBarangay?['map_city_id'] ?? 0,
      gid3: mapBarangay?['gid_3'] ?? '',
      name: name,
      coordinates: extractedCoords,
      isOpen: isOpen,
      startTime: startTime,
      endTime: endTime,
      displayStartTime: displayStartTime,
      displayEndTime: displayEndTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'map_city_id': mapCityId,
      'gid_3': gid3,
      'name': name,
      'geometry': {'type': 'MultiPolygon', 'coordinates': coordinates},
      'is_open': isOpen,
      'start_time': startTime,
      'end_time': endTime,
      'display_start_time': displayStartTime ?? '',
      'display_end_time': displayEndTime ?? '',
    };
  }

  @override
  String toString() => "${toJson()}";
}
