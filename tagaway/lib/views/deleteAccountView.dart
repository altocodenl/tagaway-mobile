import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tagaway/services/authService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class DeleteAccount extends StatefulWidget {
  static const String id = 'delete_account';

  const DeleteAccount({Key? key}) : super(key: key);

  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  late String cookie;
  late String csrf;

  @override
  void initState() {
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
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Are you sure you want to delete your tagaway account?',
                    textAlign: TextAlign.center,
                    style: kBigTitle,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
                  child: Text(
                    'If you delete your account all your data will be erased from our servers, including your photos, videos, log in credentials and all other information you\'ve stored.',
                    textAlign: TextAlign.center,
                    style: kPlainText,
                  ),
                ),
                Column(
                  children: <Widget>[
                    RoundedButton(
                      title: 'Cancel',
                      colour: kAltoBlue,
                      onPressed: () {
                        // Navigator.pushReplacement(context,
                        //     MaterialPageRoute(builder: (_) => Distributor()));
                      },
                    ),
                    RoundedButton(
                      title: 'Delete Account',
                      colour: kAltoRed,
                      onPressed: () {
                        AuthService.instance.deleteAccount().then((value) {
                          if (value == 200) {
                            StoreService.instance.reset();
                            SnackBarGlobal.buildSnackBar(context,
                                'Your account has been deleted.', 'green');
                            /*
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Distributor()));
                            */
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
