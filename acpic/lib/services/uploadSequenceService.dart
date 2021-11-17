// IMPORT FLUTTER PACKAGES
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'dart:core';
import 'package:photo_manager/photo_manager.dart';
import 'package:path/path.dart';

class UploadSequenceService {
  UploadSequenceService._privateConstructor();
  static final UploadSequenceService instance =
      UploadSequenceService._privateConstructor();

  Future<String> uploadStart(
      String op, String csrf, List tags, String cookie, int total) async {
    final response = await http.post(
      Uri.parse('https://altocode.nl/picdev/upload'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'cookie': cookie
      },
      body: jsonEncode(<String, dynamic>{
        'op': op,
        'csrf': csrf,
        'tags': tags,
        'total': total
      }),
    );
    if (response.statusCode == 200) {
      return response.body.substring(6, response.body.indexOf('}'));
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to create upload id');
    }
  }

  Future<int> uploadEnd(String op, String csrf, int id, String cookie) async {
    final response = await http.post(
      Uri.parse('https://altocode.nl/picdev/upload'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'cookie': cookie
      },
      body: jsonEncode(<String, dynamic>{'op': op, 'csrf': csrf, 'id': id}),
    );
    if (response.statusCode == 200) {
      return response.statusCode;
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to execute op $op');
    }
  }

  upload(int id, String csrf, String cookie, List tags,
      List<AssetEntity> list) async {
    for (int i = 0; i < list.length; i++) {
      File image = await list[i].file;
      var stream = new http.ByteStream(image.openRead());
      stream.cast();
      var length = await image.length();
      var uri = Uri.parse('https://altocode.nl/picdev/piv');
      var request = http.MultipartRequest('POST', uri);
      request.headers['cookie'] = cookie;
      request.fields['id'] = id.toString();
      request.fields['csrf'] = csrf;
      request.fields['tags'] = tags.toString();
      request.fields['lastModified'] =
          list[i].modifiedDateTime.millisecondsSinceEpoch.abs().toString();
      var picture = http.MultipartFile('piv', stream, length,
          filename: basename(image.path));
      request.files.add(picture);
      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      print(respStr);
      print(response.statusCode);
      print('${i + 1} of ${list.length}');
      // var progressCounter = StreamController<int>.broadcast();
      // progressCounter.sink.add(i);
      if (i + 1 == list.length) {
        return response.statusCode;
      }
    }
  }
}

//https://www.geeksforgeeks.org/dart-loop-control-statements-break-and-continue/#:~:text=Break%20Statement%3A,out%20of%20the%20nearest%20loop.
// Make a bool to be the break trigger

// File image = await list[0].file;
// var stream = new http.ByteStream(image.openRead());
// stream.cast();
// var length = await image.length();
// var uri = Uri.parse('https://altocode.nl/picdev/upload');
// var request = http.MultipartRequest('POST', uri);
// request.headers['cookie'] = cookie;
// request.fields['id'] = id.toString();
// request.fields['csrf'] = csrf;
// request.fields['lastModified'] = list[0].modifiedDateTime.toString();
// var picture = http.MultipartFile('piv', stream, length,
//     filename: basename(image.path));
// request.files.add(picture);
// var response = await request.send();
// final respStr = await response.stream.bytesToString();
// print(respStr);
// return response.statusCode;
