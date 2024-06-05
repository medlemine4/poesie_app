// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:poesie_app/screens/SearchPage.dart';
import '../data/mongo_database.dart';
import 'dart:io';

class PoetDetails extends StatelessWidget {
  final String poetName;

  PoetDetails({required this.poetName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'تفاصيل الشاعر',
                style: TextStyle(
                  fontSize: 24.0,
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'poetImage_$poetName',
                    child: _buildPoetImage(context, poetName),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
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
            backgroundColor: Colors.teal[700],
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<Map<String, dynamic>>(
              future: MongoDataBase.getPoetDetails(poetName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  Map<String, dynamic>? poetDetails = snapshot.data;
                  if (poetDetails == null || poetDetails.isEmpty) {
                    return Center(child: Text('Poet not found'));
                  }

                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('الوصف', Colors.teal[800]),
                        SizedBox(height: 20),
                        _buildDetailRow(
                          icon: Icons.library_books,
                          title: 'عدد الدواوين',
                          content: '${poetDetails['deewanCount']}',
                        ),
                        SizedBox(height: 10),
                        _buildDetailRow(
                          icon: Icons.article,
                          title: 'عدد القصائد',
                          content: '${poetDetails['poemCount']}',
                        ),
                        SizedBox(height: 20),
                        _buildDescriptionCard(
                          poetDetails['description'] ?? 'N/A',
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoetImage(BuildContext context, String poetName) {
    String imagePath = 'images/$poetName.jpg';
    bool imageExists = File(imagePath).existsSync();

    return imageExists
        ? Image.asset(
            imagePath,
            fit: BoxFit.cover,
          )
        : Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 100.0,
              ),
            ),
          );
  }

  Widget _buildSectionTitle(String title, Color? color) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 26.0,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          content,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 20.0,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
        SizedBox(width: 10),
        Icon(icon, color: Colors.teal[700]),
      ],
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'وصف الشاعر',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18.0,
                height: 1.5,
                color: Colors.grey[800],
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
