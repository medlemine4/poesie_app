// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:poesie_app/screens/full_screen_image_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poesie_app/screens/DeewanParAuteurPage.dart';
import 'package:poesie_app/screens/PoetDetails.dart';
import 'package:poesie_app/screens/SearchPage.dart';
import '../data/mongo_database.dart';

class PoetPage extends StatefulWidget {
  @override
  _PoetPageState createState() => _PoetPageState();
}

class _PoetPageState extends State<PoetPage> {
  late TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<String> favoriteAuthors = [];

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
        favoriteAuthors = favoriteAuthorIds;
      });
    }
  }

  void saveFavoriteAuthors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteAuthors', favoriteAuthors);
  }

  void toggleFavorite(String authorId) {
    setState(() {
      if (favoriteAuthors.contains(authorId)) {
        favoriteAuthors.remove(authorId);
      } else {
        favoriteAuthors.add(authorId);
      }
      saveFavoriteAuthors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'قائمة الشعراء',
          style: TextStyle(fontFamily: 'Almarai', fontSize: 27.0),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 230, 145),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
                ),
              );
            },
            icon: Icon(Icons.search),
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Container(
              decoration: BoxDecoration(
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
                  hintText: 'ابحث عن الشاعر عن طريق القائمة',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchText = '';
                      });
                    },
                    icon: Icon(Icons.clear, color: Colors.grey),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
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

                      bool isFavorite = favoriteAuthors.contains(authorId);

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
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
                            contentPadding: EdgeInsets.all(10),
                            trailing: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImagePage(
                                      imageUrl: 'images/$nom.jpg', 
                                    ),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                backgroundImage: AssetImage('images/$nom.jpg'), 
                                radius: 30,
                              ),
                            ),
                            title: Text(
                              nom,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              prenom,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            ),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
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
    return poet.values.any((value) => value.toString().toLowerCase().contains(searchText));
  }
}
