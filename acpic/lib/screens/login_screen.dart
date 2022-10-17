// IMPORT FLUTTER PACKAGES
import 'package:acpic/screens/request_permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io' show Platform;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/cupertino_elements.dart';
import 'package:acpic/ui_elements/android_elements.dart';
import 'package:acpic/ui_elements/material_elements.dart';
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SCREENS
import 'package:acpic/screens/recover_password.dart';
import 'package:acpic/screens/grid.dart';
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:acpic/screens/offline.dart';
//IMPORT SERVICES
import 'package:acpic/services/local_vars_shared_prefsService.dart';
import 'package:acpic/services/logInService.dart';
import 'package:acpic/services/permissionCheckService.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool recurringUserLocal = false;
  Future myFuture;
  String cookie;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final inviteResponse = StreamController<int>.broadcast();

  @override
  void initState() {
    if (Platform.isAndroid == true) {
      myFuture = SharedPreferencesService.instance
          .getBooleanValue('recurringUser')
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
    final flag =
        ModalRoute.of(context).settings.arguments as PermissionLevelFlag;
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 20),
                    child: Hero(
                      tag: 'logo',
                      child: Text(
                        'ac;pic',
                        style: kAcpicMain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
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
                    decoration: InputDecoration(
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
                      decoration: InputDecoration(
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
                      LogInService.instance
                          .createAlbum(
                              _usernameController.text,
                              _passwordController.text,
                              DateTime.now().timeZoneOffset.inMinutes.toInt())
                          .then((value) {
                        if (value == 200) {
                          if ((Platform.isIOS
                              ? (flag.permissionLevel == 'denied')
                              : (flag.permissionLevel == 'denied' &&
                                      recurringUserLocal == false ||
                                  recurringUserLocal == null))) {
                            _usernameController.clear();
                            _passwordController.clear();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        RequestPermission()));
                          } else if (flag.permissionLevel == 'granted' ||
                              flag.permissionLevel == 'limited') {
                            _usernameController.clear();
                            _passwordController.clear();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        GridPage()));
                          } else {
                            _usernameController.clear();
                            _passwordController.clear();
                            checkPermission(context).then((value) {
                              Navigator.pushReplacementNamed(
                                  context, PhotoAccessNeeded.id,
                                  arguments: PermissionLevelFlag(
                                      permissionLevel: value));
                            });
                          }
                        } else if (value == 403) {
                          _passwordController.clear();
                          SnackBarGlobal.buildSnackBar(context,
                              'Incorrect username, email or password.', 'red');
                        } else if (value == 0) {
                          _usernameController.clear();
                          _passwordController.clear();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => OfflineScreen()));
                        } else if (500 <= value) {
                          _usernameController.clear();
                          _passwordController.clear();
                          SnackBarGlobal.buildSnackBar(context,
                              'Something is wrong on our side. Sorry.', 'red');
                        }
                      });
                      // This makes the keyboard disappear
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                  Builder(
                    builder: (context) => Flexible(
                      flex: 2,
                      fit: FlexFit.loose,
                      child: TextButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => RecoverPasswordScreen()),
                          );
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Text(
                          'Forgot password?',
                          style: kPlainHypertext,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: TextButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Platform.isIOS
                                  ? CupertinoInvite(
                                      inviteResponse: inviteResponse,
                                    )
                                  : AndroidInvite(
                                      inviteResponse: inviteResponse,
                                    );
                            });
                      },
                      child: Text(
                        'Don\'t have an account? Request an invite.',
                        style: kPlainHypertext,
                      ),
                    ),
                  ),
                  StreamBuilder(
                      stream: inviteResponse.stream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.active &&
                            snapshot.data == 200) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            SnackBarGlobal.buildSnackBar(context,
                                'We got your request, hang tight!', 'green');
                          });
                        } else if (snapshot.connectionState ==
                                ConnectionState.active &&
                            snapshot.data != 200) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            SnackBarGlobal.buildSnackBar(
                                context,
                                'There\'s been an error. Please try again later',
                                'red');
                          });
                        }
                        return Container(
                          color: Colors.transparent,
                        );
                      })
                ],
              ),
            ),
          ))),
    );
  }
}
