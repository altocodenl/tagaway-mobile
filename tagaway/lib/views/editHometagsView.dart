import 'package:flutter/material.dart';

import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

import 'package:tagaway/services/local_vars_shared_prefsService.dart';
import 'package:tagaway/services/tagService.dart';

class EditHomeTagsView extends StatefulWidget {
  const EditHomeTagsView({Key? key}) : super(key: key);

  @override
  State<EditHomeTagsView> createState() => _EditHomeTagsViewState();
}

class _EditHomeTagsViewState extends State<EditHomeTagsView> {
   List hometags = [];

   void initState () {
      super.initState ();
      SharedPreferencesService.instance.updateStream.stream.listen ((value) async {
         if (value != 'hometags') return;
         dynamic Hometags = await SharedPreferencesService.instance.get ('hometags');
         setState (() {
            hometags = Hometags;
         });
      });
      TagService.instance.getTags ();
   }

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
            for (var v in hometags) EditTagListElement (tagColor: tagColor (v), tagName: v, onTapOnRedCircle: () {
               // We need to wrap this in another function, otherwise it gets executed on view draw. Madness.
               return () {
                  TagService.instance.removeHometag (v);
               };
            }, onTagElementVerticalDragDown: () {})
          ],
        ),
      )),
    );
  }
}
