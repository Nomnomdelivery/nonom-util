import 'package:nomnom_util/models/menu/menu_item.dart';

class CategorizedMenu {
  final String name;
  final DateTime createdAt;
  final List<MenuItem> items;

  const CategorizedMenu({
    required this.name,
    required this.items,
    required this.createdAt,
  });
  factory CategorizedMenu.fromData(
    String categoryName,
    List<dynamic> itemsList,
  ) {
    // Extract the category name from the map keys
    final items = itemsList.map((item) => MenuItem.fromJson(item)).toList();
    return CategorizedMenu(
      createdAt: items.isNotEmpty
          ? items
                .map((item) => item.createdAt)
                .reduce((a, b) => a.isBefore(b) ? a : b)
          : DateTime.now(),
      name: categoryName,
      items: items,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'category_name': name,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() => '${toJson()}';
}
