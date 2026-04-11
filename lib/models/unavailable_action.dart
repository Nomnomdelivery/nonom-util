class UnavailableAction {
  final int id;
  final String string;
  const UnavailableAction({required this.id, required this.string});

  factory UnavailableAction.fromJson(Map<String, dynamic> json) =>
      UnavailableAction(
        id: json['id'] is bool
            ? (json['id'] as bool ? 1 : 0)
            : (json['id'] as num?)?.toInt() ?? 0,
        string: json['string']?.toString() ?? "Remove it from my order",
      );
}
