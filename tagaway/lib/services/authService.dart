import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tagaway/services/local_vars_shared_prefsService.dart';
import 'package:tagaway/ui_elements/constants.dart';

class AuthService {
   AuthService._privateConstructor();

   static final AuthService instance = AuthService._privateConstructor();

   Future <int> login (String username, String password, int timezone) async {
      try {
         final response = await http.post (
            Uri.parse (kAltoPicAppURL + '/auth/login'),
            headers: <String, String> {
               'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode (<String, dynamic> {
               'username': username,
               'password': password,
               'timezone': timezone
            }),
         );
         if (response.statusCode == 200) {
            SharedPreferencesService.instance.setStringValue ('cookie', response.headers ['set-cookie']!);
            SharedPreferencesService.instance.setStringValue ('csrf',   jsonDecode (response.body) ['csrf']);
         }
         return response.statusCode;
      } on SocketException catch (_) {
         return 0;
      }
   }

   Future <int> deleteAccount () async {
      final cookie = await SharedPreferencesService.instance.getStringValue ('cookie');
      final csrf   = await SharedPreferencesService.instance.getStringValue ('csrf');
      try {
         final response = await http.post (
            Uri.parse (kAltoPicAppURL + '/auth/delete'),
            headers: <String, String> {
               'Content-Type': 'application/json; charset=UTF-8',
               'cookie':       cookie
            },
            body: jsonEncode (<String, dynamic> {'csrf': csrf}),
         );
         return response.statusCode;
      } on SocketException catch (_) {
         return 0;
      }
   }

   Future <int> changePassword (String old, String New, String repeat) async {
      final cookie = await SharedPreferencesService.instance.getStringValue ('cookie');
      final csrf   = await SharedPreferencesService.instance.getStringValue ('csrf');
      try {
         final response = await http.post (
            Uri.parse (kAltoPicAppURL + '/auth/changePassword'),
            headers: <String, String> {
               'Content-Type': 'application/json; charset=UTF-8',
               'cookie':       cookie
            },
            body: jsonEncode (<String, dynamic> {
               'csrf': csrf,
               'old':  old,
               'new':  New
            }),
         );
         return response.statusCode;
      } on SocketException catch (_) {
         return 0;
      }
   }

}
