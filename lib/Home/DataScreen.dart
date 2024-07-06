import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ProviderSection/DataProvider.dart';
import 'DetailsScreen.dart';
import 'HomeScreen.dart';
import 'package:intl/intl.dart';

class Datascreen extends StatefulWidget {
  final String apiUrl;

  const Datascreen({Key? key, required this.apiUrl}) : super(key: key);

  @override
  State<Datascreen> createState() => _DatascreenState();
}

class _DatascreenState extends State<Datascreen> {
  String _selectedFilter = 'day'; // Default filter

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<DataProvider>(context, listen: false).setBaseUrl(widget.apiUrl);
    });
  }

  // Helper function to get status color based on status code
  Color getStatusColor(int statusCode) {
    switch (statusCode) {
      case 1:
        return Colors.green; // Success
      case 2:
        return Colors.yellow.shade800; // Followup
      case 3:
        return Colors.red; // DND
      default:
        return Colors.grey; // Not Called or other status
    }
  }

  // Helper function to get status label based on status code
  String getStatusLabel(int statusCode, String remarks, DateTime? followupDate) {
    switch (statusCode) {
      case 1:
        return 'Success';
      case 2:
        return 'Followup - ${followupDate != null ? DateFormat.yMMMd().format(followupDate) : 'No Date'}';
      case 3:
        return 'DND';
      default:
        return remarks == 'No Data' ? 'Not Called' : remarks;
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        actions: [
          DropdownButton<String>(
            value: _selectedFilter,
            icon: Icon(Icons.filter_list, color: Colors.white),
            dropdownColor: Colors.indigo,
            onChanged: (String? newValue) {
              setState(() {
                _selectedFilter = newValue!;
                Provider.of<DataProvider>(context, listen: false).filterData(_selectedFilter);
              });
            },
            items: <String>['day', 'week', 'month']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ],
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
          Consumer<DataProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (provider.filteredDataList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/nodata.png',
                        width: 280,
                        height: 280,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No data available',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: () async {
                    await provider.reloadData();
                  },
                  child: ListView.builder(
                    itemCount: provider.filteredDataList.length,
                    itemBuilder: (BuildContext context, int index) {
                      // Assuming TotalDataModel has a status and remarks property
                      int statusCode = provider.filteredDataList[index].status;
                      String remarks = provider.filteredDataList[index].remarks;
                      DateTime? followupDate = provider.filteredDataList[index].date;

                      // Determine status color and label
                      Color statusColor = getStatusColor(statusCode);
                      String statusLabel = getStatusLabel(statusCode, remarks, followupDate);

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo,
                              child: Image.asset(
                                'assets/icon.png',
                                width: 40,
                                height: 40,
                              ),
                            ),
                            title: Text(
                              "CCMT0" + provider.filteredDataList[index].id.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            subtitle: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, color: Colors.indigo),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(data: provider.filteredDataList[index]),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
