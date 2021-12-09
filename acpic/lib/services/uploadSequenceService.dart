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
import 'package:provider/provider.dart';
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';

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

  Future<int> uploadEnd(BuildContext context, String op, String csrf, int id,
      String cookie) async {
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
        print(response.body);
        print(response.headers);
        print('uploadEnd done');
        return response.statusCode;
      } else {
        print(response.statusCode);
        print(response.body);
        print(response.headers);
        return response.statusCode;
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

  uploadBackground(
      BuildContext context,
      int id,
      Future<File> piv,
      AssetEntity asset,
      String csrf,
      String cookie,
      List tags,
      List<AssetEntity> list,
      uploadRecurrence) async {
    StreamSubscription subscription;
    File image = await piv;
    var uri = Uri.parse('https://altocode.nl/picdev/piv');
    FlutterUploader().clearUploads();
    // final taskId =
    await FlutterUploader().enqueue(
      MultipartFormDataUpload(
        url: uri.toString(),
        files: [
          FileItem(path: image.path, field: 'piv'),
        ], //
        method: UploadMethod.POST,
        headers: {"cookie": cookie},
        allowCellular: true,
        data: {
          "id": id.toString(),
          "csrf": csrf,
          "lastModified":
              asset.modifiedDateTime.millisecondsSinceEpoch.abs().toString(),
          "tags": tags.toString()
        },
      ),
    );
    streamListener() async {
      subscription = FlutterUploader().result.listen((result) {
        if (result.statusCode == null) return;
        // print('result is $result');
        // print(
        //     'I am in result and isUploadCancel is ${Provider.of<ProviderController>(context, listen: false).isUploadCancel}');
        print(
            'the result is ${result.statusCode} and response is ${result.response}');

        if (result.statusCode == 200 && list.isNotEmpty) {
          subscription.cancel();

          uploadRecurrence();
          return;
        }
        if (result.statusCode == 200 && list.isEmpty) {
          uploadEnd(context, 'complete', csrf, id, cookie);
          Provider.of<ProviderController>(context, listen: false)
              .selectAllTapped(false);
          Provider.of<ProviderController>(context, listen: false).redraw();
          Provider.of<ProviderController>(context, listen: false)
              .selectionInProcess(false);
          Provider.of<ProviderController>(context, listen: false)
              .showUploadingProcess(false);
          subscription.cancel();
          return;
        } else if (result.statusCode == 409) {
          subscription.cancel();
          return;
        }
      });
    }

    await streamListener();
  }

  uploadMain(BuildContext context, Stream uploadingLengthController, int id,
      String csrf, String cookie, List tags, List<AssetEntity> list) {
    final uploadingLengthController = StreamController<int>();

    uploadRecurrence() async {
      if (list.isEmpty) {
        uploadingLengthController.close();
        return;
      }
      if (list.last.width == 00 && list.last.height == 00) {
        uploadEnd(context, 'cancel', csrf, id, cookie);
        list.clear();
        Provider.of<ProviderController>(context, listen: false)
            .showUploadingProcess(false);
        Provider.of<ProviderController>(context, listen: false)
            .selectionInProcess(false);
        uploadingLengthController.close();
        return;
      }
      // uploadingLengthController.sink.add(list.length);
      // uploadingLengthController.stream.listen((event) {
      //   print('I am in the stream and event is $event');
      // });
      var asset = list[0];
      var piv = asset.file;

      list.removeAt(0);
      await uploadBackground(
          context, id, piv, asset, csrf, cookie, tags, list, uploadRecurrence);
    }

    uploadRecurrence();
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
