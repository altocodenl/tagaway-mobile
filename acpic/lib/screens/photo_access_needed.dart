// IMPORT FLUTTER PACKAGES
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/material_elements.dart';
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final flag =
        ModalRoute.of(context).settings.arguments as PermissionLevelFlag;
    // print(
    //     'I am in PhotoAccessNeeded and flag.PermissionLevel is ${flag.permissionLevel}');
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
                    flag.permissionLevel == 'limited'
                        ? 'ac;pic\'s access is limited'
                        : 'ac;pic needs access to your photos.',
                    textAlign: TextAlign.center,
                    style: kBigTitle,
                  ),
                ),
                flag.permissionLevel == 'limited'
                    ? Padding(padding: const EdgeInsets.all(0))
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          'We need access to your photos in order to upload them to your account.',
                          textAlign: TextAlign.center,
                          style: kPlainText,
                        ),
                      ),
                Padding(
                  padding: flag.permissionLevel == 'limited'
                      ? const EdgeInsets.only(bottom: 20)
                      : const EdgeInsets.only(bottom: 10),
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
                                      : ' Allow access to media only',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      : RichText(
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
                                    'If you are OK with that, tap on the button below to upload your allowed photos and videos.',
                              ),
                            ],
                          ),
                        ),
                ),
                flag.permissionLevel == 'limited'
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => GridPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: kAltoBlue,
                            minimumSize: Size(200, 42),
                            side: BorderSide(width: 1, color: kAltoBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            textStyle: kSelectAllButton,
                          ),
                          child: Text(
                            'Upload Limited Pictures',
                          ),
                        ))
                    : RoundedButton(
                        title: 'Change settings',
                        colour: kAltoBlue,
                        onPressed: () {
                          openAppSettings();
                        },
                      ),
                flag.permissionLevel == 'limited'
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: kPlainText,
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                      'If you would like to change the selection, or to have all your photos and videos available for upload, tap on the button below to change ac;pic\'s access from '),
                              TextSpan(
                                  text: 'Selected Photos',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: ' to',
                              ),
                              TextSpan(
                                  text: ' All Photos.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    : Padding(padding: const EdgeInsets.all(0)),
                flag.permissionLevel == 'limited'
                    ? RoundedButton(
                        title: 'Change settings',
                        colour: kAltoBlue,
                        onPressed: () {
                          openAppSettings();
                        },
                      )
                    : Padding(padding: const EdgeInsets.all(0)),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
