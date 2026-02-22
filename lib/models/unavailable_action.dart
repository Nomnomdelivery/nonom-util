class UnavailableAction {
  final int id;
  final String string;
  const UnavailableAction({required this.id, required this.string});

  factory UnavailableAction.fromJson(Map<String, dynamic> json) =>
      UnavailableAction(id: json['id'], string: json['string']);
}
