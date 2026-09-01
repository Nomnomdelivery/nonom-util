class CurrentSchedule {
  final int id;
  final int merchantId;
  final String startTime;
  final String endTime;
  final int day;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool enable;
  final String label;
  final int order;
  final String text;
  final String opening;
  final String start;
  final String end;
  final bool isOpen;

  CurrentSchedule({
    required this.id,
    required this.merchantId,
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.createdAt,
    required this.updatedAt,
    required this.enable,
    required this.label,
    required this.order,
    required this.text,
    required this.opening,
    required this.start,
    required this.end,
    required this.isOpen,
  });

  factory CurrentSchedule.fromJson(Map<String, dynamic> json) {
    return CurrentSchedule(
      id: json['id'],
      merchantId: json['merchant_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      day: json['day'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      enable: json['enable'] == 1,
      label: json['label'],
      order: json['order'],
      text: json['text'] ?? '',
      opening: json['opening'],
      start: json['start'],
      end: json['end'],
      isOpen: json['is_open'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'merchant_id': merchantId,
    'start_time': startTime,
    'end_time': endTime,
    'day': day,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'enable': enable ? 1 : 0,
    'label': label,
    'order': order,
    'text': text,
    'opening': opening,
    'start': start,
    'end': end,
    'is_open': isOpen,
  };
}
