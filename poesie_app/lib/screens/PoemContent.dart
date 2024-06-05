// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class PoemContent extends StatefulWidget {
  final String poemTitle;
  final String poemContent;

  PoemContent({required this.poemTitle, required this.poemContent});

  @override
  _PoemContentState createState() => _PoemContentState();
}

class _PoemContentState extends State<PoemContent> {
  double _fontSize = 18.0;
  bool _isFavorite = false;
  late ThemeData _themeData;

  @override
  void initState() {
    super.initState();
    _themeData = _buildLightTheme();
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.teal[700],
      colorScheme: ColorScheme.light(
        primary: Colors.teal[700]!,
        secondary: Colors.teal[200]!,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: _fontSize, fontFamily: 'Almarai'),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.teal[900],
      colorScheme: ColorScheme.dark(
        primary: Colors.teal[900]!,
        secondary: Colors.teal[600]!,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: _fontSize, fontFamily: 'Almarai'),
      ),
    );
  }

  void _sharePoem() {
    final String contentToShare =
        "${widget.poemTitle.isEmpty ? 'Untitled Poem' : widget.poemTitle}\n\n${widget.poemContent}";
    Share.share(contentToShare);
  }

  void _copyPoem() {
    final String contentToCopy =
        "${widget.poemTitle.isEmpty ? 'Untitled Poem' : widget.poemTitle}\n\n${widget.poemContent}";
    Clipboard.setData(ClipboardData(text: contentToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Poem copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.poemContent.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Poem',
              style: TextStyle(
                fontSize: 27.0,
                fontFamily: 'Almarai',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.teal[700],
        ),
        body: Center(
          child: Text(
            'No content available',
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: 'Almarai',
            ),
          ),
        ),
      );
    }

    List<String> lines = widget.poemContent
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    return Theme(
      data: _themeData,
      child: Scaffold(
        appBar: AppBar(
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.poemTitle.isEmpty ? 'Untitled Poem' : widget.poemTitle,
              style: TextStyle(
                fontSize: 27.0,
                fontFamily: 'Almarai',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          centerTitle: true,
          backgroundColor: _themeData.primaryColor,
          actions: [
            IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: () {
                setState(() {
                  _themeData = _themeData.brightness == Brightness.dark
                      ? _buildLightTheme()
                      : _buildDarkTheme();
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.copy),
              onPressed: _copyPoem,
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _themeData.colorScheme.secondary.withOpacity(0.1),
                _themeData.colorScheme.secondary.withOpacity(0.3)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < lines.length; i += 1)
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(vertical: 6.0),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: (i ~/ 2) % 2 == 0
                            ? _themeData.colorScheme.secondary.withOpacity(0.5)
                            : _themeData.colorScheme.secondary.withOpacity(0.3),
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
                              style: TextStyle(
                                fontFamily: 'Almarai',
                                fontSize: _fontSize,
                                height:
                                    1.5, // Improved line height for better readability
                                letterSpacing:
                                    0.5, // Slight letter spacing for clarity
                                color: _themeData.primaryColorDark,
                              ),
                              textDirection: i % 2 == 0
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20), // Extra spacing at the bottom
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _sharePoem,
          backgroundColor: _themeData.primaryColor,
          child: Icon(Icons.share),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.zoom_out),
                  onPressed: () {
                    setState(() {
                      if (_fontSize > 12.0) _fontSize -= 2.0;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.zoom_in),
                  onPressed: () {
                    setState(() {
                      if (_fontSize < 36.0) _fontSize += 2.0;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
