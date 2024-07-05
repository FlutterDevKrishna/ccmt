// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  int id;
  String name;
  String email;
  String mobile;
  String password;
  int status;
  int leader;
  int tl;
  int loginStatus;
  dynamic loginTime;
  DateTime createdAt;
  DateTime updatedAt;

  LoginModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.status,
    required this.leader,
    required this.tl,
    required this.loginStatus,
    required this.loginTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    password: json["password"],
    status: json["status"],
    leader: json["leader"],
    tl: json["tl"],
    loginStatus: json["login_status"],
    loginTime: json["login_time"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
    "password": password,
    "status": status,
    "leader": leader,
    "tl": tl,
    "login_status": loginStatus,
    "login_time": loginTime,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
