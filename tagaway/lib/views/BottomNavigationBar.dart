// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/views/home.dart';
import 'package:tagaway/views/local.dart';
import 'package:tagaway/views/uploaded.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int currentIndex = 0;
  final screens = [const Home(), const LocalView(), const UploadedView()];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: kAltoBlue,
          unselectedItemColor: kGreyDarker,
          iconSize: 38,
          currentIndex: currentIndex,
          unselectedLabelStyle: kBottomNavigationText,
          selectedLabelStyle: kBottomNavigationText,
          onTap: (index) => setState(() => currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.smartphone), label: 'Local'),
            BottomNavigationBarItem(
                icon: Icon(Icons.cloud_upload_outlined), label: 'Uploaded'),
          ],
        ),
      );
}
