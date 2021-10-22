// IMPORT FLUTTER PACKAGES
import 'package:acpic/screens/request_permission.dart';
import 'package:flutter/material.dart';
import 'dart:async';
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:acpic/screens/login_screen.dart';
import 'package:acpic/screens/distributor.dart';
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SERVICES
import 'package:acpic/services/permissionCheckService.dart';
import 'package:acpic/services/local_vars_shared_prefsService.dart';
import 'package:acpic/services/loginCheckService.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String permissionLevel;
  String cookie;
  bool isCookieLoaded = false;
  int response;

  @override
  void initState() {
    checkPermission(context).then((value) {
      permissionLevel = value;
      return permissionLevel;
    });
    returnCookie();
    super.initState();
  }

  returnCookie() async {
    await SharedPreferencesService.instance
        .getStringValue('cookie')
        .then((value) {
      setState(() {
        cookie = value;
      });
      LoginCheckService.instance.loginCheck(cookie).then((value) {
        setState(() {
          response = value;
          isCookieLoaded = true;
        });
      });
      return cookie;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: response == 200 && permissionLevel == 'granted'
      //         ? GridPage()
      //         : Distributor(),
      home: Distributor(),
      routes: {
        GridPage.id: (context) => GridPage(),
        LoginScreen.id: (context) => LoginScreen(),
        PhotoAccessNeeded.id: (context) => PhotoAccessNeeded(),
        RequestPermission.id: (context) => RequestPermission(),
        Distributor.id: (context) => Distributor()
      },
    );
  }
}

// TODO 4: online checker. If app is not connected to the internet, go to a screen that asks the user to connect to the internet to use the app
