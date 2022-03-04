// IMPORT FLUTTER PACKAGES
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:core';
import 'dart:async';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:isolate';
//IMPORT SCREENS
import 'package:acpic/screens/grid.dart';
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/material_elements.dart';

class UploadService {
  UploadService._privateConstructor();
  static final UploadService instance = UploadService._privateConstructor();
  List<String> idList = [];
  List<AssetEntity> assetEntityList = [];

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
      print('uploadStart returns offline');
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
        // print(response.body);
        // print(response.headers);
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

  Future<int> uploadError(
      String csrf, Object error, int id, String cookie) async {
    try {
      final response = await http.post(
        Uri.parse('https://altocode.nl/picdev/upload'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': cookie
        },
        body: jsonEncode(<String, dynamic>{
          'op': 'error',
          'csrf': csrf,
          'id': id,
          'error': error
        }),
      );
      if (response.statusCode == 200) {
        print(response.body);
        print(response.headers);
        print('uploadError done');
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

  Timer onlineChecker;

  uploadOnlineChecker(BuildContext context, int id, String csrf, String cookie,
      List tags, List<AssetEntity> list) {
    onlineChecker = Timer.periodic(Duration(seconds: 3), (timer) {
      uploadRetry(context, id, csrf, cookie, tags, list);
    });
  }

  uploadRetry(BuildContext context, int id, String csrf, String cookie,
      List tags, List<AssetEntity> list) async {
    try {
      final result = await InternetAddress.lookup('altocode.nl');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        uploadMain(context, id, csrf, cookie, tags, list);
        print('connected');
        onlineChecker.cancel();
        Provider.of<ProviderController>(context, listen: false)
            .uploadingPausePlay(false);
      }
    } on SocketException catch (_) {
      print('not connected');
    }
  }

  uiReset(BuildContext context) {
    Provider.of<ProviderController>(context, listen: false)
        .selectAllTapped(false);
    Provider.of<ProviderController>(context, listen: false).redraw();
    Provider.of<ProviderController>(context, listen: false)
        .selectionInProcess(false);
    Provider.of<ProviderController>(context, listen: false)
        .showUploadingProcess(false);
    Provider.of<ProviderController>(context, listen: false)
        .uploadProgressFunction(0);
  }

  uiCancelReset(BuildContext context) {
    Provider.of<ProviderController>(context, listen: false)
        .showUploadingProcess(false);
    Provider.of<ProviderController>(context, listen: false)
        .selectionInProcess(true);
    Provider.of<ProviderController>(context, listen: false)
        .uploadProgressFunction(0);
  }

  uploadMain(BuildContext context, int id, String csrf, String cookie,
      List tags, List<AssetEntity> list) {
    uploadOne() async {
      if (list.isEmpty) {
        uploadEnd('complete', csrf, id, cookie);
        uiReset(context);
        print('Made it to the end');
        return false;
      }
      if (list.last.width == 00 && list.last.height == 00) {
        uploadEnd('cancel', csrf, id, cookie);
        list.clear();
        return false;
      }
      var asset = list[0];
      print(asset.type);
      var piv = asset.file;
      list.removeAt(0);
      Provider.of<ProviderController>(context, listen: false)
          .uploadProgressFunction(
              Provider.of<ProviderController>(context, listen: false)
                      .selectedItems
                      .length -
                  list.length);
      File image = await piv;
      var uri = Uri.parse('https://altocode.nl/picdev/piv');
      var request = http.MultipartRequest('POST', uri);
      try {
        request.headers['cookie'] = cookie;
        request.fields['id'] = id.toString();
        request.fields['csrf'] = csrf;
        request.fields['tags'] = tags.toString();
        request.fields['lastModified'] =
            asset.modifiedDateTime.millisecondsSinceEpoch.abs().toString();
        request.files.add(await http.MultipartFile.fromPath('piv', image.path));
        var response = await request.send();
        final respStr = await response.stream.bytesToString();
        print(respStr);
        print(
            'DEBUG response ' + response.statusCode.toString() + ' ' + respStr);
        if (response.statusCode == 409 && respStr == '{"error":"capacity"}') {
          uploadError(csrf, {'code': response.statusCode, 'error': respStr}, id,
              cookie);
          uiReset(context);
          SnackBarGlobal.buildSnackBar(
              context, 'You\'ve run out of space.', 'red');
          return false;
        } else if (response.statusCode >= 500) {
          uploadError(csrf, {'code': response.statusCode, 'error': respStr}, id,
              cookie);
          uiReset(context);
          SnackBarGlobal.buildSnackBar(
              context, 'Something is wrong on our side. Sorry.', 'red');
          return false;
        }
      } on SocketException catch (_) {
        print('Socket Exception');
        Provider.of<ProviderController>(context, listen: false)
            .uploadingPausePlay(true);
        SnackBarGlobal.buildSnackBar(
            context, 'You\'re offline. Upload paused.', 'red');
        list.insert(0, asset);
        uploadOnlineChecker(context, id, csrf, cookie, tags, list);
        return false;
      } on Exception {
        print('Exception');
        Provider.of<ProviderController>(context, listen: false)
            .uploadingPausePlay(true);
        SnackBarGlobal.buildSnackBar(
            context, 'You\'re offline. Upload paused.', 'red');
        list.insert(0, asset);
        uploadOnlineChecker(context, id, csrf, cookie, tags, list);
        return false;
      }
      if (Platform.isIOS) {
        image.delete();
        PhotoManager.clearFileCache();
      } else {
        PhotoManager.clearFileCache();
      }
      return true;
    }

    Future.doWhile(uploadOne);
  }

  Future uploadIDListing(List<AssetEntity> list) async {
    // print('In uploadIDListing list length is ${list.length}');
    dataOfOne() async {
      if (list.isEmpty) {
        return false;
      }
      var asset = list[0];
      String id = asset.id;
      // idList.add(id);
      idList.insert(0, id);
      list.removeAt(0);
      return true;
    }

    await Future.doWhile(dataOfOne);
  }

  assetEntityCreator(BuildContext context, List idList) async {
    print('assetEntityCreator was called');
    createOneAssetEntity() async {
      if (idList.isEmpty) {
        Provider.of<ProviderController>(context, listen: false).selectedItems =
            List.from(assetEntityList);
        return false;
      }
      var item = await AssetEntity.fromId(idList[0]);
      assetEntityList.add(item);
      idList.removeAt(0);
      return true;
    }

    await Future.doWhile(createOneAssetEntity);
  }
}

//--------- Isolate upload is here because it needs to be a top level function ---------
void isolateUpload(List<Object> arguments) async {
  print('Start uploading at ' + DateTime.now().toString());
  var client = http.Client();
  SendPort sendPort = arguments[5];
  uploadOneIsolate() async {
    List<String> idList = arguments[0];
    final isolateListener = ReceivePort();
    if (idList.isEmpty) {
      sendPort.send('done');
      client.close();
      print('done');
      return false;
    }
    if (idList.last == 'zz00zz') {
      sendPort.send('cancelled');
      client.close();
      idList.clear();
      print('cancelled');
      return false;
    }
    sendPort.send(isolateListener.sendPort);
    isolateListener.listen((message) {
      if (message is String) {
        print('message is $message');
        idList.add('zz00zz');
      }
    });
    PhotoManager.setIgnorePermissionCheck(true);
    var asset = await AssetEntity.fromId(idList[0]);
    var piv = asset.originFile;
    File image = await piv;
    var uri = Uri.parse('https://altocode.nl/picdev/piv');
    var request = http.MultipartRequest('POST', uri);
    try {
      request.headers['cookie'] = arguments[1];
      request.fields['id'] = arguments[2].toString();
      request.fields['csrf'] = arguments[3];
      request.fields['tags'] = arguments[4].toString();
      request.fields['lastModified'] =
          asset.modifiedDateTime.millisecondsSinceEpoch.abs().toString();
      request.files.add(await http.MultipartFile.fromPath('piv', image.path));
      var response = await client.send(request);
      final respStr = await response.stream.bytesToString();
      print(respStr);
      print('DEBUG response ' + response.statusCode.toString() + ' ' + respStr);
      sendPort.send('online');
      idList.removeAt(0);
      if (response.statusCode == 409 && respStr == '{"error":"capacity"}') {
        sendPort.send('capacityError');
        client.close();
        idList.clear();
        return false;
        //  {"error":"status: uploading|complete|cancelled|stalled|error"}
      } else if (response.statusCode == 409 &&
          respStr == '{"error":"status: complete"}') {
        sendPort.send('completeError');
        client.close();
        idList.clear();
        return false;
      } else if (response.statusCode == 409 &&
          respStr == '{"error":"status: cancelled"}') {
        sendPort.send('cancelledError');
        client.close();
        idList.clear();
        return false;
      } else if (response.statusCode == 409 &&
          respStr == '{"error":"status: stalled"}') {
        print('Stalled');
        // Send op: 'wait' + id + csrf
        // If 200 go on, if not error streamline.
        try {
          final response = await http.post(
            Uri.parse('https://altocode.nl/picdev/upload'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'cookie': arguments[1]
            },
            body: jsonEncode(<String, dynamic>{
              'op': 'wait',
              'csrf': arguments[3],
              'id': arguments[2]
            }),
          );
          if (response.statusCode == 200) {
            uploadOneIsolate();
          } else {
            print(response.statusCode);
            print('I am in stalled Else');
            sendPort.send('offline');
          }
        } on SocketException catch (_) {
          sendPort.send('offline');
        }
      } else if (response.statusCode == 409 &&
          respStr == '{"error":"status: error"}') {
        sendPort.send('errorError');
        client.close();
        idList.clear();
        return false;
      } else if (response.statusCode >= 500) {
        sendPort.send('serverError');
        client.close();
        idList.clear();
        return false;
      }
    } on SocketException catch (_) {
      sendPort.send('offline');
      print('SocketException');
      print(idList.length);
    } on Exception catch (e) {
      print('Exception');
      print(e);
      print(idList.length);
    }
    if (await image.exists() == true) {
      // print('image.path is ${image.path}');
      try {
        if (Platform.isIOS) {
          image.delete();
        }
        PhotoManager.clearFileCache();
      } catch (e) {
        print(e);
      }
      // on FileSystemException catch (e) {
      //   print('FileSystemException $e');
      // } on Exception catch (e) {
      //   print('Exception on delete $e');
      // } on FileSystemDeleteEvent catch (e) {
      //   print(e);
      // }
    }
    sendPort.send(idList.length);
    // print('Bottom of the function at ' + DateTime.now().toString());

    return true;
  }

  await Future.doWhile(uploadOneIsolate);
}
