// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:poesie_app/screens/DeewanParAuteurPage.dart';
import 'package:poesie_app/screens/PoetDetails.dart';
import '../data/mongo_database.dart';

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MongoDataBase.getPoetDetailsList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>>? poetsList = snapshot.data;
            return ListView.builder(
              itemCount: poetsList!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> poet = poetsList[index];
                String ID_Auteur = poet['ID_Auteur'];
                String nom = poet['nom'];
                String prenom = poet['prenom'];
                String lieuNaissance = poet['lieu_naissance'];

                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeewanParAuteurPage(
                            authorId: ID_Auteur,
                            poetFirstname: nom,
                            poetLastname: prenom,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .end, // Align content from right to left
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PoetDetails(poetName: nom),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.info,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                // Handle save icon press
                              },
                              icon: Icon(Icons.favorite,
                              color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .start, // Align content from right to left
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$nom $prenom',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 20.0,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  lieuNaissance,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            CircleAvatar(
                              backgroundImage: AssetImage('images/$nom.jpg'),
                              radius: 30,
                            ),
                          ],
                        ),
                      ],
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
