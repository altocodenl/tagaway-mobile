import 'dart:convert';

import 'package:tagaway/ui_elements/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  SharedPreferencesService._privateConstructor();

  static final SharedPreferencesService instance =
      SharedPreferencesService._privateConstructor();

  set (String key, dynamic value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    debug (['SET', key, value]);
    myPrefs.setString (key, jsonEncode (value));
  }

  get (String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    debug (['GET', key, myPrefs.getString (key)]);
    return jsonDecode (myPrefs.getString (key) ?? '""');
  }

  setStringValue(String key, String value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setString(key, value);
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }

  setIntegerValue(String key, int value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setInt(key, value);
  }

  Future<int> getIntegerValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getInt(key) ?? 0;
  }

  setBooleanValue(String key, bool value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setBool(key, value);
  }

  Future<bool> getBooleanValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getBool(key) ?? false;
  }

  setStringListValue(String key, List<String> value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setStringList(key, value);
  }

  Future<List<String>?> getStringListValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getStringList(key);
  }

  Future<bool> containsKey(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.containsKey(key);
  }

  removeValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.remove(key);
  }

  removeAll() async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.clear();
  }
}
