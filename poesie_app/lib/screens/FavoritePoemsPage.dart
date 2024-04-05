import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poesie_app/models/favorite_author.dart'; // Importez le modèle de poème favori
import '../data/mongo_database.dart';
import 'PoemContent.dart'; // Importez la page du contenu du poème
import 'PoemDetails.dart'; // Importez la page de détails du poème

class FavoritePoemsPage extends StatefulWidget {
  @override
  _FavoritePoemsPageState createState() => _FavoritePoemsPageState();
}

class _FavoritePoemsPageState extends State<FavoritePoemsPage> {
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
        favoritePoems = favoritePoemIds.map((id) => FavoritePoem(poemId: id)).toList();
      });
    }
  }

  void saveFavoritePoems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritePoemIds = favoritePoems.map((poem) => poem.poemId).toList();
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
          'القصائد المفضلة',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 230, 145),
      ),
      body: FutureBuilder(
        future: MongoDataBase.getAllPoems(), // Utilisez la méthode appropriée pour obtenir tous les poèmes
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>>? allPoems = snapshot.data;
            List<Map<String, dynamic>> favoritePoemsData = allPoems!.where((poem) {
              String poemId = poem['ID_Poeme'];
              return favoritePoems.any((favorite) => favorite.poemId == poemId);
            }).toList();
            return ListView.builder(
              itemCount: favoritePoemsData.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> poem = favoritePoemsData[index];
                String poemId = poem['ID_Poeme'] ?? '';
                String titre = poem['Titre'] ?? '';
                String contenu = poem['Contenue'] ?? '';
                String alBaher = poem['AlBaher'] ?? '';
                String rawy = poem['Rawy'] ?? '';
                bool isFavorite = favoritePoems.any((poem) => poem.poemId == poemId);
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
                                      icon: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        toggleFavorite(poemId);
                                      },
                                    ),
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
              },
            );
          }
        },
      ),
    );
  }
}
