// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:poesie_app/screens/PoemListPage.dart';
import '../data/mongo_database.dart';

class DeewanPage extends StatelessWidget {
  final int? authorId;

  DeewanPage({this.authorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الدواوين',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 230, 145),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MongoDataBase.getDeewanNames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>>? deewans = snapshot.data;
            if (deewans == null || deewans.isEmpty) {
              return Center(child: Text('No data available'));
            }
            return ListView.builder(
              itemCount: deewans.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> deewan = deewans[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PoemListScreen(
                          deewanId: deewan['Id_Deewan'].toString(),
                          poetLastname: deewan['nom'].toString(),
                          poetFirstname: '',
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.info),
                                onPressed: () {
                                  // Add functionality for info button
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                deewan['nom'] ?? '',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 18.0,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 20.0),
                              Icon(Icons.book, color: Colors.blue),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
