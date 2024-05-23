// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:poesie_app/screens/SearchPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poesie_app/models/favorite_author.dart';
import '../data/mongo_database.dart';
import 'PoemContent.dart';
import 'PoemDetails.dart';

class FavoritePoemsPage extends StatefulWidget {
  @override
  _FavoritePoemsPageState createState() => _FavoritePoemsPageState();
}

class _FavoritePoemsPageState extends State<FavoritePoemsPage> {
  List<FavoritePoem> favoritePoems = [];
  late TextEditingController _searchController = TextEditingController();
  String _searchText = '';

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
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'قائمة قصائدك المفضلة',
            style: TextStyle(
                fontSize: 27.0,
                fontFamily: 'Almarai',
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
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
          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Container(
              decoration: BoxDecoration(
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
                  hintText: '...ابحث في قائمة قصائدك المفضلة',
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
                  contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.04),
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
          SizedBox(height: screenHeight * 0.04),
          Expanded(
            child: FutureBuilder(
              future: MongoDataBase.getAllPoems(),
              builder: (context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<Map<String, dynamic>>? allPoems = snapshot.data;
                  List<Map<String, dynamic>> favoritePoemsData =
                      allPoems!.where((poem) {
                    String poemId = poem['ID_Poeme'] ?? '';
                    String titre = poem['Titre'] ?? '';
                    String contenu = poem['Contenue'] ?? '';
                    String alBaher = poem['AlBaher'] ?? '';
                    String rawy = poem['Rawy'] ?? '';
                    return favoritePoems
                            .any((favorite) => favorite.poemId == poemId) &&
                        (titre
                                .toLowerCase()
                                .contains(_searchText.toLowerCase()) ||
                            contenu
                                .toLowerCase()
                                .contains(_searchText.toLowerCase()) ||
                            alBaher
                                .toLowerCase()
                                .contains(_searchText.toLowerCase()) ||
                            rawy
                                .toLowerCase()
                                .contains(_searchText.toLowerCase()));
                  }).toList();
                  return ListView.builder(
                    itemCount: favoritePoemsData.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> poem = favoritePoemsData[index];
                      String poemId = poem['ID_Poeme'] ?? '';
                      String titre = poem['Titre'] ?? '';
                      String alBaher = poem['AlBaher'] ?? '';
                      String rawy = poem['Rawy'] ?? '';
                      String contenu = poem['Contenue'] ?? '';
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
                                            'البحر: $alBaher',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Almarai',color: Colors.teal[900]),
                                          ),
                                          Text(
                                            'الروي : $rawy',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Almarai',
                                                color: Colors.teal[900]),
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
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
