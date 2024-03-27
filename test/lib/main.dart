

// // import 'package:flutter/material.dart';
// // import 'package:mongo_dart/mongo_dart.dart' as mongo;

// // const MONGO_URL =
// //     "mongodb+srv://medleminehaj:22482188@maincluster.g7p5xjc.mongodb.net/poesie_DB?retryWrites=true&w=majority&appName=mainCluster";
// // const COLLECTION_NAME = "Auteur";
// // const COLLECTION_NAME2 = "Deewan";
// // const COLLECTION_NAME3 = "Poeme";

// // class MongoDataBase {
// //   static Future<List<String>> getPoetNames() async {
// //     var db = await mongo.Db.create(MONGO_URL);
// //     await db.open();
// //     var collection = db.collection(COLLECTION_NAME);
// //     var result = await collection.find().toList();
// //     await db.close();
// //     // Récupérer seulement les noms des auteurs
// //     return result.map((poet) => poet['nom'] as String).toList();
// //   }

// //   static Future<List<String>> getDeewanNames() async {
// //     var db = await mongo.Db.create(MONGO_URL);
// //     await db.open();
// //     var collection = db.collection(COLLECTION_NAME2);
// //     var result = await collection.find().toList();
// //     await db.close();
// //     // Récupérer seulement les noms des Deewan
// //     return result.map((deewan) => deewan['nom'] as String).toList();
// //   }
// // }

// // void main() {
// //   runApp(PoetryApp());
// // }

// // class PoetryApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       title: 'ديوان العرب',
// //       theme: ThemeData(
// //         primarySwatch: Colors.yellow,
// //         primaryColor: Colors.yellow[800],
// //         fontFamily: 'Amiri',
// //       ),
// //       home: PoetListPage(),
// //     );
// //   }
// // }

// // class PoetListPage extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         decoration: BoxDecoration(
// //           image: DecorationImage(
// //             image: AssetImage('images/téléchargement.jpg'),
// //             fit: BoxFit.cover,
// //           ),
// //         ),
// //         child: Column(
// //           children: [
// //             SizedBox(height: 150),
// //             Text(
// //               'ديوان الشناقطة',
// //               style: TextStyle(
// //                 fontFamily: 'Gulzar',
// //                 fontSize: 70,
// //                 color: Colors.green,
// //               ),
// //             ),
// //             SizedBox(height: 150),
// //             Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   CustomButton(title: 'الشعراء'),
// //                   SizedBox(height: 20),
// //                   CustomButton(title: 'مفضلة الشعراء'),
// //                   SizedBox(height: 20),
// //                   CustomButton(title: 'مفضلة القصائد'),
// //                   SizedBox(height: 20),
// //                   CustomButton(title: 'الدواوين'),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: () {},
// //         child: Icon(Icons.add),
// //         backgroundColor: Color.fromARGB(255, 237, 237, 182),
// //       ),
// //       floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
// //     );
// //   }
// // }

// // class CustomButton extends StatelessWidget {
// //   final String title;

// //   CustomButton({required this.title});

// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //       width: 200,
// //       height: 50,
// //       child: ElevatedButton(
// //         onPressed: () {
// //           if (title == 'الشعراء') {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(builder: (context) => PoetPage()),
// //             );
// //           } else if (title == 'الدواوين') {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(builder: (context) => DeewanPage()),
// //             );
// //           } else {
// //             // Traiter les autres boutons ici
// //           }
// //         },
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: Color.fromARGB(255, 230, 230, 145),
// //           textStyle: TextStyle(fontSize: 20),
// //         ),
// //         child: Text(
// //           title,
// //           style: TextStyle(
// //             fontFamily: 'Lateef',
// //             fontSize: 24,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class PoetPage extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(
// //           'الشعراء',
// //           style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
// //         ),
// //         centerTitle: true,
// //         backgroundColor: Color.fromARGB(255, 230, 230, 145),
// //       ),
// //       body: FutureBuilder<List<String>>(
// //         future: MongoDataBase.getPoetNames(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return Center(child: CircularProgressIndicator());
// //           } else if (snapshot.hasError) {
// //             return Center(child: Text('Error: ${snapshot.error}'));
// //           } else {
// //             List<String>? poets = snapshot.data;
// //             return ListView.builder(
// //               itemCount: poets!.length,
// //               itemBuilder: (context, index) {
// //                 return Padding(
// //                   padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
// //                   child: ElevatedButton(
// //                     onPressed: () {
// //                       // Naviguer vers la page des poèmes pour cet auteur
// //                     },
// //                     child: Text(
// //                       poets[index],
// //                       style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0),
// //                     ),
// //                     style: ElevatedButton.styleFrom(
// //                       foregroundColor: Colors.black,
// //                       backgroundColor: Color.fromARGB(255, 237, 237, 182),
// //                       padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(20.0),
// //                       ),
// //                     ),
// //                   ),
// //                 );
// //               },
// //             );
// //           }
// //         },
// //       ),
// //     );
// //   }
// // }

