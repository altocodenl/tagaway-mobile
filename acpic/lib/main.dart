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
  Future<void> _checkPermission() async {
    final serviceStatus = await Permission.photos.status;
    final isPhotoOk = serviceStatus == ServiceStatus.enabled;
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

  // Check the Podfile, that's why you always get permanently denied https://github.com/Baseflow/flutter-permission-handler/issues/620

  @override
  Widget build(BuildContext context) {
    _checkPermission();
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}
// TODO 16: splash page
// TODO 15: Hero animation
// TODO 14: CupertinoPageTransition https://api.flutter.dev/flutter/cupertino/CupertinoPageTransition-class.html
