import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nomnom_util/api/auth_api.dart';
import 'package:nomnom_util/models/user_address.dart';
import 'package:nomnom_util/models/user_model.dart';
import 'package:nomnom_util/utils/computation.dart';

class CurrentLocationNotifier extends StateNotifier<UserAddress?> {
  CurrentLocationNotifier() : super(null);

  Future<void> setLocation(
    UserAddress? location,
    UserAddress? bestmatch,
  ) async {
    if (bestmatch != null && location != null) {
      // Calculate distance in kilometers between location and bestmatch
      final double lat1 = location.coordinates.latitude;
      final double lon1 = location.coordinates.longitude;
      final double lat2 = bestmatch.coordinates.latitude;
      final double lon2 = bestmatch.coordinates.longitude;

      final double distanceKm = await compute(haversineKm, [
        lat1,
        lon1,
        lat2,
        lon2,
      ]);
      debugPrint(
        'Distance between location and bestmatch: \u001b[32m${distanceKm * 1000} meters (${distanceKm.toStringAsFixed(5)} km)\u001b[0m',
      );
      if (distanceKm < 0.05) {
        // Use the existing bestmatch address since the new location is very close to it
        state = location.copyWith(isForSomeone: false);
      } else {
        debugPrint(
          'Location is more than 50 meters (0.05 km) away from bestmatch. Using new location.',
        );
        state = location.copyWith(isForSomeone: true);
      }
    } else {
      // If no bestmatch or location is null, just set the state as is
      state = location;
    }
  }
}

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  CurrentUserNotifier(super.state);
  void update(UserModel m) {
    state = m;
  }

  void updateDefaultAddress(int id) {
    if (state == null) return;
    final UserModel n = state!.copyWith(defaultAddress: id);
    state = n;
  }

  void reset() {
    state = null;
  }

  Future<void> fetchFromBackend({required AuthApi api}) async {
    final result = await api.getUserDetails();
    result.fold((onResult) {
      state = onResult;
    }, (err) {});
  }
}
