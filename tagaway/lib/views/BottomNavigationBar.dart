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

  int viewIndex = 1;
  final screens = [const HomeView(), const LocalView(), const ShareView()];

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen(['viewIndex'], (v1) {
      if (v1 == '') return StoreService.instance.set('viewIndex', 1);
      setState(() {
        viewIndex = v1;
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
                  StoreService.instance.remove('showButtonsLocal');
                  StoreService.instance.remove('swipedLocal');
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: FaIcon(kHomeIcon), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: FaIcon(kMobilePhoneIcon), label: 'Phone'),
                  BottomNavigationBarItem(
                      icon: FaIcon(kShareUsersIcon), label: 'Share'),
                ],
              ),
              const UploadingNumber()
            ],
          ),
        ),
      );
}

class UploadingNumber extends StatefulWidget {
  const UploadingNumber({
    Key? key,
  }) : super(key: key);

  @override
  State<UploadingNumber> createState() => _UploadingNumberState();
}

class _UploadingNumberState extends State<UploadingNumber> {
  dynamic cancelListener;
  int numeroli = 0;

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen(['uploadQueue'], (v1) {
      if (v1 != '') setState(() => numeroli = v1.length);
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

  @override
  Widget build(BuildContext context) {
    if (numeroli == 0) return const Text('');
    return Positioned(
      left: SizeService.instance.screenWidth(context) * .31,
      top: 10,
      child: SizedBox(
        height: 30,
        child: Center(
          child: Column(
            children: [
              Text(
                numeroli.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kAltoBlue),
              ),
              const Icon(
                kArrowLeftLong,
                color: kAltoBlue,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

