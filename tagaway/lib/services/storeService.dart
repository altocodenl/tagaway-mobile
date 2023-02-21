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
        store [k] = jsonDecode (myPrefs.getString (k) ?? '""');
     });
     debug (['STORE LOAD', store]);
  }

  set (String key, dynamic value) async {
     debug (['STORE SET', key, value]);
     SharedPreferences myPrefs = await SharedPreferences.getInstance ();
     store [key] = value;
     myPrefs.setString (key, jsonEncode (value));
     updateStream.add (key);
  }

  get (String key) async {
     var value = store [key] ?? '';
     debug (['STORE GET', key, value]);
     return value;
  }

}
