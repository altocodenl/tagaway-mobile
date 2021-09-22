// IMPORT FLUTTER PACKAGES
import 'package:acpic/screens/request_permission.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
//IMPORT SCREENS
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:acpic/screens/login_screen.dart';
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SERVICES
import 'package:acpic/services/checkPermission.dart';
import 'package:acpic/services/local_vars_shared_prefs.dart';

class Distributor extends StatefulWidget {
  static const String id = 'distributor';

  @override
  _DistributorState createState() => _DistributorState();
}

class _DistributorState extends State<Distributor> {
  bool recurringUserLocal = false;
  bool loggedInLocal = false;
  Future myFuture;
  Future myFutureLoggedIn;

  @override
  void initState() {
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
    myFutureLoggedIn = SharedPreferencesService.instance
        .getBooleanValue('loggedIn')
        .then((value) {
      setState(() {
        loggedInLocal = value;
      });
      return loggedInLocal;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Conditional Navigation
    checkPermission(context).then((value) {
      if (loggedInLocal == false) {
        print('loggedInLocal is $loggedInLocal');
        Navigator.pushReplacementNamed(
          context,
          LoginScreen.id,
          arguments: PermissionLevelFlag(permissionLevel: value),
        );
      } else if ((Platform.isIOS
          ? (value == 'denied' && loggedInLocal == true)
          : (value == 'denied' &&
                  loggedInLocal == true &&
                  recurringUserLocal == false ||
              recurringUserLocal == null))) {
        Navigator.pushReplacementNamed(context, RequestPermission.id);
      } else if (loggedInLocal == true && value == 'denied' ||
          value == 'permanent' ||
          value == 'limited' ||
          value == 'restricted') {
        Navigator.pushReplacementNamed(context, PhotoAccessNeeded.id,
            arguments: PermissionLevelFlag(permissionLevel: value));
      }
    });
    return Container(
      color: Colors.white,
      child: Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
      )),
    );
  }
}
