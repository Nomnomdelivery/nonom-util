import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:nomnom_util/models/menu_variation.dart';
import 'package:nomnom_util/models/order_type.dart';
import 'package:nomnom_util/models/selected_option.dart';
import 'package:nomnom_util/models/selected_option_cat.dart';

class CartItem {
  final int menuId, cartID, quantityLimit, prepTime, prepDay;
  bool isSelected;
  int quantity;
  final double rawPrice;
  final double subtotal;
  final OrderType orderType;
  final String instruction;
  final bool isAvailable;
  final String menuName, photoUrl, description;
  final MenuVariation? selectedVariant;
  final List<SelectedOptionCat> options;
  final bool isReplaced;
  final String refCode;

  CartItem({
    required this.refCode,
    required this.cartID,
    required this.isSelected,
    required this.prepDay,
    required this.selectedVariant,
    required this.menuId,
    required this.menuName,
    required this.prepTime,
    required this.photoUrl,
    required this.quantity,
    required this.quantityLimit,
    required this.subtotal,
    required this.orderType,
    required this.instruction,
    required this.rawPrice,
    required this.isAvailable,
    required this.description,
    required this.options,
    this.isReplaced = false,
  });

  // cart from order data
  factory CartItem.fromFirestore(Map<String, dynamic> json) {
    final List options = json['option'] ?? [];
    return CartItem(
      prepDay: json['prep_day'] ?? 0,
      selectedVariant: json['selected_variant'] == null
          ? null
          : MenuVariation.fromJson(json['selected_variant']),
      prepTime: json['prep_time'] == null
          ? 0
          : int.parse(json['prep_time'].toString()),
      options: options.map((e) => SelectedOptionCat.fromJson(e)).toList(),
      instruction: json['special_instructions'] ?? "",
      rawPrice: double.tryParse(json['price'].toString()) ?? 0,
      cartID: json['cartID'],
      orderType:
          json['order_type'] is String || json['order_type'].toString().isEmpty
          ? OrderType.none()
          : OrderType.fromJson(json['order_type']),
      isSelected: false,
      menuId: json['menuId'],
      menuName: json['menuName'],
      photoUrl: json['photoUrl'] ?? "",
      quantity: json['quantity'],
      quantityLimit:
          int.tryParse(json['quantity_limit']?.toString() ?? '0') ?? 0,
      isAvailable: json['is_available'] == 1,
      subtotal: double.parse(json['subtotal'].toString()),
      description: '',
      isReplaced: json['replaced_by'] != null ? true : false,
      refCode: json['cart_item_ref_code'] ?? "",
    );
  }

  factory CartItem.fromFirebase(
    Map<String, dynamic> json,
    Map<String, dynamic> menuItemData,
  ) {
    final List options = json['options'] ?? [];
    json.remove("type_config");

    final menuItem = menuItemData;
    return CartItem(
      prepDay: menuItem['preparation_days'] ?? 0,
      selectedVariant: json['variation'] == null
          ? json['selected_variant'] == null
                ? null
                : MenuVariation.fromJson(json['selected_variant'])
          : MenuVariation.fromJson(json['variation']),
      prepTime: json['preparation_time'] == null
          ? 0
          : int.parse(json['preparation_time'].toString()),
      options: options.map((e) => SelectedOptionCat.fromJson(e)).toList(),
      instruction: json['special_instructions'] ?? "",
      rawPrice: double.tryParse(menuItem['price'].toString()) ?? 0,
      cartID: json['id'],
      orderType:
          json['order_type'] is String || json['order_type'].toString().isEmpty
          ? OrderType.none()
          : OrderType.fromJson(json['order_type']),
      isSelected: false,
      menuId: int.parse(json['menu_item_id'].toString()),
      description: json['description'],
      menuName: json['name'],
      photoUrl: json['photo_url'] ?? "",
      quantity: int.parse(json['quantity'].toString()),
      quantityLimit:
          int.tryParse(menuItemData['quantity_limit']?.toString() ?? '0') ?? 0,
      isAvailable: json['is_available'] == 1,
      subtotal: double.parse(json['price'].toString()),
      refCode: json["cart_item_ref_code"] ?? "",
    );
  }

  @override
  String toString() => "${toJson()}";
  Map<String, dynamic> toJson() {
    return {
      'prep_day': prepDay,
      'prep_time': prepTime,
      'cartID': cartID,
      'isSelected': isSelected,
      'menuId': menuId,
      'menuName': menuName,
      'photoUrl': photoUrl,
      'quantity': quantity,
      'quantityLimit': quantityLimit,
      'subtotal': subtotal,
      'cart_item_ref_code': generateCode(),
      'selected_variant': selectedVariant?.toJson(),
      'order_type': orderType.toJson(),
      'is_available': isAvailable ? 1 : 0,
      'price': rawPrice,
      "option": options.map((e) => e.toJson()).toList(),
      "special_instructions": instruction,
    };
  }

  double calculateSubtotal(double markUpRate) {
    final mainPrice = ((selectedVariant?.price ?? rawPrice) * (1 + markUpRate))
        .ceilToDouble();
    double optPrice = 0;
    for (SelectedOptionCat cat in options) {
      if (cat.options.isNotEmpty) {
        for (SelectedOption opt in cat.options) {
          optPrice +=
              ((opt.suboption?.price ?? opt.price ?? 0) * (1 + markUpRate))
                  .ceilToDouble();
        }
      }
    }
    return (mainPrice + optPrice) * quantity;
  }

  String generateCode() {
    final String dataString =
        "$menuId-${DateTime.now().microsecondsSinceEpoch}";
    final digest = md5.convert(utf8.encode(dataString));
    return digest.toString();
  }
}
