import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class ManageTagsView extends StatefulWidget {
  static const String id = 'manageTagsView';
  const ManageTagsView({super.key});

  @override
  State<ManageTagsView> createState() => _ManageTagsViewState();
}

class _ManageTagsViewState extends State<ManageTagsView> {
  List allTags = [];

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
            automaticallyImplyLeading: false,
            centerTitle: false,
            backgroundColor: Colors.grey[50],
            leading: IconButton(
                icon: const FaIcon(
                  kArrowLeft,
                  color: kGreyDarker,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'querySelector');
                }),
            title: GestureDetector(
              onTap: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(allTags),
                );
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    color: kGreyLighter,
                    border: Border.all(color: kGreyDarker),
                    borderRadius: BorderRadius.circular(25)),
                child: const Row(
                  children: [
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
          ),
          body: Stack(
            children: [
              ListView(
                children: [
                  TagListElement(
                      tagColor: kTagColor1,
                      tagName: 'Tag Name',
                      view: 'manageTags',
                      onTap: () {
                        // For some reason, any code we put outside of the function below will be invoked on widget draw.
                        // Returning the desired behavior in a function solves the problem.
                        return () {};
                      })
                ],
              ),
              const RenameTagModal(view: 'manageTags'),
              const DeleteTagModal(view: 'manageTags'),
            ],
          ),
        ));
  }
}

class CustomSearchDelegate extends SearchDelegate {
  dynamic allTags = [];

  CustomSearchDelegate(dynamic allTags) : allTags = allTags;

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
    for (var tag in allTags) {
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
    for (var tag in allTags) {
      if (tag.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(tag);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return TagListElement(
            tagName: result,
            tagColor: tagColor(result),
            view: 'manageTags',
            onTap: () {
              // We need to wrap this in another function, otherwise it gets executed on view draw. Madness.
              return () {};
            });
      },
    );
  }
}
