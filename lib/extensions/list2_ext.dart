import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nomnom_util/models/rider_opinion.dart';
import 'package:nomnom_util/models/selected_option_cat.dart';

// Top-level function for sorting riders by distance (runs in isolate)
List<RiderOpinion> _sortRidersByDistance(SortRidersParams params) {
  final riders = params.riders;
  final storePoint = params.storePoint;
  const double radius = 6371.0; // Radius of Earth in kilometers

  double _toRadians(double degree) => degree * (pi / 180.0);

  double haversine(double lat1, double lon1, double lat2, double lon2) {
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);

    var a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radius * c; // Distance in kilometers
  }

  var sortedRiders = riders.map((rider) {
    var distance = haversine(
      storePoint.latitude,
      storePoint.longitude,
      rider.coordinates.latitude,
      rider.coordinates.longitude,
    );
    return RiderOpinion(distance: distance, riderId: rider.riderId);
  }).toList();

  sortedRiders.sort((a, b) => a.distance.compareTo(b.distance));
  return sortedRiders;
}

// Parameter class for isolate
class SortRidersParams {
  final List<RiderLocationData> riders;
  final GeoPoint storePoint;

  SortRidersParams(this.riders, this.storePoint);
}

extension TAKER on List<RiderLocationData> {
  // Radius of Earth in kilometers
  static const double _radius = 6371.0; // In kilometers
  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);

    var a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _radius * c; // Distance in kilometers
  }

  double _toRadians(double degree) {
    return degree * (pi / 180.0);
  }

  Future<List<RiderOpinion>> getFromNearestToFarthest({
    required GeoPoint storePoint,
  }) async {
    // Use isolate for CPU-intensive sorting if list is large
    if (length > 50) {
      return compute(_sortRidersByDistance, SortRidersParams(this, storePoint));
    } else {
      // For small lists, do it synchronously
      var sortedRiders = map((rider) {
        var distance = _haversine(
          storePoint.latitude,
          storePoint.longitude,
          rider.coordinates.latitude,
          rider.coordinates.longitude,
        );
        return RiderOpinion(distance: distance, riderId: rider.riderId);
      }).toList();
      sortedRiders.sort((a, b) => a.distance.compareTo(b.distance));

      debugPrint("SORTED RIDERS $sortedRiders");
      return sortedRiders;
    }
  }
}

extension CHECKER on List<SelectedOptionCat> {
  bool isSameWith(List<SelectedOptionCat> list) {
    if (length != list.length) return false;
    for (int i = 0; i < list.length; i++) {
      bool isSameID = this[i].id == list[i].id;
      if (!isSameID || (this[i].options.length != list[i].options.length)) {
        return false;
      }
      for (int j = 0; j < this[i].options.length; j++) {
        if (this[i].options[j].id != list[i].options[j].id) return false;
        if (this[i].options[j].suboption?.id !=
            list[i].options[j].suboption?.id) {
          return false;
        }
      }
    }
    return true;
  }
}
