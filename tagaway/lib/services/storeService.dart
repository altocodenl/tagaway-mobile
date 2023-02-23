import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagaway/ui_elements/constants.dart';

class StoreService {
  StoreService._privateConstructor ();
  static final StoreService instance = StoreService._privateConstructor ();

  bool showLogs = false;

  var updateStream = StreamController<String>.broadcast ();

  var store = {};

  listen (dynamic list, Function fun) {
      Function updater = () async {
         // No variadic functions in Dart! Put some MC Hammer for context.
         if (list.length == 1) {
            dynamic v = await StoreService.instance.get (list [0]);
            fun (v);
         }
         if (list.length == 2) {
            dynamic v1 = await StoreService.instance.get (list [0]);
            dynamic v2 = await StoreService.instance.get (list [1]);
            fun (v1, v2);
         }
         if (list.length == 3) {
            dynamic v1 = await StoreService.instance.get (list [0]);
            dynamic v2 = await StoreService.instance.get (list [1]);
            dynamic v3 = await StoreService.instance.get (list [2]);
            fun (v1, v2, v3);
         }
      };
      // Run updater once to fetch current values
      updater ();
      // Register listener and return its cancel method
      return updateStream.stream.listen ((key) async {
         if (list.contains (key)) return updater ();
      }).cancel;
   }

  reset () async {
     SharedPreferences myPrefs = await SharedPreferences.getInstance ();
     await myPrefs.clear ();
  }

  // This function is called by main.dart to recreate the in-memory store
  load () async {
     SharedPreferences myPrefs = await SharedPreferences.getInstance ();
     var keys = await myPrefs.getKeys ();
     keys.forEach ((k) {
        // TODO: remove the commented line below after debugging uploads
        // if (RegExp ('^pivMap:').hasMatch (k)) return;
        store [k] = jsonDecode (myPrefs.getString (k) ?? '""');
     });
     if (showLogs) debug (['STORE LOAD', store]);
  }

  // This function need not be awaited for setting the in-memory key, only if you want to await until the key is persisted to disk
  set (String key, dynamic value, [bool memoryOnly = false]) async {
     if (showLogs) debug (['STORE SET', key, value]);
     store [key] = value;
     updateStream.add (key);
     // Some fields should not be stored, we want these to be in-memory only
     if (! memoryOnly) {
        SharedPreferences myPrefs = await SharedPreferences.getInstance ();
        myPrefs.setString (key, jsonEncode (value));
     }
  }

  get (String key) {
     var value = store [key] ?? '';
     if (showLogs) debug (['STORE GET', key, value]);
     return value;
  }

  remove (String key) async {
     SharedPreferences myPrefs = await SharedPreferences.getInstance ();
     myPrefs.remove (key);
  }

}
