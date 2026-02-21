import 'package:nomnom_util/models/menu/menu_item.dart';

class Classification {
  final int id;
  final String name;

  Classification({required this.id, required this.name});

  factory Classification.fromJson(Map<String, dynamic> json) {
    return Classification(id: json['id'], name: json['name']);
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class Category {
  final int id;
  final String name;
  final MenuItem menuItem;

  Category({required this.id, required this.name, required this.menuItem});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      menuItem: MenuItem.fromJson(json['menu_item']),
    );
  }
}
