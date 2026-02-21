class FirePayment {
  final bool isPaid;
  final String paymentMethod;
  final String paymentType;
  final String paymentChannel;
  final String paymentId;
  final String externalId;
  final DateTime paidAt;
  final DateTime created;
  final DateTime updated;

  const FirePayment({
    required this.isPaid,
    required this.paymentType,
    required this.paymentMethod,
    required this.paymentChannel,
    required this.paymentId,
    required this.updated,
    required this.created,
    required this.paidAt,
    required this.externalId,
  });

  factory FirePayment.fromJson(Map<String, dynamic> json) => FirePayment(
    isPaid: json['is_paid'] ?? false,
    paymentType: json['payment_type'] ?? "",
    paymentMethod: json['payment_method'] ?? "",
    paymentChannel: json['payment_channel'] ?? "",
    paymentId: json['payment_id'] ?? "",
    created: _parseDateTime(json['created']),
    updated: _parseDateTime(json['updated']),
    paidAt: _parseDateTime(json['paid_at']),
    externalId: json['external_id'] ?? "",
  );

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    // Assume it's a Timestamp from Firestore
    return value.toDate() ?? DateTime.now();
  }
}
