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

  int currentIndex = 0;
  final screens = [const HomeView(), const LocalView(), const UploadedView()];

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance
        .listen(['currentIndex'], (v1) {
      setState(() {
        currentIndex = v1 == '' ? 0 : v1;
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
            index: currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Stack(
            children: [
            Visibility(
              visible: false,
              child: Center(
                child: Container(
                  height: 450,
                  width: 340,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: kGreyLight, width: .5)),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: FaIcon(
                                  kBroomIcon,
                                  color: kAltoBlue,
                                ),
                              ),
                              Text(
                                'Tagaway Space Cleaner',
                                textAlign: TextAlign.center,
                                style: kDoneEditText,
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.only(
                                bottom: 10.0, right: 20, left: 20),
                            child: Text.rich(
                              TextSpan(
                                text: 'Tagaway will delete ',
                                style: kPlainTextBold, // default text style
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'only ',
                                      style: kPlainTextBoldDarkest),
                                  TextSpan(
                                      text:
                                          'the photos and videos that you have organized.',
                                      style: kPlainTextBold),
                                ],
                              ),
                            )),
                        const Padding(
                            padding: EdgeInsets.only(
                                bottom: 10.0, right: 20, left: 20),
                            child: Text.rich(
                              TextSpan(
                                text: 'Your organized photos and videos are ',
                                style: kPlainTextBold, // default text style
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'safe in Tagaway’s cloud',
                                      style: kPlainTextBoldDarkest),
                                  TextSpan(
                                      text:
                                          ', which you can always access from this app or Tagaway Web (from web you can download the high-quality versions).',
                                      style: kPlainTextBold),
                                ],
                              ),
                            )),
                        const Padding(
                          padding: EdgeInsets.only(
                              bottom: 20.0, right: 20, left: 20),
                          child: Text(
                            'Delete your organized photos and videos from this device?',
                            textAlign: TextAlign.center,
                            style: kPlainTextBold,
                          ),
                        ),
                        Container(
                          width: 320,
                          decoration: BoxDecoration(
                              color: kGreyDarker,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              border: Border.all(color: kGreyLight, width: .5)),
                          child: GestureDetector(
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10.0),
                              child: Text(
                                'No, take me back.',
                                textAlign: TextAlign.center,
                                style: kButtonText,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: 320,
                          decoration: BoxDecoration(
                              color: kAltoBlue,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              border: Border.all(color: kGreyLight, width: .5)),
                          child: GestureDetector(
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10.0),
                              child: Text(
                                'Yes, but organized pivs 3 months or older.',
                                textAlign: TextAlign.center,
                                style: kButtonText,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: 320,
                          decoration: BoxDecoration(
                              color: kAltoBlue,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              border: Border.all(color: kGreyLight, width: .5)),
                          child: GestureDetector(
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10.0),
                              child: Text(
                                'Yes, delete all organized pivs.',
                                textAlign: TextAlign.center,
                                style: kButtonText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
                  const BottomNavigationBarItem(
                      icon: FaIcon(kHomeIcon), label: 'Home'),
                  const BottomNavigationBarItem(
                      icon: FaIcon(kMobilePhoneIcon), label: 'Phone'),
                  BottomNavigationBarItem(
                      icon: const FaIcon(kCloudArrowUp), label: 'Cloud'),
                ],
              ),
              const UploadingNumber()
            ],
          ),
        ),
      );
}
