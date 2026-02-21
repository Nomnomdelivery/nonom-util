import 'dart:convert';

class SelectedSubOption {
  final int id;
  final double price;
  final String name;

  const SelectedSubOption({
    required this.id,
    required this.name,
    required this.price,
  });

  SelectedSubOption copyWith({int? id, double? price, String? name}) {
    return SelectedSubOption(
      id: id ?? this.id,
      price: price ?? this.price,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return 'SelectedSubOption(id: $id, price: $price, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectedSubOption &&
        other.id == id &&
        other.name == name &&
        other.price == price;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ price.hashCode;

  factory SelectedSubOption.fromJson(Map<String, dynamic> json) {
    return SelectedSubOption(
      id: json['id'],
      price:
          double.tryParse(json['base_price'].toString()) ??
          double.tryParse(json['price'].toString()) ??
          0,
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'price': price, 'name': name};
  }

  String jsonEncoded() => jsonEncode(toJson());
}
