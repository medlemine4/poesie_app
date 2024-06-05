// ignore_for_file: file_names, non_constant_identifier_names, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, unused_field, prefer_final_fields, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

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

  PoemListScreen({
    required this.deewanId,
    required this.deewan_name,
  });

  @override
  _PoemListScreenState createState() => _PoemListScreenState();
}

class _PoemListScreenState extends State<PoemListScreen> {
  late TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  ValueNotifier<List<FavoritePoem>> favoritePoems = ValueNotifier<List<FavoritePoem>>([]);

  @override
  void initState() {
    super.initState();
    loadFavoritePoems();
  }

  void loadFavoritePoems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoritePoemIds = prefs.getStringList('favoritePoems');
    if (favoritePoemIds != null) {
      favoritePoems.value = favoritePoemIds.map((id) => FavoritePoem(poemId: id)).toList();
    }
  }

  void saveFavoritePoems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritePoemIds = favoritePoems.value.map((poem) => poem.poemId).toList();
    await prefs.setStringList('favoritePoems', favoritePoemIds);
  }

  void toggleFavorite(String poemId) {
    if (favoritePoems.value.any((poem) => poem.poemId == poemId)) {
      favoritePoems.value = favoritePoems.value.where((poem) => poem.poemId != poemId).toList();
    } else {
      favoritePoems.value = [...favoritePoems.value, FavoritePoem(poemId: poemId)];
    }
    saveFavoritePoems();
    favoritePoems.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'قصائد  ${widget.deewan_name}',
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
                  return ValueListenableBuilder<List<FavoritePoem>>(
                    valueListenable: favoritePoems,
                    builder: (context, favoritePoemsValue, child) {
                      return ListView.builder(
                        itemCount: poemsList!.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> poem = poemsList[index];
                          String poemId = poem['ID_Poeme'] ?? '';
                          String titre = poem['Titre'] ?? '';
                          String contenu = poem['Contenue'] ?? '';
                          String alBaher = poem['AlBaher'] ?? '';
                          String rawy = poem['Rawy'] ?? '';
                          int numberOfLines = computeLineCount(contenu);
                          bool isFavorite = favoritePoemsValue
                              .any((poem) => poem.poemId == poemId);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              Text(
                                                'عدد الأبيات: $numberOfLines',
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

  int computeLineCount(String content) {
    // Séparez le contenu en lignes
    List<String> lines = content.split('\n');

    // Filtrez les lignes vides
    List<String> nonEmptyLines =
        lines.where((line) => line.trim().isNotEmpty).toList();

    // Retournez la moitié du nombre de lignes non vides
    return (nonEmptyLines.length ~/ 2); // Utilisez la division entière
  }
}
