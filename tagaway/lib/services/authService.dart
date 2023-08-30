import 'package:tagaway/services/tools.dart';
import 'package:tagaway/services/storeService.dart';

class AuthService {
   AuthService._privateConstructor ();
   static final AuthService instance = AuthService._privateConstructor ();

   signup (String username, String password, String email) async {
      var response = await ajax ('post', 'auth/signup', {'username': username, 'password': password, 'email': email});
      return {'code': response ['code'], 'body': response ['body']};
   }

   Future <int> login (String username, String password) async {
      int timezone = DateTime.now ().timeZoneOffset.inMinutes.toInt ();
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
      if (response ['code'] == 200) await cleanupKeys ();
      return response ['code'];
   }

   cleanupKeys () async {
      await StoreService.instance.remove ('cookie',      'disk');
      await StoreService.instance.remove ('csrf',        'disk');
      await StoreService.instance.remove ('lastNTags',   'disk');
      await StoreService.instance.remove ('uploadQueue', 'disk');
      await StoreService.instance.remove ('pendingTags:*',     'disk');
      await StoreService.instance.remove ('pendingDeletion:*', 'disk');
      StoreService.instance.store = {};
      // We wait a full second because if we try to reload the store from disk while redraws are taking place after the logout, things break.
      // The only reason we need to reload is to avoid re-hashing if the user logs back in in the current run of the app.
      Future.delayed(const Duration(seconds: 1), () {
        StoreService.instance.load ();
      });
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

   Future <int> getAccount () async {
      var response = await ajax ('get', 'account', {});
      if (response ['code'] == 200) {
         StoreService.instance.set ('account', response ['body']);
      }
      return response ['code'];
   }
}
