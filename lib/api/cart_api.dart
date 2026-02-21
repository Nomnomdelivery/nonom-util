import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nomnom_util/models/cart_item.dart';
import 'package:nomnom_util/models/delivery_pricing.dart';
import 'package:nomnom_util/models/qoutation_model.dart';
import 'package:nomnom_util/models/selected_option_cat.dart';
import 'package:nomnom_util/models/user_address.dart';

abstract class BaseCartApi {
  Future<bool> checkRider({
    required int merchantID,
    required List<int> riderIds,
  });

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

  Future<QuotationModel?> checkout({
    required String items_string,
    required List<CartItem> cartItems,
    required int eta,
    required int nomnomCoins,
    required int merchantId,
    required List<int> cartIds,
    required bool isPickup,
    required bool isPreorder,
    required DateTime deliveryDate,
    required TimeOfDay deliveryTime,
    required bool hasUtensils,
    required DeliveryPricing pricing,
    required double points,
    required bool isForFriend,
    required GeoPoint storeLocation,
    required GeoPoint deliveryPoint,
    required UserAddress address,
    required String? landmark,
    required String note,
    required String name,
    required String lastname,
    required String middlename,
    required String mobileNumber,
    required bool isFriendPay,
    required String paymentMethod,
    int? cashOnHand,
  });
  Future<bool> savePendingOrder({
    required String items_string,
    required List<CartItem> cartItems,
    required int eta,
    required int nomnomCoins,
    required int merchantId,
    required List<int> cartIds,
    required bool isPickup,
    required bool isPreorder,
    required DateTime deliveryDate,
    required TimeOfDay deliveryTime,
    required bool hasUtensils,
    required DeliveryPricing pricing,
    required double points,
    required bool isForFriend,
    required GeoPoint storeLocation,
    required GeoPoint deliveryPoint,
    required UserAddress address,
    required String? landmark,
    required String note,
    required String name,
    required String lastname,
    required String middlename,
    required String mobileNumber,
    required bool isFriendPay,
    required String paymentMethod,
    required String userId,
    required String externalID,
  });
}
