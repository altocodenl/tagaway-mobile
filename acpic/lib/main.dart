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
  Future<void> checkPermission() async {
    final serviceStatus = await Permission.photos.status;
    // final isPhotoOk = serviceStatus == ServiceStatus.enabled;
    final status = await Permission.photos.request();
    if (status == PermissionStatus.granted) {
      print('Permission was granted');
    } else if (status == PermissionStatus.denied) {
      print('Permission denied');
    } else if (status == PermissionStatus.limited) {
      print('Permission limited');
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('Permission permanently denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    checkPermission();
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}

//TODO 8: implement Photo access needed conditional navigation and listening permissions in real time so app does not crash on
// change of permissions https://stackoverflow.com/questions/55442995/flutter-how-do-i-listen-to-permissions-real-time
// TODO 16: splash page
// TODO 15: Hero animation
// TODO 14: CupertinoPageTransition https://api.flutter.dev/flutter/cupertino/CupertinoPageTransition-class.html
