import 'package:flutter/material.dart';
import 'package:poesie_app/models/favorite_author.dart';
import 'package:poesie_app/screens/DeewanParAuteurPage.dart';
import 'package:poesie_app/screens/PoetDetails.dart';
import 'package:poesie_app/screens/SearchPage.dart';
import '../data/mongo_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PoetPage extends StatefulWidget {
  @override
  _PoetPageState createState() => _PoetPageState();
}

class _PoetPageState extends State<PoetPage> {
  late TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<FavoriteAuthor> favoriteAuthors = [];

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
        favoriteAuthors =
            favoriteAuthorIds.map((id) => FavoriteAuthor(authorId: id)).toList();
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
          'الشعراء',
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
                      hintText: 'ابحث عن الشاعر',
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
                    _searchController.clear();
                    setState(() {
                      _searchText = '';
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
                  // Filtrer les données en fonction du texte de recherche
                  List<Map<String, dynamic>> filteredPoetsList = _searchText.isEmpty
                      ? poetsList!
                      : poetsList!
                          .where((poet) =>
                              _searchInPoet(poet, _searchText.toLowerCase()))
                          .toList();
                  return ListView.builder(
                    itemCount: filteredPoetsList.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> poet = filteredPoetsList[index];
                      String nom = poet['nom'];
                      String prenom = poet['prenom'];
                      String authorId = poet['ID_Auteur'];

                      bool isFavorite =
                          favoriteAuthors.any((author) => author.authorId == authorId);

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
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    nom,
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 20.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    prenom,
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 20.0,
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

  bool _searchInPoet(Map<String, dynamic> poet, String searchText) {
    // Rechercher dans tous les champs du poète
    return poet.values.any((value) => value.toString().toLowerCase().contains(searchText));
  }
}