// // class DeewanPage extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(
// //           'الدواوين',
// //           style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
// //         ),
// //         centerTitle: true,
// //         backgroundColor: Color.fromARGB(255, 230, 230, 145),
// //       ),
// //       body: FutureBuilder<List<String>>(
// //         future: MongoDataBase.getDeewanNames(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return Center(child: CircularProgressIndicator());
// //           } else if (snapshot.hasError) {
// //             return Center(child: Text('Error: ${snapshot.error}'));
// //           } else {
// //             List<String>? deewans = snapshot.data;
// //             return ListView.builder(
// //               itemCount: deewans!.length,
// //               itemBuilder: (context, index) {
// //                 return Padding(
// //                   padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
// //                   child: ElevatedButton(
// //                     onPressed: () {
// //                       // Naviguer vers la page des poèmes pour cette ديوان
// //                     },
// //                     child: Text(
// //                       deewans[index],
// //                       style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0),
// //                     ),
// //                     style: ElevatedButton.styleFrom(
// //                       foregroundColor: Colors.black,
// //                       backgroundColor: Color.fromARGB(255, 237, 237, 182),
// //                       padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(20.0),
// //                       ),
// //                     ),
// //                   ),
// //                 );
// //               },
// //             );
// //           }
// //         },
// //       ),
// //     );
// //   }
// // }


// // ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

// import 'package:flutter/material.dart';
// import 'package:mongo_dart/mongo_dart.dart' as mongo;

// const MONGO_URL =
//     "mongodb+srv://medleminehaj:22482188@maincluster.g7p5xjc.mongodb.net/poesie_DB?retryWrites=true&w=majority&appName=mainCluster";
// const COLLECTION_NAME = "Auteur";
// const COLLECTION_NAME2 = "Deewan";
// const COLLECTION_NAME3 = "Poeme";

// class MongoDataBase {
//   static Future<List<String>> getPoetNames() async {
//     var db = await mongo.Db.create(MONGO_URL);
//     await db.open();
//     var collection = db.collection(COLLECTION_NAME);
//     var result = await collection.find().toList();
//     await db.close();
//     // Récupérer seulement les noms des auteurs
//     return result.map((poet) => poet['nom'] as String).toList();
//   }

//   static Future<List<String>> getDeewanNames([int? authorId]) async {
//     var db = await mongo.Db.create(MONGO_URL);
//     await db.open();
//     var collection = db.collection(COLLECTION_NAME2);
//     var query = authorId != null ? mongo.where.eq('ID_Auteur', authorId) : {};
//     var result = await collection.find(query).toList();
//     await db.close();
//     // Récupérer seulement les noms des Deewan de l'auteur spécifié
//     return result.map((deewan) => deewan['nom'] as String).toList();
//   }
// }

// void main() {
//   runApp(PoetryApp());
// }

// class PoetryApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'ديوان العرب',
//       theme: ThemeData(
//         primarySwatch: Colors.yellow,
//         primaryColor: Colors.yellow[800],
//         fontFamily: 'Amiri',
//       ),
//       home: PoetListPage(),
//     );
//   }
// }

// class PoetListPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('images/téléchargement.jpg'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Column(
//           children: [
//             SizedBox(height: 150),
//             Text(
//               'ديوان الشناقطة',
//               style: TextStyle(
//                 fontFamily: 'Gulzar',
//                 fontSize: 70,
//                 color: Colors.green,
//               ),
//             ),
//             SizedBox(height: 150),
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CustomButton(title: 'الشعراء'),
//                   SizedBox(height: 20),
//                   CustomButton(title: 'مفضلة الشعراء'),
//                   SizedBox(height: 20),
//                   CustomButton(title: 'مفضلة القصائد'),
//                   SizedBox(height: 20),
//                   CustomButton(title: 'الدواوين'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {},
//         child: Icon(Icons.add),
//         backgroundColor: Color.fromARGB(255, 237, 237, 182),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
//     );
//   }
// }

// class CustomButton extends StatelessWidget {
//   final String title;

//   CustomButton({required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 200,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: () {
//           if (title == 'الشعراء') {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => PoetPage()),
//             );
//           } else if (title == 'الدواوين') {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => DeewanPage()),
//             );
//           } else {
//             // Traiter les autres boutons ici
//           }
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Color.fromARGB(255, 230, 230, 145),
//           textStyle: TextStyle(fontSize: 20),
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//             fontFamily: 'Lateef',
//             fontSize: 24,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PoetPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
     
// appBar: AppBar(
//         title: Text(
//           'الشعراء',
//           style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
//         ),
//         centerTitle: true,
//         backgroundColor: Color.fromARGB(255, 230, 230, 145),
//       ),
//       body: FutureBuilder<List<String>>(
//         future: MongoDataBase.getPoetNames(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             List<String>? poets = snapshot.data;
//             return ListView.builder(
//               itemCount: poets!.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => DeewanPage(authorId: index + 1),
//                         ),
//                       );
//                     },
//                     child: Text(
//                       poets[index],
//                       style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.black,
//                       backgroundColor: Color.fromARGB(255, 237, 237, 182),
//                       padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// class DeewanPage extends StatelessWidget {
//   final int? authorId;

//   DeewanPage({this.authorId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'الدواوين',
//           style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
//         ),
//         centerTitle: true,
//         backgroundColor: Color.fromARGB(255, 230, 230, 145),
//       ),
//       body: FutureBuilder<List<String>>(
//         future: MongoDataBase.getDeewanNames(authorId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             List<String>? deewans = snapshot.data;
//             return ListView.builder(
//               itemCount: deewans!.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Naviguer vers la page des poèmes pour ce ديوان
//                     },
//                     child: Text(
//                       deewans[index],
//                       style: TextStyle(fontFamily: 'Amiri', fontSize: 20.0),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.black,
//                       backgroundColor: Color.fromARGB(255, 237, 237, 182),
//                       padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20.0),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
// File: lib/main.dart
import 'package:flutter/material.dart';
import 'screens/poetry_app.dart';

void main() {
  runApp(PoetryApp());
}
