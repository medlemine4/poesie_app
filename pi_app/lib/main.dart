import 'package:flutter/material.dart';
import 'package:pi_app/mongodb.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDataBase.connect();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diwan elArab',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diwan elArab'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'القصائد المميزة',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Container(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Ajoute ici des cartes représentant les poésies populaires
                  PoetryCard(title: 'قصيدة 1', author: 'الشاعر 1'),
                  PoetryCard(title: 'قصيدة 2', author: 'الشاعر 2'),
                  PoetryCard(title: 'قصيدة 3', author: 'الشاعر 3'),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'آخر القصائد',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: ListView(
                children: [
                  // Ajoute ici des listTiles représentant les dernières poésies
                  ListTile(
                    title: Text('عنوان القصيدة الأولى'),
                    subtitle: Text('الشاعر: الشاعر 1'),
                    onTap: () {
                      // Naviguer vers la page de la première poésie
                    },
                  ),
                  ListTile(
                    title: Text('عنوان القصيدة الثانية'),
                    subtitle: Text('الشاعر: الشاعر 2'),
                    onTap: () {
                      // Naviguer vers la page de la deuxième poésie
                    },
                  ),
                  ListTile(
                    title: Text('عنوان القصيدة الثالثة'),
                    subtitle: Text('الشاعر: الشاعر 3'),
                    onTap: () {
                      // Naviguer vers la page de la troisième poésie
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0,
          alignment: Alignment.center,
          child: Text(
            'جميع الحقوق محفوظة © 2024 تطوير بواسطة [اسم الشركة]',
            style: TextStyle(color: Colors.white),
          ),
        ),
        color: Colors.blue,
      ),
    );
  }
}

class PoetryCard extends StatelessWidget {
  final String title;
  final String author;

  PoetryCard({required this.title, required this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5.0),
            Text(
              'الشاعر: $author',
              style: TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }
}