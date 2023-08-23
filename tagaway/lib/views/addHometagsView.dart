import 'package:flutter/material.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class AddHometagsView extends StatefulWidget {
  static const String id = 'addHomeTags';

  const AddHometagsView({Key? key}) : super(key: key);

  @override
  State<AddHometagsView> createState() => _AddHometagsViewState();
}

class _AddHometagsViewState extends State<AddHometagsView> {
  dynamic cancelListener;
  List hometags = [];
  List tags = [];
  List potentialHometags = [];

  @override
  void initState() {
    super.initState();
    cancelListener =
        StoreService.instance.listen(['hometags', 'tags'], (v1, v2) {
      setState(() {
        hometags = v1;
        tags = v2;
        List PotentialHometags = [];
        tags.forEach((tag) {
          if (RegExp('^[a-z]::').hasMatch(tag)) return;
          if (!hometags.contains(tag)) PotentialHometags.add(tag);
        });
        potentialHometags = PotentialHometags;
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
          title: GestureDetector(
            onTap: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(potentialHometags),
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
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'editHomeTags');
                  },
                  child: const Text('Cancel', style: kPlainText)),
            )
          ],
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 5),
          child: ListView(
            // shrinkWrap: true,
            children: [
              for (var v in potentialHometags)
                TagListElement(
                    tagColor: tagColor(v),
                    tagName: v,
                    view: 'addHomeTags',
                    onTap: () {
                      // For some reason, any code we put outside of the function below will be invoked on widget draw.
                      // Returning the desired behavior in a function solves the problem.
                      return () {
                        TagService.instance.editHometags(v, true);
                        Navigator.pushReplacementNamed(context, 'editHomeTags');
                      };
                    })
            ],
          ),
        )),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  dynamic potentialHometags = [];

  CustomSearchDelegate(dynamic potentialHometags)
      : potentialHometags = potentialHometags;

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
    for (var tag in potentialHometags) {
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
    for (var tag in potentialHometags) {
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
            view: 'addHomeTags',
            onTap: () {
              // We need to wrap this in another function, otherwise it gets executed on view draw. Madness.
              return () {
                TagService.instance.editHometags(result, true);
                Navigator.pushReplacementNamed(context, 'editHomeTags');
              };
            });
      },
    );
  }
}
