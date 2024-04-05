// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../data/mongo_database.dart';
import 'PoemListPage.dart';

class DeewanParAuteurPage extends StatelessWidget {
  final String authorId;
  final String poetFirstname;
  final String poetLastname;

  DeewanParAuteurPage(
      {required this.authorId,
      required this.poetFirstname,
      required this.poetLastname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'دواوين $poetFirstname $poetLastname ',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 230, 145),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MongoDataBase.getDeewanByAuthorId(authorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>>? deewanList = snapshot.data;
            if (deewanList == null || deewanList.isEmpty) {
              return Center(child: Text('No data available'));
            }
            return ListView.builder(
              itemCount: deewanList.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> deewan = deewanList[index];
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
