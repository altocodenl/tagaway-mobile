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
