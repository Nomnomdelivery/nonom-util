import 'package:nomnom_util/models/user_address.dart';

class UserModel {
  final int id;
  final String email;
  final DateTime? emailVerifiedAt;
  final String profilePic;
  final String firstname;
  final String? middlename;
  final String lastname;
  final DateTime? birthday;
  final String? phoneNumber;
  final String firebaseId;
  final String? gender;
  final int? adminId;
  final int? defaultAddress;
  final bool? isAccountValidated;
  final DateTime createdAt;
  final String referralCode;
  final DateTime updatedAt;
  final String? alternateNumber;
  final bool isBlocked;
  final DateTime? deletedAt;
  final double points;
  final String fullname;
  final bool? codAvailable;
  final List<UserAddress> addresses;

  UserModel({
    required this.id,
    required this.email,
    this.emailVerifiedAt,
    required this.profilePic,
    required this.referralCode,
    required this.firstname,
    this.middlename,
    required this.lastname,
    this.birthday,
    this.phoneNumber,
    required this.firebaseId,
    this.gender,
    this.adminId,
    this.defaultAddress,
    this.isAccountValidated,
    required this.createdAt,
    required this.updatedAt,
    this.alternateNumber,
    required this.isBlocked,
    this.deletedAt,
    this.codAvailable = false,
    required this.points,
    required this.fullname,
    required this.addresses,
  });

  // Factory method for creating a User from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final List addresses = json['addresses'] ?? [];
    return UserModel(
      referralCode: json['code'] ?? "",
      id: json['id'],
      addresses: addresses.map((e) => UserAddress.fromJson(e)).toList(),
      email: json['email'] ?? "",
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      profilePic: json['profile_pic'] == null
          ? json['avatar'] ??
                "https://back.nomnomdelivery.com/images/no_image_placeholder.jpg"
          : "https://customer.nomnomdelivery.com${json['profile_pic']}",
      firstname: json['firstname'] ?? "",
      middlename: json['middlename'],
      lastname: json['lastname'] ?? "",
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      phoneNumber: json['phone_number'],
      firebaseId: json['firebase_id'] ?? "",
      gender: json['gender'],
      adminId: json['admin_id'],
      defaultAddress: json['default_address'],
      isAccountValidated: json['is_account_validated'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      alternateNumber: json['alternate_number'],
      isBlocked: json['is_blocked'] == 1,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      points: double.parse(json['points'].toString()),
      fullname: json['fullname'] ?? "",
      codAvailable: json['orders_count'] != null
          ? json['orders_count'] > 0
          : false,
    );
  }
  UserModel copyWith({
    int? id,
    String? email,
    DateTime? emailVerifiedAt,
    String? avatar,
    String? profilePic,
    String? firstname,
    String? middlename,
    String? lastname,
    DateTime? birthday,
    String? phoneNumber,
    String? firebaseId,
    String? gender,
    int? adminId,
    int? defaultAddress,
    bool? isAccountValidated,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? alternateNumber,
    bool? isBlocked,
    DateTime? deletedAt,
    double? points,
    String? fullname,
    String? referralCode,
    List<UserAddress>? addresses,
  }) {
    return UserModel(
      referralCode: referralCode ?? this.referralCode,
      id: id ?? this.id,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      profilePic: profilePic ?? this.profilePic,
      firstname: firstname ?? this.firstname,
      middlename: middlename ?? this.middlename,
      lastname: lastname ?? this.lastname,
      birthday: birthday ?? this.birthday,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firebaseId: firebaseId ?? this.firebaseId,
      gender: gender ?? this.gender,
      adminId: adminId ?? this.adminId,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      isAccountValidated: isAccountValidated ?? this.isAccountValidated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      alternateNumber: alternateNumber ?? this.alternateNumber,
      isBlocked: isBlocked ?? this.isBlocked,
      deletedAt: deletedAt ?? this.deletedAt,
      points: points ?? this.points,
      fullname: fullname ?? this.fullname,
      addresses: addresses ?? this.addresses,
    );
  }

  // Method to convert a User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'email': email,
      "referral_code": referralCode,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'profile_pic': profilePic,
      'firstname': firstname,
      'middlename': middlename,
      'lastname': lastname,
      'birthday': birthday?.toIso8601String(),
      'phone_number': phoneNumber,
      'firebase_id': firebaseId,
      'gender': gender,
      'admin_id': adminId.toString(),
      'default_address': defaultAddress,
      'is_account_validated': (isAccountValidated ?? false).toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'alternate_number': alternateNumber,
      'is_blocked': (isBlocked ? 1 : 0).toString(),
      'deleted_at': deletedAt?.toIso8601String(),
      'points': points.toString(),
      'fullname': fullname,
    };
  }

  Map<String, dynamic> toJson2() {
    final Map<String, dynamic> body = {
      "referral_code": referralCode,
      'email': email,
      'firstname': firstname,
      'middlename': middlename ?? "",
      'lastname': lastname,
      'phone_number': phoneNumber ?? "",
      'gender': gender ?? "",
      'fullname': fullname,
    };
    if (birthday != null) {
      body.addAll({'birthday': birthday?.toIso8601String()});
    }
    return body;
  }

  @override
  String toString() => "${toJson()}";
}
