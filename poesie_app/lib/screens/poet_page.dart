import 'package:flutter/material.dart';
import '../data/mongo_database.dart';
import 'PoetDetailsPage.dart'; // Importez la page des détails de l'auteur

class PoetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الشعراء',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 230, 145),
      ),
      body: FutureBuilder<List<String>>(
        future: MongoDataBase.getPoetNames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<String>? poets = snapshot.data;
            return ListView.builder(
              itemCount: poets!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigation vers la page des détails de l'auteur
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoetDetailsPage(poetName: poets[index]),
                        ),
                      );
                    },
                    child: Text(
                      poets[index],
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
