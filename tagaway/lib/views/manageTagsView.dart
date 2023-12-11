import 'package:flutter/material.dart';

class ManageTagsView extends StatefulWidget {
  const ManageTagsView({Key? key}) : super(key: key);

  @override
  State<ManageTagsView> createState() => _ManageTagsViewState();
}

class _ManageTagsViewState extends State<ManageTagsView> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (Navigator.of(context).userGestureInProgress) {
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          appBar: AppBar(),
        ));
  }
}
