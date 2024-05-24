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
  List<Map<String, dynamic>> poetsList = [];

  @override
  void initState() {
    super.initState();
    loadFavoriteAuthors();
    loadPoetDetails();
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

  void loadPoetDetails() async {
    List<Map<String, dynamic>> data = await MongoDataBase.getPoetDetailsList();
    setState(() {
      poetsList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'قائمة الشعراء',
          style: TextStyle(
            fontSize: 27.0,
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
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
                  hintText: '...ابحث عن الشاعر عن طريق القائمة',
                  hintStyle: TextStyle(fontFamily: 'Almarai', fontSize: 14.0),
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
          Expanded(
            child: poetsList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _getFilteredPoets().length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> poet = _getFilteredPoets()[index];
                      String nom = poet['nom'];
                      String prenom = poet['prenom'];
                      String authorId = poet['ID_Auteur'];
                      int deewanCount = poet['deewanCount'];
                      int poemCount = poet['poemCount'];

                      bool isFavorite = favoriteAuthors.contains(authorId);

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.teal[100],
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
                            contentPadding: EdgeInsets.all(8),
                            trailing: GestureDetector(
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
                                  backgroundImage: AssetImage('images/$nom.jpg'),
                                  radius: 30,
                                ),
                              ),
                            ),
                            title: Text(
                              nom,
                              style: TextStyle(
                                fontFamily: 'Almarai',
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[900],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prenom,
                                  style: TextStyle(
                                    fontFamily: 'Almarai',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19.0,
                                    color: Colors.teal[900],
                                  ),
                                ),
                                Text(
                                  'عدد الدواوين: $deewanCount',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 16.0,
                                    color: Colors.teal[700],
                                  ),
                                ),
                                Text(
                                  'عدد القصائد: $poemCount',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 16.0,
                                    color: Colors.teal[700],
                                  ),
                                ),
                              ],
                            ),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
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
                                    color: Colors.teal[900],
                                  ),
                                ),
                                SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isFavorite = !isFavorite;
                                    });
                                    toggleFavorite(authorId);
                                  },
                                  icon: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : Colors.teal[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredPoets() {
    if (_searchText.isEmpty) {
      return poetsList;
    } else {
      return poetsList
          .where((poet) => _searchInPoet(poet, _searchText.toLowerCase()))
          .toList();
    }
  }

  bool _searchInPoet(Map<String, dynamic> poet, String searchText) {
    return poet.values.any((value) => value.toString().toLowerCase().contains(searchText));
  }
}
