import 'package:nomnom_util/models/menu/menu_item.dart';

class TypedMenuItem {
  final MenuItem menu;
  final int id;
  final int menuItemId;
  final int menuId;
  final String type;
  const TypedMenuItem({
    required this.id,
    required this.menu,
    required this.menuId,
    required this.menuItemId,
    required this.type,
  });
  factory TypedMenuItem.fromJson(Map<String, dynamic> json) {
    return TypedMenuItem(
      id: json['id'],
      menuItemId: json['menu_item_id'],
      menuId: json['menu_id'],
      type: json['type'],
      menu: MenuItem.fromJson(json['menu']),
    );
  }
}
