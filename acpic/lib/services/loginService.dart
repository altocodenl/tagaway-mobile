// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/cupertino_elements.dart';
import 'package:acpic/ui_elements/android_elements.dart';
import 'package:acpic/ui_elements/material_elements.dart';
import 'package:acpic/ui_elements/constants.dart';
//IMPORT SCREENS
import 'package:acpic/screens/distributor.dart';

Future<LoginBody> createAlbum(
    String username, String password, dynamic timezone) async {
  final response = await http.post(
    Uri.parse('https://altocode.nl/picdev/auth/login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'username': username,
      'password': password,
      'timezone': timezone
    }),
  );
  if (response.statusCode == 200) {
    print('response.statusCode is ${response.statusCode}');
    print('response.body from Log In is ${response.body}');

    return LoginBody.fromJson(jsonDecode(response.body));
  } else {
    print('response.statusCode is ${response.statusCode}');
    print('response.body from Log In is ${response.body}');
    throw Exception('Failed to log in.');
  }
}

class LoginBody {
  final String username;
  final String password;
  final dynamic timezone;

  LoginBody(
      {@required this.username,
      @required this.password,
      @required this.timezone});

  factory LoginBody.fromJson(Map<String, dynamic> json) {
    return LoginBody(
        username: json['username'],
        password: json['password'],
        timezone: json['timezone']);
  }
}
