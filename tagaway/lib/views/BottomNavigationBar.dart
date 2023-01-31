// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/views/home.dart';
import 'package:tagaway/views/local.dart';
import 'package:tagaway/views/uploaded.dart';

class BottomNavigationView extends StatefulWidget {
  const BottomNavigationView({Key? key}) : super(key: key);

  @override
  State<BottomNavigationView> createState() => _BottomNavigationViewState();
}

class _BottomNavigationViewState extends State<BottomNavigationView> {
  int currentIndex = 1;
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
          iconSize: 30,
          currentIndex: currentIndex,
          unselectedLabelStyle: kBottomNavigationText,
          selectedLabelStyle: kBottomNavigationText,
          onTap: (index) => setState(() => currentIndex = index),
          items: const [
            BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.house), label: 'Home'),
            BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.mobileScreenButton),
                label: 'Local'),
            BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.cloudArrowUp), label: 'Uploaded'),
          ],
        ),
      );
}
