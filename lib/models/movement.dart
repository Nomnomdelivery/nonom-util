class Movement {
  final int id;
  final int orderId;
  final String title;
  final int status;
  final int preparationTime;
  final DateTime? preparationTimeEnd;
  final int deliveryTime;
  final DateTime? deliveryTimeEnd;
  final int reasonCode;
  final String? reason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int waitingTime;
  final DateTime mainDeliveryDate;
  final DateTime? preparationDatetimeEnd;

  Movement({
    required this.id,
    required this.orderId,
    required this.title,
    required this.status,
    required this.preparationTime,
    this.preparationTimeEnd,
    required this.deliveryTime,
    this.deliveryTimeEnd,
    required this.reasonCode,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
    required this.waitingTime,
    required this.mainDeliveryDate,
    this.preparationDatetimeEnd,
  });

  factory Movement.fromJson(Map<String, dynamic> json) {
    return Movement(
      id: json['id'],
      orderId: json['order_id'],
      title: json['title'],
      status: json['status'],
      preparationTime: json['preparation_time'],
      preparationTimeEnd: json['preparation_time_end'] != null
          ? DateTime.parse(json['preparation_time_end'])
          : null,
      deliveryTime: json['delivery_time'],
      deliveryTimeEnd: json['delivery_time_end'] != null
          ? DateTime.parse(json['delivery_time_end'])
          : null,
      reasonCode: json['reason_code'],
      reason: json['reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      waitingTime: json['waiting_time'],
      mainDeliveryDate: DateTime.parse(json['main_delivery_date']),
      preparationDatetimeEnd: json['preparation_datetime_end'] != null
          ? DateTime.parse(json['preparation_datetime_end'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'title': title,
      'status': status,
      'preparation_time': preparationTime,
      'preparation_time_end': preparationTimeEnd?.toIso8601String(),
      'delivery_time': deliveryTime,
      'delivery_time_end': deliveryTimeEnd?.toIso8601String(),
      'reason_code': reasonCode,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'waiting_time': waitingTime,
      'main_delivery_date': mainDeliveryDate.toIso8601String(),
      'preparation_datetime_end': preparationDatetimeEnd?.toIso8601String(),
    };
  }
}
