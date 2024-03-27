// File: lib/screens/poet_list_page.dart

// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class PoetListPage extends StatelessWidget {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 237, 237, 182),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
