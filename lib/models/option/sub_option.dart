class SubOption {
  final int id;
  final int mainOptionId;
  final String name;
  final double price;
  final int availability;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubOption({
    required this.id,
    required this.mainOptionId,
    required this.name,
    required this.price,
    required this.availability,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubOption.fromJson(Map<String, dynamic> json) {
    return SubOption(
      id: json['id'],
      mainOptionId: json['main_option_id'],
      name: json['name'],
      price:
          double.tryParse(json['base_price'].toString()) ??
          double.tryParse(json['price'].toString()) ??
          0,
      availability: json['availability'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'main_option_id': mainOptionId,
      'name': name,
      'price': price,
      'availability': availability,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonPayload() {
    return {
      'name': name,
      'price': price,
      'availability': availability,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateable() {
    return {
      'name': name,
      'additional_price': price,
      'is_available': availability == 1,
      "is_new": false,
    };
  }

  SubOption copyWith({
    int? mainOptionId,
    String? name,
    double? price,
    int? availability,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubOption(
      id: id,
      mainOptionId: mainOptionId ?? this.mainOptionId,
      name: name ?? this.name,
      price: price ?? this.price,
      availability: availability ?? this.availability,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
