// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class AuthorImagePage extends StatelessWidget {
  final String imagePath;

  const AuthorImagePage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black.withOpacity(0.9), // Semi-transparent black background
      body: GestureDetector(
        // GestureDetector to handle tap events
        onTap: () {
          Navigator.pop(
              context); // Pop the page when tapped anywhere on the screen
        },
        child: Stack(
          // Stack to overlay close button on top of the image
          children: [
            Center(
              // Center the image
              child: PhotoView(
                imageProvider: AssetImage(imagePath),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: imagePath),
              ),
            ),
            Positioned(
              // Positioned widget to place the close button at the top right corner
              top: 40,
              right: 20,
              child: IconButton(
                icon:
                    Icon(Icons.close, color: Colors.white), // Close button icon
                onPressed: () {
                  Navigator.pop(
                      context); // Pop the page when close button is pressed
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
