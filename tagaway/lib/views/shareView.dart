import 'package:flutter/material.dart';
import 'package:tagaway/ui_elements/constants.dart';

class ShareView extends StatefulWidget {
  static const String id = 'share';

  const ShareView({Key? key}) : super(key: key);

  @override
  State<ShareView> createState() => _ShareViewState();
}

class _ShareViewState extends State<ShareView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 110.0),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Icon(
                      kPersonDiggingIcon,
                      color: kAltoBlue,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Working on it!',
                  style: kPlainTextBold,
                  // textAlign: TextAlign.center,
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
