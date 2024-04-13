// File: lib/screens/poetry_app.dart

// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'First_screen.dart';

class PoetryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ديوان الشناقطة',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        primaryColor: Colors.yellow[800],
        fontFamily: 'Amiri',
      ),
      home: FirstScreen(),
    );
  }
}
