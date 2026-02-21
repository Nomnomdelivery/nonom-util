import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_util/models/area_setting.dart';

class DeliveryFeeParams {
  final GeoPoint deliveryPoint;
  final GeoPoint store;
  final AreaSetting areaSetting;
  final int merchantId;
  final int customerAddressId;

  const DeliveryFeeParams({
    required this.deliveryPoint,
    required this.store,
    required this.areaSetting,
    required this.merchantId,
    required this.customerAddressId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryFeeParams &&
          runtimeType == other.runtimeType &&
          deliveryPoint.latitude == other.deliveryPoint.latitude &&
          deliveryPoint.longitude == other.deliveryPoint.longitude &&
          store.latitude == other.store.latitude &&
          store.longitude == other.store.longitude &&
          areaSetting.id == other.areaSetting.id;

  @override
  int get hashCode =>
      deliveryPoint.latitude.hashCode ^
      deliveryPoint.longitude.hashCode ^
      store.latitude.hashCode ^
      store.longitude.hashCode ^
      areaSetting.id.hashCode;
}
