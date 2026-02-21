class OrderType {
  final int id;
  final String text;

  OrderType({required this.id, required this.text});

  factory OrderType.fromJson(Map<String, dynamic> json) {
    try {
      return OrderType(id: json['id'], text: json['text']);
    } catch (e) {
      return OrderType(id: 1, text: "Same Day");
    }
  }
  static OrderType none() => OrderType(id: 3, text: "Same Day/Pre-Order");

  Map<String, dynamic> toJson() => {"id": id, "name": text};

  @override
  String toString() => "${toJson()}";
}
