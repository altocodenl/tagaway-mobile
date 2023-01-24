// IMPORT FLUTTER PACKAGES
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';

class RecoverPasswordService {
  RecoverPasswordService._privateConstructor();

  static final RecoverPasswordService instance =
      RecoverPasswordService._privateConstructor();

  Future<int> recoverPassword(String username) async {
    try {
      final response = await http.post(
        Uri.parse(kAltoPicAppURL + '/auth/recover'),
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
