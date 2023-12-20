import 'package:tagaway/main.dart';
import 'package:tagaway/services/tools.dart';

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
         store.set ('cookie', response ['headers'] ['set-cookie']!, 'disk');
         store.set ('csrf',   response ['body']    ['csrf'], 'disk');
         store.set ('recurringUser', true, 'disk');
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

   checkSession () async {
      var response = await ajax ('get', 'auth/csrf', {});
      if (response ['code'] != 200) await cleanupKeys ();
      return response ['code'];
   }

   cleanupKeys () async {
      await store.remove ('cookie',      'disk');
      await store.remove ('csrf',        'disk');
      await store.remove ('lastNTags',   'disk');
      await store.remove ('uploadQueue', 'disk');
      await store.remove ('pendingTags:*',     'disk');
      await store.remove ('pendingDeletion:*', 'disk');
      await store.remove ('organizedAtDaybreak', 'disk');
      store.store = {};
      navigatorKey.currentState!.pushReplacementNamed ('login');
      // We wait a full second because if we try to reload the store from disk while redraws are taking place after the logout, things break.
      // The only reason we need to reload is to avoid re-hashing if the user logs back in in the current run of the app.
      Future.delayed(const Duration(seconds: 1), () {
        store.load ();
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
         store.set ('account', response ['body']);
      }
      return response ['code'];
   }

   geotagging (String operation) async {
      var response = await ajax ('post', 'geo', {'operation': operation});
      if (response ['code'] == 200) {
         showSnackbar ('Geotagging ' + operation + 'd successfully', 'green');
         return getAccount ();
      }
      if (response ['code'] == 409) return showSnackbar ('The server is busy processing a recent geotagging request; please wait a couple of minutes and try again.', 'yellow');
      showSnackbar ('There was an unexpected error concerning geotagging settings - CODE GEO:' + response ['code'].toString (), 'yellow');
   }
}
