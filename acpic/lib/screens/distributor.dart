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
import 'package:acpic/services/checkPermission.dart';
import 'package:acpic/services/local_vars_shared_prefs.dart';
import 'package:acpic/services/loginCheck.dart';

class Distributor extends StatefulWidget {
  static const String id = 'distributor';

  @override
  _DistributorState createState() => _DistributorState();
}

class _DistributorState extends State<Distributor> {
  bool recurringUserLocal = false;
  bool loggedInLocal = false;
  String sessionCookie;
  Future myFuture;
  Future myFutureLoggedIn;
  Future myFutureAsWell;
  Future<Album> futureAlbum;

  @override
  void initState() {
    // futureAlbum = fetchAlbum();
    if (Platform.isAndroid == true) {
      myFuture = SharedPreferencesService.instance
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
    myFutureAsWell = SharedPreferencesService.instance
        .getStringValue('sessionCookie')
        .then((value) {
      setState(() {
        sessionCookie = value;
      });
      return sessionCookie;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkPermission(context).then((value) {
      if (sessionCookie.isNotEmpty == false) {
        Navigator.pushReplacementNamed(
          context,
          LoginScreen.id,
          arguments: PermissionLevelFlag(permissionLevel: value),
        );
      } else if ((Platform.isIOS
          ? (value == 'denied' && sessionCookie.isNotEmpty == true)
          : (value == 'denied' &&
                  sessionCookie.isNotEmpty == true &&
                  recurringUserLocal == false ||
              recurringUserLocal == null))) {
        Navigator.pushReplacementNamed(context, RequestPermission.id);
      } else if (sessionCookie.isNotEmpty == true && value == 'granted') {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GridPage()),
        );
      } else if (sessionCookie.isNotEmpty == true && value == 'denied' ||
          value == 'permanent' ||
          value == 'limited' ||
          value == 'restricted') {
        Navigator.pushReplacementNamed(context, PhotoAccessNeeded.id,
            arguments: PermissionLevelFlag(permissionLevel: value));
      }
    });
    // return FutureBuilder<Album>(
    //   future: futureAlbum,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasError) {
    //       checkPermission(context).then((value) {
    //         Navigator.pushReplacementNamed(
    //           context,
    //           LoginScreen.id,
    //           arguments: PermissionLevelFlag(permissionLevel: value),
    //         );
    //       });
    //     } else if (snapshot.hasData) {
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
