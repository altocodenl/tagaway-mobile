import 'package:flutter/material.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/loginView.dart';
import 'package:tagaway/views/signUpFormView.dart';

class SignUpView extends StatelessWidget {
  static const String id = 'signup';

  const SignUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //With WillPopScope() the user cannot 'swipe' back
    return WillPopScope(
      onWillPop: () async => false,
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
                          style: kAcpicMain,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Text(
                        'Your life’s journey, organized.',
                        style: kSubtitle,
                      ),
                    ),
                    RoundedButton(
                      colour: kAltoBlue,
                      title: 'Sign up with email',
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const SignUpFormView()));
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const LoginView()));
                      },
                      child: const Text(
                        'Already have an account?',
                        style: kPlainHypertext,
                      ),
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
