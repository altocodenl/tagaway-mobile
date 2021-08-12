import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//TODO 12: Create recover password screen

class RecoverPasswordScreen extends StatefulWidget {
  static const String id = 'recover_password';
  @override
  _RecoverPasswordScreenState createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold();
  }
}
