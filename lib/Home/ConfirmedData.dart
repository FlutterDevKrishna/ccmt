import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/TotalDataModel.dart';
import 'DetailsScreen.dart';
import 'HomeScreen.dart';

class Confirmeddata extends StatefulWidget {
  const Confirmeddata({Key? key}) : super(key: key);

  @override
  State<Confirmeddata> createState() => _DatascreenState();
}

class _DatascreenState extends State<Confirmeddata> {
  List<TotalDataModel> dataList = [];
  late int id = 0;
  bool isLoading = true; // Add this variable

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
    try {
      String url = 'https://tm.webbexindia.com/api/confirmData';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, int>{'id': id}),
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        List<TotalDataModel> data = responseData.map((item) => TotalDataModel.fromJson(item)).toList();

        setState(() {
          dataList = data;
          isLoading = false; // Set loading to false
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Homescreen(),
              ),
            );
          },
        ),
        title: Text(
          'Data List',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 4,
        backgroundColor: Colors.indigo,
      ),
      body:
      Stack(
        children: [
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
          isLoading
              ? Center(child: CircularProgressIndicator())
              :  ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 18),
                    title: Text("CCMT0"+
                        dataList[index].id.toString(),
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    trailing: Icon(Icons.visibility),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(data: dataList[index]),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

        ],
      ),



    );
  }
}
