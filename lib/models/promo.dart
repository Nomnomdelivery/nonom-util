import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_util/extensions/string_parser.dart';

class PromoModel {
  final int id;
  final int merchantId;
  final String title;
  final String promoCode;
  final String description;
  final int isAvailable;
  final int orderType;
  final int promoType;
  final DateTime startDate;
  final DateTime endDate;
  final String? barangay;
  final double minimumOrderAmount;
  final double price;
  final int costPoints;
  final String? photo;
  final String address;
  final String city;
  final GeoPoint? coordinates;
  final String country;
  final String endTime;
  final int indicatedCustomersCount;
  final int isAllCustomers;
  final int isAllItems;
  final int isBarangay;
  final String region;
  final String startTime;
  final String state;
  final double value;
  final int valueType;
  final String createdAt;
  final String updatedAt;
  final List<int> items;
  final List<dynamic>? locations;
  final String devices;
  final int isNews;
  final int isSpecificCustomers;
  final dynamic customers;
  final String photoUrl;
  final String startDateDisplay;
  final String endDateDisplay;
  final String periodDisplay;
  final String startTimeDisplay;
  final String endTimeDisplay;
  final String timeDisplay;
  final bool isUsed;

  PromoModel({
    required this.id,
    required this.merchantId,
    required this.title,
    required this.promoCode,
    required this.description,
    required this.isAvailable,
    required this.orderType,
    required this.promoType,
    required this.startDate,
    required this.endDate,
    this.barangay,
    required this.minimumOrderAmount,
    required this.price,
    required this.costPoints,
    this.photo,
    required this.address,
    required this.city,
    required this.coordinates,
    required this.country,
    required this.endTime,
    required this.indicatedCustomersCount,
    required this.isAllCustomers,
    required this.isAllItems,
    required this.isBarangay,
    required this.region,
    required this.startTime,
    required this.state,
    required this.value,
    required this.valueType,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.locations,
    required this.devices,
    required this.isNews,
    required this.isSpecificCustomers,
    this.customers,
    required this.photoUrl,
    required this.startDateDisplay,
    required this.endDateDisplay,
    required this.periodDisplay,
    required this.startTimeDisplay,
    required this.endTimeDisplay,
    required this.timeDisplay,
    required this.isUsed,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    final List itemVal = (json['items'] ?? []);
    final List<int> items = itemVal
        .where((e) => int.tryParse(e.toString()) != null)
        .map((e) => int.parse(e.toString()))
        .toList();

    DateTime? startDate;
    try {
      startDate = json['start_date'] != null
          ? DateTime.parse(json['start_date'].toString())
          : DateTime.now();
    } catch (e) {
      startDate = DateTime.now();
    }

    DateTime? endDate;
    try {
      endDate = json['end_date'] != null
          ? DateTime.parse(json['end_date'].toString())
          : DateTime.now();
    } catch (e) {
      endDate = DateTime.now();
    }

    return PromoModel(
      id: json['id'] as int? ?? 0,
      merchantId: json['merchant_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      promoCode: json['promo_code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isAvailable: json['is_available'] as int? ?? 0,
      orderType: json['order_type'] as int? ?? 0,
      promoType: json['promo_type'] as int? ?? 0,
      startDate: startDate,
      endDate: endDate,
      barangay: json['barangay'] as String?,
      minimumOrderAmount:
          double.tryParse(json['minimum_order_amount']?.toString() ?? '') ??
          0.0,
      price: json['base_price'] != null
          ? double.tryParse(json['base_price'].toString()) ?? 0.0
          : json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      costPoints: json['cost_points'] as int? ?? 0,
      photo: json['photo'] as String?,
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      coordinates:
          json['coordinates'] == null || json['coordinates'].toString().isEmpty
          ? GeoPoint(0, 0)
          : json['coordinates'].toString().toGeopoint(),
      country: json['country'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      indicatedCustomersCount: json['indicated_customers_count'] as int? ?? 0,
      isAllCustomers: json['is_all_customers'] as int? ?? 0,
      isAllItems: json['is_all_items'] as int? ?? 0,
      isBarangay: json['is_barangay'] as int? ?? 0,
      region: json['region'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      state: json['state'] as String? ?? '',
      value: double.tryParse(json['value']?.toString() ?? '') ?? 0.0,
      valueType: json['value_type'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      items: items,
      locations: json['locations'] as List<dynamic>?,
      devices: json['devices'] as String? ?? '',
      isNews: json['is_news'] as int? ?? 0,
      isSpecificCustomers: json['is_specific_customers'] as int? ?? 0,
      customers: json['customers'],
      photoUrl: json['photo_url'] as String? ?? '',
      startDateDisplay: json['start_date_display'] as String? ?? '',
      endDateDisplay: json['end_date_display'] as String? ?? '',
      periodDisplay: json['period_display'] as String? ?? '',
      startTimeDisplay: json['start_time_display'] as String? ?? '',
      endTimeDisplay: json['end_time_display'] as String? ?? '',
      timeDisplay: json['time_display'] as String? ?? '',
      isUsed: json['is_used'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'title': title,
      'promo_code': promoCode,
      'description': description,
      'is_available': isAvailable,
      'order_type': orderType,
      'promo_type': promoType,
      'start_date': startDate,
      'end_date': endDate,
      'barangay': barangay,
      'minimum_order_amount': minimumOrderAmount,
      'price': price,
      'cost_points': costPoints,
      'photo': photo,
      'address': address,
      'city': city,
      'coordinates': coordinates,
      'country': country,
      'end_time': endTime,
      'indicated_customers_count': indicatedCustomersCount,
      'is_all_customers': isAllCustomers,
      'is_all_items': isAllItems,
      'is_barangay': isBarangay,
      'region': region,
      'start_time': startTime,
      'state': state,
      'value': value,
      'value_type': valueType,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'items': items,
      'locations': locations,
      'devices': devices,
      'is_news': isNews,
      'is_specific_customers': isSpecificCustomers,
      'customers': customers,
      'photo_url': photoUrl,
      'start_date_display': startDateDisplay,
      'end_date_display': endDateDisplay,
      'period_display': periodDisplay,
      'start_time_display': startTimeDisplay,
      'end_time_display': endTimeDisplay,
      'time_display': timeDisplay,
    };
  }
}
