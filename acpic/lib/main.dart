import 'package:acpic/screens/grid.dart';
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:acpic/ui_elements/android_elements.dart';
import 'package:acpic/ui_elements/cupertino_elements.dart';
import 'package:acpic/ui_elements/material_elements.dart';
import 'package:flutter/material.dart';
import 'package:acpic/screens/start.dart';
import 'package:acpic/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Grid(),
    );
  }
}

// TODO: splash page
// TODO: Hero animation
//TODO: CupertinoPageTransition https://api.flutter.dev/flutter/cupertino/CupertinoPageTransition-class.html
