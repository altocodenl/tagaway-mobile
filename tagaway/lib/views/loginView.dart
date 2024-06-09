import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/loginWithEmailView.dart';

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
  // final TextEditingController usernameController = TextEditingController();
  // final TextEditingController passwordController = TextEditingController();
  // final inviteResponse = StreamController<int>.broadcast();

  Future<void> _handleSignIn() async {
    AuthService.instance.loginGoogle().then((value) {
      if (value != 200) {
        SnackBarGlobal.buildSnackBar(context,
            'There was an error logging you in through Google.', 'red');
      }
      if (value == 200) {
        return Navigator.pushReplacementNamed(context, 'distributor');
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   inviteResponse.close();
  //   usernameController.dispose();
  //   passwordController.dispose();
  //   super.dispose();
  // }

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
      //With PopScope() the user cannot 'swipe' back
      child: PopScope(
        canPop: false,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
                child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            'Let your memories surprise you.',
                            style: kSubtitle,
                          ),
                        ),
                        RoundedExternalServiceLogInButton(
                          title: 'Continue with Google',
                          colour: kAltoBlue,
                          icon: kGoogleIcon,
                          onPressed: _handleSignIn,
                        ),
                        RoundedExternalServiceLogInButton(
                          title: 'Continue with Apple ',
                          colour: kAltoBlue,
                          icon: kAppleIcon,
                          onPressed: () {},
                        ),
                        RoundedExternalServiceLogInButton(
                          title: 'Continue with email ',
                          colour: kAltoBlue,
                          icon: kEmailIcon,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const LoginWithEmailView()));
                          },
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
