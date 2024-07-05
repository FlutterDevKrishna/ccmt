import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ProviderSection/DataProvider.dart';
import 'DetailsScreen.dart';
import 'HomeScreen.dart';

class Datascreen extends StatelessWidget {
  const Datascreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int id = Provider.of<DataProvider>(context).id;

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
              } else {
                return RefreshIndicator(
                  onRefresh: () async {
                    await provider.reloadData();
                  },
                  child: ListView.builder(
                    itemCount: provider.dataList.length,
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
                            title: Text(
                              "CCMT0" + provider.dataList[index].id.toString(),
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            trailing: Icon(Icons.visibility),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(data: provider.dataList[index]),
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
