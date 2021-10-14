// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/material_elements.dart';
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SCREENS
import 'package:acpic/screens/distributor.dart';

class RecoverPasswordScreen extends StatefulWidget {
  static const String id = 'recover_password';
  @override
  _RecoverPasswordScreenState createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  Timer navigationDelayer;

  delayedNavigation() {
    navigationDelayer = new Timer(const Duration(seconds: 5), () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => Distributor()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GestureDetector(
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
                    child: Text(
                      'ac;pic',
                      style: kAcpicMain,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Text(
                      'Recover password',
                      style: kSubtitle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                    child: TextField(
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
                  ),
                  RoundedButton(
                    title: 'Recover password',
                    colour: kAltoBlue,
                    onPressed: () {
                      SnackBarGlobal.buildSnackBar(
                          context, 'Got it! Check your email inbox.', 'green');
                      // This makes the keyboard disappear
                      FocusManager.instance.primaryFocus?.unfocus();
                      delayedNavigation();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
