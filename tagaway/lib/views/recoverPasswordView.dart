// // IMPORT FLUTTER PACKAGES
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// //IMPORT SCREENS
// import 'package:acpic/screens/distributorView.dart';
// import 'package:acpic/screens/offlineView.dart';
// //IMPORT SERVICES
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/ui_elements/constants.dart';

// // IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/offlineView.dart';

class RecoverPasswordView extends StatefulWidget {
  static const String id = 'recoverPassword';

  const RecoverPasswordView({Key? key}) : super(key: key);

  @override
  _RecoverPasswordViewState createState() => _RecoverPasswordViewState();
}

class _RecoverPasswordViewState extends State<RecoverPasswordView> {
  late Timer navigationDelayer;
  final TextEditingController _usernameController = TextEditingController();

  delayedNavigation() {
    navigationDelayer = Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, 'distributor');
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
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: kGreyDarker, size: 30),
          backgroundColor: Colors.grey[50],
          centerTitle: true,
          title:
              const Text('Recover your password', style: kSubPageAppBarTitle),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _usernameController,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      enableSuggestions: true,
                      decoration: const InputDecoration(
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
                      AuthService.instance
                          .recoverPassword(_usernameController.text)
                          .then((value) {
                        if (value == 200) {
                          SnackBarGlobal.buildSnackBar(context,
                              'Got it! Check your email inbox.', 'green');
                          _usernameController.clear();
                          delayedNavigation();
                        } else if (value == 403) {
                          SnackBarGlobal.buildSnackBar(
                              context, 'Incorrect username or email.', 'red');
                        } else if (value == 0) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const OfflineView()));
                        } else if (500 <= value && value <= 599) {
                          SnackBarGlobal.buildSnackBar(context,
                              'Something is wrong on our side. Sorry.', 'red');
                        }
                      });
                      // This makes the keyboard disappear
                      FocusManager.instance.primaryFocus?.unfocus();
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
