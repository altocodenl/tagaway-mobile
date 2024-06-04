import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/recoverPasswordView.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/services/tools.dart';

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

  GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId: Platform.isAndroid
          ? '764404427753-t9dd8bfdvsvcnomti9e2h56nr6ffaet9.apps.googleusercontent.com'
          : '764404427753-3g56747hiqnk7o8fqtsj7i4kh2c70btt.apps.googleusercontent.com',
      scopes: [
        'openid',
        'email',
      ]);

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? authentication =
          await account?.authentication;
      final String? idToken = authentication?.idToken;

      AuthService.instance.loginGoogle(idToken!).then((value) {
        if (value != 200) {
          SnackBarGlobal.buildSnackBar(context,
              'There was an error logging you in through Google.', 'red');
        }
        if (value == 200) {
          return Navigator.pushReplacementNamed(context, 'distributor');
        }
      });
    } catch (error) {
      debug(['error', error]);
    }
  }

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

  showVerifyBanner() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          onVisible: () {
            materialBannerDelayer = Timer(const Duration(seconds: 4), () {
              if (mounted)
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            });
          },
          elevation: 1,
          padding: const EdgeInsets.all(20),
          content: const Center(
            child: Row(
              children: [
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
      showVerifyBanner();
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
                            style: kTagawayMain,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 30),
                          child: Text(
                            'Let your memories surprise you.',
                            style: kSubtitle,
                          ),
                        ),
                        GestureDetector(
                          onTap: _handleSignIn,
                          child: Container(
                            width: 180.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SvgPicture.asset('images/google_logo.svg',
                                    fit: BoxFit.contain),
                              ],
                            ),
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
                                showVerifyBanner();
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
                                    context, 'signup');
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
