import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../Home/HomeScreen.dart';
import 'package:ccmt/Models/ProfileModel.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Future<void> _profileFuture;
  late int id = 0;
  late String name = 'Unknown';
  late String email = 'Unknown';
  late String contact = 'Unknown';
  late String address = 'Unknown';
  late String startDate = 'Unknown';
  late String lastLogout = 'Unknown';
  bool _isLoading = false; // To handle loading state

  @override
  void initState() {
    super.initState();
    _profileFuture = _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    await _loadUserPreferences();
    await _loadTeleCallerDetails();
  }

  Future<void> _loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getInt('user_id') ?? 11;
    });
  }

  Future<void> _loadTeleCallerDetails() async {
    try {
      String url = 'http://admin.ccmorg.in/api/profiletelecaller';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, int>{'id': id}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = ProfileModel.fromJson(jsonDecode(response.body));
        setState(() {
          name = result.name.toString();
          email = result.email.toString();
          contact = result.mobile.toString();
          address = "Active";
          startDate = DateFormat('yyyy-MM-dd – kk:mm').format(result.created);
          lastLogout = DateFormat('yyyy-MM-dd – kk:mm').format(result.loginTime);
        });
      } else {
        _showSnackBar('Unable to load the data!',Colors.red);
      }
    } catch (e) {
      _showSnackBar('Unable to Load Data!',Colors.red);
    }
  }

  Future<void> _resetPassword(String newPassword) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String url = 'http://admin.ccmorg.in/api/resetpassword';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{'id': id, 'password': newPassword}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Password reset successfully!',Colors.green);
      } else {
        _showSnackBar('Unable to reset password!',Colors.red);
      }
    } catch (e) {
      _showSnackBar('An error occurred!',Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message,Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _showPasswordResetDialog() {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _formKey = GlobalKey<FormState>();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            'Reset Password',
            style: TextStyle(
              color: Colors.indigo,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.indigo),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.indigo),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length <= 6) {
                      return 'Password must be more than 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.indigo),
                    ),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.indigo),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text('Reset', style: TextStyle(fontSize: 16)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  _resetPassword(newPasswordController.text.trim());
                }
              },
            ),
          ],
        );
      },
    );}


    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Homescreen()),
            );
          },
        ),
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
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
          FutureBuilder<void>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20.0),
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage('assets/profile.png'), // Replace with your image
                          child: CircleAvatar(
                            radius: 58,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      _buildReadOnlyField('Name', name),
                      _buildReadOnlyField('Email', email),
                      _buildReadOnlyField('Contact', contact),
                      _buildReadOnlyField('Status', address),
                      _buildReadOnlyField('Date of Start', startDate),
                      _buildReadOnlyField('Last Login Time', lastLogout),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                        ),
                        child: _isLoading ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ) : Text('Reset Password'),
                        onPressed: _isLoading ? null : _showPasswordResetDialog,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    bool isActive = label == 'Status' && value == 'Active';
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isActive ? Colors.green : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
