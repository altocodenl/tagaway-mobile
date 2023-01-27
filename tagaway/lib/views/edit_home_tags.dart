// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';

class EditHomeTagsView extends StatefulWidget {
  const EditHomeTagsView({Key? key}) : super(key: key);

  @override
  State<EditHomeTagsView> createState() => _EditHomeTagsViewState();
}

class _EditHomeTagsViewState extends State<EditHomeTagsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kAltoBlue),
        leading: const Padding(
          padding: EdgeInsets.only(top: 18, left: 12),
          child: Text('Done',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: kAltoBlue,
              )),
        ),
        title: const Text('Your home tags', style: kSubPageAppBarTitle),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
    );
  }
}
