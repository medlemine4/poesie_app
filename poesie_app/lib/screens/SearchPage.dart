// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_author.dart';
import 'search_result_page.dart'; // Importer la page des résultats de recherche

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController = TextEditingController();
  List<historical> _searchHistory = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('searchHistory');
    if (history != null) {
      setState(() {
        _searchHistory =
            history.map((item) => historical(historic: item)).toList();
        _searchHistory.sort((a, b) =>
            b.timestamp.compareTo(a.timestamp)); // Sort by most recent
      });
    }
  }

  void _saveSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = _searchHistory.map((item) => item.historic).toList();
    await prefs.setStringList('searchHistory', history);
  }

  void _performSearch(String searchText) {
    // Logic to perform the search with the search text.
    // After performing the search, navigate to the results page.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultPage(
            searchText: searchText), // Pass the search text to the results page
      ),
    );
  }

  void _clearSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() {
      _searchHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'صفحة البحث',
          style: TextStyle(fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor:
            Color.fromARGB(255, 230, 230, 145), // Couleur de l'app bar
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: screenHeight * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Container(
                decoration: BoxDecoration(
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
                    hintText: '...أدخل بحثك هنا',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: IconButton(
                      onPressed: () {
                        String searchText = _searchController.text.trim();
                        if (searchText.isNotEmpty) {
                          setState(() {
                            if (!_searchHistory
                                .any((item) => item.historic == searchText)) {
                              _searchHistory
                                  .add(historical(historic: searchText));
                              _saveSearchHistory();
                              _searchHistory.sort((a, b) => b.timestamp
                                  .compareTo(
                                      a.timestamp)); // Sort by most recent
                            }
                          });
                          _performSearch(searchText);
                        }
                      },
                      icon: Icon(Icons.search, color: Colors.grey),
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
                    contentPadding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.04),
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
                  textAlign: TextAlign.right,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    String searchText = value.trim();
                    if (searchText.isNotEmpty) {
                      setState(() {
                        if (!_searchHistory
                            .any((item) => item.historic == searchText)) {
                          _searchHistory.add(historical(historic: searchText));
                          _saveSearchHistory();
                          _searchHistory.sort((a, b) => b.timestamp
                              .compareTo(a.timestamp)); // Sort by most recent
                        }
                      });
                      _performSearch(searchText);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: _clearSearchHistory,
                  color: Colors.red,
                ),
                Text(
                  'البحث الأخير',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            Expanded(
              child: _searchHistory.isEmpty
                  ? Center(
                      child: Text('لا توجد نتائج بحث'),
                    )
                  : ListView.separated(
                      itemCount: _searchHistory.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _searchHistory.removeAt(index);
                                  _saveSearchHistory();
                                });
                              },
                              color: Colors.red,
                            ),
                            Expanded(
                              child: ListTile(
                                onTap: () {
                                  _performSearch(
                                      _searchHistory[index].historic);
                                },
                                title: Text(
                                  _searchHistory[index].historic,
                                  style: TextStyle(fontSize: 16.0),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
