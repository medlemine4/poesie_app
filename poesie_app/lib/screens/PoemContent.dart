import 'package:flutter/material.dart';

class PoemContent extends StatelessWidget {
  final String poemTitle;
  final String poemContent;

  PoemContent({required this.poemTitle, required this.poemContent});

  @override
  Widget build(BuildContext context) {
    List<String> lines = poemContent.split('\n').where((line) => line.trim().isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          poemTitle,
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 230, 145),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < lines.length; i++)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: i % 2 == 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                lines[i],
                                style: TextStyle(fontFamily: 'Almarai', fontSize: 18.0),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                lines[i],
                                style: TextStyle(fontFamily: 'Almarai', fontSize: 18.0),
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                          ],
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
