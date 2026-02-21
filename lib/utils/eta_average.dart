import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nomnom_util/extensions/geo_ext.dart';
import 'package:nomnom_util/models/area_setting.dart';
import 'package:nomnom_util/models/cart.dart';
import 'package:nomnom_util/models/user_address.dart';
import 'package:nomnom_util/providers/user_provider.dart';
import 'package:nomnom_util/utils/distance_matrix_service.dart';

Future<int> calculateAverageETA({
  required GeoPoint point,
  required GeoPoint store,
  required AreaSetting settings,
  required int merchantId,
  required int customerAddressId,
  required DistanceMatrixService service,
  double speed = 30,
}) async {
  final etaResult = await store.calculateETACentral(
    point,
    speed: speed,
    useForPrepTime: true,
    settings: settings,
    merchantId: merchantId,
    customerAddressId: customerAddressId,
    service: service,
  );

  return etaResult.eta.ceil();
}

Future<int> averageEtaWithPrepTime({
  required GeoPoint store,
  required AreaSetting settings,
  double speed = 30,
  required WidgetRef ref,
  CartModel? selectedCartModel,
  required int merchantId,
  required DistanceMatrixService service,
  required StateNotifierProvider<CurrentLocationNotifier, UserAddress?>
  currentLocationProvider,
}) async {
  final deliveryAddress = ref.read(currentLocationProvider);
  debugPrint("deliveryAddress LOCATION $deliveryAddress");
  int maxPrepTime = 0;

  if (deliveryAddress == null) {
    Fluttertoast.showToast(msg: "Enable your location address.");
    throw "Delivery address is null";
  }

  ETAResult etaResult = await store.calculateETACentral(
    deliveryAddress.coordinates,
    speed: speed,
    useForPrepTime: true,
    settings: settings,
    merchantId: merchantId,
    customerAddressId: deliveryAddress.id,
    service: service,
  );

  debugPrint("ETA RESULT $etaResult");

  if (selectedCartModel != null) {
    maxPrepTime = getHighestPrepTime(selectedCartModel);
  }

  debugPrint("averageEtaWithPrepTime : ${etaResult.eta}");

  return (etaResult.eta + maxPrepTime).ceil();
}

int getHighestPrepTime(CartModel model) {
  if (model.items.isEmpty) return 0;
  return model.items
      .map((e) => e.prepTime)
      .toList()
      .reduce((curr, next) => curr > next ? curr : next);
}
