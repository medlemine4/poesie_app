// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:poesie_app/screens/PoetDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'full_screen_image_page.dart';
import 'package:poesie_app/screens/DeewanParAuteurPage.dart';
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
  String? _sortBy = 'name';

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
      _sortPoets();
    });
  }

  void _sortPoets() {
    if (_sortBy == 'name') {
      poetsList.sort((a, b) => a['nom'].compareTo(b['nom']));
    } else if (_sortBy == 'date_naissance') {
      poetsList.sort((a, b) =>
          (a['date_naissance'] as int).compareTo(b['date_naissance'] as int));
    } else {
      // Reset the filter and reload the poet details
      loadPoetDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    _sortPoets();

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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
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
                      hintStyle:
                          TextStyle(fontFamily: 'Almarai', fontSize: 14.0),
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
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
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
                SizedBox(height: 15),
                Container(
                  width: 12, // Adjust the width of the DropdownButton
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            Colors.teal[600]!,
                            Colors.teal[300]!,
                            Colors.teal[300]!
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          icon:
                              Icon(Icons.arrow_drop_down, color: Colors.white),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          onChanged: (String? newValue) {
                            setState(() {
                              if (newValue == "إلغاء التصفية") {
                                _sortBy = null; // Reset the filter
                              } else {
                                _sortBy = newValue!;
                              }
                            });
                          },
                          items: <String>[
                            'إلغاء التصفية',
                            'name',
                            'date_naissance'
                          ] // Add Cancel Filter option
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                onEnter: (event) => setState(() {}),
                                onExit: (event) => setState(() {}),
                                child: Tooltip(
                                  message: value == 'name'
                                      ? 'Sort by Name'
                                      : (value == 'date_naissance'
                                          ? 'Sort by Date of Birth'
                                          : 'إلغاء التصفية'),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      value == 'name'
                                          ? 'الاسم'
                                          : (value == 'date_naissance'
                                              ? 'تاريخ الميلاد'
                                              : 'إلغاء التصفية'),
                                      style: TextStyle(
                                        fontSize: 19,
                                        color: Colors.teal[700],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
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
                                    poetFirstname: nom,
                                    poetLastname: prenom,
                                    authorId: authorId,
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
                                  backgroundImage:
                                      AssetImage('images/$nom.jpg'),
                                  radius: 30,
                                ),
                              ),
                            ),
                            title: Text(
                              nom,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Almarai',
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
                                    fontSize: 18.0,
                                    fontFamily: 'Almarai',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[900],
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  'الدواوين: $deewanCount',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontFamily: 'Almarai',
                                    fontWeight: FontWeight.w400,
                                    color: Colors.teal[700],
                                  ),
                                ),
                                Text(
                                  'القصائد: $poemCount',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontFamily: 'Almarai',
                                    fontWeight: FontWeight.w400,
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
                                        builder: (context) =>
                                            PoetDetails(poetName: nom),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.info,
                                    color: Colors.teal[900],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isFavorite ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      toggleFavorite(authorId);
                                    });
                                  },
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
    List<Map<String, dynamic>> filteredPoets;
    if (_searchText.isEmpty) {
      filteredPoets = poetsList;
    } else {
      filteredPoets = poetsList
          .where((poet) => _searchInPoet(poet, _searchText.toLowerCase()))
          .toList();
    }
    return filteredPoets;
  }

  bool _searchInPoet(Map<String, dynamic> poet, String searchText) {
    return poet['nom'].toLowerCase().contains(searchText) ||
        poet['prenom'].toLowerCase().contains(searchText);
  }
}
