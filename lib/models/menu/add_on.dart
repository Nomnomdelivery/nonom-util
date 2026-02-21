import 'package:nomnom_util/models/menu/menu_item.dart';

class Addon {
  final MenuItem? product;
  final int quantity;
  final double totalPrice;
  final int menuItemId;

  Addon({
    this.product,
    required this.quantity,
    required this.totalPrice,
    required this.menuItemId,
  });

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      product: json['product'] == null
          ? null
          : MenuItem.fromJson(json['product']),
      quantity: json['quantity'],
      totalPrice: double.parse(json['total_price'].toString()),
      menuItemId: json['menu_item_id'],
    );
  }
}
