import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/loginView.dart';
import 'package:tagaway/views/signupFormView.dart';

class SignUpView extends StatefulWidget {
  static const String id = 'signup';

  const SignUpView({Key? key}) : super(key: key);

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
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
  Widget build(BuildContext context) {
    //With PopScope() the user cannot 'swipe' back
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
            child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'images/tag blue with white - 400x400.png',
                        scale: 4,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0, top: 10),
                      child: Hero(
                        tag: 'welcome',
                        child: Text(
                          'Welcome to tagaway',
                          style: kTagawayMain,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Text(
                        'Let your memories surprise you.',
                        style: kSubtitle,
                      ),
                    ),
                    RoundedExternalServiceLogInButton(
                      title: 'Sign up with Google',
                      colour: kAltoBlue,
                      icon: kGoogleIcon,
                      onPressed: _handleSignIn,
                    ),
                    RoundedExternalServiceLogInButton(
                      title: 'Sign up with Apple ',
                      colour: kAltoBlue,
                      icon: kAppleIcon,
                      onPressed: () {},
                    ),
                    RoundedExternalServiceLogInButton(
                      title: 'Sign up with email ',
                      colour: kAltoBlue,
                      icon: kEmailIcon,
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const SignUpFormView()));
                      },
                    ),
                    RoundedWhiteButton(
                      title: 'Log In',
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const LoginView()));
                      },
                    ),
                  ],
                ),
              ),
            ),
            const AltocodeCommit(),
          ],
        )),
      ),
    );
  }
}
