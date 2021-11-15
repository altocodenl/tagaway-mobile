// IMPORT FLUTTER PACKAGES
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path/path.dart';
import 'dart:typed_data';

class UploadSequenceService {
  UploadSequenceService._privateConstructor();
  static final UploadSequenceService instance =
      UploadSequenceService._privateConstructor();

  Future<String> uploadStart(
      String op, String csrf, List tags, String cookie, int total) async {
    final response = await http.post(
      Uri.parse('https://altocode.nl/picdev/metaupload'),
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
      // print(response.statusCode);
      // print(response.body);
      // print(jsonDecode(response.body));
      // print(jsonDecode(response.body)
      //     .toString()
      //     .substring(5, jsonDecode(response.body).toString().indexOf('}')));
      return response.body.substring(6, response.body.indexOf('}'));
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to create upload id');
    }
  }

  Future<int> uploadEnd(String op, String csrf, int id, String cookie) async {
    final response = await http.post(
      Uri.parse('https://altocode.nl/picdev/metaupload'),
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

  Future<int> upload(int id, String csrf, String cookie,
      List<AssetEntity> list) async {
    File image = await list[0].file;
    var stream = new http.ByteStream(image.openRead());
    stream.cast();
    var length = await image.length();
    print(length);
    var uri = Uri.parse('https://altocode.nl/picdev/upload');
    var request = http.MultipartRequest('POST', uri);
    request.headers['cookie'] = cookie;
    request.fields['id'] = id.toString();
    request.fields['csrf'] = csrf;
    request.fields['lastModified'] = list[0].modifiedDateTime.toString();
    var picture = http.MultipartFile('piv', stream, length,
        filename: basename(image.path));
    request.files.add(picture);
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    print(respStr);
    return response.statusCode;
  }
}
