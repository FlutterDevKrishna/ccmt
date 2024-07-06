import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ccmt/Models/DataReportModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ccmt/Home/HomeScreen.dart';

class Datareport extends StatefulWidget {
  const Datareport({Key? key}) : super(key: key);

  @override
  State<Datareport> createState() => _DatareportState();
}

class _DatareportState extends State<Datareport> {
  int totalData = 0;
  int remainingData = 0;
  int followupData = 0;
  int dndData = 0;
  int confirmedData=0;
  int id = 0;
  DataReportModel? dataReportModel;

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
    String url = 'http://admin.ccmorg.in/api/telecallerdatareport';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, int>{'id': id}),
    );
    if (response.statusCode == 200) {
      final result = DataReportModel.fromJson(jsonDecode(response.body));
      setState(() {
        dataReportModel = result;
        totalData = result.totalData;
        confirmedData=result.confirmedData;
        remainingData = result.pendingData;
        followupData = result.followupData;
        dndData = result.dndData;
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
            'Data Report',
            style: TextStyle(color: Colors.white),
          ),
          elevation: 4,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
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
            child: dataReportModel == null
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildMetricContainer('Total Data',
                                totalData.toString(), Colors.teal),
                            buildMetricContainer('Remaining data',
                                remainingData.toString(), Colors.green),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildMetricContainer('Follow-up Data',
                                followupData.toString(), Colors.yellow),
                            buildMetricContainer(
                                'DND Data', dndData.toString(), Colors.red),
                          ],
                        ),
                        SizedBox(height: 12),
                        Container(
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
                                'Telecaller Data Reports',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 8),
                              Center(
                                child: Container(
                                  height: 300, // Adjust height as needed
                                  child:SfCircularChart(
                                    legend: Legend(isVisible: true), // Show legends
                                    series: <CircularSeries<ChartData, String>>[
                                      PieSeries<ChartData, String>(
                                        dataSource: _getChartData(),
                                        xValueMapper: (ChartData data, _) => data.category,
                                        yValueMapper: (ChartData data, _) => data.value,
                                        pointColorMapper: (ChartData data, _) => data.color,
                                        dataLabelSettings: DataLabelSettings(isVisible: true),
                                      )
                                    ],
                                  ),

                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ]));
  }

  Widget buildMetricContainer(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> _getChartData() {
    Color successColor = Colors.green;
    Color dndColor = Colors.red;
    Color followupColor = Colors.yellow;
    Color remainingColor = Colors.teal;

    return [
      ChartData('Confirmed', confirmedData, successColor),
      ChartData('DND Data', dndData, dndColor),
      ChartData('Follow-up Data', followupData, followupColor),
      ChartData('Remaining Data', remainingData, remainingColor),
    ];
  }

}

class ChartData {
  final String category;
  final int value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}

