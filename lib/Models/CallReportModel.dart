// To parse this JSON data, do
//
//     final callReportModel = callReportModelFromJson(jsonString);

import 'dart:convert';

CallReportModel callReportModelFromJson(String str) => CallReportModel.fromJson(json.decode(str));

String callReportModelToJson(CallReportModel data) => json.encode(data.toJson());

class CallReportModel {
  String dailyCalls;
  String weeklyCalls;
  String monthlyCalls;

  CallReportModel({
    required this.dailyCalls,
    required this.weeklyCalls,
    required this.monthlyCalls,
  });

  factory CallReportModel.fromJson(Map<String, dynamic> json) => CallReportModel(
    dailyCalls: json["daily_calls"],
    weeklyCalls: json["weekly_calls"],
    monthlyCalls: json["monthly_calls"],
  );

  Map<String, dynamic> toJson() => {
    "daily_calls": dailyCalls,
    "weekly_calls": weeklyCalls,
    "monthly_calls": monthlyCalls,
  };
}
