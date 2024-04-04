// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import '../data/mongo_database.dart';
import 'PoemContent.dart';
import 'PoemDetails.dart';

class PoemListScreen extends StatelessWidget {
  final String deewanId;
  final String poetFirstname;
  final String poetLastname;

  PoemListScreen({
    required this.deewanId,
    required this.poetFirstname,
    required this.poetLastname,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'قصائد $poetFirstname $poetLastname',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 230, 145),
      ),
      body: FutureBuilder(
        future: MongoDataBase.getPoemsByDeewanId(deewanId),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Map<String, dynamic>>? poemsList = snapshot.data;
            return ListView.builder(
              itemCount: poemsList!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> poem = poemsList[index];
                String titre = poem['Titre'];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoemContent(
                            poemContent: poem['Contenue'],
                            poemTitle: poem['Titre'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.favorite,
                                      color: Colors.black,
                                      ),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.info,
                                      color: Colors.black,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PoemDetails(
                                              poemeName: titre,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      poem['Titre'] ?? '',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'البحر: ${poem['AlBaher'] ?? ''}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'الروي : ${poem['Rawy'] ?? ''}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text('No poems available.'),
            );
          }
        },
      ),
    );
  }
}
