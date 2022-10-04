// IMPORT FLUTTER PACKAGES
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/constants.dart';

class LoginCheckService {
  LoginCheckService._privateConstructor();
  static final LoginCheckService instance =
      LoginCheckService._privateConstructor();
  Future<int> loginCheck(String cookie) async {
    try {
      final response = await http.get(
        Uri.parse(kAltoPicApp + '/auth/csrf'),
        headers: <String, String>{'cookie': cookie},
      );
      return response.statusCode;
    } on SocketException catch (_) {
      return 0;
    }
  }
}
