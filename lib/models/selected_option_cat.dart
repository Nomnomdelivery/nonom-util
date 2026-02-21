import 'dart:convert';
import 'package:nomnom_util/models/selected_option.dart';

class SelectedOptionCat {
  final int id;
  final String name;
  final List<SelectedOption> options;

  const SelectedOptionCat({
    required this.name,
    required this.id,
    required this.options,
  });

  SelectedOptionCat copyWith({
    int? id,
    String? name,
    List<SelectedOption>? options,
  }) {
    return SelectedOptionCat(
      id: id ?? this.id,
      name: name ?? this.name,
      options: options ?? this.options,
    );
  }

  @override
  String toString() {
    return '${toJson()}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectedOptionCat && _listsAreEqual(other.options);
  }

  @override
  int get hashCode => options.hashCode;

  // Helper function to compare two lists
  bool _listsAreEqual(List<SelectedOption> otherOptions) {
    if (options.length != otherOptions.length) return false;
    for (int i = 0; i < options.length; i++) {
      if (options[i] != otherOptions[i]) return false;
    }
    return true;
  }

  factory SelectedOptionCat.fromJson(Map<String, dynamic> json) {
    final List options = json['options'] ?? [];
    return SelectedOptionCat(
      id: json['id'],
      name: json['name'],
      options: options.map((e) => SelectedOption.fromJson(e)).toList(),
      // option: json['option'] == null
      //     ? null
      //     : SelectedOption.fromJson(json['option']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }

  String jsonStringify() => jsonEncode(toJson());
}
