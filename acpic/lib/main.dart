// IMPORT FLUTTER PACKAGES
import 'package:acpic/screens/request_permission.dart';
import 'package:acpic/services/local_vars_shared_prefs.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:acpic/screens/login_screen.dart';
import 'package:acpic/screens/recover_password.dart';
//IMPORT SERVICES
import 'package:acpic/services/checkPermission.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
        RequestPermission.id: (context) => RequestPermission(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool recurringUserLocal = false;
  bool loggedInLocal = false;
  Future myFuture;
  Future myFutureLoggedIn;

  @override
  void initState() {
    if (Platform.isAndroid == true) {
      myFuture = SharedPreferencesService.instance
          .getBooleanValue('recurringUser')
          .then((value) => setState(() {
                recurringUserLocal = value;
              }));
    }

    // TODO: Delete this function later. This is just to make the interface work as it should
    myFutureLoggedIn = SharedPreferencesService.instance
        .getBooleanValue('loggedIn')
        .then((value) => setState(() {
              loggedInLocal = value;
            }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkPermission(context).then((value) {
      if (loggedInLocal == false) {
        Navigator.pushReplacementNamed(
          context,
          LoginScreen.id,
          arguments: PermissionLevelFlag(permissionLevel: value),
        );
      } else if ((Platform.isIOS
          ? (value == 'denied' && loggedInLocal == true)
          : (value == 'denied' &&
                  loggedInLocal == true &&
                  recurringUserLocal == false ||
              recurringUserLocal == null))) {
        Navigator.pushReplacementNamed(context, RequestPermission.id);
      } else if (value == 'granted' && loggedInLocal == true) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GridPage()),
        );
      } else {
        Navigator.pushReplacementNamed(context, PhotoAccessNeeded.id,
            arguments: PermissionLevelFlag(permissionLevel: value));
      }
    });
    return Container();
  }
}

// TODO 6: splash page https://medium.com/codechai/lunching-other-screen-after-delay-in-flutter-c9ebf4d7406e
// TODO 5: Hero animation
// TODO 4: CupertinoPageTransition https://api.flutter.dev/flutter/cupertino/CupertinoPageTransition-class.html
