// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:poesie_app/data/mongo_database.dart';
import 'package:poesie_app/models/favorite_author.dart';
import 'package:poesie_app/screens/DeewanParAuteurPage.dart';
import 'package:poesie_app/screens/PoemContent.dart';
import 'package:poesie_app/screens/PoemDetails.dart';
import 'package:poesie_app/screens/PoemListPage.dart';
import 'package:poesie_app/screens/PoetDetails.dart';
import 'package:poesie_app/screens/full_screen_image_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // To handle JSON encoding and decoding

class SearchResultPage extends StatefulWidget {
  final String searchText;

  const SearchResultPage({Key? key, required this.searchText})
      : super(key: key);

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  List<FavoriteAuthor> favoriteAuthors = [];
  List<FavoritePoem> favoritePoems = [];
  List<Map<String, dynamic>> allResults = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
    loadSavedResults();
  }

  void loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriteAuthorIds = prefs.getStringList('favoriteAuthors');
    List<String>? favoritePoemIds = prefs.getStringList('favoritePoems');

    if (favoriteAuthorIds != null) {
      setState(() {
        favoriteAuthors = favoriteAuthorIds
            .map((id) => FavoriteAuthor(authorId: id))
            .toList();
      });
    }

    if (favoritePoemIds != null) {
      setState(() {
        favoritePoems =
            favoritePoemIds.map((id) => FavoritePoem(poemId: id)).toList();
      });
    }
  }

  void saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteAuthorIds =
        favoriteAuthors.map((author) => author.authorId).toList();
    List<String> favoritePoemIds =
        favoritePoems.map((poem) => poem.poemId).toList();

    await prefs.setStringList('favoriteAuthors', favoriteAuthorIds);
    await prefs.setStringList('favoritePoems', favoritePoemIds);
  }

  void loadSavedResults() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedResults =
        prefs.getString('searchResults_${widget.searchText}');

    if (savedResults != null) {
      setState(() {
        allResults = List<Map<String, dynamic>>.from(json.decode(savedResults));
      });
    } else {
      // Fetch results if not saved
      List<Map<String, dynamic>>? fetchedResults = await loadResults();
      if (fetchedResults != null) {
        setState(() {
          allResults = fetchedResults;
          saveResults(fetchedResults);
        });
      }
    }
  }

  void saveResults(List<Map<String, dynamic>> results) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'searchResults_${widget.searchText}', json.encode(results));
  }

  Future<List<Map<String, dynamic>>?> loadResults() async {
    try {
      List<Map<String, dynamic>> poemsList =
          await MongoDataBase.searchAllCollections(widget.searchText);

      List<Map<String, dynamic>> allResults = [];
      allResults.addAll(poemsList);

      return allResults;
    } catch (error) {
      print('Error loading results: $error');
      return null;
    }
  }

  void toggleFavoriteAuthor(String authorId) {
    setState(() {
      if (favoriteAuthors.any((author) => author.authorId == authorId)) {
        favoriteAuthors.removeWhere((author) => author.authorId == authorId);
      } else {
        favoriteAuthors.add(FavoriteAuthor(authorId: authorId));
      }
      saveFavorites();
    });
  }

  void toggleFavoritePoem(String poemId) {
    setState(() {
      if (favoritePoems.any((poem) => poem.poemId == poemId)) {
        favoritePoems.removeWhere((poem) => poem.poemId == poemId);
      } else {
        favoritePoems.add(FavoritePoem(poemId: poemId));
      }
      saveFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'نتائج البحث',
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
      ),
      body: allResults.isEmpty
          ? FutureBuilder<List<Map<String, dynamic>>?>(
              future: loadResults(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning,
                          size: 50,
                          color: Colors.red,
                        ),
                        Text(
                          '...لا معلومات موجودة عن ما تبحث عنه للأسف',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                List<Map<String, dynamic>> results = snapshot.data!;
                saveResults(results);
                setState(() {
                  allResults = results;
                });

                return buildResultsList();
              },
            )
          : buildResultsList(),
    );
  }

  Widget buildResultsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.searchText.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'نتائج البحث عن : ${widget.searchText}',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: allResults.length,
            itemBuilder: (context, index) {
              var result = allResults[index];

              if (result.containsKey('nom') && result.containsKey('prenom')) {
                String nom = result['nom'];
                String prenom = result['prenom'];
                String lieuNaissance = result['lieu_naissance'] ?? '';
                String authorId = result['ID_Auteur'];
                int deewanCount = result['deewanCount'] ?? 0;
                int poemCount = result['poemCount'] ?? 0;

                bool isFavorite = favoriteAuthors
                    .any((author) => author.authorId == authorId);

                return _buildAuthorCard(nom, prenom, lieuNaissance, authorId,
                    deewanCount, poemCount, isFavorite);
              } else if (result.containsKey('Id_Deewan')) {
                String deewanId = result['Id_Deewan'].toString();
                String nom = result['nom'].toString();
                int nombrePoemes = result['poemCount'] ?? 0;

                return _buildDeewanCard(deewanId, nom, nombrePoemes);
              } else if (result.containsKey('Titre')) {
                String titre = result['Titre'] ?? '';
                String contenu = result['Contenue'] ?? '';
                String alBaher = result['AlBaher'] ?? '';
                String rawy = result['Rawy'] ?? '';
                String poemId = result['ID_Poeme'] ?? '';

                bool isFavorite =
                    favoritePoems.any((poem) => poem.poemId == poemId);

                return _buildPoemCard(
                    titre, contenu, alBaher, rawy, poemId, isFavorite);
              } else {
                return SizedBox();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorCard(String nom, String prenom, String lieuNaissance,
      String authorId, int deewanCount, int poemCount, bool isFavorite) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(20.0),
        shadowColor: Colors.black, // Added box shadow color
        child: InkWell(
          onTap: () {
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
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.teal[100],
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
                            builder: (context) => PoetDetails(
                              poetName: nom,
                              poetlastname: prenom,
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.info,
                        color: Colors.teal[900],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        toggleFavoriteAuthor(authorId);
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.teal[900],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$nom',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[900],
                      ),
                    ),
                    Text(
                      '$prenom',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[900],
                      ),
                    ),
                    Text(
                      'عدد الدواوين: $deewanCount',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 16.0,
                        color: Colors.teal[700],
                      ),
                    ),
                    Text(
                      'عدد القصائد: $poemCount',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 16.0,
                        color: Colors.teal[700],
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
                            tag: 'hero-$nom', imageUrl: 'images/$nom.jpg'),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage('images/$nom.jpg'),
                    radius: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeewanCard(String deewanId, String nom, int nombrePoemes) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PoemListScreen(
                  deewanId: deewanId,
                  deewan_name: nom,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.teal[300], // Updated color
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$nom', // Prefix "ديوان" to the name
                          style: TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ), // Add spacing between $nom and icon
                        Icon(Icons.book, color: Colors.blue),
                      ],
                    ),
                    SizedBox(height: 5), // Add some spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'عدد القصائد: $nombrePoemes',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 15.0,
                            color: Colors.grey[900],
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
  }

  Widget _buildPoemCard(String titre, String contenu, String alBaher,
      String rawy, String poemId, bool isFavorite) {
    int numberOfLines = computeLineCount(contenu);
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
          elevation: 5, // Increase elevation for a stronger shadow
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Use circular border radius
          ),
          color: Colors.teal[50], // Add background color
          shadowColor: Colors.grey.withOpacity(0.8), // Stronger shadow color
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
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.teal[900],
                          ),
                          onPressed: () {
                            toggleFavoritePoem(poemId);
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
                          'البحر:  $alBaher',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Almarai',
                              color: Colors.teal[900]),
                        ),
                        Text(
                          'الروي :  $rawy',
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
    );
  }
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

class AuthorImagePage extends StatelessWidget {
  final String imagePath;

  const AuthorImagePage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'صورة الشاعر',
          style: TextStyle(
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal[700],
      ),
      body: Center(
        child: PhotoView(
          imageProvider: AssetImage(imagePath),
        ),
      ),
    );
  }
}
