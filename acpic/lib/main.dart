// IMPORT FLUTTER PACKAGES
import 'package:acpic/screens/request_permission.dart';
import 'package:acpic/services/local_vars_shared_prefs.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:acpic/screens/login_screen.dart';
import 'package:acpic/screens/distributor.dart';
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
        Distributor.id: (context) => Distributor()
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
  double opacityLevel = 1.0;

  @override
  void initState() {
    delayedSplash();
    super.initState();
  }

  delayedSplash() async {
    var duration = new Duration(seconds: 2);
    return new Timer(duration, route);
  }

  route() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => Distributor()),
    );
  }

  void _changeOpacity() {
    setState(() {
      opacityLevel = opacityLevel == 0.0 ? 1.0 : 0.0;
    });
    print('Hello world');
  }

  @override
  Widget build(BuildContext context) {
    _changeOpacity();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(seconds: 2),
          curve: Curves.fastOutSlowIn,
          child: Text(
            'ac;pic',
            textAlign: TextAlign.center,
            style: kAcpicSplash,
          ),
        ),
      ),
    );
  }
}

// TODO 6: splash page https://medium.com/codechai/lunching-other-screen-after-delay-in-flutter-c9ebf4d7406e
// TODO 5: Hero animation
// TODO 4: CupertinoPageTransition https://api.flutter.dev/flutter/cupertino/CupertinoPageTransition-class.html
