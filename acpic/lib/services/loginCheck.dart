// IMPORT FLUTTER PACKAGES
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
//IMPORT SERVICES
import 'package:acpic/services/local_vars_shared_prefs.dart';

String sessionCookie;

Future<Album> fetchAlbum() async {
  SharedPreferencesService.instance
      .getStringValue('sessionCookie')
      .then((value) {
    sessionCookie = value;
    return sessionCookie;
  });
  final response = await http.get(
    Uri.parse('https://altocode.nl/picdev/csrf'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'sessionCookie': sessionCookie
    },
  );
  print('I am floating and this is sessionCookie $sessionCookie');

  if (response.statusCode == 200) {
    print(response.statusCode);
    print(response.body);
    return Album.fromJson(jsonDecode(response.body));
  } else {
    print(response.statusCode);
    print(response.body);
    print('I am in fetchAlbum and sessionCookie is $sessionCookie');
    throw Exception('Not logged in');
  }
}

class Album {
  final String token;

  Album({
    @required this.token,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      token: json['csrf'],
    );
  }
}
