import 'dart:async';
import 'package:nomnom_util/models/selected_option_cat.dart';

abstract class BaseCartApi {
  // Future<bool> checkRider({
  //   required int merchantID,
  //   required List<int> riderIds,
  // });

  Future<bool> add({
    required int menuItemID,
    required int quantity,
    String? instruction,
    required double markupRate,
    required double subtotal,
    required List<SelectedOptionCat> optionSelection,
    required int orderType,
    int? replaceItemId,
    String? orderId,
    int? variationId,
  });
  Future<bool> updateQuantity(int id, int newQuantity);

  Future<bool> delete(int id);

  // Future<QuotationModel?> checkout({
  //   required String itemString,
  //   required List<CartItem> cartItems,
  //   required int eta,
  //   required int nomnomCoins,
  //   required int merchantId,
  //   required List<int> cartIds,
  //   required bool isPickup,
  //   required bool isPreorder,
  //   required DateTime deliveryDate,
  //   required TimeOfDay deliveryTime,
  //   required bool hasUtensils,
  //   required DeliveryPricing pricing,
  //   required double points,
  //   required bool isForFriend,
  //   required GeoPoint storeLocation,
  //   required GeoPoint deliveryPoint,
  //   required UserAddress address,
  //   required String? landmark,
  //   required String note,
  //   required String name,
  //   required String lastname,
  //   required String middlename,
  //   required String mobileNumber,
  //   required bool isFriendPay,
  //   required String paymentMethod,
  //   int? cashOnHand,
  // });
  // Future<bool> savePendingOrder({
  //   required String itemString,
  //   required List<CartItem> cartItems,
  //   required int eta,
  //   required int nomnomCoins,
  //   required int merchantId,
  //   required List<int> cartIds,
  //   required bool isPickup,
  //   required bool isPreorder,
  //   required DateTime deliveryDate,
  //   required TimeOfDay deliveryTime,
  //   required bool hasUtensils,
  //   required DeliveryPricing pricing,
  //   required double points,
  //   required bool isForFriend,
  //   required GeoPoint storeLocation,
  //   required GeoPoint deliveryPoint,
  //   required UserAddress address,
  //   required String? landmark,
  //   required String note,
  //   required String name,
  //   required String lastname,
  //   required String middlename,
  //   required String mobileNumber,
  //   required bool isFriendPay,
  //   required String paymentMethod,
  //   required String userId,
  //   required String externalID,
  // });
}
