// IMPORT FLUTTER PACKAGES
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:acpic/ui_elements/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/material_elements.dart';
//IMPORT SERVICES
import 'package:acpic/services/local_vars_shared_prefs.dart';
import 'package:acpic/services/inviteService.dart';
//IMPORT SCREENS
import 'package:acpic/screens/distributor.dart';

// Future<EmailAlbum> sendInviteEmail(String email) async {
//   final response = await http.post(
//     Uri.parse('https://altocode.nl/picdev/requestInvite'),
//     headers: <String, String>{
//       'Content-Type': 'application/json;charset=UTF-8',
//     },
//     body: jsonEncode(<String, String>{
//       'email': email,
//     }),
//   );
//   if (response.statusCode == 200) {
//     print(response.statusCode);
//     print('Hello people');
//     return EmailAlbum.fromJson(jsonDecode(response.body));
//   } else {
//     print('response.statusCode is ${response.statusCode}');
//     throw Exception('Invite not sent');
//   }
// }

class EmailAlbum {
  final String email;
  EmailAlbum({@required this.email});
  factory EmailAlbum.fromJson(Map<String, String> json) {
    return EmailAlbum(email: json['email']);
  }
}

enum Option { logOut, web }

class AndroidInvite extends StatefulWidget {
  @override
  State<AndroidInvite> createState() => _AndroidInviteState();
}

class _AndroidInviteState extends State<AndroidInvite> {
  final TextEditingController emailController = TextEditingController();

  final RegExp emailValidation = RegExp(
      r"^(?=[A-Z0-9][A-Z0-9@._%+-]{5,253}$)[A-Z0-9._%+-]{1,64}@(?:(?=[A-Z0-9-]{1,63}\.)[A-Z0-9]+(?:-[A-Z0-9]+)*\.){1,8}[A-Z]{2,63}$",
      caseSensitive: false);

  Future<EmailAlbum> sendInviteEmail(String email) async {
    final response = await http.post(
      Uri.parse('https://altocode.nl/picdev/requestInvite'),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );
    if (response.statusCode == 200) {
      print(response.statusCode);

      // SnackBarGlobal.buildSnackBar(context, 'All good', 'green');
      print('what about this');
      if (response.body.isNotEmpty) {
        json.decode(response.body);
      } else if (response.body.isEmpty) {
        print('response.body.characters ${response.body.characters}');
        print('response.body.runtimeType ${response.body.runtimeType}');
      }
      return jsonDecode(response.body);
      // return EmailAlbum.fromJson(jsonDecode(response.body));
    } else {
      print('response.statusCode is ${response.statusCode}');
      SnackBarGlobal.buildSnackBar(context, 'Not good', 'red');
      throw Exception('Invite not sent');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Get your invite to ac;pic'),
      content: TextField(
        controller: emailController,
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
              if (emailValidation.hasMatch(emailController.text) == true) {
                sendInviteEmail(emailController.text);
                Navigator.of(context, rootNavigator: true).pop();
              } else {
                Navigator.of(context, rootNavigator: true).pop();
                SnackBarGlobal.buildSnackBar(
                    context, 'Please enter a valid email address', 'red');
              }
              emailController.clear();
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
