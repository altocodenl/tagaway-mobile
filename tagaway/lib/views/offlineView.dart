// IMPORT FLUTTER PACKAGES
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';

class OfflineView extends StatefulWidget {
  static const String id = 'offline';

  const OfflineView({Key? key}) : super(key: key);

  @override
  State<OfflineView> createState() => _OfflineViewState();
}

class _OfflineViewState extends State<OfflineView> {
  late Timer onlineChecker;

  @override
  void initState() {
    onlineChecker = Timer.periodic(const Duration(seconds: 1), (timer) {
      internetAvailabilityCheck();
    });
    super.initState();
  }

  internetAvailabilityCheck() async {
    try {
      final result = await InternetAddress.lookup(kAltoURLDomain);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Navigator.pushReplacementNamed(context, 'distributor');
        onlineChecker.cancel();
      }
    } catch (error) {}
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
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'You\'re offline.',
                  textAlign: TextAlign.center,
                  style: kBigTitleOffline,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
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
