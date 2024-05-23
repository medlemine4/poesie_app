// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:poesie_app/screens/PoemListPage.dart';
import 'package:poesie_app/screens/SearchPage.dart';
import '../data/mongo_database.dart';

class DeewanPage extends StatefulWidget {
  final int? authorId;
  DeewanPage({this.authorId});

  @override
  _DeewanPageState createState() => _DeewanPageState();
}

class _DeewanPageState extends State<DeewanPage> {
  late TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'قائمة الدواوين',
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '...ابحث في قائمة الدواوين',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _searchText = '';
                        _searchController.clear();
                      });
                    },
                    icon: Icon(Icons.clear, color: Colors.grey),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        BorderSide(color: Colors.grey.shade600, width: 1.5),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: MongoDataBase.getDeewanNames(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<Map<String, dynamic>>? deewans = snapshot.data;
                  if (deewans == null || deewans.isEmpty) {
                    return Center(
                        child: Text('لا توجد قصائد متاحة في هذا الديوان'));
                  }
                  // Filtrer les données en fonction du texte de recherche :
                  List<Map<String, dynamic>> filteredDeewans =
                      _searchText.isEmpty
                          ? deewans
                          : deewans
                              .where((deewan) => (deewan['nom'] as String)
                                  .toLowerCase()
                                  .contains(_searchText.toLowerCase()))
                              .toList();
                  return ListView.builder(
                    itemCount: filteredDeewans.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> deewan = filteredDeewans[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PoemListScreen(
                                deewanId: deewan['Id_Deewan'].toString(),
                                deewan_name: deewan['nom'].toString(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.teal[300],
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      deewan['nom'] ?? '',
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 30.0),
                                    Icon(Icons.book, color: Colors.blue),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
