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
    id: json['id'],
    isActive: json['is_active'] == 1,
    name: json['name'],
    photoUrl: json['photo_url'],
    price: double.parse(json['price'].toString()),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "is_active": isActive,
    "price": price,
    "photo_url": photoUrl,
  };

  @override
  String toString() => "${toJson()}";
}
