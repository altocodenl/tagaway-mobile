// IMPORT FLUTTER PACKAGES
import 'package:acpic/screens/request_permission.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:acpic/screens/login_screen.dart';
import 'package:acpic/screens/distributor.dart';
//IMPORT SERVICES
import 'package:acpic/services/checkPermission.dart';
import 'package:acpic/services/local_vars_shared_prefs.dart';

Future<Album> fetchAlbum() async {
  final response = await http.get(Uri.parse('https://altocode.nl/picdev/csrf'));
  if (response.statusCode == 200) {
    print('response.statusCode is ${response.statusCode}');
    return Album.fromJson(jsonDecode(response.body));
  } else {
    print('Not logged in, response.statusCode is ${response.statusCode}');
    // throw Exception('Not logged in');
  }
}

class Album {
  final String token;

  Album({
    @required this.token,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      token: json['csrf'],
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loggedInLocal = false;
  Future myFutureLoggedIn;
  String permissionLevel;
  Future<Album> futureAlbum;

  @override
  void initState() {
    futureAlbum = fetchAlbum();
    // TODO: Delete this function later. This is just to make the interface work as it should
    myFutureLoggedIn = SharedPreferencesService.instance
        .getBooleanValue('loggedIn')
        .then((value) {
      setState(() {
        loggedInLocal = value;
      });
      return loggedInLocal;
    });
    // Permission Level Checker
    checkPermission(context).then((value) {
      permissionLevel = value;
      return permissionLevel;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: loggedInLocal == true && permissionLevel == 'granted'
          ? GridPage()
          : Distributor(),
      routes: {
        GridPage.id: (context) => GridPage(),
        LoginScreen.id: (context) => LoginScreen(),
        PhotoAccessNeeded.id: (context) => PhotoAccessNeeded(),
        RequestPermission.id: (context) => RequestPermission(),
      },
    );
  }
}
