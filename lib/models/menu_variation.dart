class MenuVariation {
  final int id;
  final String name;
  final double price;
  final String photoUrl;
  final bool isActive;
  const MenuVariation({
    required this.id,
    required this.isActive,
    required this.name,
    required this.photoUrl,
    required this.price,
  });

  factory MenuVariation.fromJson(Map<String, dynamic> json) => MenuVariation(
    id: json['id'] ?? 0,
    isActive: json['is_active'] == 1,
    name: json['name'] ?? "",
    photoUrl: json['photo_url'] ?? "",
    price: double.parse((json['price'] ?? 0).toString()),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "is_active": isActive,
    "price": price,
    "photo_url": photoUrl,
  };

  // Used to apply a refreshed price onto an existing variant without losing its other fields.
  MenuVariation copyWith({
    int? id,
    String? name,
    double? price,
    String? photoUrl,
    bool? isActive,
  }) => MenuVariation(
    id: id ?? this.id,
    name: name ?? this.name,
    price: price ?? this.price,
    photoUrl: photoUrl ?? this.photoUrl,
    isActive: isActive ?? this.isActive,
  );

  @override
  String toString() => "${toJson()}";
}
