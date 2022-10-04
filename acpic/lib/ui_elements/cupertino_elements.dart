// IMPORT FLUTTER PACKAGES
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/material_elements.dart';
//IMPORT SERVICES
import 'package:acpic/services/local_vars_shared_prefsService.dart';
import 'package:acpic/services/inviteEmailService.dart';
//IMPORT SCREENS
import 'package:acpic/screens/distributor.dart';

class CupertinoInvite extends StatelessWidget {
  final StreamController<int> inviteResponse;
  CupertinoInvite({@required this.inviteResponse});
  final TextEditingController emailController = TextEditingController();

  final RegExp emailValidation = RegExp(
      r"^(?=[A-Z0-9][A-Z0-9@._%+-]{5,253}$)[A-Z0-9._%+-]{1,64}@(?:(?=[A-Z0-9-]{1,63}\.)[A-Z0-9]+(?:-[A-Z0-9]+)*\.){1,8}[A-Z]{2,63}$",
      caseSensitive: false);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Get your invite to ac;pic'),
      ),
      content: CupertinoTextField(
        keyboardType: TextInputType.emailAddress,
        textAlign: TextAlign.center,
        autofillHints: <String>[AutofillHints.email],
        placeholder: 'Enter your email',
      ),
      actions: [
        CupertinoDialogAction(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          child: Text('Send'),
          onPressed: () {
            print(emailController.text.toString());
            if (emailValidation.hasMatch(emailController.text) == true) {
              InviteService.instance
                  .sendInviteEmail(emailController.text)
                  .then((value) {
                print('value is $value');
                inviteResponse.sink.add(value);
              });
              Navigator.of(context, rootNavigator: true).pop();
              emailController.clear();
            } else {
              // This makes the keyboard disappear
              FocusManager.instance.primaryFocus?.unfocus();
              //---
              SnackBarGlobal.buildSnackBar(
                  context, 'Please enter a valid email address', 'red');
            }
          },
        ),
      ],
    );
  }
}

class CupertinoLogOut extends StatelessWidget {
  const CupertinoLogOut({
    Key key,
  }) : super(key: key);
  _launchURL() async {
    const url = 'https://altocode.nl/pic/app/#/login';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.more_horiz_rounded),
        color: Colors.white,
        onPressed: () {
          showCupertinoModalPopup(
            context: context,
            builder: (context) => CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () {
                    _launchURL();
                  },
                  child: Text('Go to ac;pic web'),
                ),
                CupertinoActionSheetAction(
                  onPressed: () {
                    SharedPreferencesService.instance.removeAll();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => Distributor()));
                  },
                  child: Text('Log Out'),
                  isDestructiveAction: true,
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        });
  }
}
