// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class PoemContent extends StatelessWidget {
  final String poemTitle;
  final String poemContent;

  PoemContent({required this.poemTitle, required this.poemContent});

  @override
  Widget build(BuildContext context) {
    // Ensure poem content is not empty
    if (poemContent.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Poem',
            style: TextStyle(
                fontSize: 27.0,
                fontFamily: 'Almarai',
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.teal[700],
        ),
        body: Center(
          child: Text(
            'No content available',
            style: TextStyle(fontSize: 18.0, fontFamily: 'Almarai'),
          ),
        ),
      );
    }

    List<String> lines = poemContent
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          poemTitle.isEmpty ? 'Untitled Poem' : poemTitle,
          style: const TextStyle(
              fontSize: 27.0,
              fontFamily: 'Almarai',
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[50]!, Colors.teal[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < lines.length; i += 2)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: i % 2 == 0 ? Colors.white : Colors.teal[50],
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: i % 2 == 0
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            lines[i],
                            style: const TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 18.0,
                            ),
                            textDirection: i % 2 == 0
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
