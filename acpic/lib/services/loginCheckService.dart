// IMPORT FLUTTER PACKAGES
import 'dart:async';
import 'dart:io';
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
    return response.statusCode;
  }
}
