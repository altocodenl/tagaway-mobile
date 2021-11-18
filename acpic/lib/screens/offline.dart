// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';
//IMPORT SCREENS
import 'package:acpic/screens/distributor.dart';
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/constants.dart';

class OfflineScreen extends StatefulWidget {
  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  Timer onlineChecker;

  @override
  void initState() {
    onlineChecker = Timer.periodic(Duration(seconds: 3), (timer) {
      print(timer.tick);
      internetAvailabilityCheck();
    });
    super.initState();
  }

  internetAvailabilityCheck() async {
    try {
      final result = await InternetAddress.lookup('altocode.nl');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print(result);
        print('connected');
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Distributor()),
        );
        onlineChecker.cancel();
      }
    } on SocketException catch (_) {
      print('not connected');
    }
  }

  @override
  void dispose() {
    onlineChecker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'You\'re offline.',
                  textAlign: TextAlign.center,
                  style: kBigTitleOffline,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Please, check your connection.',
                  textAlign: TextAlign.center,
                  style: kPlainText,
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
