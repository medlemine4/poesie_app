// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/téléchargement.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 150),
            Text(
              'ديوان الشناقطة',
              style: TextStyle(
                fontFamily: 'Gulzar',
                fontSize: 70,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 150),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(title: 'الشعراء'),
                  SizedBox(height: 20),
                  CustomButton(title: 'مفضلة الشعراء'),
                  SizedBox(height: 20),
                  CustomButton(title: 'مفضلة القصائد'),
                  SizedBox(height: 20),
                  CustomButton(title: 'الدواوين'),
                ],
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => SearchPage()),
      //     );
      //   },
      //   child: Icon(Icons.search),
      //   backgroundColor: Color.fromARGB(255, 237, 237, 182),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
