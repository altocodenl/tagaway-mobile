// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
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
import 'package:acpic/screens/recover_password.dart';
import 'package:acpic/screens/distributor.dart';
//IMPORT SERVICES
import 'package:acpic/services/local_vars_shared_prefs.dart';
import 'package:acpic/services/inviteService.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool recurringUserLocal = false;
  Future myFuture;
  String sessionCookie;
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
      print('response.headers is ${response.headers}');
      sessionCookie = response.headers['set-cookie'];
      print('sessionCookie is $sessionCookie');
      SharedPreferencesService.instance
          .setStringValue('sessionCookie', response.headers['set-cookie']);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => Distributor()),
      );
      return LoginBody.fromJson(jsonDecode(response.body));
    } else {
      print('response.statusCode is ${response.statusCode}');
      print('response.body from Log In is ${response.body}');
      SnackBarGlobal.buildSnackBar(
          context, 'Incorrect username, email or password.', 'red');
      throw Exception('Failed to log in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    // final flag =
    //     ModalRoute.of(context).settings.arguments as PermissionLevelFlag;
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
                      createAlbum(
                          _usernameController.text,
                          _passwordController.text,
                          DateTime.now().timeZoneOffset.inMinutes.toInt());
                      _usernameController.clear();
                      _passwordController.clear();

                      // TODO: Delete this function later. This is just to make the interface work as it should
                      SharedPreferencesService.instance
                          .setBooleanValue('loggedIn', true);
                      // ---

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
                                  ? CupertinoInvite()
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
                        print('snapshot is $snapshot');
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.data == 200) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            SnackBarGlobal.buildSnackBar(context,
                                'We got your request, hang tight!', 'green');
                          });
                        } else if (snapshot.connectionState ==
                                ConnectionState.done &&
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

// States:
// First time: 'denied' && recurringUserLocal == false || recurringUserLocal == null; => goes to RequestPermission [1]
// Other times: 'granted' && recurringUserLocal == true; => goes to Grid [2]
//              'limited' && recurringUserLocal == true; => goes to PhotoAccessNeeded [3]
//              'denied' || 'permanent' && recurringUserLocal == true; => goes to PhotoAccessNeeded [3]
