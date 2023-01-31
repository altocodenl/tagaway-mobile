// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:tagaway/ui_elements/constants.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Change your password', style: kSubPageAppBarTitle),
      ),
    );
  }
}
