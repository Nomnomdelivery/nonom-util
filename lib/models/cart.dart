import 'package:nomnom_util/models/cart_item.dart';
import 'package:nomnom_util/models/merchant/merchant_with_city.dart';

class CartModel {
  final MerchantWithCity merchant;
  final List<CartItem> items;
  final bool isVisible;

  const CartModel({
    required this.merchant,
    required this.items,
    required this.isVisible,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    isVisible: json['visible'],
    merchant: MerchantWithCity.fromJson(json),
    items: json['items'] == null
        ? []
        : (json['items'] as List)
              .map((e) => CartItem.fromFirebase(e, json['menu_item']))
              .toList(),
  );

  Map<String, dynamic> toJson() => {
    "merchant": merchant.toJson(),
    "items": items.map((e) => e.toJson()).toList(),
  };
  @override
  String toString() => "${toJson()}";
}

class RawMerchant {
  final int id;
  final String name;

  const RawMerchant({required this.id, required this.name});

  factory RawMerchant.fromJson(Map<String, dynamic> json) =>
      RawMerchant(id: json['merchant_id'], name: json['merchant_name']);

  Map<String, dynamic> toJson() => {"id": id, "name": name};

  @override
  String toString() => "${toJson()}";
}
