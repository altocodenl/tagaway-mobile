import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/recoverPasswordView.dart';
import 'package:tagaway/views/signupView.dart';

class LoginView extends StatefulWidget {
  static const String id = 'login';

  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late Timer materialBannerDelayer;
  bool recurringUserLocal = false;
  late Future myFuture;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final inviteResponse = StreamController<int>.broadcast();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    inviteResponse.close();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  materialBannerDisplay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          onVisible: () {
            materialBannerDelayer = Timer(const Duration(seconds: 4), () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            });
          },
          elevation: 1,
          padding: const EdgeInsets.all(20),
          content: Center(
            child: Row(
              children: const [
                Icon(
                  kEmailValidation,
                  color: kAltoBlue,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'You need to validate your email before logging in!',
                      textAlign: TextAlign.center,
                      style: kPlainTextBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.grey[50],
          actions: const <Widget>[SizedBox()],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    final check =
        ModalRoute.of(context)?.settings.arguments as ShowVerifyBanner?;
    if (check?.showVerifyBanner == 'showVerifyBanner') {
      materialBannerDisplay();
    } else if (check?.showVerifyBanner == null) {
      Container();
    }
    return GestureDetector(
      // This makes the keyboard disappear when tapping outside of it
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      //With WillPopScope() the user cannot 'swipe' back
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
                child: Stack(
              children: [
                Center(
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
                            'Your life’s journey, organized.',
                            style: kSubtitle,
                          ),
                        ),
                        TextField(
                          controller: usernameController,
                          keyboardType: TextInputType.emailAddress,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          enableSuggestions: true,
                          decoration: const InputDecoration(
                            hintText: 'Username or email',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                          child: TextField(
                            controller: passwordController,
                            autofocus: true,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
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
                                    usernameController.text,
                                    passwordController.text,
                                    DateTime.now()
                                        .timeZoneOffset
                                        .inMinutes
                                        .toInt()
                                    // TODO: move to handler function
                                    )
                                .then((value) {
                              if (value != 403) usernameController.clear();
                              passwordController.clear();

                              if (value == 403) {
                                SnackBarGlobal.buildSnackBar(
                                    context,
                                    'Incorrect username, email or password.',
                                    'red');
                              }
                              if (value == 500) {
                                SnackBarGlobal.buildSnackBar(
                                    context,
                                    'Something is wrong on our side. Sorry.',
                                    'red');
                              }
                              if (value == 200) {
                                return Navigator.pushReplacementNamed(
                                    context, 'distributor');
                              }
                              if (value == 0) {
                                Navigator.pushReplacementNamed(
                                    context, 'offline');
                              }
                              if (value == 1) {
                                materialBannerDisplay();
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
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) =>
                                        const RecoverPasswordView()));
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: const Text(
                                'Forgot password?',
                                style: kPlainHypertext,
                              ),
                            ),
                          ),
                        ),
                        Builder(
                          builder: (context) => Flexible(
                            flex: 2,
                            fit: FlexFit.loose,
                            child: TextButton(
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                Navigator.pushReplacementNamed(
                                    context, SignUpView.id);
                                // FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: const Text(
                                'Don\'t have an account? Sign up!',
                                style: kPlainHypertext,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const AltocodeCommit(),
              ],
            ))),
      ),
    );
  }
}

class ShowVerifyBanner {
  final String showVerifyBanner;

  ShowVerifyBanner(this.showVerifyBanner);
}
