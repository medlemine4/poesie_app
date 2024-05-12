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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PoemDetailItem(label: ': الوصف', text: poemDetails!['description'] ?? 'N/A'),
                  PoemDetailItem(label: ': البحر', text: poemDetails['AlBaher'] ?? 'N/A'),
                  PoemDetailItem(label: ': غرض القصيدة', text: poemDetails['Categorie'] ?? 'N/A'),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(), // Aller vers la page de recherche
            ),
          );
        },
        backgroundColor: Color.fromARGB(255, 230, 230, 145), // Couleur du bouton flottant
        child: Icon(Icons.search), // Icône de recherche
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
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
