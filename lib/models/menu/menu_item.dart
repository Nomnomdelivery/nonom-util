import 'package:nomnom_util/models/menu/item_variation.dart';

class MenuItem {
  final int id;
  final String? mainCat;
  final String? subCat;
  final String pid;
  final String name;
  final double rate;
  final int type;
  final String unit;
  final double price;
  final int sizeId;
  final int isAmount;
  final String photoUrl;
  final double basePrice;
  final DateTime createdAt;
  final int isPercent;
  bool isPopular;
  final int orderType;
  final DateTime updatedAt;
  final int categoryId;
  final String description;
  final int merchantId;
  final String typeConfig;
  bool isAvailable;
  final int extraRequired;
  final int quantityLimit;
  final int subCategoryId;
  final int preparationDays;
  final int preparationTime;
  final int classificationId;
  final ItemVariation? itemVariation;
  MenuItem({
    required this.subCat,
    required this.mainCat,
    required this.itemVariation,
    required this.id,
    required this.pid,
    required this.name,
    required this.rate,
    required this.type,
    required this.unit,
    required this.price,
    required this.sizeId,
    required this.isAmount,
    required this.photoUrl,
    required this.basePrice,
    required this.createdAt,
    required this.isPercent,
    required this.isPopular,
    required this.orderType,
    required this.updatedAt,
    required this.categoryId,
    required this.description,
    required this.merchantId,
    required this.typeConfig,
    required this.isAvailable,
    required this.extraRequired,
    required this.quantityLimit,
    required this.subCategoryId,
    required this.preparationDays,
    required this.preparationTime,
    required this.classificationId,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemVariation: json['item_variation'] == null
          ? null
          : ItemVariation.fromJson(json['item_variation']),
      mainCat: json['main_category'],
      subCat: json['sub_category'],
      id: json['id'],
      pid: json['pid'],
      name: json['name'],
      rate: double.parse(json['rate'].toString()),
      type: json['type'],
      unit: json["unit"] ?? "",
      price: double.parse(json['price'].toString()) == 0
          ? double.parse(json['base_price'].toString())
          : double.parse(json['price'].toString()),
      sizeId: json['size_id'],
      isAmount: json['is_amount'],
      photoUrl:
          json['photo_url'] ??
          "https://back.nomnomdelivery.com/images/no_image_placeholder.jpg",
      basePrice: double.parse(json['base_price'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      isPercent: json['is_percent'],
      isPopular: json['is_popular'] == 1,
      orderType: json['order_type'],
      updatedAt: DateTime.parse(json['updated_at']),
      categoryId: json['category_id'],
      description: json['description'] ?? "",
      merchantId: json['merchant_id'],
      typeConfig: json['type_config'],
      isAvailable: json['is_available'] == 1,
      extraRequired: json['extra_required'],
      quantityLimit: json['quantity_limit'],
      subCategoryId: json['sub_category_id'] ?? 0,
      preparationDays: json['preparation_days'],
      preparationTime: json['preparation_time'],
      classificationId: json['classification_id'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pid': pid,
      'name': name,
      'rate': rate,
      'type': type,
      'unit': unit,
      'price': price,
      'size_id': sizeId,
      'is_amount': isAmount,
      'photo_url': photoUrl,
      'base_price': basePrice,
      'created_at': createdAt.toIso8601String(),
      'is_percent': isPercent,
      'is_popular': isPopular ? 1 : 0,
      'order_type': orderType,
      'updated_at': updatedAt.toIso8601String(),
      'category_id': categoryId,
      'description': description,
      'merchant_id': merchantId,
      'type_config': typeConfig,
      'is_available': isAvailable ? 1 : 0,
      'extra_required': extraRequired,
      'quantity_limit': quantityLimit,
      'sub_category_id': subCategoryId,
      'preparation_days': preparationDays,
      'preparation_time': preparationTime,
      'classification_id': classificationId,
    };
  }
}
