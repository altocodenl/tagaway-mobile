import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/services.dart';

import 'package:tagaway/main.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/authService.dart';

int now () {
  return DateTime.now().millisecondsSinceEpoch;
}

int ms (date) {
  return date.millisecondsSinceEpoch;
}

void debug (dynamic params, [sendToServer = false]) {
  String acc = 'DEBUG (' + (now () - initT).toString () + 'ms)';
  params.forEach ((v) => acc += ' ' + v.toString ());
  print (acc);
  if (sendToServer) ajax ('post', 'debug', {'DEBUG': [(now () - initT).toString () + 'ms', ...params]});
}

bool ajaxLogs = true;

// We need to specify <String, dynamic> because otherwise Dart will try to infer the type of all the keys of the body as being of the same type, which very often will not be the case.
Future<dynamic> ajax (String method, String path, [Map<String, dynamic> body = const {}]) async {
  // Note the await
  String cookie = await StoreService.instance.getAwait ('cookie');
  int start = now ();
  var response;
  try {
    if (method == 'get') {
      response = await http.get (Uri.parse(kAltoPicAppURL + '/' + path),
          headers: {'cookie': cookie});
    } else {

      if (path != 'auth/login' && path != 'auth/signup' && path != 'auth/recover') {
        body ['csrf'] = await StoreService.instance.getAwait ('csrf');
      }
      var httpOperation = method == 'post' ? http.post : http.put;
      response = await httpOperation(Uri.parse(kAltoPicAppURL + '/' + path),
          headers: {
            'cookie': cookie,
            'Content-Type': 'application/json; charset=UTF-8'
          },
          body: jsonEncode(body));
    }

    if (ajaxLogs)
      debug([
        method,
        '/' + path,
        (now() - start).toString() + 'ms',
        response.statusCode,
        ((response.body == '' ? '{}' : utf8.decode(response.bodyBytes)).length /
                    1000)
                .round()
                .toString() +
            'kb'
      ]);

    // If we get a 403, it must be because the cookie has expired. We delete it locally.
    if (response.statusCode == 403) {
      if (! RegExp ('^auth').hasMatch (path)) showSnackbar ('Your session has expired. Please log in.', 'yellow');
      await AuthService.instance.cleanupKeys ();
    }

    return {
      'code': response.statusCode,
      'headers': response.headers,
      'body': jsonDecode(
          response.body == '' ? '{}' : utf8.decode(response.bodyBytes))
    };
  } on SocketException catch (_) {
    if (ajaxLogs)
      debug([
        method,
        '/' + path,
        (now() - start).toString() + 'ms',
        'Socket Exception'
      ]);
    redirectToOfflineView ();
    return {'code': 0};
  }
}

Future<dynamic> ajaxMulti (String path, dynamic fields, dynamic filePath) async {
  var request =
      http.MultipartRequest('post', Uri.parse(kAltoPicAppURL + '/' + path));

  request.headers['cookie'] = await StoreService.instance.getAwait('cookie');
  request.fields['csrf'] = await StoreService.instance.getAwait('csrf');

  fields.forEach((k, v) => request.fields[k] = v.toString());
  request.files.add(await http.MultipartFile.fromPath('piv', filePath));

  int start = now();
  var response;
  try {
    response = await request.send();
    String rbody = await response.stream.bytesToString();
    if (ajaxLogs)
      debug([
        'post',
        '/' + path,
        (now() - start).toString() + 'ms',
        response.statusCode,
        (rbody.length / 1000).round().toString() + 'kb'
      ]);

    // If we get a 403, it must be because the cookie has expired. We delete it locally.
    if (response.statusCode == 403) {
      if (! RegExp ('^auth').hasMatch (path)) showSnackbar ('Your session has expired. Please log in.', 'yellow');
      await AuthService.instance.cleanupKeys ();
    }

    return {
      'code': response.statusCode,
      'headers': response.headers,
      'body': jsonDecode(rbody == '' ? '{}' : rbody)
    };
  } on SocketException catch (_) {
    if (ajaxLogs)
      debug([
        'post',
        '/' + path,
        (now() - start).toString() + 'ms',
        'Socket Exception'
      ]);
    redirectToOfflineView ();
    return {'code': 0};
  }
}

// Taken from https://github.com/HosseinYousefi/murmurhash/blob/master/lib/murmurhash.dart
// Thank you Hossein Yousefi!
// Adapted to behave like the JS implementation through the `zeroFillRightShift` function.
// Also adapted to take a `partialHash`, which is the hash computed from all previous chunks of the file, so that we don't have to read large files onto memory at once.
// The chunking should be done in chunks that are a multiple of 4, except for the last chunk.
// When invoking the last chunk, the `totalLength` of the original input should be passed. This is required by the algorithm, and it also lets the function know that it is processing the last chunk.

