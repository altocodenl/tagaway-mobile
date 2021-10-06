// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:acpic/ui_elements/constants.dart';
import 'package:url_launcher/url_launcher.dart';
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/material_elements.dart';
//IMPORT SERVICES
import 'package:acpic/services/local_vars_shared_prefs.dart';
//IMPORT SCREENS
import 'package:acpic/screens/distributor.dart';

enum Option { logOut, web }

class AndroidInvite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Get your invite to ac;pic'),
      content: TextField(
        keyboardType: TextInputType.emailAddress,
        textAlign: TextAlign.center,
        autofillHints: <String>[AutofillHints.email],
        decoration: InputDecoration(
          hintText: 'Enter your email',
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel')),
        TextButton(
            onPressed: () {
              SnackbarGlobal.buildSnackbar(
                  context,
                  'We received your request successfully, hang tight!',
                  'green');
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text('Send')),
      ],
    );
  }
}

class AndroidLogOut extends StatelessWidget {
  const AndroidLogOut({
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
    return PopupMenuButton(
      onSelected: (value) {
        if (value == Option.logOut) {
          SharedPreferencesService.instance.removeValue('sessionCookie');
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => Distributor()));
        } else if (value == Option.web) {
          _launchURL();
        }
      },
      icon: Icon(
        Icons.more_horiz_rounded,
        color: Colors.white,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Option>>[
        const PopupMenuItem<Option>(
          value: Option.web,
          child: Text(
            'Go to ac;pic web',
            textAlign: TextAlign.right,
            style: kGoToWebButton,
          ),
        ),
        const PopupMenuItem<Option>(
          value: Option.logOut,
          child: Text(
            'Log Out',
            textAlign: TextAlign.right,
            style: kLogOutButton,
          ),
        ),
      ],
    );
  }
}
