// IMPORT FLUTTER PACKAGES
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/ui_elements/constants.dart';
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/material_elements.dart';
//IMPORT SCREENS
import 'package:tagaway/views/BottomNavigationBar.dart';

class RequestPermissionView extends StatelessWidget {
  static const String id = 'requestPermission';
  const RequestPermissionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    'images/tag blue with white - 400x400.png',
                    scale: 2,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Start organising and backing up your pictures.',
                    textAlign: TextAlign.center,
                    style: kBigTitle,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
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
                    await StoreService.instance.set ('userWasAskedPermission', true);
                    final permitted =
                        await PhotoManager.requestPermissionExtend();
                    if (permitted.isAuth) {
                      Navigator.pushReplacementNamed(context, 'bottomNavigation');
                      /*
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const BottomNavigationView()),
                      );
                      */
                    } else {
                      Navigator.pushReplacementNamed(context, 'distributor');
                      // SnackBarGlobal.buildSnackBar(
                          //context, 'to be fixed', 'red');

                      // checkPermission(context).then((value) {
                      //   Navigator.pushReplacementNamed(context, Distributor.id,
                      //       arguments:
                      //           PermissionLevelFlag(permissionLevel: value));
                      // });
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

//RequestPermission logic to implement
//IF user when presses button if('granted' || Platform.isIOS && 'limited'), then send to BottomNavigationView() and create local bool 'wentThroughPermission' == true.
//IF user when presses button if(!='granted' || !='limited'), then send to DistributorView() and create local bool 'wentThroughPermission' == true.
