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

  void _clearSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() {
      _searchHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'البحث',
          style: TextStyle(fontSize: 20.0),
        ),
        backgroundColor: Color.fromARGB(255, 230, 230, 145), // Couleur de l'app bar
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'أدخل بحثك هنا',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                String searchText = _searchController.text.trim();
                if (searchText.isNotEmpty) {
                  setState(() {
                    // Ajouter le terme à l'historique s'il n'existe pas déjà.
                    if (!_searchHistory.any((item) => item.historic == searchText)) {
                      _searchHistory.add(historical(historic: searchText));
                      _saveSearchHistory();
                    }
                  });
                  _performSearch(searchText);
                }
              },
              child: Text(
                'ابحث',
                style: TextStyle(fontSize: 18.0),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Couleur du bouton
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'سجل البحث',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchHistory.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _performSearch(_searchHistory[index].historic);
                    },
                    child: Card(
                      elevation: 3.0,
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          _searchHistory[index].historic,
                          style: TextStyle(fontSize: 16.0),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _clearSearchHistory,
              color: Colors.red, // Couleur de l'icône
            ),
          ],
        ),
      ),
    );
  }
}
