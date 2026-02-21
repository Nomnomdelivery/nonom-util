import 'package:nomnom_util/models/order/order_model.dart';
import 'package:nomnom_util/models/rider_opinion.dart';

class QuotationModel {
  final int id;
  final int customerId;
  final int riderId;
  final int type;
  final double price;
  final int status;
  final String destination;
  final String pickupLocation;
  final String note;
  final String address;
  final String state;
  final String city;
  final String country;
  final String recipientFirstname;
  final String recipientMiddlename;
  final String recipientLastname;
  final String createdAt;
  final String updatedAt;
  final String? paymentReference;
  final String? tnxid;
  final String landmark;
  final String mobileNumber;
  final String barangay;
  final String street;
  final double points;
  final bool isForFriend;
  final List<RiderOpinion> riderPredictions;
  final double subtotal;
  final double vat;
  final double vatRate;
  final double discount;
  final double total;
  final double deliveryFee;
  final double merchantFee;
  final String reference;
  final int number;
  final String promoCode;
  final double paymentFee;
  final double penaltiesAmount;
  final OrderModel order;
  final bool? isPaid;
  final double? usedNomnomCoins;
  QuotationModel({
    required this.id,
    required this.customerId,
    required this.riderId,
    required this.type,
    required this.price,
    required this.status,
    required this.destination,
    required this.pickupLocation,
    required this.note,
    required this.address,
    required this.state,
    required this.city,
    required this.country,
    required this.recipientFirstname,
    required this.recipientMiddlename,
    required this.recipientLastname,
    required this.createdAt,
    required this.updatedAt,
    this.paymentReference,
    this.tnxid,
    required this.landmark,
    required this.mobileNumber,
    required this.barangay,
    required this.street,
    required this.points,
    required this.isForFriend,
    required this.riderPredictions,
    required this.subtotal,
    required this.vat,
    required this.vatRate,
    required this.discount,
    required this.total,
    required this.deliveryFee,
    required this.merchantFee,
    required this.reference,
    required this.number,
    required this.promoCode,
    required this.paymentFee,
    required this.penaltiesAmount,
    required this.order,
    this.isPaid,
    this.usedNomnomCoins,
  });
  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    return QuotationModel(
      id: json['id'],
      customerId: json['customer_id'],
      riderId: json['rider_id'],
      type: json['type'],
      price: (json['price'] as num).toDouble(),
      status: json['status'],
      destination: json['destination'],
      pickupLocation: json['pickup_location'],
      note: json['note'],
      address: json['address'],
      state: json['state'],
      city: json['city'],
      country: json['country'],
      recipientFirstname: json['recipient_firstname'],
      recipientMiddlename: json['recipient_middlename'],
      recipientLastname: json['recipient_lastname'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      paymentReference: json['payment_reference'],
      tnxid: json['tnxid'],
      landmark: json['landmark'],
      mobileNumber: json['mobile_number'],
      barangay: json['barangay'],
      street: json['street'],
      points: (json['points'] as num).toDouble(),
      isForFriend: json['is_for_friend'] == 1,
      riderPredictions: (json['rider_predictions'] as List<dynamic>)
          .map((e) => RiderOpinion.fromJson(e))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      vat: (json['vat'] as num).toDouble(),
      vatRate: (json['vat_rate'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      merchantFee: json['merchant_fee'] != null
          ? (json['merchant_fee'] is num
                ? (json['merchant_fee'] as num).toDouble()
                : double.tryParse(json['merchant_fee'].toString()) ?? 0.0)
          : 0.0,
      reference: json['reference'],
      number: json['number'],
      promoCode: json['promo_code'],
      paymentFee: (json['payment_fee'] as num).toDouble(),
      penaltiesAmount: (json['penalties_amount'] as num).toDouble(),
      order: OrderModel.fromJson(json['order']),
      isPaid: json['is_paid'] == null ? null : json['is_paid'] == 1,
      usedNomnomCoins: json['used_nomnom_coins'] != null
          ? (json['used_nomnom_coins'] is num
                ? (json['used_nomnom_coins'] as num).toDouble()
                : double.tryParse(json['used_nomnom_coins'].toString()) ?? 0.0)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'rider_id': riderId,
      'type': type,
      'price': price,
      'status': status,
      'destination': destination,
      'pickup_location': pickupLocation,
      'note': note,
      'address': address,
      'state': state,
      'city': city,
      'country': country,
      'recipient_firstname': recipientFirstname,
      'recipient_middlename': recipientMiddlename,
      'recipient_lastname': recipientLastname,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'payment_reference': paymentReference,
      'tnxid': tnxid,
      'landmark': landmark,
      'mobile_number': mobileNumber,
      'barangay': barangay,
      'street': street,
      'points': points,
      'is_for_friend': isForFriend ? 1 : 0,
      'rider_predictions': riderPredictions.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'vat': vat,
      'vat_rate': vatRate,
      'discount': discount,
      'total': total,
      'delivery_fee': deliveryFee,
      'merchant_fee': merchantFee,
      'reference': reference,
      'number': number,
      'promo_code': promoCode,
      'payment_fee': paymentFee,
      'penalties_amount': penaltiesAmount,
      'order': order.toJson(),
      'is_paid': isPaid,
      'used_nomnom_coins': usedNomnomCoins,
    };
  }
}
