// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:test/screens/Auteur_info.dart';
import '../data/mongo_database.dart';
// import 'deewan_page.dart';

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
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(
                                'images/profile.jpg'), // Replace with actual image path
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                poets[index], // Display nom + prenom
                                style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 20.0,
                                    color: Colors.black),
                              ),
                              Text(
                                'lieu_naissance', // Display lieu_naissance
                                style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 16.0,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AuteurInfo()));
                            },
                            icon: Icon(Icons.info), // Info icon
                            color: Colors.black,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.save), // Save icon
                            color: Colors.black,
                          ),
                        ],
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
