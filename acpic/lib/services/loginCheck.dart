// IMPORT FLUTTER PACKAGES
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
//IMPORT SERVICES
import 'package:acpic/services/local_vars_shared_prefs.dart';

String sessionCookie;

startCheck() {
  SharedPreferencesService.instance
      .getStringValue('sessionCookie')
      .then((value) {
    sessionCookie = value;
    print(sessionCookie);
    fetchAlbum();
  });
}

Future<Album> fetchAlbum() async {
  print(sessionCookie);
  final response = await http.get(
    Uri.parse('https://altocode.nl/picdev/csrf'),
    headers: <String, String>{'cookie': sessionCookie},
  );

  if (response.statusCode == 200) {
    print(response.statusCode);
    print(response.body);
    print('Response here was 200');
    return Album.fromJson(jsonDecode(response.body));
  } else {
    print(response.statusCode);
    print(response.body);

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
