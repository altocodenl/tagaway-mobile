import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/loginView.dart';

class SignUpFormView extends StatefulWidget {
  static const String id = 'signupForm';

  const SignUpFormView({Key? key}) : super(key: key);

  @override
  State<SignUpFormView> createState() => _SignUpFormViewState();
}

class _SignUpFormViewState extends State<SignUpFormView> {
  late Timer navigationDelayer;
  late bool showSuccess = false;
  final PageController pageController = PageController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController repeatUserNameController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController repeatEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();
  final RegExp emailValidation = RegExp(
      r"^(?=[A-Z0-9][A-Z0-9@._%+-]{5,253}$)[A-Z0-9._%+-]{1,64}@(?:(?=[A-Z0-9-]{1,63}\.)[A-Z0-9]+(?:-[A-Z0-9]+)*\.){1,8}[A-Z]{2,63}$",
      caseSensitive: false);

  @override
  void dispose() {
    pageController.dispose();
    userNameController.dispose();
    repeatUserNameController.dispose();
    emailController.dispose();
    repeatEmailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            toolbarHeight: 200,
            iconTheme: const IconThemeData(color: kAltoBlue, size: 30),
            backgroundColor: Colors.grey[50],
            elevation: 0,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'images/tag blue with white - 400x400.png',
                    scale: 4,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Create your account',
                    style: kBigTitle,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 5),
                      child: Column(
                        children: [
                          const Text(
                            'Step 1 of 3',
                            style: kWhiteButtonText,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, top: 20),
                            child: TextField(
                              controller: userNameController,
                              keyboardType: TextInputType.text,
                              autofocus: true,
                              textAlign: TextAlign.center,
                              enableSuggestions: false,
                              decoration: const InputDecoration(
                                hintText: 'Choose your username',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                ),
                              ),
                            ),
                          ),
                          TextField(
                            controller: repeatUserNameController,
                            keyboardType: TextInputType.text,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            enableSuggestions: false,
                            decoration: const InputDecoration(
                              hintText: 'Repeat your username',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: RoundedButton(
                                title: 'Next',
                                colour: kGreyDarker,
                                onPressed: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  if (userNameController.text.isEmpty ||
                                      repeatUserNameController.text.isEmpty) {
                                    SnackBarGlobal.buildSnackBar(context,
                                        'Please fill both fields', 'red');
                                  } else if (userNameController.text !=
                                      repeatUserNameController.text) {
                                    SnackBarGlobal.buildSnackBar(context,
                                        'Your usernames do not match', 'red');
                                  } else if (userNameController.text
                                          .contains('@') ||
                                      userNameController.text.contains(':')) {
                                    SnackBarGlobal.buildSnackBar(
                                        context,
                                        'Your username cannot contain @ or :',
                                        'red');
                                  } else if (userNameController.text.trim ().length <
                                      3) {
                                    SnackBarGlobal.buildSnackBar(
                                        context,
                                        'Your username should have at least 3 characters',
                                        'red');
                                  } else if (userNameController.text ==
                                      repeatUserNameController.text) {
                                    pageController.animateToPage(
                                      1,
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                }),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 5),
                      child: Column(
                        children: [
                          const Text(
                            'Step 2 of 3',
                            style: kWhiteButtonText,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, top: 20),
                            child: TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofocus: true,
                              textAlign: TextAlign.center,
                              enableSuggestions: true,
                              decoration: const InputDecoration(
                                hintText: 'Your email address',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                ),
                              ),
                            ),
                          ),
                          TextField(
                            controller: repeatEmailController,
                            keyboardType: TextInputType.emailAddress,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            enableSuggestions: true,
                            decoration: const InputDecoration(
                              hintText: 'Repeat your email address',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 3.0),
                            child: Text(
                                'You\'ll have to validate your email later.',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: kGreyDarker,
                                )),
                          ),
                          RoundedButton(
                              title: 'Next',
                              colour: kGreyDarker,
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (emailController.text.isEmpty ||
                                    repeatEmailController.text.isEmpty) {
                                  SnackBarGlobal.buildSnackBar(context,
                                      'Please fill both fields', 'red');
                                } else if (emailController.text !=
                                    repeatEmailController.text) {
                                  SnackBarGlobal.buildSnackBar(context,
                                      'Your emails do not match', 'red');
                                } else if (emailValidation
                                        .hasMatch(emailController.text) ==
                                    false) {
                                  SnackBarGlobal.buildSnackBar(
                                      context,
                                      'Please enter a valid email address',
                                      'red');
                                } else if (emailValidation
                                        .hasMatch(emailController.text) &&
                                    emailController.text ==
                                        repeatEmailController.text) {
                                  pageController.animateToPage(
                                    2,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              })
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 5),
                      child: Column(
                        children: [
                          const Text(
                            'Step 3 of 3',
                            style: kWhiteButtonText,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, top: 20),
                            child: TextField(
                              controller: passwordController,
                              keyboardType: TextInputType.text,
                              autofocus: true,
                              obscureText: true,
                              textAlign: TextAlign.center,
                              enableSuggestions: false,
                              decoration: const InputDecoration(
                                hintText: 'Your password',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                ),
                              ),
                            ),
                          ),
                          TextField(
                            controller: repeatPasswordController,
                            keyboardType: TextInputType.text,
                            autofocus: true,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            enableSuggestions: false,
                            decoration: const InputDecoration(
                              hintText: 'Repeat your password',
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: RoundedButton(
                                title: 'Create account',
                                colour: kAltoBlue,
                                onPressed: () {
                                  setState(() {
                                    showSuccess = true;
                                  });
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  if (passwordController.text.isEmpty ||
                                      repeatPasswordController.text.isEmpty) {
                                    SnackBarGlobal.buildSnackBar(context,
                                        'Please fill both fields', 'red');
                                  } else if (passwordController.text !=
                                      repeatPasswordController.text) {
                                    SnackBarGlobal.buildSnackBar(context,
                                        'Your passwords do not match', 'red');
                                  } else if (passwordController.text.length <
                                      6) {
                                    SnackBarGlobal.buildSnackBar(
                                        context,
                                        'Your password should have at least 6 characters',
                                        'red');
                                  }
                                  else if (passwordController.text ==
                                      repeatPasswordController.text) {
                                    AuthService.instance
                                        .signup(
                                            userNameController.text,
                                            passwordController.text,
                                            emailController.text)
                                        .then((value) {
                                      if (value ['code'] == 200) {
                                        navigationDelayer = Timer(
                                            const Duration(seconds: 2), () {
                                          Navigator.pushReplacementNamed(
                                              context, 'login',
                                              arguments: ShowVerifyBanner(
                                                  'showVerifyBanner'));
                                          userNameController.clear();
                                          repeatUserNameController.clear();
                                          emailController.clear();
                                          repeatEmailController.clear();
                                          passwordController.clear();
                                          repeatPasswordController.clear();
                                        });
                                      } else if (value ['code'] == 403) {
                                        if (value ['body'] ['error'] == 'email') SnackBarGlobal.buildSnackBar(context,
                                            'That email is already in use', 'red');
                                        if (value ['body'] ['error'] == 'username') SnackBarGlobal.buildSnackBar(context,
                                            'That username is already in use', 'red');
                                      } else if (value ['code'] > 500) {
                                        SnackBarGlobal.buildSnackBar(context,
                                           'Something is wrong on our side. Sorry.', 'red');
                                      } else if (value ['code'] == 0) {
                                        Navigator.pushReplacementNamed(
                                            context, 'offline');
                                      } else if (value ['code'] == 418) {
                                        SnackBarGlobal.buildSnackBar(context,
                                           'We currently have too many users. Please wait a few days!', 'red');
                                      }
                                    });
                                  }
                                }),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const AltocodeCommit(),
              ],
            ),
          ),
        ),
        SafeArea(
            child: Align(
          alignment: Alignment.topCenter,
          child: Visibility(
            visible: !showSuccess,
            child: Container(),
            replacement: Material(
              elevation: 1,
              child: Container(
                height: 80,
                width: double.infinity,
                color: Colors.grey[50],
                // color: Colors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      kCircleCheckIcon,
                      color: kAltoBlue,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: DefaultTextStyle(
                        style: kPlainTextBold,
                        child: Text(
                          'Welcome ${userNameController.text}!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ))
      ]),
    );
  }
}
