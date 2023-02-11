import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:tagaway/services/local_vars_shared_prefsService.dart';
import 'package:tagaway/ui_elements/constants.dart';

class TagService {
   TagService._privateConstructor();

   static final TagService instance = TagService._privateConstructor();

   Future <dynamic> getTags () async {
      try {
         final cookie = await SharedPreferencesService.instance.get ('cookie');
         final response = await http.get (
            Uri.parse (kAltoPicAppURL + '/tags'),
            headers: <String, String> {'cookie': cookie}
         );
         if (response.statusCode == 200) {
            dynamic body = jsonDecode (response.body);
            SharedPreferencesService.instance.set ('hometags', body ['hometags']);
            SharedPreferencesService.instance.set ('tags',     body ['tags']);
            debug (['hometags', body ['hometags']]);
            return body ['hometags'];
         }
         return [];
      } on SocketException catch (_) {
         return 0;
      }
   }
}
