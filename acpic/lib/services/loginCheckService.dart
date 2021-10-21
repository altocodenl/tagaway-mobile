// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class LoginCheckService {
  LoginCheckService._privateConstructor();
  static final LoginCheckService instance =
      LoginCheckService._privateConstructor();

  Future<int> loginCheck(String cookie) async {
    final response = await http.get(
      Uri.parse('https://altocode.nl/picdev/csrf'),
      headers: <String, String>{'cookie': cookie},
    );
    print('I am in loginCheck() and cookie is $cookie');
    print('I am in loginCheck() response.statusCode is ${response.statusCode}');
    // print('I am in loginCheck() and response.body is ${response.body}');
    return response.statusCode;
  }
}

//
// String cookie;
//
// startCheck() {
//   SharedPreferencesService.instance.getStringValue('cookie').then((value) {
//     cookie = value;
//     print(cookie);
//     fetchAlbum();
//   });
// }
//
// Future<Album> fetchAlbum() async {
//   print(cookie);
//   final response = await http.get(
//     Uri.parse('https://altocode.nl/picdev/csrf'),
//     headers: <String, String>{'cookie': cookie},
//   );
//   if (response.statusCode == 200) {
//     print(response.statusCode);
//     print(response.body);
//     print('Response here was 200');
//     return Album.fromJson(jsonDecode(response.body));
//   } else {
//     print(response.statusCode);
//     print(response.body);
//     throw Exception('Not logged in');
//   }
// }
//
// class Album {
//   final String token;
//
//   Album({
//     @required this.token,
//   });
//
//   factory Album.fromJson(Map<String, dynamic> json) {
//     return Album(
//       token: json['csrf'],
//     );
//   }
// }
