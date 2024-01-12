import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class ManageTagsView extends StatefulWidget {
  static const String id = 'manageTagsView';
  const ManageTagsView({super.key});

  @override
  State<ManageTagsView> createState() => _ManageTagsViewState();
}

class _ManageTagsViewState extends State<ManageTagsView> {
  dynamic cancelListener;
  List userTags = [];

  @override
  void initState() {
    super.initState();
    cancelListener = store.listen([
      'usertags',
    ], (UserTags) {
      setState(() {
        if (UserTags != '') userTags = UserTags;
      });
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
                  delegate: CustomSearchDelegate(userTags),
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
              ListView.builder(
                  itemCount: userTags.length,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    var tag = userTags[index];
                    return TagListElement(
                        // Because tags can be renamed, we need to set a key here to avoid recycling them if they change.
                        key: Key('manageTags-' + tag),
                        tagColor: tagColor(tag),
                        tagName: tag,
                        view: 'manageTags',
                        onTap: () {});
                  }),
              const RenameTagModal(view: 'ManageTags'),
              const DeleteTagModal(view: 'ManageTags'),
            ],
          ),
        ));
  }
}

class CustomSearchDelegate extends SearchDelegate {
  dynamic userTags = [];

  CustomSearchDelegate(dynamic userTags) : userTags = userTags;

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
    for (var tag in userTags) {
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
    for (var tag in userTags) {
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
