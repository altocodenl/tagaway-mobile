import 'package:flutter/material.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/BottomNavigationBar.dart';
import 'package:tagaway/views/addHometagsView.dart';
import 'package:tagaway/views/editHometagsView.dart';

class YourHometagsView extends StatefulWidget {
  static const String id = 'yourHomeTags';

  const YourHometagsView({Key? key}) : super(key: key);

  @override
  State<YourHometagsView> createState() => _YourHometagsViewState();
}

class _YourHometagsViewState extends State<YourHometagsView> {
  dynamic cancelListener;
  List hometags = [];

  @override
  void initState() {
    cancelListener = StoreService.instance.listen(['hometags'], (v) {
      setState(() => hometags = v);
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
  }

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
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.grey[50],
          iconTheme: const IconThemeData(color: kAltoBlue),
          leading: Padding(
            padding: const EdgeInsets.only(top: 18, left: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, EditHometagsView.id);
              },
              child: const Text('Edit', style: kDoneEditText),
            ),
          ),
          title: const Text('Your home tags', style: kSubPageAppBarTitle),
          actions: [
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AddHometagsView.id);
                }),
          ],
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 5),
          child: ListView(shrinkWrap: true, children: [
            for (var v in hometags)
              TagListElement(tagColor: tagColor(v), tagName: v, onTap: () {})
          ]),
        )),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushReplacementNamed(context, BottomNavigationView.id);
          },
          backgroundColor: kAltoBlue,
          label: const Text('Done', style: kSelectAllButton),
          icon: const Icon(Icons.done),
        ),
      ),
    );
  }
}
