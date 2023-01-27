// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class YourHomeTagsView extends StatefulWidget {
  const YourHomeTagsView({Key? key}) : super(key: key);

  @override
  State<YourHomeTagsView> createState() => _YourHomeTagsViewState();
}

class _YourHomeTagsViewState extends State<YourHomeTagsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kAltoBlue),
        leading: Padding(
          padding: const EdgeInsets.only(top: 18, left: 12),
          child: GestureDetector(
            onTap: () {},
            child: const Text('Edit',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: kAltoBlue,
                )),
          ),
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
          shrinkWrap: true,
          children: [
            TagListElement(
              tagColor: kTagColor1,
              tagName: 'Vacations',
              onTap: () {},
            ),
            TagListElement(
              tagColor: kTagColor2,
              tagName: 'Vacations',
              onTap: () {},
            ),
            TagListElement(
              tagColor: kTagColor3,
              tagName: 'Vacations',
              onTap: () {},
            ),
            TagListElement(
              tagColor: kTagColor4,
              tagName: 'Vacations',
              onTap: () {},
            ),
            TagListElement(
              tagColor: kTagColor5,
              tagName: 'Vacations',
              onTap: () {},
            ),
            TagListElement(
              tagColor: kTagColor6,
              tagName: 'Vacations',
              onTap: () {},
            ),
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: kAltoBlue,
        child: const Icon(Icons.done),
      ),
    );
  }
}
