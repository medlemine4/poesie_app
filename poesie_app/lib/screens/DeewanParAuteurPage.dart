import 'package:flutter/material.dart';
import '../data/mongo_database.dart';

class DeewanParAuteurPage extends StatelessWidget {
  final String authorId;

  DeewanParAuteurPage({required this.authorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Deewan par auteur',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 230, 145),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MongoDataBase.getDeewanByAuthorId(authorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>>? deewanList = snapshot.data;
            return ListView.builder(
              itemCount: deewanList!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> deewan = deewanList[index];
                // Build your UI to display deewan name only
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_forward),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          deewan['nom'],
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
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
