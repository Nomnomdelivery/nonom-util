import 'dart:convert';
import 'package:nomnom_util/models/selected_sub_option.dart';

class SelectedOption {
  final int id;
  final String imageUrl, name;
  final SelectedSubOption? suboption;
  final double? price;
  const SelectedOption({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.suboption,
    required this.price,
  });

  SelectedOption copyWith({
    int? id,
    String? imageUrl,
    String? name,
    SelectedSubOption? suboption,
    double? price,
  }) {
    return SelectedOption(
      price: price ?? this.price,
      name: name ?? this.name,
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      suboption: suboption ?? this.suboption,
    );
  }

  @override
  String toString() {
    return '${toJson()}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectedOption &&
        other.id == id &&
        other.imageUrl == imageUrl &&
        other.name == name &&
        other.suboption == suboption &&
        other.price == price;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      imageUrl.hashCode ^
      name.hashCode ^
      suboption.hashCode ^
      price.hashCode;

  factory SelectedOption.fromJson(Map<String, dynamic> json) {
    return SelectedOption(
      name: json['name'],
      price: json['price'] == null
          ? null
          : double.tryParse(json['price'].toString()),
      id: json['id'],
      imageUrl: json['imageUrl'],
      suboption: json['suboption'] == null
          ? null
          : SelectedSubOption.fromJson(json['suboption']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'price': price,
      'imageUrl': imageUrl,
      'suboption': suboption?.toJson(),
    };
  }

  String encode() => jsonEncode({
    'name': name,
    'id': id,
    'price': price,
    'imageUrl': imageUrl,
    'suboption': suboption?.jsonEncoded(),
  });
}
