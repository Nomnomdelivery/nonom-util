import 'package:nomnom_util/models/option/neo_option.dart';

class OptionCategory {
  final int id;
  final int merchantId;
  final String name;
  final DateTime createdAt;
  final int requiredOptionCount;
  final DateTime updatedAt;
  final List<NeoOption> options;

  OptionCategory({
    required this.id,
    required this.merchantId,
    required this.requiredOptionCount,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.options,
  });

  factory OptionCategory.fromJson(Map<String, dynamic> json) {
    return OptionCategory(
      requiredOptionCount: json['required_options_count'] == null
          ? 1
          : int.parse(json['required_options_count'].toString()),
      id: json['id'],
      merchantId: json['merchant_id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      options: (json['options'] as List<dynamic>)
          .map((option) => NeoOption.fromJson(option))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'required_options_count': requiredOptionCount,
      'id': id,
      'merchant_id': merchantId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'options': options.map((option) => option.toJson()).toList(),
    };
  }

  List<Map<String, dynamic>> optionToData() {
    final List<Map<String, dynamic>> data = options
        .map((e) => e.toUpdateable())
        .toList();
    return data;
  }
}
