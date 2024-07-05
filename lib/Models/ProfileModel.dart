// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  String name;
  String email;
  String mobile;
  int loginStatus;
  DateTime created;
  DateTime loginTime;

  ProfileModel({
    required this.name,
    required this.email,
    required this.mobile,
    required this.loginStatus,
    required this.created,
    required this.loginTime,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    loginStatus: json["login_status"],
    created: DateTime.parse(json["created"]),
    loginTime: DateTime.parse(json["login_time"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "mobile": mobile,
    "login_status": loginStatus,
    "created": created.toIso8601String(),
    "login_time": loginTime.toIso8601String(),
  };
}
