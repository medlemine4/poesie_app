// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import '../data/mongo_database.dart';
import 'package:intl/intl.dart'; // Import the intl package to format dates

class PoemDetails extends StatelessWidget {
  final String poemeName;

  PoemDetails({required this.poemeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل القصيدة',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 230, 145),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: MongoDataBase.getPoemDetails(poemeName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic>? poemDetails = snapshot.data;

            return Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ': الوصف',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    poemDetails!['description'] ?? 'N/A',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
                  ),
                  SizedBox(height: 20),
                  Text(
                    ': البحر',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    poemDetails['AlBaher'] ?? 'N/A',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
                  ),
                  SizedBox(height: 20),
                  Text(
                    ': الروي',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    poemDetails['Rawy'] ?? 'N/A',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
                  ),
                  SizedBox(height: 20),
                  Text(
                    ': غرض القصيدة',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    poemDetails['Categorie'] ?? 'N/A',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
                  ),
                  SizedBox(height: 20),
                  Text(
                    ': تاريخ النشر',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    poemDetails['Date_Publication'] != null
                        ? DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(poemDetails['Date_Publication']))
                        : 'N/A',
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
