import 'package:nomnom_util/models/menu/classification.dart';
import 'package:nomnom_util/models/menu/raw_category.dart';

class OrderItem {
  final int id;
  final int orderId;
  final int menuItemId;
  final int sizeId;
  final String name;
  final int quantityLimit;
  final String? size;
  final Classification classification;
  final String description;
  final RawCategory category;
  final RawCategory subCategory;
  final bool isPopular;
  final bool isAvailable;
  final bool isAmount;
  final bool isPercent;
  final double price;
  final double rate;
  final double basePrice;
  final String unit;
  final int quantity;
  final String createdAt;
  final String updatedAt;
  final int orderTypeValue;
  final double amount;
  final String specialInstructions;
  final List<dynamic> addons;
  final int merchantId;
  final int customerId;
  final String merchantName;
  final int cartId;
  final int preparationTime;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.sizeId,
    required this.name,
    required this.quantityLimit,
    this.size,
    required this.classification,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.isPopular,
    required this.isAvailable,
    required this.isAmount,
    required this.isPercent,
    required this.price,
    required this.rate,
    required this.basePrice,
    required this.unit,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.orderTypeValue,
    required this.amount,
    required this.specialInstructions,
    required this.addons,
    required this.merchantId,
    required this.customerId,
    required this.merchantName,
    required this.cartId,
    required this.preparationTime,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      menuItemId: json['menu_item_id'],
      sizeId: json['size_id'],
      name: json['name'],
      quantityLimit: json['quantity_limit'],
      size: json['size'],
      classification: Classification.fromJson(json['classification']),
      description: json['description'],
      category: json['category'].isEmpty
          ? RawCategory(id: 0, name: "uncategorized")
          : RawCategory.fromJson(json['category']),
      subCategory: json['sub_category'].isEmpty
          ? RawCategory(id: 0, name: "uncategorized")
          : RawCategory.fromJson(json['sub_category']),
      isPopular: json['is_popular'] == 1,
      isAvailable: json['is_available'] == 1,
      isAmount: json['is_amount'] == 1,
      isPercent: json['is_percent'] == 1,
      price: (json['price'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      basePrice: (json['base_price'] as num).toDouble(),
      unit: json['unit'] ?? "",
      quantity: json['quantity'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      orderTypeValue: json['order_type_value'],
      amount: (json['amount'] as num).toDouble(),
      specialInstructions: json['special_instructions'],
      addons: json['addons'] as List<dynamic>,
      merchantId: json['merchant_id'],
      customerId: json['customer_id'],
      merchantName: json['merchant_name'],
      cartId: json['cart_id'],
      preparationTime: json['preparation_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'size_id': sizeId,
      'name': name,
      'quantity_limit': quantityLimit,
      'size': size,
      'classification': classification.toJson(),
      'description': description,
      'category': category.toJson(),
      'sub_category': subCategory.toJson(),
      'is_popular': isPopular ? 1 : 0,
      'is_available': isAvailable ? 1 : 0,
      'is_amount': isAmount ? 1 : 0,
      'is_percent': isPercent ? 1 : 0,
      'price': price,
      'rate': rate,
      'base_price': basePrice,
      'unit': unit,
      'quantity': quantity,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'order_type_value': orderTypeValue,
      'amount': amount,
      'special_instructions': specialInstructions,
      'addons': addons,
      'merchant_id': merchantId,
      'customer_id': customerId,
      'merchant_name': merchantName,
      'cart_id': cartId,
      'preparation_time': preparationTime,
    };
  }
}
