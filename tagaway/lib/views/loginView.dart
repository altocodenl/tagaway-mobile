import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/BottomNavigationBar.dart';
import 'package:tagaway/views/offlineView.dart';

class LoginView extends StatefulWidget {
  static const String id = 'login_screen';

  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

// TODO: remove this once we restore the proper permission level check code
class FakeFlag {
  String permissionLevel = 'granted';
}

class _LoginViewState extends State<LoginView> {
  bool recurringUserLocal = false;
  late Future myFuture;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final inviteResponse = StreamController<int>.broadcast();

  @override
  void initState() {
    if (Platform.isAndroid == true) {
      myFuture = StoreService.instance
          .get('recurringUser')
          .then((value) => setState(() {
                recurringUserLocal = value;
              }));
    }
    super.initState();
  }

  @override
  void dispose() {
    inviteResponse.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    // TODO: uncomment and get proper status
    // final flag = ModalRoute.of(context)?.settings.arguments as PermissionLevelFlag;
    final flag = FakeFlag();

    return GestureDetector(
      // This makes the keyboard disappear when tapping outside of it
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
              child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'images/tag blue with white - 400x400.png',
                      scale: 4,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10.0, top: 10),
                    child: Text(
                      'tagaway',
                      style: kAcpicMain,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Text(
                      'A home for your pictures',
                      style: kSubtitle,
                    ),
                  ),
                  TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    enableSuggestions: true,
                    decoration: const InputDecoration(
                      hintText: 'Username or email',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                    child: TextField(
                      controller: _passwordController,
                      autofocus: true,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
                    ),
                  ),
                  RoundedButton(
                    title: 'Log In',
                    colour: kAltoBlue,
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      AuthService.instance
                          .login(
                              _usernameController.text,
                              _passwordController.text,
                              DateTime.now().timeZoneOffset.inMinutes.toInt()
                              // TODO: move to handler function
                              )
                          .then((value) {
                        if (value != 403) _usernameController.clear();
                        _passwordController.clear();

                        if (value == 0)
                          return Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const OfflineScreen()));

                        if (value == 403)
                          return SnackBarGlobal.buildSnackBar(context,
                              'Incorrect username, email or password.', 'red');
                        if (value == 500)
                          return SnackBarGlobal.buildSnackBar(context,
                              'Something is wrong on our side. Sorry.', 'red');

                        if (value == 200) {
                          if (Platform.isIOS &&
                                  flag.permissionLevel == 'denied' ||
                              Platform.isAndroid &&
                                  flag.permissionLevel == 'denied' &&
                                  (recurringUserLocal == false ||
                                      recurringUserLocal == null)) {
                            // TODO: add proper routing here
                            Navigator.pushReplacementNamed(
                                context, BottomNavigationView.id);
                            // Navigator.pushReplacement (context, MaterialPageRoute (builder: (BuildContext context) => RequestPermission ()));
                            return SnackBarGlobal.buildSnackBar(context,
                                'Login successful, need permissions', 'yellow');
                          } else if (flag.permissionLevel == 'granted' ||
                              flag.permissionLevel == 'limited') {
                            // TODO: add proper routing here
                            Navigator.pushReplacementNamed(
                                context, BottomNavigationView.id);
                            // Navigator.pushReplacement (context, MaterialPageRoute (builder: (BuildContext context) => GridPage ()));
                            return SnackBarGlobal.buildSnackBar(
                                context,
                                'Login successful, permissions granted!',
                                'green');
                          } else {
                            // TODO: add proper routing here
                            //Navigator.pushReplacementNamed (context, PhotoAccessNeeded.id, arguments: PermissionLevelFlag (permissionLevel: value));
                            return SnackBarGlobal.buildSnackBar(context,
                                'Login successful, need permissions', 'green');
                          }
                        }
                      });
                    },
                  ),
                  Builder(
                    builder: (context) => Flexible(
                      flex: 2,
                      fit: FlexFit.loose,
                      child: TextButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          // Navigator.of(context).push (MaterialPageRoute (builder: (_) => RecoverPasswordScreen()));
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: const Text(
                          'Forgot password?',
                          style: kPlainHypertext,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ))),
    );
  }
}
