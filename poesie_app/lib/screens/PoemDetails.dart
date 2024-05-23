// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:poesie_app/screens/SearchPage.dart';
import '../data/mongo_database.dart';

class PoemDetails extends StatelessWidget {
  final String poemeName;

  PoemDetails({required this.poemeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل القصيدة',
          style: TextStyle(
              fontSize: 27.0,
              fontFamily: 'Almarai',
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
                ),
              );
            },
            icon: Icon(Icons.search),
            color: Colors.white,
          ),
        ],
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
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PoemDetailItem(
                        label: 'الوصف:',
                        text: poemDetails!['description'] ?? 'غير متوفر'),
                    PoemDetailItem(
                        label: 'البحر:',
                        text: poemDetails['AlBaher'] ?? 'غير متوفر'),
                    PoemDetailItem(
                        label: 'غرض القصيدة:',
                        text: poemDetails['Categorie'] ?? 'غير متوفر'),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class PoemDetailItem extends StatelessWidget {
  final String label;
  final String text;

  PoemDetailItem({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          text,
          style: TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
