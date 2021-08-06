import 'package:flutter/material.dart';
import 'package:acpic/ui_elements/constants.dart';

enum Option { logOut }

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
              /**/
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

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_horiz_rounded,
        color: Colors.white,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Option>>[
        const PopupMenuItem<Option>(
          value: Option.logOut,
          child: Text(
            'Log Out',
            textAlign: TextAlign.right,
            style: kSelectAllButton,
          ),
        ),
      ],
    );
  }
}
