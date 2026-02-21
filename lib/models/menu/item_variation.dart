import 'package:nomnom_util/extensions/string_capitalize.dart';
import 'package:nomnom_util/models/menu_variation.dart';

class ItemVariation {
  final int id;
  final String name;
  final List<MenuVariation> variations;
  const ItemVariation({
    required this.id,
    required this.name,
    required this.variations,
  });

  factory ItemVariation.fromJson(Map<String, dynamic> json) {
    final List l = json['menu_variations'] ?? [];
    return ItemVariation(
      id: json['id'],
      name: json['name'].toString().capitalizeWords(),
      variations: l.map((e) => MenuVariation.fromJson(e)).toList(),
    );
  }
}
