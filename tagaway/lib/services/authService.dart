import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/services/storeService.dart';

class AuthService {
   AuthService._privateConstructor ();
   static final AuthService instance = AuthService._privateConstructor ();

   Future <int> signup (String username, String password, String email) async {
      var response = await ajax ('post', 'auth/signup', {'username': username, 'password': password, 'email': email});
      return response ['code'];
   }

   Future <int> login (String username, String password, int timezone) async {
      var response = await ajax ('post', 'auth/login', {'username': username, 'password': password, 'timezone': timezone});
      if (response ['code'] == 200) {
         StoreService.instance.set ('cookie', response ['headers'] ['set-cookie']!, 'disk');
         StoreService.instance.set ('csrf',   response ['body']    ['csrf'], 'disk');
         StoreService.instance.set ('recurringUser', true, 'disk');
      }
      // Error code 1 signifies that the user must verify their email
      if (response ['code'] == 403 && response ['body'] ['error'] == 'verify') return 1;
      return response ['code'];
   }

   Future <int> recoverPassword (String username) async {
      var response = await ajax ('post', 'auth/recover', {'username': username});
      return response ['code'];
   }

   Future <int> logout () async {
      var response = await ajax ('post', 'auth/logout', {});
      if (response ['code'] == 200) {
         await StoreService.instance.remove ('cookie', 'disk');
         await StoreService.instance.remove ('csrf',   'disk');
      }
      return response ['code'];
   }

   Future <int> deleteAccount () async {
      var response = await ajax ('post', 'auth/delete', {});
      return response ['code'];
   }

   Future <int> changePassword (String old, String nEw, String repeat) async {
      if (nEw != repeat) return 1;
      var response = await ajax ('post', 'auth/changePassword', {'old': old, 'new': nEw});
      return response ['code'];
   }

}
