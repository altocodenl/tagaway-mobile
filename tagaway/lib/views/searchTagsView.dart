import 'package:flutter/material.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class SearchTagsView extends StatefulWidget {
  static const String id = 'searchTags';

  const SearchTagsView({Key? key}) : super(key: key);

  @override
  State<SearchTagsView> createState() => _SearchTagsViewState();
}

class _SearchTagsViewState extends State<SearchTagsView> {
  dynamic cancelListener;
  List queryTags = [];
  List tags = [];
  List showTags = [];

  @override
  void initState() {
    super.initState();
    cancelListener =
        StoreService.instance.listen(['queryTags', 'tags'], (v1, v2) {
      setState(() {
        if (v1 != '') queryTags = v1;
        tags = v2;
        List ShowTags = [];
        tags.forEach((tag) {
          if (RegExp('^[a-z]::').hasMatch(tag)) return;
          if (!queryTags.contains(tag)) ShowTags.add(tag);
        });
        showTags = ShowTags;
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
                delegate: TagSearchClass(showTags),
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
                        'Search for a tag',
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
                    Navigator.pushReplacementNamed(context, 'bottomNavigation');
                  },
                  child: const Text('Cancel', style: kPlainText)),
            )
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 5),
            child: ListView(
              children: [
                for (var v in showTags)
                  TagListElement(
                      tagColor: tagColor(v),
                      tagName: v,
                      onTap: () {
                        // For some reason, any code we put outside of the function below will be invoked on widget draw.
                        // Returning the desired behavior in a function solves the problem.
                        return () {
                          var updatedTags = StoreService.instance.get ('queryTags');
                          updatedTags.add (v);
                          StoreService.instance.set ('queryTags', updatedTags, true);
                          Navigator.pushReplacementNamed(context, 'bottomNavigation');
                        };
                      })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TagSearchClass extends SearchDelegate {
  dynamic tags = [];

  TagSearchClass(dynamic tags)
      : this.tags = tags;

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
    for (var tag in tags) {
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
    for (var tag in tags) {
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
            onTap: () {
              // We need to wrap this in another function, otherwise it gets executed on view draw. Madness.
              return () {
                var updatedTags = StoreService.instance.get ('queryTags');
                updatedTags.add (result);
                StoreService.instance.set ('queryTags', updatedTags, true);
                Navigator.pushReplacementNamed(context, 'bottomNavigation');
              };
            });
      },
    );
  }
}
