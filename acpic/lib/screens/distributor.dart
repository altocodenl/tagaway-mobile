// IMPORT FLUTTER PACKAGES
import 'package:acpic/screens/request_permission.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'dart:io';
//IMPORT SCREENS
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:acpic/screens/login_screen.dart';
import 'package:acpic/screens/grid.dart';
import 'package:acpic/screens/offline.dart';
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SERVICES
import 'package:acpic/services/permissionCheckService.dart';
import 'package:acpic/services/local_vars_shared_prefsService.dart';
import 'package:acpic/services/loginCheckService.dart';

class Distributor extends StatefulWidget {
  static const String id = 'distributor';

  @override
  _DistributorState createState() => _DistributorState();
}

class _DistributorState extends State<Distributor> {
  bool recurringUserLocal = false;
  bool isCookieLoaded = false;
  String cookie = 'empty';

  @override
  void initState() {
    if (Platform.isAndroid == true) {
      SharedPreferencesService.instance
          .getBooleanValue('recurringUser')
          .then((value) {
        setState(() {
          recurringUserLocal = value;
        });
      });
    }
    returnCookie();
    super.initState();
  }

  void returnCookie() async {
    await SharedPreferencesService.instance
        .getStringValue('cookie')
        .then((value) {
      if (value.isEmpty) {
        setState(() {
          isCookieLoaded = true;
        });
      } else {
        setState(() {
          cookie = value;
          isCookieLoaded = true;
        });
      }
      return cookie;
    });
  }

  // TODO: When there's no cookie: Dart Unhandled Exception: Null check operator used on a null value
  @override
  Widget build(BuildContext context) {
    !isCookieLoaded
        ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
          )
        : LoginCheckService.instance.loginCheck(cookie).then((value) {
            if (value == 403 || 500 <= value) {
              checkPermission(context).then((value) {
                Navigator.pushReplacementNamed(
                  context,
                  LoginScreen.id,
                  arguments: PermissionLevelFlag(permissionLevel: value),
                );
              });
            } else if (value == 200) {
              checkPermission(context).then((value) {
                if ((Platform.isIOS
                    ? (value == 'denied')
                    : (value == 'denied' && recurringUserLocal == false ||
                        recurringUserLocal == null))) {
                  Navigator.pushReplacementNamed(context, RequestPermission.id);
                } else if (value == 'granted') {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => GridPage()));
                } else if (value == 'denied' ||
                    value == 'permanent' ||
                    value == 'limited' ||
                    value == 'restricted') {
                  Navigator.pushReplacementNamed(context, PhotoAccessNeeded.id,
                      arguments: PermissionLevelFlag(permissionLevel: value));
                }
              });
            } else if (value == 0) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => OfflineScreen()));
            }
          });
    // checkPermission(context).then((value) {
    //   if (cookie.isNotEmpty == false) {
    //     Navigator.pushReplacementNamed(
    //       context,
    //       LoginScreen.id,
    //     );
    //   } else if ((Platform.isIOS
    //       ? (value == 'denied' && cookie.isNotEmpty == true)
    //       : (value == 'denied' &&
    //               cookie.isNotEmpty == true &&
    //               recurringUserLocal == false ||
    //           recurringUserLocal == null))) {
    //     Navigator.pushReplacementNamed(context, RequestPermission.id);
    //   } else if (cookie.isNotEmpty == true && value == 'granted') {
    //     Navigator.of(context).push(
    //       MaterialPageRoute(builder: (_) => GridPage()),
    //     );
    //   } else if (cookie.isNotEmpty == true && value == 'denied' ||
    //       value == 'permanent' ||
    //       value == 'limited' ||
    //       value == 'restricted') {
    //     Navigator.pushReplacementNamed(context, PhotoAccessNeeded.id,
    //         arguments: PermissionLevelFlag(permissionLevel: value));
    //   }
    // });
    // return FutureBuilder<int>(
    //   future: LoginCheckService.instance.loginCheck(cookie),
    //   builder: (context, snapshot) {
    //     // print(
    //     //     'I am in the FutureBuilder Distributor and snapshot.data is ${snapshot.data}');
    //     if (snapshot.data != 200) {
    //       checkPermission(context).then((value) {
    //         Navigator.pushReplacementNamed(
    //           context,
    //           LoginScreen.id,
    //           // arguments: PermissionLevelFlag(permissionLevel: value),
    //         );
    //       });
    //     } else if (snapshot.data == 200) {
    //       checkPermission(context).then((value) {
    //         if ((Platform.isIOS
    //             ? (value == 'denied')
    //             : (value == 'denied' && recurringUserLocal == false ||
    //                 recurringUserLocal == null))) {
    //           Navigator.pushReplacementNamed(context, RequestPermission.id);
    //         } else if (value == 'granted') {
    //           Navigator.of(context).push(
    //             MaterialPageRoute(builder: (_) => GridPage()),
    //           );
    //         } else if (value == 'denied' ||
    //             value == 'permanent' ||
    //             value == 'limited' ||
    //             value == 'restricted') {
    //           Navigator.pushReplacementNamed(context, PhotoAccessNeeded.id,
    //               arguments: PermissionLevelFlag(permissionLevel: value));
    //         }
    //       });
    //     }
    //     return Container(
    //       color: Colors.white,
    //       child: Center(
    //           child: CircularProgressIndicator(
    //         valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
    //       )),
    //     );
    //   },
    // );
    return Container(
      color: Colors.white,
      child: Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
      )),
    );
  }
}
