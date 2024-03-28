// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

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
        future: MongoDataBase.getDeewanNames(authorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<String>? deewans = snapshot.data;
            return ListView.builder(
              itemCount: deewans!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the poems page for this ديوان
                    },
                    child: Text(
                      deewans[index],
                      style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Color.fromARGB(255, 237, 237, 182),
                      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
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
