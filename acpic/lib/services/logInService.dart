// IMPORT FLUTTER PACKAGES
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
//IMPORT SERVICES
import 'package:acpic/services/local_vars_shared_prefsService.dart';

class LogInService {
  LogInService._privateConstructor();
  static final LogInService instance = LogInService._privateConstructor();

  Future<int> createAlbum(
      String username, String password, dynamic timezone) async {
    final response = await http.post(
      Uri.parse('https://altocode.nl/picdev/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'username': username,
        'password': password,
        'timezone': timezone
      }),
    );
    if (response.statusCode == 200) {
      await SharedPreferencesService.instance
          .setStringValue('cookie', response.headers['set-cookie']);
      return response.statusCode;
    } else {
      return response.statusCode;
    }
  }
}
