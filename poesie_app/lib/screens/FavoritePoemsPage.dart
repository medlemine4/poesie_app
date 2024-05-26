// ignore_for_file: prefer_const_constructors, prefer_final_fields, unused_import

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
  late List<Map<String, dynamic>> favoritePoemsData = [];
  late List<ValueNotifier<bool>> isFavoriteList = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
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
    List<ValueNotifier<bool>> favorites = [];
    if (favoritePoemIds != null) {
      favorites.addAll(favoritePoemIds.map((id) {
        return ValueNotifier<bool>(true);
      }));
      favoritePoemIds.forEach((id) {
        // Fetch the poem data based on id and add it to favoritePoemsData
        // Assuming MongoDataBase.getPoemById is a method to fetch poem by id
        MongoDataBase.getPoemById(id).then((poem) {
          favoritePoemsData.add(poem);
          _listKey.currentState?.insertItem(favoritePoemsData.length - 1);
        });
      });
    }
    setState(() {
      isFavoriteList = favorites;
    });
  }

  void saveFavoritePoems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritePoemIds = [];
    isFavoriteList.asMap().forEach((index, notifier) {
      if (notifier.value) {
        favoritePoemIds.add(index.toString());
      }
    });
    await prefs.setStringList('favoritePoems', favoritePoemIds);
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
                  favoritePoemsData = allPoems!.where((poem) {
                    String poemId = poem['ID_Poeme'] ?? '';
                    String titre = poem['Titre'] ?? '';
                    String contenu = poem['Contenue'] ?? '';
                    String alBaher = poem['AlBaher'] ?? '';
                    String rawy = poem['Rawy'] ?? '';
                    return isFavoriteList.any((notifier) => notifier.value) &&
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
                  return AnimatedList(
                    key: _listKey,
                    initialItemCount: favoritePoemsData.length,
                    itemBuilder: (context, index, animation) {
                      return _buildItem(
                          context, favoritePoemsData[index], animation, index);
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

  Widget _buildItem(BuildContext context, Map<String, dynamic> poem,
      Animation<double> animation, int index) {
    String poemId = poem['ID_Poeme'] ?? '';
    String titre = poem['Titre'] ?? '';
    String alBaher = poem['AlBaher'] ?? '';
    String rawy = poem['Rawy'] ?? '';
    String contenu = poem['Contenue'] ?? '';
    int numberOfLines = computeLineCount(contenu);

    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.info, color: Colors.teal[900]),
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
                          ValueListenableBuilder<bool>(
                            valueListenable: isFavoriteList[index],
                            builder: (context, isFavorite, child) {
                              return IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? Colors.red
                                      : Colors.teal[900],
                                ),
                                onPressed: () {
                                  if (isFavorite) {
                                    _removeItem(index);
                                  }
                                  isFavoriteList[index].value = !isFavorite;
                                  saveFavoritePoems();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
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
                                fontFamily: 'Almarai',
                                color: Colors.teal[900]),
                          ),
                          Text(
                            'الروي : $rawy',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Almarai',
                                color: Colors.teal[900]),
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
      ),
    );
  }

  void _removeItem(int index) {
    final removedPoem = favoritePoemsData.removeAt(index);
    isFavoriteList.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildItem(context, removedPoem, animation, index),
      duration: Duration(milliseconds: 300),
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
