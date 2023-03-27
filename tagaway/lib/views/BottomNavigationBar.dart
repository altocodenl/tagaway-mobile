// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/views/homeView.dart';
import 'package:tagaway/views/localView.dart';
import 'package:tagaway/views/uploadedView.dart';

import 'package:tagaway/services/storeService.dart';

class BottomNavigationView extends StatefulWidget {
  static const String id = 'bottomNavigation';

  const BottomNavigationView({Key? key}) : super(key: key);

  @override
  State<BottomNavigationView> createState() => _BottomNavigationViewState();
}

class _BottomNavigationViewState extends State<BottomNavigationView> {
  dynamic cancelListener;

  int currentIndex = 0;
  final screens = [const HomeView(), const LocalView(), const UploadedView()];

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen(['currentIndex'], (v) {
      // When the view changes, reset state variables that are used by both Local and Uploaded
      StoreService.instance.set ('currentlyTagging', '', true);
      StoreService.instance.set ('swiped', false, true);
      StoreService.instance.set ('newTag', '', true);
      StoreService.instance.set ('startTaggingModal', false, true);
      StoreService.instance.set ('taggedPivCount', '', true);
      setState(() => currentIndex = v == '' ? 0 : v);
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

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
          onTap: (index) {
            StoreService.instance.set('currentIndex', index, true);
          },
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
