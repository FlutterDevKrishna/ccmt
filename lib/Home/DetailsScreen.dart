import 'dart:convert';
import 'dart:io'; // Import dart:io for File class
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

import '../Models/TotalDataModel.dart';

class DetailScreen extends StatefulWidget {
  final TotalDataModel data;

  const DetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _statusController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _utrController;
  late TextEditingController _amountController;
  late TextEditingController _remarksController;
  String? _base64Image;
  DateTime? _selectedDate;
  bool _isLoading = false;
  late int id = 0;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences().then((_) {
      _statusController = TextEditingController(text: _mapStatusToString(widget.data.status));
      _nameController = TextEditingController(text: widget.data.name.toString());
      _emailController = TextEditingController(text: widget.data.email.toString());
      _utrController = TextEditingController(text: widget.data.utr.toString());
      _amountController = TextEditingController(text: widget.data.amount.toString());
      _remarksController = TextEditingController(text: widget.data.remarks.toString());
      _selectedDate = widget.data.date;
    });

  }

  Future<void> _loadUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getInt('user_id') ?? 11;
    });
  }
  @override
  void dispose() {
    _statusController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _utrController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  String _mapStatusToString(int status) {
    switch (status) {
      case 1:
        return 'Confirm';
      case 2:
        return 'Follow-up';
      case 3:
        return 'DND';
      default:
        return 'Pending';
    }
  }

  // Function to update data via API
  Future<void> _updateData(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    // Gather updated data from form fields
    String id = widget.data.id.toString();
    String updatedName = _nameController.text;
    String updatedEmail = _emailController.text;
    String updatedUtr = _utrController.text;
    String updatedAmount = _amountController.text;
    String updatedRemarks = _remarksController.text;

    // Map status string to numeric code
    Map<String, int> statusMapping = {
      'Pending': 0,
      'Confirm': 1,
      'Follow-up': 2,
      'DND': 3,
    };

    int updatedStatusCode = statusMapping[_statusController.text] ?? 0;

    // Prepare payload
    Map<String, dynamic> payload = {
      'id': id,
      'name': updatedName ?? '',
      'email': updatedEmail ?? '',
      'utr': updatedUtr ?? '',
      'amount': updatedAmount ?? '',
      'status': updatedStatusCode ?? '', // Send numeric status code
      'remarks': updatedRemarks ?? '',
      'date': _selectedDate?.toString() ?? '',
      'image': _base64Image,
    };
    // Replace with your API endpoint
    var apiUrl = Uri.parse('http://admin.ccmorg.in/api/update-data-status');

    try {
      var response = await http.post(
        apiUrl,
        body: jsonEncode(payload),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Update successful, show success animation or message
        _showSuccessAnimation(context);
      } else {
        // Handle API error
        throw Exception('Failed to update data');
      }
    } catch (e) {
      // Handle network or API errors
      print('Error updating data: $e');
      // Show error message or handle as needed
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Data Details',
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
      body: Stack(
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16),
                  _buildActionButtons(context),
                  SizedBox(height: 24),
                  _buildTextField('Customer ID', "CCMT0${widget.data.id.toString()}", readOnly: true),
                  SizedBox(height: 12),
                  _buildTextField('Customer Name', widget.data.name.toString(), controller: _nameController),
                  SizedBox(height: 12),
                  _buildTextField('Email Address', widget.data.email.toString(), controller: _emailController),
                  SizedBox(height: 12),
                  _buildTextField('UTR or Trans Number', widget.data.utr.toString(), controller: _utrController),
                  SizedBox(height: 24),
                  _buildUploadButton(context),
                  SizedBox(height: 24),
                  _buildTextField('Donation Amount', widget.data.amount.toString(), controller: _amountController),
                  SizedBox(height: 16),
                  _buildStatusDropdown(),
                  SizedBox(height: 16),
                  _buildTextField('Remark', widget.data.remarks.toString(), controller: _remarksController),
                  SizedBox(height: 16),
                  _buildNextFollowupDatePicker(context, _selectedDate),
                  SizedBox(height: 24),
                  _buildUpdateButton(context),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCustomButton('Call', Colors.green,Icons.call, () {
          _launchPhoneCall(widget.data.mobile);
        }),
        _buildCustomButton('Message', Colors.indigo,Icons.message, () {
          openWhatsApp(widget.data.mobile);
        }),
      ],
    );
  }
  Widget _buildCustomButton(String label, Color color, IconData iconData, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData,color: Colors.white,), // Icon
          SizedBox(width: 8.0), // Adjust the spacing between icon and text
          Text(
            label,
            style: TextStyle(fontSize: 16), // Adjust text style as needed
          ),
        ],
      ),
    );
  }
  //call & call Duration
  Future<void> _launchPhoneCall(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    // Convert the URL string to a Uri object
    final numberUri = Uri.parse(url);
    if (await canLaunchUrl(numberUri)) {
      final bool launched = await launchUrl(numberUri);
      if (launched) {
        // Wait for the call to end, then send duration to API
        // Simulating a duration here, since direct call tracking is not possible in Flutter
        await Future.delayed(Duration(seconds: 30)); // Replace with actual duration tracking logic
        int duration = 30; // Replace with actual call duration in seconds

        // Send duration to API
        await _sendCallDuration(duration);
      }
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _sendCallDuration(int duration) async {
    try {
      String apiUrl = 'http://admin.ccmorg.in/api/callduration';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'outputDuration': duration,
        }),
      );

      if (response.statusCode == 200) {
        print('Call duration sent successfully.');
      } else {
        print('Failed to send call duration. Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception while sending call duration: $e');
    }
  }



  void openWhatsApp(String phoneNumber) async {
    // Handle empty phone number
    if (phoneNumber.isEmpty) {
      throw "Phone number cannot be empty";
    }

    // Handle leading zero (optional for most cases)
    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }

    String countryCode = '+91'; // Example: India's country code
    String url = "https://wa.me/$countryCode$phoneNumber";

    // Convert the URL string to a Uri object
    final whatsappUri = Uri.parse(url);

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      throw "Could not launch WhatsApp for $phoneNumber";
    }
  }

  Widget _buildTextField(String labelText, String initialValue, {TextEditingController? controller, bool readOnly = false}) {
    return TextFormField(
      initialValue: controller == null ? initialValue : null,
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.indigo),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _openImagePicker(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload),
          SizedBox(width: 8),
          Text('Upload Screenshot'),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  void _openImagePicker(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _base64Image = base64Encode(imageFile.readAsBytesSync());
      });
    }
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _statusController.text,
      onChanged: (String? newValue) {
        setState(() {
          _statusController.text = newValue!;
        });
      },
      items: ['Pending', 'Confirm', 'Follow-up', 'DND']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Status',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.indigo),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    );
  }

  Widget _buildNextFollowupDatePicker(BuildContext context, DateTime? selectedDate) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),

        );
        if (pickedDate != null && pickedDate != selectedDate) {
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Next Follow-up Date',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            suffix: Icon(Icons.calendar_month,color: Colors.indigo,),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.indigo),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          ),
          controller: TextEditingController(
            text: _selectedDate != null
                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                : '',
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _updateData(context);
      },
      child: Text('Update Data'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  void _showSuccessAnimation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/animation/success.json',
                    width: 150,
                    height: 150,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Data updated successfully!',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
