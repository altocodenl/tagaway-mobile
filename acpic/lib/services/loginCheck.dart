// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

Future<Album> fetchAlbum() async {
  final response = await http.get(Uri.parse('https://altocode.nl/picdev/csrf'));
  if (response.statusCode == 200) {
    print(response.body);
    return Album.fromJson(jsonDecode(response.body));
  } else {
    print(response.body);
    throw Exception('Not logged in');
  }
}

class Album {
  final String token;

  Album({
    @required this.token,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      token: json['csrf'],
    );
  }
}
