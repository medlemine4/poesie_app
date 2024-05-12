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
        title: const Text(
          'تفاصيل القصيدة',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 230, 230, 145),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: MongoDataBase.getPoemDetails(poemeName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic>? poemDetails = snapshot.data;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    ': الوصف',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    poemDetails!['description'] ?? 'N/A',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    ': البحر',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    poemDetails['AlBaher'] ?? 'N/A',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    ': غرض القصيدة',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    poemDetails['Categorie'] ?? 'N/A',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
                  ),
                  const SizedBox(height: 20),
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
        backgroundColor: const Color.fromARGB(255, 230, 230, 145), // Couleur du bouton flottant
        child: const Icon(Icons.search), // Icône de recherche
      ),
    );
  }
}
