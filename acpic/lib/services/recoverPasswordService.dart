// IMPORT FLUTTER PACKAGES
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/constants.dart';

class RecoverPasswordService {
  RecoverPasswordService._privateConstructor();
  static final RecoverPasswordService instance =
      RecoverPasswordService._privateConstructor();

  Future<int> recoverPassword(String username) async {
    try {
      final response = await http.post(
        Uri.parse(kAltoPicApp + '/auth/recover'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': username,
        }),
      );
      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        return response.statusCode;
      }
    } on SocketException catch (_) {
      return 0;
    }
  }
}
