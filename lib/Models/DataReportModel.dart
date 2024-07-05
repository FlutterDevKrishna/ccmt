// To parse this JSON data, do
//
//     final dataReportModel = dataReportModelFromJson(jsonString);

import 'dart:convert';

DataReportModel dataReportModelFromJson(String str) => DataReportModel.fromJson(json.decode(str));

String dataReportModelToJson(DataReportModel data) => json.encode(data.toJson());

class DataReportModel {
  int totalData;
  int pendingData;
  int confirmedData;
  int followupData;
  int dndData;

  DataReportModel({
    required this.totalData,
    required this.pendingData,
    required this.confirmedData,
    required this.followupData,
    required this.dndData,
  });

  factory DataReportModel.fromJson(Map<String, dynamic> json) => DataReportModel(
    totalData: json["total_data"],
    pendingData: json["pending_data"],
    confirmedData: json["confirmed_data"],
    followupData: json["followup_data"],
    dndData: json["dnd_data"],
  );

  Map<String, dynamic> toJson() => {
    "total_data": totalData,
    "pending_data": pendingData,
    "confirmed_data": confirmedData,
    "followup_data": followupData,
    "dnd_data": dndData,
  };
}
