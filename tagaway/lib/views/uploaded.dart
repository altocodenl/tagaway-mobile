// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';

class UploadedView extends StatefulWidget {
  const UploadedView({Key? key}) : super(key: key);

  @override
  State<UploadedView> createState() => _UploadedViewState();
}

class _UploadedViewState extends State<UploadedView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
            child: Text(
          'This is uploaded',
          style: kBigTitle,
        )),
      ),
    );
  }
}
