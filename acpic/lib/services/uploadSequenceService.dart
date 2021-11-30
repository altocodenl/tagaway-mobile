// IMPORT FLUTTER PACKAGES
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'dart:core';
import 'package:photo_manager/photo_manager.dart';
import 'package:path/path.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:flutter/material.dart';

class UploadSequenceService {
  UploadSequenceService._privateConstructor();
  static final UploadSequenceService instance =
      UploadSequenceService._privateConstructor();

  Future<String> uploadStart(
      String op, String csrf, List tags, String cookie, int total) async {
    try {
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
        return 'error';
      }
    } on SocketException catch (_) {
      return 'offline';
    }
  }

  Future<int> uploadEnd(String op, String csrf, int id, String cookie) async {
    try {
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
    } on SocketException catch (_) {
      return 0;
    }
  }

  upload(int id, String csrf, String cookie, List tags,
      List<AssetEntity> list) async {
    try {
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
    } on SocketException catch (_) {
      return 0;
    }
  }

  void backgroundHandler() {
    // Needed so that plugin communication works.
    WidgetsFlutterBinding.ensureInitialized();

    // This uploader instance works within the isolate only.
    FlutterUploader uploader = FlutterUploader();

    // You have now access to:
    uploader.progress.listen((progress) {
      // upload progress
    });
    uploader.result.listen((result) {
      // upload results
    });

    FlutterUploader().setBackgroundHandler(backgroundHandler);
  }

  uploadBackground(int id, String csrf, String cookie, List tags,
      List<AssetEntity> list) async {
    FlutterUploader().clearUploads();
    File image = await list[0].file;
    var uri = Uri.parse('https://altocode.nl/picdev/piv');
    final taskId = await FlutterUploader().enqueue(
      MultipartFormDataUpload(
        url: uri.toString(), //required: url to upload to
        files: [
          FileItem(path: image.path, field: 'piv'),
        ], // required: list of files that you want to upload
        method: UploadMethod.POST, // HTTP method  (POST or PUT or PATCH)
        headers: {"cookie": cookie},
        allowCellular: true,
        data: {
          "id": id.toString(),
          "csrf": csrf,
          "lastModified":
              list[0].modifiedDateTime.millisecondsSinceEpoch.abs().toString(),
          "tags": tags.toString()
        }, // any data you want to send in upload request
        tag: 'upload', // custom tag which is returned in result/progress
      ),
    );
    return taskId;
  }
}

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
