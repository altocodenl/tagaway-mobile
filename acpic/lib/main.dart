// IMPORT FLUTTER PACKAGES
import 'package:acpic/screens/request_permission.dart';
import 'package:flutter/material.dart';
import 'dart:async';
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:acpic/screens/login_screen.dart';
import 'package:acpic/screens/distributor.dart';
//IMPORT SERVICES
import 'package:acpic/services/checkPermission.dart';
import 'package:acpic/services/local_vars_shared_prefs.dart';
import 'package:acpic/services/loginCheck.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String permissionLevel;
  Future<Album> futureAlbum;
  String sessionCookie;
  Future myFutureAsWell;

  @override
  void initState() {
    myFutureAsWell = SharedPreferencesService.instance
        .getStringValue('sessionCookie')
        .then((value) {
      setState(() {
        sessionCookie = value;
      });
      return sessionCookie;
    });
    // startCheck();
    // futureAlbum = fetchAlbum();
    // Permission Level Checker
    checkPermission(context).then((value) {
      permissionLevel = value;
      return permissionLevel;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('I am in main build and sessionCookie is $sessionCookie');
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<Album>(
        future: futureAlbum,
        builder: (context, snapshot) {
          if (snapshot.hasData && permissionLevel == 'granted') {
            return GridPage();
          }
          return Distributor();
        },
      ),
      // home: sessionCookie.isNotEmpty == true && permissionLevel == 'granted'
      //     ? GridPage()
      //     : Distributor(),
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
