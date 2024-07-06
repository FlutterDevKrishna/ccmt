import 'dart:convert';
import 'package:ccmt/Home/DataScreen.dart';
import 'package:ccmt/Models/DashboardModel.dart';
import 'package:ccmt/TelecallerSection/CallReport.dart';
import 'package:ccmt/TelecallerSection/Profile.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../TelecallerSection/ColllectionReport.dart';
import '../TelecallerSection/DataReport.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../UserScreen/LoginScreen.dart';


class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  // Telecaller details
  late int id = 0;
  late String telecallerName = "Unknown";
  late String loginTime = "unknown";
  late int totalData = 0;
  late int totalRevenue = 0;
  late int confirmedData=0;
  late int dailyCollection = 0;
  late int dailyCalls = 0;
  late int followup = 0;
  late int dnd = 0;
  late int weeklyCollection = 0;
  late int newLead = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences().then((_) {
      _loadTeleCallerDetails();
    });
  }

  // Sample data for bar chart
  List<Task> barData = [];
  List<Task> collectionBarData = [];

  Future<void> _loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getInt('user_id') ?? 11;
    });
  }

  Future<void> _loadTeleCallerDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String url = 'http://admin.ccmorg.in/api/teledata';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, int>{'id': id}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = DashboardModel.fromJson(jsonDecode(response.body));

        setState(() {
          telecallerName = result.name.toString();
          loginTime = DateFormat('yyyy-MM-dd – kk:mm').format(result.loginTime);;
          totalData = result.total;
          confirmedData=result.confirm;
          totalRevenue = result.revenue;
          dailyCollection = result.dailycollections;
          dailyCalls = result.dailycalls;
          followup = result.followup;
          dnd=result.dnd;
          weeklyCollection=result.weeklycollection;
          newLead = result.newData;

          barData = [
            Task('Total Data', totalData),
            Task('Confirmed ', confirmedData),
            Task('Follow-Up', followup),
            Task('DND Data', dnd),
          ];
          collectionBarData=[
            Task('Total Revenue', totalRevenue ),
            Task('Weekly',  weeklyCollection),
            Task('Daily',  dailyCollection),
          ];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load the data!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to Load Data!'), backgroundColor: Colors.red),
      );
    }
  }

  //logout
  Future<void> logout(BuildContext context) async {
    // Retrieve the ID from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    await prefs.setBool('isLogged', false);
    await prefs.remove('isLogged');
    await prefs.clear();

    if (userId != null) {
      // Send a POST request to the logout API
      var response = await http.post(
        Uri.parse('http://admin.ccmorg.in/api/logout'),
        body: {'id': userId},
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response, clear shared preferences and navigate to the login page

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Loginscreen()),
              (Route<dynamic> route) => false,
        );

      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to log out');
      }
    } else {
      // If no user ID is found in shared preferences, navigate to the login page
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Loginscreen(),));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _confirmLogout(context);
            },
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Telecaller Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Profile()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  _confirmLogout(context);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.bar_chart),
                title: Text('Collection Report'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Collectionreport()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.call),
                title: Text('Calls Report'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Callreport()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.data_usage),
                title: Text('Data Report'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Datareport()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child:  _isLoading
              ? Center(
            child: CircularProgressIndicator(),
          )
              : SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Telecaller details section
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.blue[50]!],
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
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                AnimatedTextKit(
                                  animatedTexts: [
                                    TyperAnimatedText(
                                      'Telecaller Details',
                                      textStyle: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                      speed: Duration(milliseconds: 100),
                                    ),
                                  ],
                                  isRepeatingAnimation: false,
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.black87,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Name: $telecallerName',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.black87,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Login Time: $loginTime',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Metrics containers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          buildMetricContainer('Total Data', '$totalData', Colors.blue, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>Datascreen(apiUrl: "http://admin.ccmorg.in/api/totaldata",)),
                            );
                          }),
                          buildMetricContainer('Total Revenue', '₹$totalRevenue', Colors.green, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>Datascreen(apiUrl: "http://admin.ccmorg.in/api/confirmData",)),
                            );
                          }),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildMetricContainer(
                              'Daily Revenue', '₹$dailyCollection', Colors.orange, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Datascreen(apiUrl: "http://admin.ccmorg.in/api/dailycollectiondata",)),
                            );
                          }),
                          buildMetricContainer('Daily Calls', '$dailyCalls', Colors.purple, () {

                          }),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildMetricContainer('Follow-Up', '$followup', Colors.red, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Datascreen(apiUrl: "http://admin.ccmorg.in/api/followupdata",)),
                            );
                          }),
                          buildMetricContainer('New Leads', '$newLead', Colors.teal, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Datascreen(apiUrl: "http://admin.ccmorg.in/api/newdata",)),
                            );
                          }),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Bar chart for the sample data
                      // Bar chart
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.blue[50]!],
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
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.bar_chart,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Data Metrics',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Bar chart with sample data
                            SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              series: <CartesianSeries>[
                                ColumnSeries<Task, String>(
                                  dataSource: barData,
                                  xValueMapper: (Task task, _) => task.task,
                                  yValueMapper: (Task task, _) => task.value,
                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      //          bar chart
                      // Bar chart
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.blue[50]!],
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
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.bar_chart,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Revenue Metrics',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Bar chart with sample data
                            SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              series: <CartesianSeries>[
                                ColumnSeries<Task, String>(
                                  dataSource: collectionBarData,
                                  xValueMapper: (Task task, _) => task.task,
                                  yValueMapper: (Task task, _) => task.value,
                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]),
              ))),);
  }

  Widget buildMetricContainer(String title, String value, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
                  fontSize: 16,
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
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await _loadTeleCallerDetails();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // Perform logout operations here

      logout(context);
    }
  }
}

class Task {
  Task(this.task, this.value);
  final String task;
  final int value;
}
