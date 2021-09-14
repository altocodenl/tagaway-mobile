// IMPORT FLUTTER PACKAGES
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
//IMPORT SERVICES
import 'package:acpic/services/local_vars_shared_prefs.dart';
//IMPORT SCREENS
import 'package:acpic/screens/distributor.dart';

class CupertinoInvite extends StatelessWidget {
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
            /**/
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
                    SharedPreferencesService.instance.removeValue('loggedIn');
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
