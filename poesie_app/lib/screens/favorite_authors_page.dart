import 'package:flutter/material.dart';
import 'package:poesie_app/screens/SearchPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poesie_app/models/favorite_author.dart';
import 'package:poesie_app/screens/DeewanParAuteurPage.dart';
import 'package:poesie_app/screens/PoetDetails.dart';
import '../data/mongo_database.dart';

class FavoriteAuthorsPage extends StatefulWidget {
  @override
  _FavoriteAuthorsPageState createState() => _FavoriteAuthorsPageState();
}

class _FavoriteAuthorsPageState extends State<FavoriteAuthorsPage> {
  List<FavoriteAuthor> favoriteAuthors = [];
  late TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    loadFavoriteAuthors();
  }

  void loadFavoriteAuthors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriteAuthorIds = prefs.getStringList('favoriteAuthors');
    if (favoriteAuthorIds != null) {
      setState(() {
        favoriteAuthors = favoriteAuthorIds
            .map((id) => FavoriteAuthor(authorId: id))
            .toList();
      });
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الشعراء المفضلين',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 230, 145),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث في الشعراء المفضلين',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _searchText = '';
                      _searchController.clear();
                    });
                  },
                  icon: Icon(Icons.clear),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: MongoDataBase.getPoetDetailsList(),
              builder: (context, snapshot) {
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
                    String lieuNaissance = poet['lieu_naissance'];
                    return favoriteAuthors
                            .any((author) => author.authorId == authorId) &&
                        (nom
                                .toLowerCase()
                                .contains(_searchText.toLowerCase()) ||
                            prenom
                                .toLowerCase()
                                .contains(_searchText.toLowerCase()) ||
                            lieuNaissance
                                .toLowerCase()
                                .contains(_searchText.toLowerCase()));
                  }).toList();

                  return ListView.builder(
                    itemCount: favoritePoets.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> poet = favoritePoets[index];
                      String nom = poet['nom'];
                      String prenom = poet['prenom'];
                      String lieuNaissance = poet['lieu_naissance'];
                      String authorId = poet['ID_Auteur'];

                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
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
                                    onPressed: () {
                                      toggleFavorite(authorId);
                                    },
                                    icon: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
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
                                    backgroundImage:
                                        AssetImage('images/$nom.jpg'),
                                    radius: 30,
                                  ),
                                ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SearchPage(), // Aller vers la page de recherche
            ),
          );
        },
        backgroundColor:
            Color.fromARGB(255, 230, 230, 145), // Couleur du bouton flottant
        child: Icon(Icons.search), // Icône de recherche
      ),
    );
  }
}
