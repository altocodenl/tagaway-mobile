import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagaway/ui_elements/constants.dart';

class StoreService {
  StoreService._privateConstructor ();
  static final StoreService instance = StoreService._privateConstructor ();

  var updateStream = StreamController<String>.broadcast ();

  reset () async {
     SharedPreferences myPrefs = await SharedPreferences.getInstance ();
     await myPrefs.clear ();
  }

  // This function is called by main.dart to recreate the in-memory store
  load () async {
     SharedPreferences myPrefs = await SharedPreferences.getInstance ();
     var keys = await myPrefs.getKeys ();
     return keys;
  }

  set (String key, dynamic value) async {
     SharedPreferences myPrefs = await SharedPreferences.getInstance ();
     // debug (['SET', key, value]);
     myPrefs.setString (key, jsonEncode (value));
     updateStream.add (key);
  }

  get (String key) async {
     SharedPreferences myPrefs = await SharedPreferences.getInstance ();
     // debug (['GET', key, myPrefs.getString (key)]);
     return jsonDecode (myPrefs.getString (key) ?? '""');
  }

}
