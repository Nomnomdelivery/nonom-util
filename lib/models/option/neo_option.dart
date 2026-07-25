import 'package:nomnom_util/models/option/sub_option.dart';

class NeoOption {
  final int id;
  final int optionCategoryId;
  final String name;
  final String image;
  final String? groupName;
  final double price;
  final int availability;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SubOption> subOptions;

  NeoOption({
    required this.id,
    required this.optionCategoryId,
    required this.name,
    required this.image,
    required this.groupName,
    required this.price,
    required this.availability,
    required this.createdAt,
    required this.updatedAt,
    required this.subOptions,
  });

  NeoOption copyWith({
    int? id,
    int? optionCategoryId,
    String? name,
    String? image,
    String? groupName,
    double? price,
    int? availability,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SubOption>? subOptions,
  }) {
    return NeoOption(
      id: id ?? this.id,
      optionCategoryId: optionCategoryId ?? this.optionCategoryId,
      name: name ?? this.name,
      image: image ?? this.image,
      groupName: groupName ?? this.groupName,
      price: price ?? this.price,
      availability: availability ?? this.availability,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subOptions: subOptions ?? this.subOptions,
    );
  }

  factory NeoOption.fromJson(Map<String, dynamic> json) {
    final List subOptions = json['sub_options'] ?? [];

    return NeoOption(
      price: double.tryParse(json['price'].toString()) ?? 0,
      groupName: json['group_name'],
      id: json['id'],
      optionCategoryId: json['option_category_id'],
      name: json['name'],
      image: json['photo_url'].toString(),
      availability: int.parse(json['availability'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      subOptions: subOptions.map((s) => SubOption.fromJson(s)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'option_category_id': optionCategoryId,
      'name': name,
      'image': image,
      'availability': availability,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sub_options': subOptions
          .map((subNeoOption) => subNeoOption.toJson())
          .toList(),
    };
  }

  Map<String, dynamic> toJsonPayload() {
    return {
      'name': name,
      'image': image,
      'availability': availability,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sub_options': subOptions
          .map((subNeoOption) => subNeoOption.toJsonPayload())
          .toList(),
    };
  }

  Map<String, dynamic> toUpdateable() {
    return {
      "is_new": false,
      'name': name,
      'image': image,
      'is_available': availability == 1,
      'sub_opt': subOptions
          .map((subNeoOption) => subNeoOption.toUpdateable())
          .toList(),
    };
  }
}
