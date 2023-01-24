// IMPORT FLUTTER PACKAGES
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool recurringUserLocal = false;
  late Future myFuture;
  late String cookie;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final inviteResponse = StreamController<int>.broadcast();

  // @override
  // void initState() {
  //   if (Platform.isAndroid == true) {
  //     myFuture = SharedPreferencesService.instance
  //         .getBooleanValue('recurringUser')
  //         .then((value) => setState(() {
  //               recurringUserLocal = value;
  //             }));
  //   }
  //   super.initState();
  // }

  @override
  void dispose() {
    inviteResponse.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    // final flag =
    //     ModalRoute.of(context)?.settings.arguments as PermissionLevelFlag;
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
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10.0, top: 20),
                    child: Hero(
                      tag: 'logo',
                      child: Text(
                        'tagaway',
                        style: kAcpicMain,
                      ),
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
                      // LogInService.instance
                      //     .createAlbum(
                      //         _usernameController.text,
                      //         _passwordController.text,
                      //         DateTime.now().timeZoneOffset.inMinutes.toInt())
                      //     .then((value) {
                      //   if (value == 200) {
                      //     if ((Platform.isIOS
                      //         ? (flag.permissionLevel == 'denied')
                      //         : (flag.permissionLevel == 'denied' &&
                      //             recurringUserLocal == false
                      //         // || recurringUserLocal == null
                      //         ))) {
                      //       _usernameController.clear();
                      //       _passwordController.clear();
                      //       // Navigator.pushReplacement(
                      //       //     context,
                      //       //     MaterialPageRoute(
                      //       //         builder: (BuildContext context) =>
                      //       //             RequestPermission()));
                      //     } else if (flag.permissionLevel == 'granted' ||
                      //         flag.permissionLevel == 'limited') {
                      //       _usernameController.clear();
                      //       _passwordController.clear();
                      //       // Navigator.pushReplacement(
                      //       //     context,
                      //       //     MaterialPageRoute(
                      //       //         builder: (BuildContext context) =>
                      //       //             GridPage()));
                      //     } else {
                      //       _usernameController.clear();
                      //       _passwordController.clear();
                      //       checkPermission(context).then((value) {
                      //         // Navigator.pushReplacementNamed(
                      //         //     context, PhotoAccessNeeded.id,
                      //         //     arguments: PermissionLevelFlag(
                      //         //         permissionLevel: value));
                      //       });
                      //     }
                      //   } else if (value == 403) {
                      //     _passwordController.clear();
                      //     SnackBarGlobal.buildSnackBar(context,
                      //         'Incorrect username, email or password.', 'red');
                      //   } else if (value == 0) {
                      //     _usernameController.clear();
                      //     _passwordController.clear();
                      //     Navigator.of(context).push(MaterialPageRoute(
                      //         builder: (_) => const OfflineScreen()));
                      //   } else if (500 <= value) {
                      //     _usernameController.clear();
                      //     _passwordController.clear();
                      //     SnackBarGlobal.buildSnackBar(context,
                      //         'Something is wrong on our side. Sorry.', 'red');
                      //   }
                      // });
                      // // This makes the keyboard disappear
                      // FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                  Builder(
                    builder: (context) => Flexible(
                      flex: 2,
                      fit: FlexFit.loose,
                      child: TextButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //       builder: (_) => RecoverPasswordScreen()),
                          // );
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
