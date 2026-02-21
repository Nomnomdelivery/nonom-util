class RawCategory {
  final int id;
  final String name;

  RawCategory({required this.id, required this.name});

  factory RawCategory.fromJson(Map<String, dynamic> json) {
    return RawCategory(id: json['id'], name: json['name']);
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
