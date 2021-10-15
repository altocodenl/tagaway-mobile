// IMPORT FLUTTER PACKAGES
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/material_elements.dart';

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
    print('response.body.characters ${response.body.characters}');
    print('response.body.runtimeType ${response.body.runtimeType}');
    print('jsonDecode(response.body) is ${jsonDecode(response.body)}');
    print(
        'EmailAlbum.fromJson(jsonDecode(response.body)) is ${EmailAlbum.fromJson(jsonDecode(response.body))}');
    return EmailAlbum.fromJson(jsonDecode(response.body));
  } else {
    print('response.statusCode is ${response.statusCode}');
    throw Exception('Invite not sent');
  }
}

class EmailAlbum {
  final String email;
  EmailAlbum({@required this.email});

  factory EmailAlbum.fromJson(Map<String, dynamic> json) {
    return EmailAlbum(email: json['email']);
  }
}
