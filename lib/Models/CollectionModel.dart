// To parse this JSON data, do
//
//     final collectionModel = collectionModelFromJson(jsonString);

import 'dart:convert';

CollectionModel collectionModelFromJson(String str) => CollectionModel.fromJson(json.decode(str));

String collectionModelToJson(CollectionModel data) => json.encode(data.toJson());

class CollectionModel {
  int totalCollection;
  int dailyCollection;
  int weeklyCollection;
  int monthlyCollection;

  CollectionModel({
    required this.totalCollection,
    required this.dailyCollection,
    required this.weeklyCollection,
    required this.monthlyCollection,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) => CollectionModel(
    totalCollection: json["total_collection"],
    dailyCollection: json["daily_collection"],
    weeklyCollection: json["weekly_collection"],
    monthlyCollection: json["monthly_collection"],
  );

  Map<String, dynamic> toJson() => {
    "total_collection": totalCollection,
    "daily_collection": dailyCollection,
    "weekly_collection": weeklyCollection,
    "monthly_collection": monthlyCollection,
  };
}
