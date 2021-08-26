// IMPORT FLUTTER PACKAGES
import 'package:acpic/screens/request_permission.dart';
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
  bool recurringUserLocal;
  bool loggedInLocal;
  Future myFuture;
  Future myFutureLoggedIn;

  Future<bool> getLocalRecurringUserBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool recurringUser = (prefs.getBool('recurringUser') ?? false);
    recurringUser ? recurringUserLocal = true : recurringUserLocal = false;
    print('recurringUser $recurringUser');
    return recurringUser;
  }

  // TODO: Delete this function later. This is just to make the interface work as it should
  Future<bool> getLocalLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = (prefs.getBool('loggedIn') ?? false);
    loggedIn ? loggedInLocal = true : loggedInLocal = false;
    print('loggedIn $loggedIn');
    return loggedIn;
  }

  @override
  void initState() {
    Platform.isAndroid ? myFuture = getLocalRecurringUserBool() : null;
    myFutureLoggedIn = getLocalLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkPermission(context).then((value) {
      if (loggedInLocal == false) {
        Navigator.pushReplacementNamed(context, LoginScreen.id, arguments: {
          PermissionLevelFlag(permissionLevel: value),
          recurringUserLocal
        }
            // add recurringUserLocal
            );
      } else if ((Platform.isIOS
          ? (value == 'denied' && loggedInLocal == true)
          : (value == 'denied' &&
                  loggedInLocal == true &&
                  recurringUserLocal == false ||
              recurringUserLocal == null))) {
        Navigator.pushReplacementNamed(context, RequestPermission.id);
      } else if (value == 'granted' &&
          loggedInLocal == true &&
          recurringUserLocal == true) {
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
// First time: 'denied' && recurringUserLocal == false || recurringUserLocal == null && loggedIn == false; => goes to LogIn [1]
// Other times: 'granted' && recurringUserLocal == true && loggedIn == false; => goes to LogIn [1]
//              'limited' && recurringUserLocal == true && loggedIn == false; => goes to LogIn [1]
//              'denied' || 'permanent' && recurringUserLocal == true && loggedIn == false; => goes to LogIn [1]
//              'denied' && recurringUserLocal == false || recurringUserLocal == null && loggedIn == true; => goes to Request Permission [2]
//              'granted' && recurringUserLocal == true && loggedIn == true; => goes to Grid [3]
//              'denied' || 'permanent' && recurringUserLocal == true && loggedIn == true; => goes Need Photo Access [4]
//              'limited' && recurringUserLocal == true && loggedIn == true; => goes to Need Photo Access [4]

//TODO 9: implement Photo access needed conditional navigation and listening permissions in real time so app does not crash on
// change of permissions https://stackoverflow.com/questions/55442995/flutter-how-do-i-listen-to-permissions-real-time
// TODO 16: splash page
// TODO 15: Hero animation
// TODO 14: CupertinoPageTransition https://api.flutter.dev/flutter/cupertino/CupertinoPageTransition-class.html
