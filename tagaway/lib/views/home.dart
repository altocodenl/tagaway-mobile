// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart'; // IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Image.asset(
          'images/tag blue with white - 400x400.png',
          scale: 8,
        ),
        title: const Text('tagaway', style: kAcpicMain),
        centerTitle: false,
        titleSpacing: 0.0,
        actions: const [Text('username', style: kBottomNavigationText)],
      ),
      drawer: const Drawer(
        backgroundColor: kAltoBlue,
      ),
    );
  }
}
