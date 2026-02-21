import 'package:nomnom_util/models/categorized_menu.dart';
import 'package:nomnom_util/models/menu/menu_item.dart';

class MenuResult {
  final List<MenuItem> popularItems;
  final List<CategorizedMenu> categorizedMenu;
  MenuResult({
    List<MenuItem>? popularItems,
    List<CategorizedMenu>? categorizedMenu,
  }) : popularItems = popularItems ?? [],
       categorizedMenu = categorizedMenu ?? [];
  factory MenuResult.fromJson(Map<String, dynamic> json) {
    return MenuResult(
      popularItems: (json['popular_items'] as List)
          .map((item) => MenuItem.fromJson(item))
          .toList(),
      categorizedMenu: json['group_data'].isEmpty
          ? []
          : (json['group_data'] as Map<String, dynamic>)
                .map((categoryName, itemsList) {
                  return MapEntry(
                    categoryName == '' ? "Uncategorized" : categoryName,
                    CategorizedMenu.fromData(
                      categoryName,
                      itemsList as List<dynamic>,
                    ),
                  );
                })
                .values
                .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'popular_items': popularItems.map((item) => item.toJson()).toList(),
      'categorized_menu': categorizedMenu,
    };
  }

  @override
  String toString() => "${toJson()}";
}