int murmurhashV3 (Uint8List key, int seed, dynamic partialHash, [dynamic totalLength = 0]) {
   int zeroFillRightShift (int n, int amount) {
      return (n & 0xFFFFFFFF) >> amount;
   }
   int remainder = key.length & 3;
   int bytes = key.length - remainder;
   int h1 = partialHash == null ? seed : partialHash;
   int c1 = 0xcc9e2d51;
   int c2 = 0x1b873593;
   int i = 0;
   int k1, h1b;
   while (i < bytes) {
      k1 = ((key[i] & 0xff)) |
          ((key[++i] & 0xff) << 8) |
          ((key[++i] & 0xff) << 16) |
          ((key[++i] & 0xff) << 24);
      ++i;
      k1 = ((((k1 & 0xffff) * c1) + (((zeroFillRightShift (k1, 16) * c1) & 0xffff) << 16))) &
          0xffffffff;
      k1 = (k1 << 15) | zeroFillRightShift (k1, 17);
      k1 = ((((k1 & 0xffff) * c2) + (((zeroFillRightShift (k1, 16) * c2) & 0xffff) << 16))) &
          0xffffffff;

      h1 ^= k1;
      h1 = (h1 << 13) | zeroFillRightShift (h1, 19);
      h1b = ((((h1 & 0xffff) * 5) + (((zeroFillRightShift (h1, 16) * 5) & 0xffff) << 16))) &
          0xffffffff;
      h1 = (((h1b & 0xffff) + 0x6b64) +
          (((zeroFillRightShift (h1b, 16) + 0xe654) & 0xffff) << 16));
   }
   k1 = 0;

   switch (remainder) {
      case 3:
         k1 ^= (key[i + 2] & 0xff) << 16;
         continue case2;
      case2:
      case 2:
         k1 ^= (key[i + 1] & 0xff) << 8;
         continue case1;
      case1:
      case 1:
         k1 ^= (key[i] & 0xff);

         k1 = (((k1 & 0xffff) * c1) + (((zeroFillRightShift (k1, 16) * c1) & 0xffff) << 16)) &
             0xffffffff;
         k1 = (k1 << 15) | zeroFillRightShift (k1, 17);
         k1 = (((k1 & 0xffff) * c2) + (((zeroFillRightShift (k1, 16) * c2) & 0xffff) << 16)) &
             0xffffffff;
         h1 ^= k1;
   }
   if (totalLength == 0) return h1;
   h1 ^= totalLength;

   h1 ^= zeroFillRightShift (h1, 16);
   h1 = (((h1 & 0xffff) * 0x85ebca6b) +
      (((zeroFillRightShift (h1, 16) * 0x85ebca6b) & 0xffff) << 16)) &
       0xffffffff;
   h1 ^= zeroFillRightShift (h1, 13);
   h1 = ((((h1 & 0xffff) * 0xc2b2ae35) +
      (((zeroFillRightShift (h1, 16) * 0xc2b2ae35) & 0xffff) << 16))) &
       0xffffffff;
   h1 ^= zeroFillRightShift (h1, 16);

   return zeroFillRightShift (h1, 0);
}

// Note: if this function is edited, we need to stop and start the Flutter process (rather than hot reloading) because it will be run in an isolate
@pragma('vm:entry-point')
hashPiv (dynamic pivId) async {

   PhotoManager.setIgnorePermissionCheck (true);

   var piv = await AssetEntity.fromId (pivId) as dynamic;
   var file = await piv.originFile;
   var fileLength = await file.length ();
   var inputStream = file.openRead ();

   var hash;
   var remainder = <int>[];
   int processedBytes = 0;
   await for (var data in inputStream) {
      processedBytes += data.length as int;
      var currentData = remainder + data;
      var excess = currentData.length % 4;

      // If we have excess bytes, move them to the remainder for the next iteration.
      remainder = currentData.sublist(currentData.length - excess);
      currentData = currentData.sublist(0, currentData.length - excess);

      if (processedBytes == fileLength && remainder.length == 0) hash = murmurhashV3 (Uint8List.fromList (currentData), 0, hash, fileLength);
      else                                                       hash = murmurhashV3 (Uint8List.fromList (currentData), 0, hash);
   }
   if (remainder.length > 0) hash = murmurhashV3 (Uint8List.fromList (remainder), 0, hash, fileLength);
   // Note that we do not await for this, we just want to clear it out in the background.
   clearFile (file);
   return hash.toString () + ':' + fileLength.toString ();
}

clearFile (dynamic file) async {
   if (await file.exists () != true) return;
   // https://github.com/fluttercandies/flutter_photo_manager/tree/main#cache-on-ios
   if (Platform.isIOS) await file.delete ();
   // https://github.com/fluttercandies/flutter_photo_manager/tree/main#clear-caches
   await PhotoManager.clearFileCache ();
}


showSnackbar (String message, String color) {
   var context = navigatorKey.currentState?.context;
   SnackBarGlobal.buildSnackBar (context!, message, color);
}

redirectToOfflineView () {
   navigatorKey.currentState!.pushReplacementNamed ('offline');
}

pad (n) {
   return n < 10 ? '0' + n.toString () : n.toString ();
}

// `getTags` has a call that requires this to be typed
List getList (dynamic key) {
   var value = StoreService.instance.get (key);
   if (value == '') return [];
   // We return a copy.
   return value.toList ();
}

getAvailableStorage () async {
  const platform = MethodChannel ('nl.tagaway/storage');
  try {
    final int? result = await platform.invokeMethod ('getAvailableStorage');
    return result;
  } catch (e) {
    print(e);
    return null;
  }
}

printBytes (int bytes) {
   if (bytes < 1000 * 1000 * 1000) return ((bytes / (1000 * 100)).round () / 10).toString () + 'MB';
   return ((bytes / (1000 * 1000 * 100)).round () / 10).toString () + 'GB';
}
