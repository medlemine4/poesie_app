// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations, prefer_const_literals_to_create_immutables, unused_import

import 'package:flutter/material.dart';
import 'package:poesie_app/models/favorite_author.dart';
import 'package:poesie_app/screens/DeewanParAuteurPage.dart';
import 'package:poesie_app/screens/PoemContent.dart';
import 'package:poesie_app/screens/PoemDetails.dart';
import 'package:poesie_app/screens/PoemListPage.dart';
import 'package:poesie_app/screens/PoetDetails.dart';
import 'package:poesie_app/screens/photo_view_gallery.dart';
import '../data/mongo_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
  Set<String> displayedResults = Set();

  @override
  void initState() {
    super.initState();
    loadFavorites();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'نتائج البحث',
          style: TextStyle(
              fontSize: 24.0,
              fontFamily: 'Almarai',
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color here
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
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

          List<Map<String, dynamic>> allResults = snapshot.data!;

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
                    if (displayedResults.contains(result.toString())) {
                      return SizedBox();
                    }

                    displayedResults.add(result.toString());

                    if (result.containsKey('nom') &&
                        result.containsKey('prenom')) {
                      String nom = result['nom'];
                      String prenom = result['prenom'];
                      String lieuNaissance = result['lieu_naissance'] ?? '';
                      String authorId = result['ID_Auteur'];

                      bool isFavorite = favoriteAuthors
                          .any((author) => author.authorId == authorId);

                      return _buildAuthorCard(
                          nom, prenom, lieuNaissance, authorId, isFavorite);
                    } else if (result.containsKey('Id_Deewan')) {
                      String deewanId = result['Id_Deewan'].toString();
                      String nom = result['nom'].toString();

                      return _buildDeewanCard(deewanId, nom);
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
        },
      ),
    );
  }

  Widget _buildAuthorCard(String nom, String prenom, String lieuNaissance,
      String authorId, bool isFavorite) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(20.0),
        shadowColor: Colors.black, // Added box shadow color
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AuthorImagePage(imagePath: 'images/$nom.jpg'),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.blueGrey[900],
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
                            builder: (context) => PoetDetails(poetName: nom),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.info,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        toggleFavoriteAuthor(authorId);
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
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
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$prenom',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AuthorImagePage(imagePath: 'images/$nom.jpg'),
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

  Widget _buildDeewanCard(String deewanId, String nom) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
              color: Colors.blue[200], // Updated color
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
                            color: Colors.black,
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
                        SizedBox(
                          width: 30.0,
                        ), // Push 'عدد القصائد' more towards left
                        Text(
                          ': عدد القصائد',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 15.0,
                            color: Colors.grey[700],
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
          color: Colors.indigo[400], // Add background color
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
                        Icon(Icons.info, color: Colors.white),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.black,
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
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'البحر:  $alBaher',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Almarai',
                              color: Colors.white),
                        ),
                        Text(
                          'الروي :  $rawy',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Almarai',
                              color: Colors.white),
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
