// To parse this JSON data, do
//
//     final dashboardModel = dashboardModelFromJson(jsonString);

import 'dart:convert';

DashboardModel dashboardModelFromJson(String str) => DashboardModel.fromJson(json.decode(str));

String dashboardModelToJson(DashboardModel data) => json.encode(data.toJson());

class DashboardModel {
  bool status;
  int id;
  String name;
  DateTime loginTime;
  int total;
  int revenue;
  int dailycollections;
  int dailycalls;
  int pending;
  int confirm;
  int followup;
  int dnd;
  int weeklycollection;
  int newData;

  DashboardModel({
    required this.status,
    required this.id,
    required this.name,
    required this.loginTime,
    required this.total,
    required this.revenue,
    required this.dailycollections,
    required this.dailycalls,
    required this.pending,
    required this.confirm,
    required this.followup,
    required this.dnd,
    required this.weeklycollection,
    required this.newData,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    status: json["status"],
    id: json["id"],
    name: json["name"],
    loginTime: DateTime.parse(json["login_time"]),
    total: json["total"],
    revenue: json["revenue"],
    dailycollections: json["dailycollections"],
    dailycalls: json["dailycalls"],
    pending: json["pending"],
    confirm: json["confirm"],
    followup: json["followup"],
    dnd: json["dnd"],
    weeklycollection: json["weeklycollection"],
    newData: json["new_data"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "id": id,
    "name": name,
    "login_time": loginTime.toIso8601String(),
    "total": total,
    "revenue": revenue,
    "dailycollections": dailycollections,
    "dailycalls": dailycalls,
    "pending": pending,
    "confirm": confirm,
    "followup": followup,
    "dnd": dnd,
    "weeklycollection": weeklycollection,
    "new_data": newData,
  };
}
