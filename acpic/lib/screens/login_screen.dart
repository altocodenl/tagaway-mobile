// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/cupertino_elements.dart';
import 'package:acpic/ui_elements/android_elements.dart';
import 'package:acpic/ui_elements/material_elements.dart';
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SCREENS
import 'request_permission.dart';
import 'package:acpic/screens/grid.dart';
import 'package:acpic/screens/photo_access_needed.dart';
import 'package:acpic/screens/recover_password.dart';
//IMPORT SERVICES
import 'package:acpic/services/checkPermission.dart';
import 'package:acpic/services/local_vars_shared_prefs.dart';

//  TODO 1: This will have to navigate to Distributor
//  TODO 3: Check token persistence between sessions

Future<LoginBody> createAlbum(
    String username, String password, dynamic timezone) async {
  final response = await http.post(
    Uri.parse('https://altocode.nl/picdev/auth/login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'username': username,
      'password': password,
      'timezone': timezone
    }),
  );
  if (response.statusCode == 200) {
    print('response.statusCode is ${response.statusCode}');
    print('response.body from Log In is ${response.body}');
    return LoginBody.fromJson(jsonDecode(response.body));
  } else {
    print('response.statusCode is ${response.statusCode}');
    print('response.body from Log In is ${response.body}');
    throw Exception('Failed to log in.');
  }
}

class LoginBody {
  final String username;
  final String password;
  final dynamic timezone;

  LoginBody(
      {@required this.username,
      @required this.password,
      @required this.timezone});

  factory LoginBody.fromJson(Map<String, dynamic> json) {
    return LoginBody(
        username: json['username'],
        password: json['password'],
        timezone: json['timezone']);
  }
}

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool recurringUserLocal = false;
  Future myFuture;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Future<LoginBody> _futureLoginBody;

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
                      _futureLoginBody = createAlbum(
                          _usernameController.text,
                          _passwordController.text,
                          DateTime.now().timeZoneOffset.inMinutes.toInt());
                      _usernameController.clear();
                      _passwordController.clear();

                      // TODO: Delete this function later. This is just to make the interface work as it should
                      SharedPreferencesService.instance
                          .setBooleanValue('loggedIn', true);
                      // ---
                      // if (Platform.isIOS
                      //     ? flag.permissionLevel == 'denied'
                      //     : flag.permissionLevel == 'denied' &&
                      //             recurringUserLocal == false ||
                      //         recurringUserLocal == null) {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) {
                      //         return RequestPermission();
                      //       },
                      //     ),
                      //   );
                      // } else if (flag.permissionLevel == 'granted') {
                      //   Navigator.of(context).push(
                      //     MaterialPageRoute(builder: (_) => GridPage()),
                      //   );
                      // } else {
                      //   checkPermission(context).then((value) {
                      //     Navigator.pushReplacementNamed(
                      //         context, PhotoAccessNeeded.id,
                      //         arguments:
                      //             PermissionLevelFlag(permissionLevel: value));
                      //   });
                      // }
                      // This makes the keyboard disappear
                      FocusManager.instance.primaryFocus?.unfocus();
                      //  TODO 2: Add snackbar for incorrect username or password
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
                                  ? CupertinoInvite()
                                  : AndroidInvite();
                            });
                      },
                      child: Text(
                        'Don\'t have an account? Request an invite.',
                        style: kPlainHypertext,
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

// States:
// First time: 'denied' && recurringUserLocal == false || recurringUserLocal == null; => goes to RequestPermission [1]
// Other times: 'granted' && recurringUserLocal == true; => goes to Grid [2]
//              'limited' && recurringUserLocal == true; => goes to PhotoAccessNeeded [3]
//              'denied' || 'permanent' && recurringUserLocal == true; => goes to PhotoAccessNeeded [3]
