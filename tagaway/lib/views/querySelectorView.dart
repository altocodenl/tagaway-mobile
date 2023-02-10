import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagaway/ui_elements/constants.dart';

class QuerySelectorView extends StatefulWidget {
  const QuerySelectorView({Key? key}) : super(key: key);

  @override
  State<QuerySelectorView> createState() => _QuerySelectorViewState();
}

class _QuerySelectorViewState extends State<QuerySelectorView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kAltoBlue),
        leadingWidth: 70,
        leading: IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.solidCircleXmark,
              color: kGreyDarker,
              size: 25,
            ),
            onPressed: () {}),
        title: const Text('Filter', style: kSubPageAppBarTitle),
        actions: const [
          Padding(
            padding: EdgeInsets.only(top: 18, right: 20),
            child: Text(
              'Reset',
              style: kPlainTextBold,
            ),
          ),
          // IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Container(),
      ),
      floatingActionButton: Align(
        alignment: const Alignment(0.11, 1),
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: kAltoBlue,
          label: const Text('See XXX results', style: kSelectAllButton),
        ),
      ),
    );
  }
}
