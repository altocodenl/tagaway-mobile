// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:acpic/screens/login_screen.dart';
//IMPORT SERVICES
import 'package:acpic/services/checkPermission.dart';

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

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool recurringUserLocal;
  bool loggedInLocal;
  Future myFuture;

  Future<bool> getLocalRecurringUserBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool recurringUser = (prefs.getBool('recurringUser') ?? false);
    recurringUser ? recurringUserLocal = true : recurringUserLocal = false;
    bool loggedIn = (prefs.getBool('loggedIn') ?? false);
    loggedIn ? loggedInLocal = true : loggedInLocal = false;
    print('recurringUser $recurringUser');
    print('loggedIn $loggedIn');
    return recurringUser;
  }

  @override
  void initState() {
    Platform.isAndroid ? myFuture = getLocalRecurringUserBool() : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkPermission(context).then((value) {
      if (Platform.isIOS
          ? (value == 'denied')
          : (value == 'denied' && recurringUserLocal == false ||
              recurringUserLocal == null)) {
        // TODO: Logged in check goes here.
        Navigator.pushReplacementNamed(context, LoginScreen.id);
      } else if (value == 'granted') {
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

// States:
// First time: 'denied' && recurringUserLocal == false || recurringUserLocal == null && loggedIn == false; => goes to LogIn
// Other times: 'denied' && recurringUserLocal == false || recurringUserLocal == null && loggedIn == true; => goes to Start (Request Permission)
//              'denied' && recurringUserLocal == true && loggedIn == true; => goes Need Photo Access
//              'granted' && recurringUserLocal == true && loggedIn == true; => goes to Grid
//              'granted' && recurringUserLocal == true && loggedIn == false; => goes to LogIn
//              'limited' && recurringUserLocal == true && loggedIn == true; => goes to Need Photo Access
//              'limited' && recurringUserLocal == true && loggedIn == false; => goes to LogIn

//TODO 9: implement Photo access needed conditional navigation and listening permissions in real time so app does not crash on
// change of permissions https://stackoverflow.com/questions/55442995/flutter-how-do-i-listen-to-permissions-real-time
// TODO 16: splash page
// TODO 15: Hero animation
// TODO 14: CupertinoPageTransition https://api.flutter.dev/flutter/cupertino/CupertinoPageTransition-class.html
