import 'package:nomnom_util/extensions/string_parser.dart';

class LocationModel {
  final int id;
  final String name;
  final List<int> mergedIds;
  const LocationModel({
    required this.name,
    required this.id,
    required this.mergedIds,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    mergedIds: json['merge_on'] == null
        ? [int.parse(json['id'].toString())]
        : json['merge_on']
              .toString()
              .replaceAll(RegExp(r'[\[\]]'), '')
              .split(',')
              .map((e) => int.parse(e))
              .toList(),
    name: json['name'].toString().pascalToNormal(),
    id: int.parse(json['id'].toString()),
  );

  Map<String, dynamic> toJson() => {"id": id, "name": name};

  @override
  String toString() => "${toJson()}";
}
