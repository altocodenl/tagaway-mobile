// IMPORT FLUTTER PACKAGES
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class LoginCheckService {
  LoginCheckService._privateConstructor();
  static final LoginCheckService instance =
      LoginCheckService._privateConstructor();
  Future<int> loginCheck(String cookie) async {
    try {
      final response = await http.get(
        Uri.parse('https://altocode.nl/picdev/csrf'),
        headers: <String, String>{'cookie': cookie},
      );
      print(response.body);
      return response.statusCode;
    } on SocketException catch (_) {
      return 0;
    }
  }
}
