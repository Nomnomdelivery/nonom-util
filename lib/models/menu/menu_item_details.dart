import 'package:nomnom_util/models/menu/item_variation.dart';
import 'package:nomnom_util/models/menu/menu_item.dart';
import 'package:nomnom_util/models/menu/raw_category.dart';
import 'package:nomnom_util/models/merchant/merchant_with_city.dart';
import 'package:nomnom_util/models/option/option_category.dart';
import 'package:nomnom_util/models/type_menu_item.dart';

class MenuItemDetails extends MenuItem {
  final MerchantWithCity merchant;
  final RawCategory category;
  final List<TypedMenuItem> typedMenuItem; // for meal and bundle
  MenuItemDetails({
    required this.typedMenuItem,
    required super.subCat,
    required super.mainCat,
    required super.itemVariation,
    required super.id,
    required super.pid,
    required super.name,
    required super.rate,
    required super.type,
    required super.unit,
    required super.price,
    required super.sizeId,
    required super.isAmount,
    required super.photoUrl,
    required super.basePrice,
    required super.createdAt,
    required super.isPercent,
    required super.isPopular,
    required super.orderType,
    required super.updatedAt,
    required super.categoryId,
    required super.description,
    required super.merchantId,
    required super.typeConfig,
    required super.isAvailable,
    required super.extraRequired,
    required super.quantityLimit,
    required super.subCategoryId,
    required super.preparationDays,
    required super.preparationTime,
    required this.category,
    required this.merchant,
    required super.classificationId,
    required super.defaultPhotoUrl,
    required super.availableStartTime,
    required super.availableEndTime,
    required super.optionCategories,
  });

  factory MenuItemDetails.fromJson(Map<String, dynamic> json) {
    final List options = json['option_categories'] ?? [];
    final List typedItems = json['items'] ?? [];
    return MenuItemDetails(
      availableEndTime: json['available_end_time'],
      availableStartTime: json['available_start_time'],
      typedMenuItem: typedItems.map((e) => TypedMenuItem.fromJson(e)).toList(),
      itemVariation: json['item_variation'] == null
          ? null
          : ItemVariation.fromJson(json['item_variation']),
      optionCategories: options.map((e) => OptionCategory.fromJson(e)).toList(),
      mainCat: json['main_category'],
      subCat: json['sub_category'],
      id: json['id'],
      pid: json['pid'],
      name: json['name'],
      rate: double.parse(json['rate'].toString()),
      type: json['type'],
      unit: json['unit'] ?? "",
      price:
          double.tryParse(json['base_price'].toString()) ??
          double.tryParse(json['price'].toString()) ??
          0,
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
      category: json['category'] == null
          ? RawCategory(id: 0, name: "Uncategorized")
          : RawCategory.fromJson(json['category']),
      merchant: MerchantWithCity.fromJson(json['merchant']),
      defaultPhotoUrl:
          json['default_photo_url'] ??
          "https://back.nomnomdelivery.com/images/no_image_placeholder.jpg",
    );
  }
  Map<String, dynamic> toMap() {
    final body = toJson();
    body.addAll({'options': [], 'merchant': merchant.toJson()});
    return body;
  }

  @override
  String toString() => "${toJson()}";
}
