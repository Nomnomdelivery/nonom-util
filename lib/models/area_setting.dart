import 'package:nomnom_util/models/setting.dart';

class AreaSetting {
  final int id;
  final int areaId;
  final int serviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Setting setting;

  AreaSetting({
    required this.id,
    required this.areaId,
    required this.serviceId,
    required this.createdAt,
    required this.updatedAt,
    required this.setting,
  });

  factory AreaSetting.fromJson(Map<String, dynamic> json) {
    return AreaSetting(
      id: json['id'],
      areaId: json['area_id'],
      serviceId: json['service_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      setting: Setting.fromJson(json['setting']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'area_id': areaId,
      'service_id': serviceId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'setting': setting.toJson(),
    };
  }

  @override
  String toString() => "${toJson()}";
}
