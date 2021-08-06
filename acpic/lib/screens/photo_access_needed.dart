// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/cupertino_elements.dart';
import 'package:acpic/ui_elements/android_elements.dart';
import 'package:acpic/ui_elements/material_elements.dart';
import 'package:acpic/ui_elements/constants.dart';

//TODO 9: implement this view's logic

class PhotoAccessNeeded extends StatefulWidget {
  @override
  _PhotoAccessNeededState createState() => _PhotoAccessNeededState();
}

class _PhotoAccessNeededState extends State<PhotoAccessNeeded> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Image.asset(
                'images/icon-guide--upload.png',
                scale: 3,
                // TODO 6: Scale should depend on device and orientation
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'ac;pic needs access to your photos.',
                textAlign: TextAlign.center,
                style: kBigTitle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                'We need access to your photos in order to upload them to your account.',
                textAlign: TextAlign.center,
                style: kPlainText,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              //TODO 8: Research the message for Android and change the routing for iOS and Android
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: kPlainText,
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            'Click on the button below to change ac;pic\'s access from '),
                    TextSpan(
                        text: 'None',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: ' to',
                    ),
                    TextSpan(
                        text: ' All Photos.',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            RoundedButton(
              title: 'Change settings',
              colour: kAltoBlue,
              onPressed: () {
                // TODO 10: Implement this
                /**/
              },
            ),
          ],
        ),
      )),
    );
  }
}
