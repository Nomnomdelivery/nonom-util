import 'package:nomnom_util/models/user_model.dart';

class CustomerFeedback {
  final int id, rate, code;
  final DateTime updatedAt, createdAt;
  final UserModel customer;
  final String feedback;
  const CustomerFeedback({
    required this.code,
    required this.createdAt,
    required this.customer,
    required this.id,
    required this.rate,
    required this.updatedAt,
    required this.feedback,
  });

  factory CustomerFeedback.fromJson(Map<String, dynamic> json) =>
      CustomerFeedback(
        code: json['code'] ?? 0,
        feedback: json['feedback'] ?? "",
        createdAt: DateTime.parse(json['created_at']),
        customer: UserModel.fromJson(json['customer']),
        id: json['id'],
        rate: json['rate'],
        updatedAt: DateTime.parse(json['updated_at']),
      );
  Map<String, dynamic> toJson() => {
    "id": id,
    "rate": rate,
    "code": code,
    "updated_at": updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "customer": customer.toJson(),
  };

  @override
  String toString() => "${toJson()}";
}
