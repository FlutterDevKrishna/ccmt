import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ccmt/Home/HomeScreen.dart';

import '../Models/CollectionModel.dart';

class Collectionreport extends StatefulWidget {
  const Collectionreport({Key? key}) : super(key: key);

  @override
  State<Collectionreport> createState() => _CollectionreportState();
}

class _CollectionreportState extends State<Collectionreport> {
  int total = 0;
  int dailycollection = 0;
  int weeklycollection = 0;
  int monthlycollection = 0;
  int id = 0;
  CollectionModel? collectionModel;

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
    String url = 'https://tm.webbexindia.com/api/collectionreport';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, int>{'id': id}),
    );
    if (response.statusCode == 200) {
      final result = CollectionModel.fromJson(jsonDecode(response.body));
      setState(() {
        collectionModel = result;
        total = result.totalCollection;
        dailycollection = result.dailyCollection;
        weeklycollection = result.weeklyCollection;
        monthlycollection = result.monthlyCollection;
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
            'Collection Report',
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
            child: collectionModel == null
                ? Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildMetricContainer(
                              'Total Collection', '₹$total', Colors.red),
                          SizedBox(
                            width: 12,
                          ),
                          buildMetricContainer('Daily Collection',
                              '₹$dailycollection', Colors.teal),
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
                                'Collections Reports',
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
                                        ChartData('Daily', dailycollection),
                                        ChartData('Weekly', weeklycollection),
                                        ChartData('Monthly', monthlycollection),
                                        ChartData('Total', total),
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
