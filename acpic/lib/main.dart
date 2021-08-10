import 'package:permission_handler/permission_handler.dart';
import 'package:acpic/screens/grid.dart';
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:flutter/material.dart';
import 'package:acpic/screens/start.dart';
import 'package:acpic/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PhotoAccessNeeded(),
    );
  }
}
// TODO 16: splash page
// TODO 15: Hero animation
// TODO 14: CupertinoPageTransition https://api.flutter.dev/flutter/cupertino/CupertinoPageTransition-class.html
