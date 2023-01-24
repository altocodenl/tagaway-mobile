// IMPORT FLUTTER PACKAGES
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:http/http.dart' as http;
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';

class DeleteAccountService {
  DeleteAccountService._privateConstructor();

  static final DeleteAccountService instance =
      DeleteAccountService._privateConstructor();

  Future<int> deleteAccountService(String cookie, String csrf) async {
    try {
      final response = await http.post(
        Uri.parse(kAltoPicAppURL + '/auth/delete'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': cookie
        },
        body: jsonEncode(<String, dynamic>{
          'csrf': csrf,
        }),
      );
      return response.statusCode;
    } on SocketException catch (_) {
      return 0;
    }
  }
}
