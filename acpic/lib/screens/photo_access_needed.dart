// IMPORT FLUTTER PACKAGES
import 'dart:ui';
import 'package:acpic/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/cupertino_elements.dart';
import 'package:acpic/ui_elements/android_elements.dart';
import 'package:acpic/ui_elements/material_elements.dart';
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';
import 'package:acpic/main.dart';
//IMPORT SERVICES
import 'package:acpic/services/checkPermission.dart';
import 'package:acpic/services/lifecycle_manager.dart';

class PhotoAccessNeeded extends StatefulWidget {
  static const String id = 'photo_access_needed';

  @override
  _PhotoAccessNeededState createState() => _PhotoAccessNeededState();
}

class _PhotoAccessNeededState extends State<PhotoAccessNeeded> {
  @override
  Widget build(BuildContext context) {
    print('I am in the PhotoAccessNeeded build');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final flag =
        ModalRoute.of(context).settings.arguments as PermissionLevelFlag;
    return LifeCycleManager(
      child: Scaffold(
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
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
                  child: Platform.isIOS &&
                              flag.permissionLevel == 'permanent' ||
                          Platform.isAndroid && flag.permissionLevel == 'denied'
                      ? RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: kPlainText,
                            children: <TextSpan>[
                              TextSpan(
                                  text: Platform.isIOS
                                      ? 'Tap on the button below to change ac;pic\'s access from '
                                      : 'Tap on the button below and go to '),
                              TextSpan(
                                  text:
                                      Platform.isAndroid ? 'Permissions.' : '',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: Platform.isAndroid ? ' Then tap on ' : '',
                              ),
                              TextSpan(
                                  text: Platform.isAndroid
                                      ? 'Files and media. \n\n'
                                      : '',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: Platform.isAndroid
                                    ? ' Change ac;pic\'s access from '
                                    : '',
                              ),
                              TextSpan(
                                  text: Platform.isIOS ? 'None' : 'Deny',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: ' to',
                              ),
                              TextSpan(
                                  text: Platform.isIOS
                                      ? ' All Photos.'
                                      //TODO 8: Android is going to need for the permission to be checked again, since when it moves from "deny" to "allowed" is does not kill the app.
                                      : ' Allow access to media only',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      : RichText(
                          // TODO: What are we going to do with 'Limited' access?
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: kPlainText,
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Your permission level for ac;pic is '),
                              TextSpan(
                                  text: 'Selected Photos.\n\n',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text:
                                    'If you are OK with that, click on the button below to upload your allowed photos and videos.',
                              ),
                            ],
                          ),
                        ),
                ),
                RoundedButton(
                  title: 'Change settings',
                  colour: kAltoBlue,
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
