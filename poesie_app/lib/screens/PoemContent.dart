// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class PoemContent extends StatelessWidget {
  final String poemTitle;
  final String poemContent;

  PoemContent({required this.poemTitle, required this.poemContent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          poemTitle,
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 230, 145),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Text(
            poemContent,
            style: TextStyle(fontFamily: 'Amiri', fontSize: 18.0),
          ),
        ),
      ),
    );
  }
}
