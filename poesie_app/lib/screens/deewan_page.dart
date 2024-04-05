// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
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
      body: FutureBuilder<List<String>>(
        future: MongoDataBase.getDeewanNames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<String>? deewans = snapshot.data;
            return Directionality(
              textDirection: TextDirection.rtl,
              child: ListView.builder(
                itemCount: deewans!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Card(
                      elevation: 2.0,
                      margin: EdgeInsets.zero,
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
                                Icon(Icons.book, color: Colors.blue),
                                SizedBox(width: 40.0),
                                Text(
                                  deewans[index],
                                  style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0),
                                ),
                              ],
                            ),
                            Icon(Icons.info),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
