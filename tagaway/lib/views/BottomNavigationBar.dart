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
  static const String id = 'bottom_navigation_view';

  const BottomNavigationView({Key? key}) : super(key: key);

  @override
  State<BottomNavigationView> createState() => _BottomNavigationViewState();
}

class _BottomNavigationViewState extends State<BottomNavigationView> {
  int currentIndex = 0;
  final screens = [const HomeView(), const LocalView(), const UploadedView()];

  @override
  void initState() {
    super.initState();
    StoreService.instance.updateStream.stream.listen((value) async {
      if (value != 'currentIndex') return;
      dynamic CurrentIndex = await StoreService.instance.get('currentIndex');
      setState(() {
        currentIndex = CurrentIndex;
      });
    });
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
             StoreService.instance.set ('currentIndex', index);
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
