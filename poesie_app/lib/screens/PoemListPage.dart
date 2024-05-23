// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, prefer_final_fields, unused_field

import 'package:flutter/material.dart';
import 'package:poesie_app/screens/SearchPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poesie_app/models/favorite_author.dart';
import '../data/mongo_database.dart';
import 'PoemContent.dart';
import 'PoemDetails.dart';

class PoemListScreen extends StatefulWidget {
  final String deewanId;
  final String deewan_name;
  // final String poetLastname;

  PoemListScreen({
    required this.deewanId,
    required this.deewan_name,
    // required this.poetLastname,
  });

  @override
  _PoemListScreenState createState() => _PoemListScreenState();
}

class _PoemListScreenState extends State<PoemListScreen> {
  late TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<FavoritePoem> favoritePoems = [];

  @override
  void initState() {
    super.initState();
    loadFavoritePoems();
  }

  void loadFavoritePoems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoritePoemIds = prefs.getStringList('favoritePoems');
    if (favoritePoemIds != null) {
      setState(() {
        favoritePoems =
            favoritePoemIds.map((id) => FavoritePoem(poemId: id)).toList();
      });
    }
  }

  void saveFavoritePoems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritePoemIds =
        favoritePoems.map((poem) => poem.poemId).toList();
    await prefs.setStringList('favoritePoems', favoritePoemIds);
  }

  void toggleFavorite(String poemId) {
    setState(() {
      if (favoritePoems.any((poem) => poem.poemId == poemId)) {
        favoritePoems.removeWhere((poem) => poem.poemId == poemId);
      } else {
        favoritePoems.add(FavoritePoem(poemId: poemId));
      }
      saveFavoritePoems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'قصائد  ${widget.deewan_name}',
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
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
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
                        hintText: '...ابحث في قائمة القصائد',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        // prefixIcon: Icon(Icons.search, color: Colors.grey),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchText = '';
                            });
                          },
                          icon: Icon(Icons.clear, color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 20.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade300, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                              color: Colors.grey.shade600, width: 1.5),
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
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: MongoDataBase.getPoemsByDeewanId(widget.deewanId),
              builder: (context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
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
                      String poemId = poem['ID_Poeme'] ?? '';
                      String titre = poem['Titre'] ?? '';
                      String contenu = poem['Contenue'] ?? '';
                      String alBaher = poem['AlBaher'] ?? '';
                      String rawy = poem['Rawy'] ?? '';
                      bool isFavorite =
                          favoritePoems.any((poem) => poem.poemId == poemId);
                      return Padding(
                        padding: EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PoemContent(
                                  poemContent: contenu,
                                  poemTitle: titre,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            color: Colors.teal[50],
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.info,
                                                color: Colors.teal[900]),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PoemDetails(
                                                    poemeName: titre,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFavorite
                                                  ? Colors.red
                                                  : Colors.teal[900],
                                            ),
                                            onPressed: () {
                                              toggleFavorite(poemId);
                                            },
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            titre,
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Almarai',
                                              color: Colors.teal[900],
                                            ),
                                          ),
                                          Text(
                                            'البحر:  $alBaher',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Almarai',
                                              color: Colors.teal[900],
                                            ),
                                          ),
                                          Text(
                                            'الروي :  $rawy',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Almarai',
                                              color: Colors.teal[900],
                                            ),
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
                    child: Text('لا توجد قصائد متاحة في هذا الديوان'),
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
