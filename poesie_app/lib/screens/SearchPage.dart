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
        _searchHistory = history.map((item) => historical(historic: item)).toList();
      });
    }
  }

  void _saveSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = _searchHistory.map((item) => item.historic).toList();
    await prefs.setStringList('searchHistory', history);
  }

  void _performSearch(String searchText) {
    // Logique pour effectuer la recherche avec le texte de recherche.
    // Après avoir effectué la recherche, naviguez vers la page des résultats.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultPage(searchText: searchText), // Passer le texte de recherche à la page des résultats
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    // Met à jour le texte de recherche à chaque modification.
                  });
                },
                decoration: InputDecoration(
                  hintText: 'ابحث هنا...',
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                String searchText = _searchController.text.trim();
                if (searchText.isNotEmpty) {
                  setState(() {
                    // Ajoute le mot dans l'historique s'il n'existe pas déjà.
                    if (!_searchHistory.any((item) => item.historic == searchText)) {
                      _searchHistory.add(historical(historic: searchText));
                      _saveSearchHistory();
                    }
                  });
                  _performSearch(searchText);
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_searchHistory[index].historic),
                  onTap: () {
                    _performSearch(_searchHistory[index].historic);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
