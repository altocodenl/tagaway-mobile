import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Distributor extends StatefulWidget {
  static const String id = 'distributor';

  const Distributor({Key? key}) : super(key: key);

  @override
  State<Distributor> createState() => _DistributorState();
}

class _DistributorState extends State<Distributor> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

//Distributor logic to implement:
//Distributor is the home, the user is always sent first to the Distributor
//IF user has no valid credentials && permission is 'denied' && 'recurring' local bool is false, it goes to Sign Up flow.
//IF user has no valid credentials && permission is 'denied' && 'recurring' local bool is true, goes to Log In. 'recurring' local bool should be created upon first successful login
//IF has valid credentials && permission is 'denied' || 'denied' && Platform.isAndroid &&  local bool 'wentThroughPermission' is false, goes to RequestPermissionView(). The local bool 'wentThroughPermission' should be created once user presses permission button in RequestPermissionView().
//IF has valid credentials && permission is 'denied' || 'permanent' || 'restricted', but local bool 'wentThroughPermission' is true, goes to PhotoAccessNeededView()
//IF call to server cannot be completed, it goes to OfflineView()
