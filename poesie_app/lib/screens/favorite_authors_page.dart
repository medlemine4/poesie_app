// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:poesie_app/screens/SearchPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poesie_app/models/favorite_author.dart';
import 'package:poesie_app/screens/DeewanParAuteurPage.dart';
import 'package:poesie_app/screens/PoetDetails.dart';
import 'package:poesie_app/screens/full_screen_image_page.dart'; // Importez la nouvelle page ici
import '../data/mongo_database.dart';

class FavoriteAuthorsPage extends StatefulWidget {
  @override
  _FavoriteAuthorsPageState createState() => _FavoriteAuthorsPageState();
}

class _FavoriteAuthorsPageState extends State<FavoriteAuthorsPage>
    with AutomaticKeepAliveClientMixin<FavoriteAuthorsPage> {
  List<FavoriteAuthor> favoriteAuthors = [];
  late TextEditingController _searchController;
  String _searchText = '';
  late Future<List<Map<String, dynamic>>> _allAuthorsFuture;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _allAuthorsFuture = MongoDataBase.getPoetDetailsList();
    loadFavoriteAuthors();
  }

  void loadFavoriteAuthors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriteAuthorIds = prefs.getStringList('favoriteAuthors');
    if (favoriteAuthorIds != null) {
      favoriteAuthors =
          favoriteAuthorIds.map((id) => FavoriteAuthor(authorId: id)).toList();
    }
  }

  void saveFavoriteAuthors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteAuthorIds =
        favoriteAuthors.map((author) => author.authorId).toList();
    await prefs.setStringList('favoriteAuthors', favoriteAuthorIds);
  }

  void toggleFavorite(String authorId) {
    setState(() {
      if (favoriteAuthors.any((author) => author.authorId == authorId)) {
        favoriteAuthors.removeWhere((author) => author.authorId == authorId);
      } else {
        favoriteAuthors.add(FavoriteAuthor(authorId: authorId));
      }
      saveFavoriteAuthors();
    });
  }

  @override
  Widget build(BuildContext context) {
    super
        .build(context); // This ensures that the mixin's build method is called
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'قائمة الشعراء المفضلين',
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
            icon: Icon(Icons.search, color: Colors.white),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal[300],
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
                  hintText: '...ابحث في قائمة شعرائك المفضلين',
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
          SizedBox(height: screenHeight * 0.04),
          Expanded(
            child: FutureBuilder(
              future: _allAuthorsFuture,
              builder: (context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<Map<String, dynamic>>? poetsList = snapshot.data;
                  List<Map<String, dynamic>> favoritePoets =
                      poetsList!.where((poet) {
                    String authorId = poet['ID_Auteur'];
                    String nom = poet['nom'];
                    String prenom = poet['prenom'];
                    return favoriteAuthors
                            .any((author) => author.authorId == authorId) &&
                        (nom
                                .toLowerCase()
                                .contains(_searchText.toLowerCase()) ||
                            prenom
                                .toLowerCase()
                                .contains(_searchText.toLowerCase()));
                  }).toList();

                  return ListView.builder(
                    itemCount: favoritePoets.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> poet = favoritePoets[index];
                      String nom = poet['nom'];
                      String prenom = poet['prenom'];
                      String authorId = poet['ID_Auteur'];
                      bool isFavorite = favoriteAuthors
                          .any((author) => author.authorId == authorId);

                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeewanParAuteurPage(
                                  authorId: authorId,
                                  poetFirstname: nom,
                                  poetLastname: prenom,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[50],
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
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
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite
                                          ? Colors.red
                                          : Colors.teal[900],
                                    ),
                                    onPressed: () {
                                      toggleFavorite(authorId);
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '$nom',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.05,
                                      color: Colors.teal[900],
                                    ),
                                  ),
                                  Text(
                                    '$prenom',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.05,
                                      color: Colors.teal[900],
                                    ),
                                  ),
                                  Text(
                                    'عدد الدواوين: ${poet['deewanCount']}',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.teal[900],
                                    ),
                                  ),
                                  Text(
                                    'عدد القصائد: ${poet['poemCount']}',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.teal[900],
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImagePage(
                                        imageUrl: 'images/$nom.jpg',
                                        tag: 'hero-$nom',
                                      ),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: 'hero-$nom',
                                  child: CircleAvatar(
                                    backgroundImage:
                                        AssetImage('images/$nom.jpg'),
                                    radius: 30.0,
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Change this to true to keep the state
}
