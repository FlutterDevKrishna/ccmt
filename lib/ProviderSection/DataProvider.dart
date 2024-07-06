import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/TotalDataModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataProvider extends ChangeNotifier {
  String _baseUrl = "https://defaultapi.com";
  List<TotalDataModel> _dataList = [];
  List<TotalDataModel> get dataList => _dataList;
  List<TotalDataModel> _filteredDataList = [];
  List<TotalDataModel> get filteredDataList => _filteredDataList;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  late int _id = 0;
  int get id => _id;

  Timer? _timer;

  DataProvider() {
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt('user_id') ?? 11;
    fetchData();
    _startAutoRefresh(); // Start the timer to auto-refresh data
  }

  void setBaseUrl(String url) {
    _baseUrl = url;
    fetchData(); // Optionally fetch data immediately after setting the base URL
    notifyListeners();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      String url = '$_baseUrl';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, int>{'id': _id}),
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        List<TotalDataModel> data = responseData.map((item) => TotalDataModel.fromJson(item)).toList();

        _dataList = data;
        _filteredDataList = data; // Initialize the filtered data list
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startAutoRefresh() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(minutes: 5), (timer) { // Adjust the duration as needed
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the provider is disposed
    super.dispose();
  }

  Future<void> reloadData() async {
    await fetchData();
  }

  void filterData(String period) {
    DateTime now = DateTime.now();
    List<TotalDataModel> filtered = [];

    switch (period) {
      case 'day':
        filtered = _dataList.where((data) => data.date.isAfter(now.subtract(Duration(days: 1)))).toList();
        break;
      case 'week':
        filtered = _dataList.where((data) => data.date.isAfter(now.subtract(Duration(days: 7)))).toList();
        break;
      case 'month':
        filtered = _dataList.where((data) => data.date.isAfter(now.subtract(Duration(days: 30)))).toList();
        break;
    }

    _filteredDataList = filtered;
    notifyListeners();
  }
}
