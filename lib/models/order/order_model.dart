import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_util/extensions/string_parser.dart';
import 'package:nomnom_util/models/menu/order_item.dart';
import 'package:nomnom_util/models/merchant/merchant.dart';
import 'package:nomnom_util/models/movement.dart';

class OrderModel {
  final Movement currentMovement;
  final int id;
  final int? quotationId;
  final int? riderId;
  final int customerId;
  final int? merchantId;
  final int type;
  final int status;
  final GeoPoint pickupLocation;
  final GeoPoint destination;
  final String? title;
  final String? description;
  final String note;
  final String address;
  final String street;
  final String barangay;
  final String city;
  final String state;
  final String country;
  final String recipientFirstname;
  final String recipientMiddlename;
  final String recipientLastname;
  final String landmark;
  final String mobileNumber;
  final double points;
  final bool isForFriend;
  final double price;
  final double subtotal;
  final double vat;
  final double vatRate;
  final double discount;
  final double total;
  final String createdAt;
  final String updatedAt;
  final double deliveryFee;
  final double merchantFee;
  final String reference;
  final int number;
  final String promoCode;
  final String? paymentReference;
  final String? tnxid;
  final int reasonCode;
  final String? reason;
  final bool isPickUp;
  final double penaltiesAmount;
  final int? candidateId;
  final String? assignmentDatetime;
  final List transfers;
  final bool hasUtensils;
  final bool isPreorder;
  final bool isVoucher;
  final int? promoType;
  final int? areaId;
  final DateTime deliveryDate;
  final String? paymentMethod;
  final bool isPaid;
  final List<OrderItem> orderItems;
  final Merchant merchant;

  OrderModel({
    required this.id,
    required this.currentMovement,
    required this.quotationId,
    this.riderId,
    required this.customerId,
    required this.merchantId,
    required this.type,
    required this.status,
    required this.pickupLocation,
    required this.destination,
    this.title,
    this.description,
    required this.note,
    required this.address,
    required this.street,
    required this.barangay,
    required this.city,
    required this.state,
    required this.country,
    required this.recipientFirstname,
    required this.recipientMiddlename,
    required this.recipientLastname,
    required this.landmark,
    required this.mobileNumber,
    required this.points,
    required this.isForFriend,
    required this.price,
    required this.subtotal,
    required this.vat,
    required this.vatRate,
    required this.discount,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveryFee,
    required this.merchantFee,
    required this.reference,
    required this.number,
    required this.promoCode,
    this.paymentReference,
    this.tnxid,
    required this.reasonCode,
    this.reason,
    required this.isPickUp,
    required this.penaltiesAmount,
    required this.candidateId,
    this.assignmentDatetime,
    this.transfers = const [],
    required this.hasUtensils,
    required this.isPreorder,
    required this.isVoucher,
    required this.promoType,
    required this.areaId,
    required this.deliveryDate,
    this.paymentMethod,
    required this.isPaid,
    required this.orderItems,
    required this.merchant,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      currentMovement: Movement.fromJson(json['current_movement']),
      id: json['id'],
      quotationId: json['quotation_id'],
      riderId: json['rider_id'],
      customerId: json['customer_id'],
      merchantId: json['merchant_id'],
      type: json['type'],
      status: json['status'],
      pickupLocation: json['pickup_location'].toString().toGeopoint(),
      destination: json['destination'].toString().toGeopoint(),
      title: json['title'],
      description: json['description'],
      note: json['note'],
      address: json['address'],
      street: json['street'] ?? "",
      barangay: json['barangay'] ?? "",
      city: json['city'],
      state: json['state'],
      country: json['country'],
      recipientFirstname: json['recipient_firstname'],
      recipientMiddlename: json['recipient_middlename'] ?? "",
      recipientLastname: json['recipient_lastname'],
      landmark: json['landmark'] ?? "",
      mobileNumber: json['mobile_number'],
      points: (json['points'] as num).toDouble(),
      isForFriend: json['is_for_friend'] == 1,
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      vat: (json['vat'] as num).toDouble(),
      vatRate: (json['vat_rate'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      merchantFee: json['merchant_fee'] != null
          ? (json['merchant_fee'] is num
                ? (json['merchant_fee'] as num).toDouble()
                : double.tryParse(json['merchant_fee'].toString()) ?? 0.0)
          : 0.0,
      reference: json['reference'],
      number: json['number'],
      promoCode: json['promo_code'] ?? "",
      paymentReference: json['payment_reference'],
      tnxid: json['tnxid'],
      reasonCode: json['reason_code'] ?? 0,
      reason: json['reason'],
      isPickUp: json['is_pick_up'] == 1,
      penaltiesAmount: (json['penalties_amount'] as num).toDouble(),
      candidateId: json['candidate_id'],
      assignmentDatetime: json['assignment_datetime'],
      transfers: json['transfers'] ?? [],
      hasUtensils: json['has_utensils'] == 1,
      isPreorder: json['is_preorder'] == 1,
      isVoucher: json['is_voucher'] == 1,
      promoType: json['promo_type'],
      areaId: json['area_id'],
      deliveryDate: DateTime.parse(json['delivery_date']),
      paymentMethod: json['payment_method'],
      isPaid: json['is_paid'],
      orderItems: (json['order_items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      merchant: Merchant.fromJson(json['merchant']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'current_movement': currentMovement.toJson(),
      'quotation_id': quotationId,
      'rider_id': riderId,
      'customer_id': customerId,
      'merchant_id': merchantId,
      'type': type,
      'status': status,
      'pickup_location': pickupLocation,
      'destination': destination,
      'title': title,
      'description': description,
      'note': note,
      'address': address,
      'street': street,
      'barangay': barangay,
      'city': city,
      'state': state,
      'country': country,
      'recipient_firstname': recipientFirstname,
      'recipient_middlename': recipientMiddlename,
      'recipient_lastname': recipientLastname,
      'landmark': landmark,
      'mobile_number': mobileNumber,
      'points': points,
      'is_for_friend': isForFriend ? 1 : 0,
      'price': price,
      'subtotal': subtotal,
      'vat': vat,
      'vat_rate': vatRate,
      'discount': discount,
      'total': total,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'delivery_fee': deliveryFee,
      'merchant_fee': merchantFee,
      'reference': reference,
      'number': number,
      'promo_code': promoCode,
      'payment_reference': paymentReference,
      'tnxid': tnxid,
      'reason_code': reasonCode,
      'reason': reason,
      'is_pick_up': isPickUp ? 1 : 0,
      'penalties_amount': penaltiesAmount,
      'candidate_id': candidateId,
      'assignment_datetime': assignmentDatetime,
      'transfers': transfers,
      'has_utensils': hasUtensils ? 1 : 0,
      'is_preorder': isPreorder ? 1 : 0,
      'is_voucher': isVoucher ? 1 : 0,
      'promo_type': promoType,
      'area_id': areaId,
      'delivery_date': deliveryDate,
      'payment_method': paymentMethod,
      'is_paid': isPaid,
      'order_items': orderItems.map((e) => e.toJson()).toList(),
      'merchant': merchant.toJson(),
    };
  }
}
