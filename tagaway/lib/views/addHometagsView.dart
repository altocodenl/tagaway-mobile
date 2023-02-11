import 'package:flutter/material.dart';

import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

import 'package:tagaway/services/tagService.dart';

class AddHomeTagsView extends StatefulWidget {
  const AddHomeTagsView({Key? key}) : super(key: key);

  @override
  State<AddHomeTagsView> createState() => _AddHomeTagsViewState();
}

class _AddHomeTagsViewState extends State<AddHomeTagsView> {
   List hometags = [];

   void initState () {
      super.initState ();
      TagService.instance.getTags ().then ((value) {
         setState (() {
            hometags = value;
         });
      });
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: Colors.white,
        title: GestureDetector(
          onTap: () {
            showSearch(
              context: context,
              delegate: CustomSearchDelegate(hometags),
            );
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
                color: kGreyLighter,
                border: Border.all(color: kGreyDarker),
                borderRadius: BorderRadius.circular(25)),
            child: Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Or search for a tag',
                      style: kPlainText,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.search,
                    color: kGrey,
                  ),
                )
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 18, right: 12),
            child: GestureDetector(
                onTap: () {}, child: const Text('Cancel', style: kPlainText)),
          )
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 5),
        child: ListView(
          // shrinkWrap: true,
          children: [
            for (var v in hometags) TagListElement (tagColor: tagColor (v), tagName: v, onTap: () {})
          ],
        ),
      )),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {

   dynamic hometags = [];

   CustomSearchDelegate (dynamic hometags) : this.hometags = hometags;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var tag in hometags) {
      if (tag.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(tag);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var tag in hometags) {
      if (tag.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(tag);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }
}
