// To parse this JSON data, do
//
//     final totalDataModel = totalDataModelFromJson(jsonString);

import 'dart:convert';

List<TotalDataModel> totalDataModelFromJson(String str) => List<TotalDataModel>.from(json.decode(str).map((x) => TotalDataModel.fromJson(x)));

String totalDataModelToJson(List<TotalDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TotalDataModel {
  int id;
  String name;
  String mobile;
  String email;
  String? atnumber;
  String telecallerName;
  int telecallerId;
  int status;
  int amount;
  DateTime date;
  String? utr;
  dynamic image;
  int paymentStatus;
  String remarks;
  DateTime update;
  DateTime createdAt;
  DateTime updatedAt;

  TotalDataModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.atnumber,
    required this.telecallerName,
    required this.telecallerId,
    required this.status,
    required this.amount,
    required this.date,
    required this.utr,
    required this.image,
    required this.paymentStatus,
    required this.remarks,
    required this.update,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TotalDataModel.fromJson(Map<String, dynamic> json) => TotalDataModel(
    id: json["id"],
    name: json["name"],
    mobile: json["mobile"],
    email: json["email"],
    atnumber: json["atnumber"],
    telecallerName: json["telecaller_name"],
    telecallerId: json["telecaller_id"],
    status: json["status"],
    amount: json["amount"],
    date: DateTime.parse(json["date"]),
    utr: json["utr"],
    image: json["image"],
    paymentStatus: json["payment_status"],
    remarks: json["remarks"],
    update: DateTime.parse(json["update"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "mobile": mobile,
    "email": email,
    "atnumber": atnumber,
    "telecaller_name": telecallerName,
    "telecaller_id": telecallerId,
    "status": status,
    "amount": amount,
    "date": date.toIso8601String(),
    "utr": utr,
    "image": image,
    "payment_status": paymentStatus,
    "remarks": remarks,
    "update": "${update.year.toString().padLeft(4, '0')}-${update.month.toString().padLeft(2, '0')}-${update.day.toString().padLeft(2, '0')}",
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
