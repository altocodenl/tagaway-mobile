// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

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
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(top: 18, left: 12),
          child: GestureDetector(
              onTap: () {}, child: const Text('Done', style: kDoneEditText)),
        ),
        title: const Text('Your home tags', style: kSubPageAppBarTitle),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 5),
        child: ListView(
          // shrinkWrap: true,
          children: [
            EditTagListElement(
              tagColor: kTagColor1,
              tagName: 'Lorem ipsum dolor',
              onTapOnRedCircle: () {},
              onTagElementVerticalDragDown: () {},
            ),
            EditTagListElement(
              tagColor: kTagColor2,
              tagName: 'Lorem ipsum dolor',
              onTapOnRedCircle: () {},
              onTagElementVerticalDragDown: () {},
            ),
            EditTagListElement(
              tagColor: kTagColor3,
              tagName: 'Lorem ipsum dolor',
              onTapOnRedCircle: () {},
              onTagElementVerticalDragDown: () {},
            ),
            EditTagListElement(
              tagColor: kTagColor4,
              tagName: 'Lorem ipsum dolor',
              onTapOnRedCircle: () {},
              onTagElementVerticalDragDown: () {},
            ),
          ],
        ),
      )),
    );
  }
}
