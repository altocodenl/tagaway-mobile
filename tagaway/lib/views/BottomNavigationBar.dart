// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagaway/services/storeService.dart';
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/homeView.dart';
import 'package:tagaway/views/localView.dart';
import 'package:tagaway/views/shareView.dart';

class BottomNavigationView extends StatefulWidget {
  static const String id = 'bottomNavigation';

  const BottomNavigationView({Key? key}) : super(key: key);

  @override
  State<BottomNavigationView> createState() => _BottomNavigationViewState();
}

class _BottomNavigationViewState extends State<BottomNavigationView> {
  dynamic cancelListener;

  int viewIndex = 0;
  final screens = [const HomeView(), const LocalView(), const ShareView()];

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen(['viewIndex'], (v1) {
      setState(() {
        viewIndex = v1 == '' ? 0 : v1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: IndexedStack(
            index: viewIndex,
            children: screens,
          ),
          bottomNavigationBar: Stack(
            children: [
              BottomNavigationBar(
                selectedItemColor: kAltoBlue,
                unselectedItemColor: kGreyDarker,
                iconSize: 25,
                currentIndex: viewIndex,
                unselectedLabelStyle: kBottomNavigationText,
                selectedLabelStyle: kBottomNavigationText,
                onTap: (index) {
                  StoreService.instance.set('viewIndex', index);
                },
                items: [
                  const BottomNavigationBarItem(
                      icon: FaIcon(kHomeIcon), label: 'Home'),
                  const BottomNavigationBarItem(
                      icon: FaIcon(kMobilePhoneIcon), label: 'Phone'),
                  BottomNavigationBarItem(
                      icon: const FaIcon(kCloudArrowUp), label: 'Share'),
                ],
              ),
              const UploadingNumber()
            ],
          ),
        ),
      );
}
