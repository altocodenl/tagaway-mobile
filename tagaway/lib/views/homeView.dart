import 'package:flutter/material.dart';

import '../ui_elements/constants.dart';

class HomeView extends StatefulWidget {
  static const String id = 'scroll';
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kAltoBlue),
        leading: Image.asset(
          'images/tag blue with white - 400x400.png',
          scale: 8,
        ),
        title: const Expanded(
            flex: 2, child: Text('tagaway', style: kTagawayMain)),
      ),
    );
  }
}
