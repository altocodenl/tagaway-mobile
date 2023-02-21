import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagaway/ui_elements/constants.dart';

class StoreService {
  StoreService._privateConstructor ();
  static final StoreService instance = StoreService._privateConstructor ();

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
     debug (['STORE LOAD', store]);
  }

  // This function need not be awaited for setting the in-memory key, only if you want to await until the key is persisted to disk
  set (String key, dynamic value) async {
     debug (['STORE SET', key, value]);
     store [key] = value;
     updateStream.add (key);
     SharedPreferences myPrefs = await SharedPreferences.getInstance ();
     myPrefs.setString (key, jsonEncode (value));
  }

  get (String key) {
     var value = store [key] ?? '';
     debug (['STORE GET', key, value]);
     return value;
  }

}
