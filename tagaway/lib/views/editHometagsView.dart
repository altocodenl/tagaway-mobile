import 'package:flutter/material.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class EditHometagsView extends StatefulWidget {
  static const String id = 'editHomeTags';

  const EditHometagsView({Key? key}) : super(key: key);

  @override
  State<EditHometagsView> createState() => _EditHometagsViewState();
}

class _EditHometagsViewState extends State<EditHometagsView> {
  dynamic cancelListener;
  List hometags = [];

  @override
  void initState() {
    super.initState();
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
          leadingWidth: 70,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(top: 18, left: 12),
            child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, 'yourHomeTags');
                },
                child: const Text('Done', style: kDoneEditText)),
          ),
          title: Text('Edit your home tags',
              style: SizeService.instance.screenWidth(context) < 380
                  ? kTagListElementText
                  : kSubPageAppBarTitle),
          actions: [
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'addHomeTags');
                }),
          ],
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 5),
          child: ListView(
            // shrinkWrap: true,
            children: [
              for (var v in hometags)
                EditTagListElement(
                    tagColor: tagColor(v),
                    tagName: v,
                    onTapOnRedCircle: () {
                      // We need to wrap this in another function, otherwise it gets executed on view draw. Madness.
                      return () {
                        TagService.instance.editHometags(v, false);
                      };
                    },
                    onTagElementVerticalDragDown: () {})
            ],
          ),
        )),
      ),
    );
  }
}
