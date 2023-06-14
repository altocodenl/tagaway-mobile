// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagaway/services/storeService.dart';

// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/homeView.dart';
import 'package:tagaway/views/localView.dart';
import 'package:tagaway/views/uploadedView.dart';

class BottomNavigationView extends StatefulWidget {
  static const String id = 'bottomNavigation';

  const BottomNavigationView({Key? key}) : super(key: key);

  @override
  State<BottomNavigationView> createState() => _BottomNavigationViewState();
}

class _BottomNavigationViewState extends State<BottomNavigationView> {
  dynamic cancelListener;
  dynamic countLocal = '';
  dynamic countUploaded = '';

  int currentIndex = 0;
  final screens = [const HomeView(), const LocalView(), const UploadedView()];

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance
        .listen(['currentIndex', 'countLocal', 'countUploaded'], (v1, v2, v3) {
      setState(() {
        currentIndex = v1 == '' ? 0 : v1;
        countLocal = v2.toString();
        countUploaded = v3.toString();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Stack(
          children: [
            BottomNavigationBar(
              selectedItemColor: kAltoBlue,
              unselectedItemColor: kGreyDarker,
              iconSize: 25,
              currentIndex: currentIndex,
              unselectedLabelStyle: kBottomNavigationText,
              selectedLabelStyle: kBottomNavigationText,
              onTap: (index) {
                StoreService.instance.set('currentIndex', index);
              },
              items: [
                BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.house), label: ''),
                BottomNavigationBarItem(
                    icon: FaIcon(FontAwesomeIcons.mobileScreenButton),
                    label: countLocal),
                BottomNavigationBarItem(
                    icon: FaIcon(kCloudArrowUp), label: countUploaded),
              ],
            ),
            const UploadingNumber()
          ],
        ),
      );
}
