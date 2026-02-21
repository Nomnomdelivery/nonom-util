import 'package:flutter/material.dart';
import 'package:nomnom_util/models/cart_item.dart';
import 'package:nomnom_util/models/delivery_details';
import 'package:nomnom_util/models/location.dart';
import 'package:nomnom_util/models/rider_opinion.dart';
import 'package:nomnom_util/models/user_address.dart';

class OrderRequest {
  final String itemString;
  final List<CartItem> cartItems;
  final int eta;
  final int nomnomCoins;
  final String payment;
  final List<int> cartIds;
  final bool isFriendPay;
  final bool isPickup;
  final bool isPreorder;
  final DateTime preorderDeliveryDate;
  final TimeOfDay preorderDeliveryTime;
  final bool hasUtensils;
  final double points;
  final List<RiderOpinion> riderPredictions;
  final List<DeliveryDetails> deliveryDetails;
  final double total;
  final bool isForFriend;
  final Location destination;
  final Location pickupLocation;
  final UserAddress address;
  final String? landmark;
  final String note;
  final String recipientFirstname;
  final String recipientMiddlename;
  final String recipientLastname;
  final String mobileNumber;
  final String promoCode;
  final int? cashOnHand;

  OrderRequest({
    required this.itemString,
    required this.cartItems,
    required this.eta,
    required this.nomnomCoins,
    required this.payment,
    required this.cartIds,
    required this.isFriendPay,
    required this.isPickup,
    required this.isPreorder,
    required this.preorderDeliveryDate,
    required this.preorderDeliveryTime,
    required this.hasUtensils,
    required this.points,
    required this.riderPredictions,
    required this.deliveryDetails,
    required this.total,
    required this.isForFriend,
    required this.destination,
    required this.pickupLocation,
    required this.address,
    required this.note,
    required this.recipientFirstname,
    required this.recipientMiddlename,
    required this.recipientLastname,
    required this.mobileNumber,
    required this.promoCode,
    this.cashOnHand,
    this.landmark,
  });

  /*
Helpers, manipulates data berfore passing as payload
*/
  String _formatItemsToList(List<int> values) => values.join(',');

  String _boolToInt(bool value) => value ? '1' : '0';

  String _formatTime(TimeOfDay time) => '${time.hour}:${time.minute}';

  String _formatLocation(Location loc) => '${loc.latitude},${loc.longitude}';

  List<Map<String, dynamic>> _formatList(List<dynamic> items) =>
      items.map((e) => e.toJson() as Map<String, dynamic>).toList();

  Map<String, String> _formatAddressFields() {
    return {
      "address_id": address.id.toString(),
      "street": address.pinned,
      "barangay": address.barangay,
      "city": address.city,
      "state": address.state,
      "country": address.country,
      "address": address.title.toLowerCase() == 'current location'
          ? address.pinned
          : "${address.addressLine}, ${address.barangay}, ${address.city}, ${address.state}",
      "landmark": landmark ?? "N/A",
    };
  }
  // ------------------------------------------------------------------------------------------------------ >>

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "items_string": itemString,
      "cartItems": _formatList(cartItems),
      "eta": eta,
      "nomnomCoins": nomnomCoins,
      "payment": payment,
      "cart_ids": _formatItemsToList(cartIds),
      "is_friend_pay": _boolToInt(isFriendPay),
      "is_pick_up": _boolToInt(isPickup),
      "is_preorder": _boolToInt(isPreorder),
      "preorder_delivery_date": preorderDeliveryDate.toIso8601String(),
      "preorder_delivery_time": _formatTime(preorderDeliveryTime),
      "has_utensils": _boolToInt(hasUtensils),
      "points": points,
      "rider_predictions": _formatList(riderPredictions),
      "delivery_details": _formatList(deliveryDetails),
      "total": total.toStringAsFixed(2),
      "is_for_friend": _boolToInt(isForFriend),
      "destination": _formatLocation(destination),
      "pickup_location": _formatLocation(pickupLocation),
      ..._formatAddressFields(),
      "note": note,
      "recipient_firstname": recipientFirstname,
      "recipient_middlename": recipientMiddlename,
      "recipient_lastname": recipientLastname,
      "mobile_number": mobileNumber,
      "cash_on_hand": cashOnHand?.toString(),
    };

    if (promoCode.isNotEmpty) {
      data["promo_code"] = promoCode;
    }
    if (cashOnHand != null) {
      data["cash_on_hand"] = cashOnHand!.toString();
    }
    return data;
  }

  @override
  String toString() {
    return 'OrderRequest('
        'payment: $payment, '
        'cartIds: $cartIds, '
        'isFriendPay: $isFriendPay, '
        'isPickup: $isPickup, '
        'isPreorder: $isPreorder, '
        'preorderDeliveryDate: $preorderDeliveryDate, '
        'preorderDeliveryTime: ${preorderDeliveryTime.hour}:${preorderDeliveryTime.minute}, '
        'hasUtensils: $hasUtensils, '
        'points: $points, '
        'riderPredictions: $riderPredictions, '
        'deliveryDetails: $deliveryDetails, '
        'total: $total, '
        'isForFriend: $isForFriend, '
        'destination: (${destination.latitude}, ${destination.longitude}), '
        'pickupLocation: (${pickupLocation.latitude}, ${pickupLocation.longitude}), '
        'address: ${address.toJson()}, '
        'landmark: $landmark, '
        'note: $note, '
        'recipientFirstname: $recipientFirstname, '
        'recipientMiddlename: $recipientMiddlename, '
        'recipientLastname: $recipientLastname, '
        'mobileNumber: $mobileNumber, '
        'promoCode: $promoCode'
        'cashOnHand: $cashOnHand'
        ')';
  }
}
