// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/cupertino_elements.dart';
import 'package:acpic/ui_elements/android_elements.dart';
import 'package:acpic/ui_elements/material_elements.dart';
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';
import 'package:acpic/main.dart';
import 'package:acpic/screens/photo_access_needed.dart';
//IMPORT SERVICES
import 'package:acpic/services/checkPermission.dart';

//https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html
//https://api.flutter.dev/flutter/widgets/Flexible-class.html
//https://api.flutter.dev/flutter/cupertino/CupertinoDialog-class.html

class RequestPermission extends StatelessWidget {
  static const String id = 'permission_screen';

  Future<bool> saveLocalRecurringUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('recurringUser', true);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Image.asset(
                    'images/icon-guide--upload.png',
                    scale: 3,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Start organising and backing up your pictures.',
                    textAlign: TextAlign.center,
                    style: kBigTitle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Click the button below and start adding pictures.',
                    textAlign: TextAlign.center,
                    style: kPlainText,
                  ),
                ),
                RoundedButton(
                  title: 'Upload Pictures',
                  colour: kAltoBlue,
                  onPressed: () async {
                    final permitted =
                        await PhotoManager.requestPermissionExtend();
                    if (permitted.isAuth) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => GridPage()),
                      );
                    } else {
                      checkPermission(context).then((value) {
                        Navigator.pushReplacementNamed(
                            context, PhotoAccessNeeded.id,
                            arguments:
                                PermissionLevelFlag(permissionLevel: value));
                      });
                    }
                    Platform.isAndroid ? saveLocalRecurringUser() : null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
