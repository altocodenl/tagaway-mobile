import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagaway/views/recoverPasswordView.dart';

import '../services/authService.dart';
import '../ui_elements/constants.dart';
import '../ui_elements/material_elements.dart';

class LoginWithEmailView extends StatefulWidget {
  static const String id = 'loginWithEmailForm';

  const LoginWithEmailView({super.key});

  @override
  State<LoginWithEmailView> createState() => _LoginWithEmailViewState();
}

class _LoginWithEmailViewState extends State<LoginWithEmailView> {
  late Timer materialBannerDelayer;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
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
                  'Log in to your account',
                  style: kBigTitle,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: usernameController,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                textAlign: TextAlign.center,
                enableSuggestions: true,
                decoration: const InputDecoration(
                  hintText: 'Username or email',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                child: TextField(
                  controller: passwordController,
                  autofocus: true,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
                      SnackBarGlobal.buildSnackBar(context,
                          'Incorrect username, email or password.', 'red');
                    }
                    if (value == 500) {
                      SnackBarGlobal.buildSnackBar(context,
                          'Something is wrong on our side. Sorry.', 'red');
                    }
                    if (value == 200) {
                      return Navigator.pushReplacementNamed(
                          context, 'distributor');
                    }
                    if (value == 0) {
                      Navigator.pushReplacementNamed(context, 'offline');
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
                          builder: (_) => const RecoverPasswordView()));
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
      ),
    );
  }
}
