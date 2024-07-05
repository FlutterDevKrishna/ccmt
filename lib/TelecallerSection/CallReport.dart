import 'dart:convert';
import 'package:ccmt/Models/CallReportModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ccmt/Home/HomeScreen.dart';

import '../Models/CollectionModel.dart';

class Callreport extends StatefulWidget {
  const Callreport({Key? key}) : super(key: key);

  @override
  State<Callreport> createState() => _CollectionreportState();
}

class _CollectionreportState extends State<Callreport> {
  int dailycall = 0;
  int weeklycall = 0;
  int monthlycall = 0;
  int id = 0;
  CallReportModel? callModel;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences().then((_) {
      fetchData();
    });
  }

  Future<void> _loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getInt('user_id') ?? 11;
    });
  }

  Future<void> fetchData() async {
    String url = 'https://tm.webbexindia.com/api/callreport';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, int>{'id': id}),
    );
    if (response.statusCode == 200) {
      final result = CallReportModel.fromJson(jsonDecode(response.body));
      setState(() {
        callModel = result;
        dailycall = int.parse(result.dailyCalls);
        weeklycall = int.parse(result.weeklyCalls);
        monthlycall =int.parse( result.monthlyCalls);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Homescreen()));
            },
          ),
          title: Text(
            'Call  Report',
            style: TextStyle(color: Colors.white),
          ),
          elevation: 4,
          backgroundColor: Colors.indigo,
        ),
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2196F3), // Light Blue
                  Color(0xFFE1BEE7), // Lavender
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.7],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: callModel == null
                ? Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildMetricContainer('Monthly Calls',
                              monthlycall.toString(), Colors.red),
                          SizedBox(
                            width: 12,
                          ),
                          buildMetricContainer(
                              'Daily Calls', dailycall.toString(), Colors.teal),
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Call  Reports',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 8),
                              Expanded(
                                child: SfCartesianChart(
                                  primaryXAxis: CategoryAxis(),
                                  series: <CartesianSeries>[
                                    ColumnSeries<ChartData, String>(
                                      dataSource: <ChartData>[
                                        ChartData('Daily', dailycall),
                                        ChartData('Weekly', weeklycall),
                                        ChartData('Monthly', monthlycall),
                                      ],
                                      xValueMapper: (ChartData sales, _) =>
                                          sales.category,
                                      yValueMapper: (ChartData sales, _) =>
                                          sales.value,
                                      dataLabelSettings:
                                          DataLabelSettings(isVisible: true),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ]));
  }

  Widget buildMetricContainer(String title, String value, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String category;
  final int value;

  ChartData(this.category, this.value);
}
