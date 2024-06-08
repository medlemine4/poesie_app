// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:poesie_app/screens/PoemListPage.dart';
import 'package:poesie_app/screens/SearchPage.dart';
import '../data/mongo_database.dart';

class DeewanPage extends StatefulWidget {
  final int? authorId;
  DeewanPage({this.authorId});

  @override
  _DeewanPageState createState() => _DeewanPageState();
}

class _DeewanPageState extends State<DeewanPage> {
  late TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'قائمة الدواوين',
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.white,
        ),
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal[300],
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
                  hintText: '...ابحث في قائمة الدواوين',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: MongoDataBase.getDeewanNames().timeout(
                Duration(seconds: 30),
                onTimeout: () {
                  showSnackbar(
                    '!تحقق من اتصالك بالإنترنت',
                    context,
                  );
                  return [];
                },
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  showSnackbar('Error: ${snapshot.error}', context);
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<Map<String, dynamic>>? deewans = snapshot.data;
                  if (deewans == null || deewans.isEmpty) {
                    return Center(
                        child: Text('لا توجد قصائد متاحة في هذا الديوان'));
                  }
                  // Filtrer les données en fonction du texte de recherche :
                  List<Map<String, dynamic>> filteredDeewans =
                      _searchText.isEmpty
                          ? deewans
                          : deewans
                              .where((deewan) => (deewan['nom'] as String)
                                  .toLowerCase()
                                  .contains(_searchText.toLowerCase()))
                              .toList();
                  return ListView.builder(
                    itemCount: filteredDeewans.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> deewan = filteredDeewans[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PoemListScreen(
                                deewanId: deewan['Id_Deewan'].toString(),
                                deewan_name: deewan['nom'].toString(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.teal[300],
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
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      deewan['nom'] ?? '',
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'عدد القصائد: ${deewan['poemCount'] ?? 0}',
                                      style: TextStyle(
                                        fontFamily: 'Almarai',
                                        fontSize: 16.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 30.0),
                                Icon(Icons.book, color: Colors.blue),
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

  void showSnackbar(String message, BuildContext context) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: TopSnackBar(
          message: message,
          onClose: () {
            overlayEntry?.remove();
          },
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    Future.delayed(Duration(seconds: 5), () {
      overlayEntry?.remove();
    });
  }
}

class TopSnackBar extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  TopSnackBar({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(16.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Almarai',
                ),
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(Icons.close, color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
