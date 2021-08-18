import 'package:acpic/screens/recover_password.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:acpic/screens/grid.dart';
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:flutter/material.dart';
import 'package:acpic/screens/start.dart';
import 'package:acpic/screens/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        PhotoAccessNeeded.id: (context) => PhotoAccessNeeded(),
        GridPage.id: (context) => GridPage(),
      },
    );
  }
}

Future<String> checkPermission(BuildContext context) async {
  final serviceStatus = await Permission.photos.status;
  // final isPhotoOk = serviceStatus == ServiceStatus.enabled;
  // final status = await Permission.photos.request();
  if (serviceStatus == PermissionStatus.granted) {
    print('granted');
    return 'granted';
  } else if (serviceStatus == PermissionStatus.denied) {
    print('denied');
    return 'denied';
  } else if (serviceStatus == PermissionStatus.limited) {
    print('limited');
    return 'limited';
  } else if (serviceStatus == PermissionStatus.restricted) {
    print('restricted');
    return 'restricted';
  } else if (serviceStatus == PermissionStatus.permanentlyDenied) {
    print('permanently denied');
    return 'permanent';
  }
}

class SplashScreen extends StatelessWidget {
  // const SplashScreen({Key? key}) : super(key: key);
  static const String id = 'splash_screen';
  @override
  Widget build(BuildContext context) {
    checkPermission(context).then((value) {
      if (value == 'granted' || value == 'denied') {
        Navigator.pushReplacementNamed(context, LoginScreen.id);
      } else {
        Navigator.pushReplacementNamed(context, PhotoAccessNeeded.id,
            arguments: PermissionLevelFlag(permissionLevel: value));
      }
    });
    return Container();
  }
}

class PermissionLevelFlag {
  final String permissionLevel;

  PermissionLevelFlag({this.permissionLevel});
}

//TODO 8: implement Photo access needed conditional navigation and listening permissions in real time so app does not crash on
// change of permissions https://stackoverflow.com/questions/55442995/flutter-how-do-i-listen-to-permissions-real-time
// TODO 16: splash page
// TODO 15: Hero animation
// TODO 14: CupertinoPageTransition https://api.flutter.dev/flutter/cupertino/CupertinoPageTransition-class.html
