// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/material_elements.dart';
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SCREENS
import 'package:acpic/screens/distributor.dart';
//IMPORT SERVICES
import 'package:acpic/services/local_vars_shared_prefsService.dart';
import 'package:acpic/services/deleteAccountService.dart';

class DeleteAccount extends StatefulWidget {
  static const String id = 'delete_account';
  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  String cookie;
  String csrf;

  @override
  void initState() {
    SharedPreferencesService.instance.getStringValue('cookie').then((value) {
      setState(() {
        cookie = value;
      });
    });
    SharedPreferencesService.instance.getStringValue('csrf').then((value) {
      setState(() {
        csrf = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Are you sure you want to delete your ac;pic account?',
                    textAlign: TextAlign.center,
                    style: kBigTitle,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10, left: 20, right: 20),
                  child: Text(
                    'If you delete your account all your data will be erased from our servers, including your photos, videos, log in credentials and all other information you\'ve stored.',
                    textAlign: TextAlign.center,
                    style: kPlainText,
                  ),
                ),
                Column(
                  children: [
                    RoundedButton(
                      title: 'Cancel',
                      colour: kAltoBlue,
                      onPressed: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => Distributor()));
                      },
                    ),
                    RoundedButton(
                      title: 'Delete Account',
                      colour: kAltoRed,
                      onPressed: () {
                        DeleteAccountService.instance
                            .deleteAccountService(cookie, csrf)
                            .then((value) {
                          if (value == 200) {
                            SharedPreferencesService.instance.removeAll();
                            SnackBarGlobal.buildSnackBar(context,
                                'Your account has been deleted.', 'green');
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Distributor()));
                          } else {
                            SnackBarGlobal.buildSnackBar(
                                context,
                                'There was an unexpected error. Your account was not deleted.',
                                'red');
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
