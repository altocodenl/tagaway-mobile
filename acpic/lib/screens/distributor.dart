// IMPORT FLUTTER PACKAGES
import 'package:acpic/screens/request_permission.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
//IMPORT SCREENS
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:acpic/screens/login_screen.dart';
import 'package:acpic/screens/grid.dart';
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
  bool loggedInLocal = false;
  String cookie;

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
    // TODO: Delete this function later. This is just to make the interface work as it should
    // myFutureLoggedIn = SharedPreferencesService.instance
    //     .getBooleanValue('loggedIn')
    //     .then((value) {
    //   setState(() {
    //     loggedInLocal = value;
    //   });
    //
    //   return loggedInLocal;
    // });
    SharedPreferencesService.instance.getStringValue('cookie').then((value) {
      if (value = null) {
        setState(() {
          cookie = 'empty';
        });
      } else {
        setState(() {
          cookie = value;
        });
      }
      return cookie;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LoginCheckService.instance.loginCheck(cookie).then((value) {
      if (value != 200) {
        Navigator.pushReplacementNamed(
          context,
          LoginScreen.id,
        );
      } else if (value == 200) {
        checkPermission(context).then((value) {
          if ((Platform.isIOS
              ? (value == 'denied')
              : (value == 'denied' && recurringUserLocal == false ||
                  recurringUserLocal == null))) {
            Navigator.pushReplacementNamed(context, RequestPermission.id);
          } else if (value == 'granted') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => GridPage()),
            );
          } else if (value == 'denied' ||
              value == 'permanent' ||
              value == 'limited' ||
              value == 'restricted') {
            Navigator.pushReplacementNamed(context, PhotoAccessNeeded.id,
                arguments: PermissionLevelFlag(permissionLevel: value));
          }
        });
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
