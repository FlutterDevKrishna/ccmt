import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/TotalDataModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataProvider extends ChangeNotifier {
  List<TotalDataModel> _dataList = [];
  List<TotalDataModel> get dataList => _dataList;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  late int _id; // Define id variable
  int get id => _id; // Getter for id

  DataProvider() {
    _loadUserPreferences(); // Load preferences in constructor
  }

  Future<void> _loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt('user_id') ?? 11; // Initialize id
    fetchData(); // Fetch data after loading id
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners(); // Notify listeners that loading started

    try {
      String url = 'https://tm.webbexindia.com/api/totaldata';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, int>{'id': _id}),
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        List<TotalDataModel> data = responseData.map((item) => TotalDataModel.fromJson(item)).toList();

        _dataList = data;
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners that loading finished
    }
  }

  Future<void> reloadData() async {
    await fetchData();
  }
}
