import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagaway/ui_elements/constants.dart';

class StoreService {
  late SharedPreferences prefs;
  getPrefs () async {
     prefs = await SharedPreferences.getInstance ();
  }

  StoreService._privateConstructor () {
     getPrefs ();
  }
  static final StoreService instance = StoreService._privateConstructor ();

  bool showLogs = false;
  bool loaded   = false;

  var updateStream = StreamController<String>.broadcast ();

  var store = {};

   listen (dynamic list, Function fun) {
      Function updater = () async {
         var results = [];
         list.forEach ((v) => results.add (StoreService.instance.get (v)));
         Function.apply (fun, results);
      };
      // Run updater once to fetch current values
      updater ();
      // Register listener and return its cancel method
      return updateStream.stream.listen ((key) async {
         if (list.contains (key)) return updater ();
      }).cancel;
   }

   reset () async {
     store = {};
     // We load prefs directly to have them already available.
     var prefs = await SharedPreferences.getInstance ();
     await prefs.clear ();
   }

   // To be invoked to clear everything except auth state - for development purposes only
   resetDev () async {
      var prefs = await SharedPreferences.getInstance ();
      var keys = await prefs.getKeys ().toList ();
      for (var k in keys) {
        if (k == 'cookie' || k == 'csrf') return;
        await remove (k);
      }
    }

   // This function is called by main.dart to recreate the in-memory store
   load ([var reset]) async {
      if (reset != null) return await resetDev ();
      // We load prefs directly to have them already available.
      var prefs = await SharedPreferences.getInstance ();
      // TODO REMOVE
      await prefs.remove ('currentIndex');
      var keys = await prefs.getKeys ().toList ();
      keys.sort ();
      for (var k in keys) {
         store [k] = await jsonDecode (prefs.getString (k) ?? '""');
      };
      if (showLogs) keys.forEach ((k) => debug (['STORE LOAD', k, jsonEncode (store [k])]));
      loaded = true;
   }

   // This function need not be awaited for setting the in-memory key, only if you want to await until the key is persisted to disk
   set (String key, dynamic value, [bool memoryOnly = false]) async {
      if (showLogs) debug (['STORE SET', memoryOnly ? 'MEMONLY' : 'MEM&DISK', key, jsonEncode (value)]);
      store [key] = value;
      updateStream.add (key);
      // Some fields should not be stored, we want these to be in-memory only
      if (! memoryOnly) await prefs.setString (key, jsonEncode (value));
   }

   get (String key) {
      var value = store [key] == null ? '' : store [key];
      if (showLogs) debug (['STORE GET', key, jsonEncode (value)]);
      return value;
   }

   // Necessary function if you're trying to get things before the prefs get initialized
   getBeforeLoad (String key) async {
      if (! loaded) {
         // We load prefs directly to have them already available.
         var prefs = await SharedPreferences.getInstance ();
         var value = await prefs.getString (key);
         if (showLogs) debug (['STORE GET', key, jsonEncode (value)]);
         return value == null ? '' : jsonDecode (value);
      }
      var value = store [key] == null ? '' : store [key];
      if (showLogs) debug (['STORE GET', key, jsonEncode (value)]);
      return value;
   }

   remove (String key, [bool memoryOnly = false]) async {
      if (RegExp ('^[^:]+:\\*').hasMatch (key)) {
         for (var k in store.keys) {
            if (RegExp (key.split (':') [0]).hasMatch (k)) await remove (k, memoryOnly);
         }
         return;
      }
      if (showLogs) debug (['STORE REMOVE', key]);
      store [key] = '';
      updateStream.add (key);
      if (! memoryOnly) await prefs.remove (key);
   }

}
