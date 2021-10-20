// IMPORT FLUTTER PACKAGES
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class InviteService {
  StreamController<int> inviteResponse;
  InviteService._privateConstructor();
  InviteService({this.inviteResponse});

  static final InviteService instance = InviteService._privateConstructor();

  Future<int> sendInviteEmail(String email) async {
    final response = await http.post(
      Uri.parse('https://altocode.nl/picdev/requestInvite'),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );
    return response.statusCode;
  }
}
