import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/models/cart_item.dart';
import 'package:nomnom_util/models/firebase/fire_destination.dart';
import 'package:nomnom_util/models/firebase/fire_merchant.dart';
import 'package:nomnom_util/models/firebase/fire_order_rating.dart';
import 'package:nomnom_util/models/firebase/fire_payment.dart';
import 'package:nomnom_util/models/firebase/fire_recipient.dart';
import 'package:nomnom_util/models/firebase/fire_rider.dart';
import 'package:nomnom_util/models/firebase/item_unavailable_action.dart';
import 'package:nomnom_util/utils/date_parse.dart';
import 'unavailable_action.dart';

class DeliveryModel {
  final DateTime? riderPickedUpAt;
  final DateTime? riderArrivedAt;
  final DateTime? riderDeliveredAt;
  final FireMerchant merchant;
  final DateTime deliveryDate;
  final double deliveryFee;
  final double merchantFee;
  final TimeOfDay deliveryTime;
  final FireDestination destination;
  final double eta;
  final int originalEta;
  final DateTime? prepTime;
  final int id;
  final bool isForFriend;
  final bool isPickup, isFriendPay;
  final bool isPreorder;
  final int merchantId;
  final FireRecipient recipient;
  final GeoPoint? riderCoordinates;
  final FireRider? rider;
  final int status;
  final String reference;
  final Timestamp? storeAcceptedAt;
  final double total;
  final int? cancelCode;
  final String? cancelReason;
  final String itemsString;
  final Timestamp timestamp;
  final List<CartItem> items;
  final double usedCoins;
  final FireOrderRating orderRating;
  final FirePayment payment;
  final double discount;
  final ItemUnavailableAction itemUnavailableAction;
  final int userId;
  final int cashOnhand;
  final double change;
  final double usedNomnomCoins;
  final bool isMerchantTestAccount;
  final DateTime? lastRiderRejectedAt;
  final DateTime? storeReadyForPickupAt;
  final int riderRejections;
  final UnavailableAction unavailableAction;
  final List<int> candidates;

  DeliveryModel({
    required this.candidates,
    required this.unavailableAction,
    required this.riderRejections,
    required this.storeReadyForPickupAt,
    required this.lastRiderRejectedAt,
    required this.isMerchantTestAccount,
    required this.merchant,
    required this.deliveryTime,
    required this.deliveryDate,
    required this.deliveryFee,
    required this.originalEta,

    required this.merchantFee,
    required this.riderArrivedAt,
    required this.riderDeliveredAt,
    required this.riderPickedUpAt,
    this.cancelCode,
    this.cancelReason,
    required this.reference,
    required this.usedCoins,
    required this.destination,
    required this.eta,
    required this.prepTime,
    required this.isFriendPay,
    required this.id,
    required this.isForFriend,
    required this.merchantId,
    required this.recipient,
    required this.riderCoordinates,
    required this.rider,
    required this.status,
    required this.isPickup,
    required this.isPreorder,
    required this.timestamp,
    required this.total,
    required this.itemsString,
    required this.storeAcceptedAt,
    required this.items,
    required this.orderRating,
    required this.payment,
    required this.discount,
    required this.itemUnavailableAction,
    required this.userId,
    required this.cashOnhand,
    required this.change,
    required this.usedNomnomCoins,
  });

  factory DeliveryModel.fromFirestore(Map<String, dynamic> data) {
    final List itms = data['cart_items'] == null
        ? []
        : data['cart_items'] as List;

    final List riderCandidates = data['rider_candidates'] ?? [];
    if (riderCandidates.contains(null)) {
      riderCandidates.removeWhere((e) => e == null);
    }

    return DeliveryModel(
      usedCoins: (data['used_nomnom_coins'] ?? 0).toDouble(),
      orderRating: data['order_rating'] == null
          ? FireOrderRating()
          : FireOrderRating.fromJson(data['order_rating']),
      riderArrivedAt: data['rider_arrived_at'] == null
          ? null
          : DateTime.parse(data['rider_arrived_at'].toString()),
      riderDeliveredAt: data['item_delivered_at'] == null
          ? null
          : DateTime.parse(data['item_delivered_at'].toString()),
      riderPickedUpAt: data['rider_picked_up_at'] == null
          ? null
          : DateTime.parse(data['rider_picked_up_at'].toString()),
      items: itms.map((e) => CartItem.fromFirestore(e)).toList(),
      cancelReason: data['reason_phrase'] as String?,
      cancelCode: data['cancel_error'] as int?,
      storeAcceptedAt: data['store_accepted_at'] as Timestamp?,
      merchant: FireMerchant.fromJson(data['merchant']),
      prepTime: data['prep_time'] == null
          ? null
          : DateTime.parse(data['prep_time']),
      isFriendPay: data['is_pay_friend'] == null
          ? false
          : data['is_pay_friend'] as bool,
      reference: data['reference'] as String,
      deliveryTime: data['delivery_time'] == null
          ? TimeOfDay.now()
          : (data['delivery_time'] as String).toTimeOfDay,
      deliveryDate: DateTime.parse(data['delivery_date'].toString()),
      deliveryFee: (data['delivery_fee'] as num).toDouble(),
      merchantFee: (data['merchant_fee'] as num?)?.toDouble() ?? 0.0,
      destination: FireDestination.fromFirestore(
        data['destination'] as Map<String, dynamic>,
      ),
      eta: double.parse(data['eta'].toString()),
      originalEta: (data['original_eta'] as int?) ?? 0,

      id: data['id'] as int,
      isPreorder: data['is_pre_order'] as bool,
      isPickup: data['is_pick_up'] as bool,
      isForFriend: data['is_for_friend'] as bool,
      merchantId: data['merchant_id'] as int,
      recipient: FireRecipient.fromFirestore(
        data['recipient'] as Map<String, dynamic>,
      ),
      riderCoordinates: data['rider_coordinates'] == null
          ? null
          : (data['rider_coordinates'] as String).toGeopoint(),
      rider: data['rider'] == null ? null : FireRider.fromJson(data['rider']),
      status: data['status'] as int,
      timestamp: data['timestamp'] as Timestamp,
      total: (data['total'] as num).toDouble(),
      itemsString: data['items_string'] as String,
      payment: FirePayment.fromJson(data['payment']),
      discount: data['discount']?.toDouble() ?? 0.0,
      itemUnavailableAction: data['item_unavailable_action'] == null
          ? const ItemUnavailableAction(
              id: 0,
              string: "Remove it from my order",
            )
          : ItemUnavailableAction.fromJson(data['item_unavailable_action']),
      userId: data['user_id'] as int,
      cashOnhand:
          data['cash_on_hand'] == null ||
              data['cash_on_hand'].toString().trim().isEmpty ||
              double.tryParse(data['cash_on_hand'].toString()) == null ||
              double.parse(data['cash_on_hand'].toString()) <= 0.0
          ? 0
          : double.parse(data['cash_on_hand'].toString()).toInt(),

      change: data['change'] == null ? 0.0 : (data['change'] as num).toDouble(),
      usedNomnomCoins: (data['used_nomnom_coins'] ?? 0).toDouble(),
      isMerchantTestAccount: (data['is_merchant_test_account'] ?? 0) == 1,
      lastRiderRejectedAt: parseDateNullable(data['last_rider_rejected_at']),
      storeReadyForPickupAt: parseDateNullable(
        data['store_ready_for_pickup_at'],
      ),
      riderRejections: data['rider_rejections'] ?? data['rider_rejections'],
      unavailableAction: UnavailableAction.fromJson(
        data['item_unavailable_action'],
      ),
      candidates: riderCandidates.map((e) => int.parse(e.toString())).toList(),
    );
  }

