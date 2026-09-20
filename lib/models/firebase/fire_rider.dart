import 'package:nomnom_util/models/firebase/fire_rating.dart';

class FireRider {
  final String fullname, photoUrl;
  final int id;
  final String? phoneNumber;
  final FireRating? rate;
  const FireRider({
    required this.fullname,
    required this.id,
    required this.photoUrl,
    required this.phoneNumber,
    required this.rate,
  });

  factory FireRider.fromJson(Map<String, dynamic> json) => FireRider(
    rate: json['rate'] == null ? null : FireRating.fromJson(json['rate']),
    fullname: json['fullname'],
    phoneNumber: json['phone_number'],
    id: json['id'],
    // photo_url can be null in Firestore (e.g. rider hasn't set one); fall back to empty
    // string to avoid a null-cast crash that used to break the whole order stream.
    photoUrl: json['photo_url'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "rate": rate?.toJson(),
    "id": id,
    "photo_url": photoUrl,
    "fullname": fullname,
    "phone_number": phoneNumber,
  };
}
