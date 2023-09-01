import 'dart:core';

import 'package:flutter/material.dart';
import 'package:tagaway/services/pivService.dart';
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
    // By awaiting here, we also ensure that subsequent gets to the store service will not have to await, since it will be already loaded.
    var cookie = await StoreService.instance.getAwait('cookie');
    if (cookie == '') {
      // If user has no cookie...
      var recurringUser = StoreService.instance.get('recurringUser');
      // If user is recurring, send to login; otherwise, send to signup.
      return Navigator.pushReplacementNamed(
          context, recurringUser == true ? 'login' : 'signup');
    }
    // If we are here, user has cookie. We assume the cookie to be valid; if it's expired, let the auth service handle that.
    var permissionStatus = await checkPermission();
    // If user has granted complete or partial permissions, go to the main part of the app.
    if (permissionStatus == 'granted' || permissionStatus == 'limited') {
      // Load all local pivs
      PivService.instance.loadLocalPivs();
      return Navigator.pushReplacementNamed(context, 'bottomNavigation');
    }

    var userWasAskedPermission = StoreService.instance.get('userWasAskedPermission');
    return Navigator.pushReplacementNamed(
        context,
        userWasAskedPermission == true
            ? 'photoAccessNeeded'
            : 'requestPermission');
  }

  @override
  Widget build(BuildContext context) {
    // It used to be the case that we needed this to be more than zero, but we now hide the tip of the scrollable sheet when it's not swiped.
    StoreService.instance.set('initialScrollableSize', 0.0);
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
