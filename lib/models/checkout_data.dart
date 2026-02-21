import 'package:flutter/material.dart';
import 'package:nomnom_util/models/cart.dart';
import 'package:nomnom_util/models/delivery_pricing.dart';
import 'package:nomnom_util/models/delivery_type.dart';

class CheckoutData {
  final CartModel cart;
  final DeliveryPricing pricing;
  final DeliveryType deliveryType;
  final bool isForFriend;
  final bool isPreorder;
  final bool hasUtensils;
  final DateTime deliveryDate;
  final TimeOfDay deliveryTime;
  final String note;
  // final bool isCod;
  int etaMinute;
  CheckoutData({
    required this.cart,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.deliveryType,
    required this.isForFriend,
    required this.isPreorder,
    required this.note,
    required this.etaMinute,
    required this.hasUtensils,
    required this.pricing,
  });
  CheckoutData copyWith({
    CartModel? cart,
    DeliveryPricing? pricing,
    DeliveryType? deliveryType,
    bool? isForFriend,
    bool? isPreorder,
    DateTime? deliveryDate,
    TimeOfDay? deliveryTime,
    String? note,
    bool? hasUtensils,
    int? etaMinute,
  }) {
    return CheckoutData(
      hasUtensils: hasUtensils ?? this.hasUtensils,
      cart: cart ?? this.cart,
      pricing: pricing ?? this.pricing,
      deliveryType: deliveryType ?? this.deliveryType,
      isForFriend: isForFriend ?? this.isForFriend,
      isPreorder: isPreorder ?? this.isPreorder,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      note: note ?? this.note,
      etaMinute: etaMinute ?? this.etaMinute,
    );
  }

  @override
  String toString() {
    return cart.toString();
  }
}
