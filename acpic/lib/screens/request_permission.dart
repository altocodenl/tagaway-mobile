// IMPORT FLUTTER PACKAGES
import 'package:acpic/screens/distributor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io' show Platform;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/material_elements.dart';
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';
//IMPORT SERVICES
import 'package:acpic/services/permissionCheckService.dart';
import 'package:acpic/services/local_vars_shared_prefsService.dart';

class RequestPermission extends StatelessWidget {
  static const String id = 'permission_screen';

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
                        Navigator.pushReplacementNamed(context, Distributor.id,
                            arguments:
                                PermissionLevelFlag(permissionLevel: value));
                      });
                    }
                    if (Platform.isAndroid == true) {
                      SharedPreferencesService.instance
                          .setBooleanValue('recurringUser', true);
                    }
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