  String statusString() {
    // Treat remitted (9) as delivered (5) for customer-facing display
    final effectiveStatus = status == 9 ? 5 : status;
    Map<int, String> statusMap = {
      -1: "Pending payment",
      0: 'Waiting for Store',
      1: 'Preparing Order',
      11: 'Assigned',
      2: 'Ready for Pickup',
      3: 'Order is on it\'s way',
      4: 'Order Arrived',
      5: 'Order Delivered',
      7: 'User cancelled',
      6: 'Store Cancelled',
      8: systemCancelReason(),
    };

    return statusMap[effectiveStatus] ?? 'Unknown Status';
  }

  String systemCancelReason() {
    if (cancelCode == null) {
      return "System Cancelled";
    } else if (cancelCode! >= 9) {
      return "Admin Cancelled";
    }
    return "System Cancelled";
  }

  DateTime statusDateTime() {
    debugPrint("Calculating status datetime for status: $status");
    debugPrint("Delivery date: $deliveryDate");
    if (status == 0) {
      return deliveryDate;
    } else if (status == 1) {
      return storeAcceptedAt?.toDate() ?? deliveryDate;
    } else if (status == 3) {
      return riderPickedUpAt ?? deliveryDate;
    } else if (status == 4) {
      return riderArrivedAt ?? deliveryDate;
    } else if (status == 5) {
      return riderDeliveredAt ?? deliveryDate;
    } else {
      return deliveryDate;
    }
  }

  Color statusColor() {
    // Map remitted (9) visually to delivered (5)
    const Map<int, Color> statusColorMap = {
      0: Colors.orange,
      1: Color(0xFF50A3FB),
      11: Color(0xFF993CFC),
      2: Color(0xFF26DE57),
      3: Colors.teal,
      4: Color(0xFF26DE57),
      5: Color(0xFF26DE57),
      6: Color(0xFFFF0000),
      7: Color(0xFFFF0000),
      8: Color(0xFFFF0000),
    };
    final effectiveStatus = status == 9 ? 5 : status;
    return statusColorMap[effectiveStatus] ?? Colors.black;
  }

  Color statusColorRedGreen() {
    const Set<int> redStatuses = {
      6,
      7,
      8,
    }; // Not Accepted, Cancelled, System Cancelled
    return redStatuses.contains(status) ? Colors.red : Colors.green;
  }

  String shortStatusString() {
    const Map<int, String> statusMap = {
      0: 'Waiting for Store',
      1: 'Preparing Order',
      11: 'Assigned',
      2: 'Ready for Pickup',
      3: 'Picked Up',
      4: 'Arrived',
      5: 'Delivered',
      6: 'Not Accepted',
      7: 'Cancelled',
      8: 'System Cancelled',
      9: 'Remitted',
    };
    return statusMap[status] ?? 'Unknown Status';
  }

  String statusStringNextStep() {
    const Map<int, String> statusMap = {
      0: 'Waiting for Store',
      1: 'Ordered',
      11: 'Assigned',
      2: 'Ready for Pickup',
      3: 'Picked Up',
      4: 'Arrived',
      5: 'Delivered',
      6: 'User Cancelled',
      7: 'Store Cancelled',
      8: 'System Cancelled',
      9: 'Remitted',
    };
    return statusMap[status + 1] ?? 'Unknown Status';
  }
}
