// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import '../data/mongo_database.dart';

class PoemDetailsPage extends StatelessWidget {
  final String poetName;

  PoemDetailsPage({required this.poetName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل الشاعر',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 230, 145),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: MongoDataBase.getPoetDetails(poetName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic>? poetDetails = snapshot.data;
            return Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الوصف:',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    poetDetails!['description'] ?? 'N/A',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'مكان الولادة:',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    poetDetails['lieu_naissance'] ?? 'N/A',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'تاريخ الولادة:',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    poetDetails['date_naissance'] ?? 'N/A',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'تاريخ الوفاة:',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    poetDetails['date_deces'] ?? 'N/A',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
