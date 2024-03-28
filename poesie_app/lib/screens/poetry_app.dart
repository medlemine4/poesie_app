// File: lib/screens/poetry_app.dart

// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'poet_list_page.dart';

class PoetryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ديوان العرب',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        primaryColor: Colors.yellow[800],
        fontFamily: 'Amiri',
      ),
      home: PoetListPage(),
    );
  }
}
