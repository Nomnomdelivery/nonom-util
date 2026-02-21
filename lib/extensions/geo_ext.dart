import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/utils/distance_matrix_service.dart';

class ETAResult {
  /// Duration in minutes
  final int eta;
  final int deliveryFee;

  const ETAResult({required this.eta, required this.deliveryFee});

  @override
  String toString() {
    return 'ETAResult(eta: $eta,   deliveryFee: $deliveryFee,)';
  }
}

extension EXT on GeoPoint {
  String convertString() => "$latitude,$longitude";
  bool distanceIsWithin(Position pos, {required double kmRadius}) {
    const double pi = 3.1415926535897932;
    const double earthRadius = 6371.0; // Radius of the earth in kilometers

    double dLat = (pos.latitude - latitude) * (pi / 180.0);
    double dLon = (pos.longitude - longitude) * (pi / 180.0);

    double a =
        pow(sin(dLat / 2), 2) +
        cos(latitude * (pi / 180.0)) *
            cos(pos.latitude * (pi / 180.0)) *
            pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c <= kmRadius; // Distance in kilometers
  }

  double distanceBetween(Position pos) {
    const double pi = 3.1415926535897932;
    const double earthRadius = 6371.0; // Radius of the earth in kilometers

    double dLat = (pos.latitude - latitude) * (pi / 180.0);
    double dLon = (pos.longitude - longitude) * (pi / 180.0);

    double a =
        pow(sin(dLat / 2), 2) +
        cos(latitude * (pi / 180.0)) *
            cos(pos.latitude * (pi / 180.0)) *
            pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in kilometers
  }

  double distanceBetweenPoints(GeoPoint point) {
    const double pi = 3.1415926535897932;
    const double earthRadius = 6371.0; // Radius of the earth in kilometers

    double dLat = (point.latitude - latitude) * (pi / 180.0);
    double dLon = (point.longitude - longitude) * (pi / 180.0);

    double a =
        pow(sin(dLat / 2), 2) +
        cos(latitude * (pi / 180.0)) *
            cos(point.latitude * (pi / 180.0)) *
            pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in kilometers
  }

  double calculateDistance(GeoPoint point) {
    final double endLatitude = point.latitude;
    final double endLongitude = point.longitude;
    const double earthRadius = 6371.0; // Earth's radius in kilometers
    double dLat = _degreesToRadians(endLatitude - latitude);
    double dLon = _degreesToRadians(endLongitude - longitude);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(latitude)) *
            cos(_degreesToRadians(endLatitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<ETAResult> calculateETACentral(
    GeoPoint point, {
    double speed = 20,
    required bool useForPrepTime,
    required AreaSetting settings,
    required int merchantId,
    required int customerAddressId,
    required DistanceMatrixService service,
  }) async {
    // If using for prep time, use simple calculation directly
    if (useForPrepTime) {
      final double straightLineDistance = calculateDistance(point);

      // Apply a road distance factor (roads are typically 1.2-1.4x longer than straight line)
      // Urban areas: 1.3-1.4, Rural: 1.2-1.3
      const double roadFactor = 1.45;
      final double estimatedRoadDistance = straightLineDistance * roadFactor;

      // Adjust speed based on distance (shorter trips have more stops/turns)
      double adjustedSpeed = speed;
      if (estimatedRoadDistance < 2) {
        adjustedSpeed = speed * 0.7; // 30% slower for short urban trips
      } else if (estimatedRoadDistance < 5) {
        adjustedSpeed = speed * 0.85; // 15% slower for medium trips
      }

      final double eta = (estimatedRoadDistance / adjustedSpeed) * 60;
      debugPrint("etaINFO Preptime: $eta (road factor applied)");

      return ETAResult(eta: eta.ceil(), deliveryFee: 0);
    }

    try {
      final etaInfo = await service.getETAInfoAPI(
        merchantId: merchantId,
        customerAddressId: customerAddressId,
      );

      // final etaInfoMatrix = await service.getETAInfo(this, point);

      debugPrint("etaINFO: $etaInfo");
      // debugPrint("etaINFOMatrix: $etaInfoMatrix");

      // Validate response data
      if (etaInfo == null ||
          etaInfo['data']['eta'] == null ||
          etaInfo['data']['deliveryFee'] == null) {
        throw Exception("Invalid response from DeliveryFee and ETA API");
      }

      return ETAResult(
        eta: etaInfo['data']['eta'], // Convert seconds to minutes
        deliveryFee: etaInfo['data']['deliveryFee'],
      );
    } catch (e, s) {
      debugPrint(
        "Distance Matrix API failed, using fallback calculation: $e $s",
      );
      // Fallback to simple calculation if API fails
      final double dst = calculateDistance(point);
      final double eta = (dst / speed) * 60; // Convert to minutes

      debugPrint("calculate ETACentral $dst");
      debugPrint("DISTANCE $dst");
      double ratePerKm = 0;
      if (dst < settings.setting.applicableDistance) {
        ratePerKm =
            settings.setting.deliveryBaseFare +
            (dst * settings.setting.deliveryRatePerKm);
      } else {
        ratePerKm =
            settings.setting.deliveryBaseFare +
            (dst * settings.setting.deliveryRatePerKmBeyond);
      }
      debugPrint(
        "Delivery Fee Calculation: Distance: $dst, Rate per Km: $ratePerKm",
      );

      return ETAResult(eta: eta.ceil(), deliveryFee: ratePerKm.ceil());
    }
  }
}

extension Convert on Position {
  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);
}
