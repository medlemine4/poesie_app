// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:poesie_app/screens/SearchPage.dart';
import '../data/mongo_database.dart';

class PoetDetails extends StatelessWidget {
  final String poetName;

  PoetDetails({required this.poetName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'تفاصيل الشاعر',
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
          ]),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: MongoDataBase.getPoetDetails(poetName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              Map<String, dynamic>? poetDetails = snapshot.data;
              return Column(
                children: [
                  // Afficher l'image de l'auteur
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'images/$poetName.jpg'), // Remplacer par le chemin correct
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'الوصف',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      poetDetails!['description'] ?? 'N/A',
                      style: TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
                      textDirection: TextDirection
                          .rtl, // Aligner le texte de droite à gauche
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
