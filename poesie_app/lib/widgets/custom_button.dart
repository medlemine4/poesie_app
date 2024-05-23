import 'package:flutter/material.dart';
import 'package:poesie_app/screens/FavoritePoemsPage.dart';
import 'package:poesie_app/screens/poet_page.dart';
import '../screens/favorite_authors_page.dart';
import '../screens/deewan_page.dart';

class CustomButton extends StatelessWidget {
  final String title;

  CustomButton({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (title == 'الشعراء') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PoetPage()),
            );
          } else if (title == 'الدواوين') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DeewanPage()),
            );
          } else if (title == 'مفضلة الشعراء') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoriteAuthorsPage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoritePoemsPage()),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal, // Utilisation de la couleur teal
          textStyle: TextStyle(fontSize: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // Bord arrondi
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
