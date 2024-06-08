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
        future: MongoDataBase.getPoemDetails(poemeName).timeout(
          Duration(seconds: 30),
          onTimeout: () {
            showSnackbar(
              '!تحقق من اتصالك بالإنترنت',
              context,
            );
            return {};
          },
        ),
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

void showSnackbar(String message, BuildContext context) {
  final overlay = Overlay.of(context);
  OverlayEntry? overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: TopSnackBar(
        message: message,
        onClose: () {
          overlayEntry?.remove();
        },
      ),
    ),
  );

  overlay?.insert(overlayEntry);

  Future.delayed(Duration(seconds: 5), () {
    overlayEntry?.remove();
  });
}

class TopSnackBar extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  TopSnackBar({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(16.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Almarai',
                ),
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(Icons.close, color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
