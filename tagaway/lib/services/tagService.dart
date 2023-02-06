// IMPORT FLUTTER PACKAGES
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:http/http.dart' as http;
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';

class tagService {
  tagService._privateConstructor();

  static final tagService instance =
      tagService._privateConstructor();

  Future<dynamic> getTags (String cookie, String csrf) async {
    try {
      final response = await http.get(
        Uri.parse(kAltoPicAppURL + '/tags'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          cookie:         cookie
        }
      );
      return response.statusCode;
    } on SocketException catch (_) {
      return 0;
    }
  }

  Future<int> setHometags (dynamic hometags) async {
    try {
      final response = await http.post(
        Uri.parse(kAltoPicAppURL + '/hometags'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          cookie:         cookie
        },
        body: jsonEncode(<String, dynamic>{
          csrf:     csrf,
          hometags: hometags
        }),
      );
      return response.statusCode;
    } on SocketException catch (_) {
      return 0;
    }
  }

  Future<int> tagPivs (String tag, dynamic ids) async {
    try {
      final response = await http.post(
        Uri.parse(kAltoPicAppURL + '/tag'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          cookie: cookie
        },
        body: jsonEncode(<String, dynamic>{
          csrf: csrf,
          tag:  tag,
          ids:  ids
        }),
      );
      return response.statusCode;
    } on SocketException catch (_) {
      return 0;
    }
  }
}
