// IMPORT FLUTTER PACKAGES
import 'package:acpic/screens/request_permission.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:acpic/screens/login_screen.dart';
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SERVICES
import 'package:acpic/services/checkPermission.dart';
import 'package:acpic/services/local_vars_shared_prefs.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loggedInLocal = false;
  Future myFutureLoggedIn;
  String permissionLevel;

  @override
  void initState() {
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
    // print('loggedInLocal is $loggedInLocal');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('loggedInLocal in MyApp Build is $loggedInLocal');
    print('permissionLevel in MyApp Build is $permissionLevel');
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Distributor(),
      // permissionLevel != 'granted' || loggedInLocal == false
      //     ? Distributor()
      //     : GridPage(),
      routes: {
        GridPage.id: (context) => GridPage(),
        LoginScreen.id: (context) => LoginScreen(),
        PhotoAccessNeeded.id: (context) => PhotoAccessNeeded(),
        RequestPermission.id: (context) => RequestPermission(),
      },
    );
  }
}

class Distributor extends StatefulWidget {
  static const String id = 'distributor';

  @override
  _DistributorState createState() => _DistributorState();
}

class _DistributorState extends State<Distributor> {
  bool recurringUserLocal = false;
  bool loggedInLocal = false;
  Future myFuture;
  Future myFutureLoggedIn;

  @override
  void initState() {
    if (Platform.isAndroid == true) {
      myFuture = SharedPreferencesService.instance
          .getBooleanValue('recurringUser')
          .then((value) {
        setState(() {
          recurringUserLocal = value;
        });
      });
    }
    // TODO: Delete this function later. This is just to make the interface work as it should
    myFutureLoggedIn = SharedPreferencesService.instance
        .getBooleanValue('loggedIn')
        .then((value) {
      setState(() {
        loggedInLocal = value;
      });
      return loggedInLocal;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('loggedInLocal in Distributor Build is $loggedInLocal');
    print('recurringUserLocal in Distributor Build is $recurringUserLocal');
    // Conditional Navigation
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
        // print('I am in Distributor else and value is $value');
        Navigator.pushReplacementNamed(context, PhotoAccessNeeded.id,
            arguments: PermissionLevelFlag(permissionLevel: value));
      }
    });
    return Container(
      color: Colors.white,
      child: Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
      )),
    );
  }
}

// TODO 4: CupertinoPageTransition https://api.flutter.dev/flutter/cupertino/CupertinoPageTransition-class.html
// TODO: Maybe SplashScreen should disappear and load the validation (and forwarding) either at login or Grid.
//  Decision to be made after implementing splash according to best practices
// From MyApp>MaterialApp>Home will split into 3: LogIn and Grid will load directly, if not, user will be sent to distributor.
// Distributor will only handle RequestPermission and PhotoAccessNeeded

// Conditional Navigation
// checkPermission(context).then((value) {
// if (loggedInLocal == false) {
// Navigator.pushReplacementNamed(
// context,
// LoginScreen.id,
// arguments: PermissionLevelFlag(permissionLevel: value),
// );
// } else if ((Platform.isIOS
// ? (value == 'denied' && loggedInLocal == true)
//     : (value == 'denied' &&
// loggedInLocal == true &&
// recurringUserLocal == false ||
// recurringUserLocal == null))) {
// Navigator.pushReplacementNamed(context, RequestPermission.id);
// } else if (value == 'granted' && loggedInLocal == true) {
// Navigator.of(context).push(
// MaterialPageRoute(builder: (_) => GridPage()),
// );
// } else {
// Navigator.pushReplacementNamed(context, PhotoAccessNeeded.id,
// arguments: PermissionLevelFlag(permissionLevel: value));
// }
// });
