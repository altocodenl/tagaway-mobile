// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';

class LocalView extends StatefulWidget {
  const LocalView({Key? key}) : super(key: key);

  @override
  State<LocalView> createState() => _LocalViewState();
}

class _LocalViewState extends State<LocalView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'This is local',
            style: kBigTitle,
          ),
        ),
      ),
    );
  }
}
