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
      print(
          'I am in LogInService and response.statusCode is ${response.statusCode} ');
      String cookie = response.headers['set-cookie'];
      print('cookie is $cookie');
      await SharedPreferencesService.instance
          .setStringValue('cookie', response.headers['set-cookie']);
      return response.statusCode;
    } else {
      return response.statusCode;
    }
  }
}
//
// class LoginBody {
//   final String username;
//   final String password;
//   final dynamic timezone;
//
//   LoginBody(
//       {@required this.username,
//         @required this.password,
//         @required this.timezone});
//
//   factory LoginBody.fromJson(Map<String, dynamic> json) {
//     return LoginBody(
//         username: json['username'],
//         password: json['password'],
//         timezone: json['timezone']);
//   }
// }
