import 'package:flutter/material.dart';
import 'package:poesie_app/models/favorite_author.dart';
import 'package:poesie_app/screens/DeewanParAuteurPage.dart';
import 'package:poesie_app/screens/PoemContent.dart';
import 'package:poesie_app/screens/PoemDetails.dart';
import 'package:poesie_app/screens/PoemListPage.dart';
import 'package:poesie_app/screens/PoetDetails.dart';
import '../data/mongo_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        title: Text('نتائج البحث'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: loadResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Error loading data'));
          }

          List<Map<String, dynamic>> allResults = snapshot.data!;

          return ListView.builder(
            itemCount: allResults.length,
            itemBuilder: (context, index) {
              var result = allResults[index];
              if (displayedResults.contains(result.toString())) {
                return SizedBox(); // Si l'élément est déjà affiché, ne rien afficher
              }

              displayedResults.add(result
                  .toString()); // Ajouter l'élément à l'ensemble des éléments déjà affichés

              if (result.containsKey('nom') && result.containsKey('prenom')) {
                // C'est un auteur
                String nom = result['nom'];
                String prenom = result['prenom'];
                String lieuNaissance = result['lieu_naissance'] ?? '';
                String authorId = result['ID_Auteur'];

                bool isFavorite = favoriteAuthors
                    .any((author) => author.authorId == authorId);

                return _buildAuthorCard(
                    nom, prenom, lieuNaissance, authorId, isFavorite);
              } else if (result.containsKey('Id_Deewan')) {
                // C'est un deewan
                String deewanId = result['Id_Deewan'].toString();
                String nom = result['nom'].toString();

                return _buildDeewanCard(deewanId, nom);
              } else if (result.containsKey('Titre')) {
                // C'est un poème
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
                return SizedBox(); // Gérer d'autres types d'éléments si nécessaire
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildAuthorCard(String nom, String prenom, String lieuNaissance,
      String authorId, bool isFavorite) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
          backgroundColor: Colors.white,
          padding: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    toggleFavoriteAuthor(authorId);
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$nom $prenom',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      lieuNaissance,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundImage: AssetImage('images/$nom.jpg'),
                  radius: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeewanCard(String deewanId, String nom) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoemListScreen(
              deewanId: deewanId,
              poetLastname: nom,
              poetFirstname: '',
            ),
          ),
        );
      },
      child: Card(
        elevation: 2.0,
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.info),
                    onPressed: () {
                      // Add functionality for info button
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    nom,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Icon(Icons.book, color: Colors.blue),
                ],
              ),
            ],
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
          elevation: 4,
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
                          icon: Icon(Icons.info, color: Colors.black),
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
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'البحر: $alBaher',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'الروي : $rawy',
                          style: TextStyle(fontSize: 16),
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
