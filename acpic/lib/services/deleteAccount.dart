// IMPORT FLUTTER PACKAGES
import 'dart:async';
import 'dart:io';
import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/constants.dart';
import 'package:acpic/ui_elements/cupertino_elements.dart';

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
