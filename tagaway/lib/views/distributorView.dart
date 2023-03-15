import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagaway/services/permissionService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/ui_elements/constants.dart';

class Distributor extends StatefulWidget {
  static const String id = 'distributor';

  const Distributor({Key? key}) : super(key: key);

  @override
  State<Distributor> createState() => _DistributorState();
}

class _DistributorState extends State<Distributor> {
  @override
  void initState() {
    super.initState();
    distributor();
  }

  distributor() async {
    /* DEBUG MODE */
    // await Future.delayed(const Duration(milliseconds: 150));
    // await StoreService.instance.set('cookie', '');
    // await StoreService.instance.set('recurringUser', true);

    var cookie = await StoreService.instance.getBeforeLoad('cookie');
    if (cookie == '') {
      // If user has no cookie...
      var recurringUser =
          await StoreService.instance.getBeforeLoad('recurringUser');
      debug(['No cookie, recurring user?', recurringUser == true]);
      // If user is recurring, send to login; otherwise, send to signup.
      return Navigator.pushReplacementNamed(
          context, recurringUser == true ? 'login' : 'signup');
    }
    // If we are here, user has cookie. We assume the cookie to be valid; if it's expired, let the auth service handle that.
    var permissionStatus = await checkPermission(context);
    // TODO: remove hardcoding
    // permissionStatus = 'granted';
    debug(['Cookie present, permission level:', permissionStatus]);
    // If user has granted complete or partial permissions, go to the main part of the app.
    if (permissionStatus == 'granted' || permissionStatus == 'limited')
      return Navigator.pushReplacementNamed(context, 'bottomNavigation');

    var userWasAskedPermission =
        await StoreService.instance.getBeforeLoad('userWasAskedPermission');
    return Navigator.pushReplacementNamed(
        context,
        userWasAskedPermission == true
            ? 'photoAccessNeeded'
            : 'requestPermission');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
        ),
      ),
    );
  }
}

//Distributor logic to implement:
//Distributor is the home, the user is always sent first to the Distributor
//IF user has no valid credentials && permission is 'denied' && 'recurring' local bool is false, it goes to Sign Up flow.
//IF user has no valid credentials && permission is 'denied' && 'recurring' local bool is true, goes to Log In. 'recurring' local bool should be created upon first successful login
//IF has valid credentials && permission is 'denied' || 'denied' && Platform.isAndroid &&  local bool 'wentThroughPermission' is false, goes to RequestPermissionView(). The local bool 'wentThroughPermission' should be created once user presses permission button in RequestPermissionView().
//IF has valid credentials && permission is 'denied' || 'permanent' || 'restricted', but local bool 'wentThroughPermission' is true, goes to PhotoAccessNeededView()
//IF call to server cannot be completed, it goes to OfflineView()
