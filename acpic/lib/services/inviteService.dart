// IMPORT FLUTTER PACKAGES
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/material_elements.dart';

class InviteWidget extends StatefulWidget {
  final Widget child;
  InviteWidget({this.child});

  @override
  State<InviteWidget> createState() => _InviteWidgetState();
}

class _InviteWidgetState extends State<InviteWidget> {
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
      SnackbarGlobal.buildSnackbar(context,
          'We received your request successfully, hang tight!', 'green');
      return EmailAlbum.fromJson(jsonDecode(response.body));
    } else {
      // print('response.statusCode is ${response.statusCode}');
      SnackbarGlobal.buildSnackbar(
          context, 'There\'s been an error. Please try again later', 'red');
      throw Exception('Invite not sent');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: widget.child);
  }
}

class EmailAlbum {
  final String email;
  EmailAlbum({@required this.email});
  factory EmailAlbum.fromJson(Map<String, String> json) {
    return EmailAlbum(email: json['email']);
  }
}
