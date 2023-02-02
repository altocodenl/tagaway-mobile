// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
// IMPORT UI ELEMENTS
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class AddHomeTagsView extends StatefulWidget {
  const AddHomeTagsView({Key? key}) : super(key: key);

  @override
  State<AddHomeTagsView> createState() => _AddHomeTagsViewState();
}

class _AddHomeTagsViewState extends State<AddHomeTagsView> {
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
              delegate: CustomSearchDelegate(),
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
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  List<String> searchTerms = ['Vacations', 'Family', 'Friends'];

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
    for (var tag in searchTerms) {
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
    for (var tag in searchTerms) {
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
