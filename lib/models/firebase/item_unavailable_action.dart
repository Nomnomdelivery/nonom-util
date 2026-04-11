import 'package:flutter/material.dart';

class ItemUnavailableAction {
  final int id;
  final String string;
  const ItemUnavailableAction({required this.id, required this.string});

  factory ItemUnavailableAction.fromId(int id) {
    switch (id) {
      case 0:
        return const ItemUnavailableAction(
          id: 0,
          string: "Remove it from my order",
        );
      case 1:
        return const ItemUnavailableAction(
          id: 1,
          string: "Cancel entire order",
        );
      case 2:
        return const ItemUnavailableAction(id: 2, string: "Replace item");
      default:
        return const ItemUnavailableAction(
          id: 0,
          string: "Remove it from my order",
        );
    }
  }

  factory ItemUnavailableAction.fromJson(Map<String, dynamic> json, int id) {
    try {
      return ItemUnavailableAction(id: id, string: json['string'] as String);
    } catch (e) {
      debugPrint("Error parsing ItemUnavailableAction from JSON: $e $id");
      return ItemUnavailableAction.fromId(0);
    }
  }

  Map<String, dynamic> toJson() => {"id": id, "string": string};

  @override
  String toString() => string;

  static List<ItemUnavailableAction> getAllActions() => [
    const ItemUnavailableAction(id: 0, string: "Remove it from my order"),
    const ItemUnavailableAction(id: 1, string: "Cancel entire order"),
    const ItemUnavailableAction(id: 2, string: "Replace item"),
  ];
}
