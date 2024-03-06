import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/services/tools.dart';
import 'package:tagaway/ui_elements/constants.dart';

class QuerySelectorView extends StatefulWidget {
  static const String id = 'querySelector';

  const QuerySelectorView({Key? key}) : super(key: key);

  @override
  State<QuerySelectorView> createState() => _QuerySelectorViewState();
}

class _QuerySelectorViewState extends State<QuerySelectorView> {
  dynamic cancelListener;
  final TextEditingController searchQueryController = TextEditingController();

  dynamic queryTags = [];
  dynamic queryResult = {
    'total': 0,
    'tags': {'a::': 0, 'u::': 0, 't::': 0, 'o::': 0}
  };
  dynamic years = [];
  dynamic months = [];
  dynamic countries = [];
  dynamic cities = [];
  dynamic usertags = [];
  dynamic expandYears = false;
  dynamic expandCountries = false;
  dynamic filteredYears = [];
  dynamic filteredCountries = [];
  bool queryInProgress = false;

  // This function will be called every time the text changes
  searchQueryChanged() {
    store.set('queryFilter', searchQueryController.text);
  }

  @override
  void initState() {
    super.initState();
    searchQueryController.addListener(searchQueryChanged);
    if (store.get('queryTags') == '') store.set('queryTags', []);
    // The listeners are separated because we don't want to query pivs again once queryResult is updated.
    cancelListener = store
        .listen(['queryTags', 'queryResult', 'queryFilter', 'queryInProgress'],
            (v1, v2, v3, QueryInProgress) {
      // queryPivs will not make a call to the server if `queryResult` or `queryFilter` change because it will check if the tags have changed.
      TagService.instance.queryPivs();
      setState(() {
        queryTags = v1;
        bool matchFilter(tag) {
          if (v3 == '' || queryTags.contains(tag)) return true;
          return tag.toLowerCase().contains(v3.toLowerCase());
        }

        queryInProgress = QueryInProgress != '';

        if (v2 == '') return;
        queryResult = v2;
        var selectableTags = queryResult['tags']
            .keys
            .where((tag) => !queryTags.contains(tag))
            .toList();
        years = selectableTags
            .where((tag) => RegExp('^d::[0-9]').hasMatch(tag))
            .where(matchFilter)
            .toList();
        years.sort();
        months = selectableTags
            .where((tag) => RegExp('^d::M').hasMatch(tag))
            .where(matchFilter)
            .toList();
        months.sort(
            (a, b) => int.parse(a.substring(4)) - int.parse(b.substring(4)));
        countries = selectableTags
            .where((tag) => RegExp('^g::[A-Z]{2}').hasMatch(tag))
            .where(matchFilter)
            .toList();
        countries.sort();
        cities = selectableTags
            .where((tag) =>
                RegExp('^g::').hasMatch(tag) && !countries.contains(tag))
            .where(matchFilter)
            .toList();
        cities.sort();
        usertags = selectableTags
            .where((tag) => !RegExp('^[a-z]::').hasMatch(tag))
            .where(matchFilter)
            .toList();
        usertags.sort();
        filteredYears = (expandYears || years.length < 4)
            ? years
            : years.sublist(years.length - 4, years.length);
        filteredCountries = (expandCountries || countries.length < 2)
            ? countries
            : countries.sublist(countries.length - 2, countries.length);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
    searchQueryController.dispose();
    searchQueryController.removeListener(searchQueryChanged);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          iconTheme: const IconThemeData(color: kAltoBlue),
          centerTitle: true,
          leadingWidth: 50,
          leading: IconButton(
              icon: const FaIcon(
                kArrowLeft,
                color: kGreyDarker,
              ),
              onPressed: () {
                store.set('queryTags', []);
                Navigator.pushReplacementNamed(context, 'home');
              }),
          title: TextField(
            controller: searchQueryController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
              fillColor: kGreyLightest,
              hintText: SizeService.instance.screenWidth(context) <= 375
                  ? 'Search tag, year or geo'
                  : 'Search by tag, year or geo',
              hintMaxLines: 1,
              hintStyle: SizeService.instance.screenWidth(context) < 414
                  ? kGridBottomRowText
                  : kGridTagListElement,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: kAltoBlue)),
              suffixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, top: 18),
                child: FaIcon(
                  kSearchIcon,
                  size: 14,
                  color: kGreyDarker,
                ),
              ),
            ),
            onChanged: null,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 0, right: 20),
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      store.set('queryTags', []);
                      searchQueryController.clear();
                    });
                  },
                  child: const Text('Clear', style: kPlainTextBold)),
            ),
          ],
        ),
        body: SafeArea(
            child: ListView(
          padding:
              const EdgeInsets.only(left: 12, right: 12, top: 20, bottom: 80),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: [
            Visibility(
                visible: queryTags.length > 0,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selected tags',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: kGreyDarker,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: queryTags.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 4,
                            ),
                            itemBuilder: (BuildContext context, index) {
                              var tag = queryTags[index];
                              return QuerySelectionTagElement(
                                  onTap: () {
                                    TagService.instance.toggleQueryTag(tag);
                                    searchQueryController.clear();
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  elementColor: kSelectedTag,
                                  icon: tagIcon(tag),
                                  iconColor: tagIconColor(tag),
                                  tagTitle: shorten(tagTitle(tag), context));
                            }),
                      ),
                    ])),
            Visibility(
                visible: (queryResult['tags']['u::'] > 0 &&
                        !queryTags.contains('u::')) ||
                    (queryResult['tags']['t::'] > 0 &&
                        !queryTags.contains('t::')),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Organization', style: kQuerySelectorSubtitles),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          shrinkWrap: true,
                          childAspectRatio: 4,
                          children: (() {
                            List<Widget> output = [];
                            if (queryResult['tags']['u::'] > 0 &&
                                !queryTags.contains('u::'))
                              output.add(QuerySelectionTagElement(
                                onTap: () {
                                  TagService.instance.toggleQueryTag('u::');
                                  searchQueryController.clear();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                elementColor: kGreyLighter,
                                icon: tagIcon('u::'),
                                iconColor: tagIconColor('u::'),
                                tagTitle: tagTitle('u::'),
                              ));
                            if (queryResult['tags']['t::'] > 0 &&
                                !queryTags.contains('t::'))
                              output.add(QuerySelectionTagElement(
                                onTap: () {
                                  TagService.instance.toggleQueryTag('t::');
                                  searchQueryController.clear();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                elementColor: kGreyLighter,
                                icon: tagIcon('t::'),
                                iconColor: tagIconColor('t::'),
                                tagTitle: tagTitle('t::'),
                              ));
                            if (queryResult['tags']['o::'] > 0 &&
                                !queryTags.contains('o::'))
                              output.add(QuerySelectionTagElement(
                                onTap: () {
                                  TagService.instance.toggleQueryTag('o::');
                                  searchQueryController.clear();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                elementColor: kGreyLighter,
                                icon: tagIcon('o::'),
                                iconColor: tagIconColor('o::'),
                                tagTitle: tagTitle('o::'),
                              ));
                            return output;
                          })()),
                    ),
                  ],
                )),
            Visibility(
                visible: years.length > 0,
                child: const Text('Years', style: kQuerySelectorSubtitles)),
            Visibility(
                visible: years.length > 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredYears.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 4,
                      ),
                      itemBuilder: (BuildContext context, index) {
                        var year = filteredYears[index];
                        return QuerySelectionTagElement(
                            onTap: () {
                              TagService.instance.toggleQueryTag(year);
                              searchQueryController.clear();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            elementColor: queryTags.contains(year)
                                ? kSelectedTag
                                : kGreyLighter,
                            icon: tagIcon(year),
                            iconColor: tagIconColor(year),
                            tagTitle: tagTitle(year));
                      }),
                )),
            Visibility(
                visible: years.length > 4,
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        expandYears = !expandYears;
                        filteredYears = (expandYears || years.length < 4)
                            ? years
                            : years.sublist(years.length - 4, years.length);
                      });
                    },
                    child: Text(
                        'See ' + (expandYears ? 'less' : 'more') + ' years',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: kGrey,
                        )))),
            Visibility(
                visible: queryTags
                            .where((tag) => RegExp('^d::').hasMatch(tag))
                            .toList()
                            .length >
                        0 &&
                    months.length > 0,
                child: const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('Months',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: kGreyDarker,
                      )),
                )),
            Visibility(
                visible: queryTags
                            .where((tag) => RegExp('^d::').hasMatch(tag))
                            .toList()
                            .length >
                        0 &&
                    months.length > 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: months.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 4,
                      ),
                      itemBuilder: (BuildContext context, index) {
                        var month = months[index];
                        return QuerySelectionTagElement(
                          onTap: () {
                            TagService.instance.toggleQueryTag(month);
                            searchQueryController.clear();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          elementColor: queryTags.contains(month)
                              ? kSelectedTag
                              : kGreyLighter,
                          icon: tagIcon(month),
                          iconColor: tagIconColor(month),
                          tagTitle: tagTitle(month),
                        );
                      }),
                )),
            Visibility(
                visible: countries.length > 0,
                child: const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('Geo', style: kQuerySelectorSubtitles),
                )),
            Visibility(
                visible: countries.length > 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredCountries.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 4,
                      ),
                      itemBuilder: (BuildContext context, index) {
                        var country = filteredCountries[index];
                        return QuerySelectionTagElement(
                            onTap: () {
                              TagService.instance.toggleQueryTag(country);
                              searchQueryController.clear();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            elementColor: queryTags.contains(country)
                                ? kSelectedTag
                                : kGreyLighter,
                            icon: tagIcon(country),
                            iconColor: tagIconColor(country),
                            tagTitle: tagTitle(country));
                      }),
                )),
            Visibility(
                visible: countries.length > 2,
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        expandCountries = !expandCountries;
                        filteredCountries =
                            (expandCountries || countries.length < 2)
                                ? countries
                                : countries.sublist(
                                    countries.length - 2, countries.length);
                      });
                    },
                    child: Text(
                        'See ' +
                            (expandCountries ? 'less' : 'more') +
                            ' countries',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: kGrey,
                        )))),
            Visibility(
                visible: queryTags
                            .where((tag) => RegExp('^g::').hasMatch(tag))
                            .toList()
                            .length >
                        0 &&
                    cities.length > 0,
                child: const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('Cities',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: kGreyDarker,
                      )),
                )),
            Visibility(
                visible: queryTags
                            .where((tag) => RegExp('^g::').hasMatch(tag))
                            .toList()
                            .length >
                        0 &&
                    cities.length > 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: cities.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 4,
                      ),
                      itemBuilder: (BuildContext context, index) {
                        var city = cities[index];
                        return QuerySelectionTagElement(
                            onTap: () {
                              TagService.instance.toggleQueryTag(city);
                              searchQueryController.clear();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            elementColor: queryTags.contains(city)
                                ? kSelectedTag
                                : kGreyLighter,
                            icon: tagIcon(city),
                            iconColor: tagIconColor(city),
                            tagTitle: shorten(tagTitle(city), context));
                      }),
                )),
            Visibility(
                visible: usertags.length > 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      const Text('Your tags', style: kQuerySelectorSubtitles),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kAltoOrganized,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, 'manageTags');
                            },
                            child: const Text(
                              'Manage',
                              style: kButtonText,
                            )),
                      )
                    ],
                  ),
                )),
            Visibility(
                visible: usertags.length > 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 4,
                      ),
                      itemCount: usertags.length,
                      itemBuilder: (BuildContext context, index) {
                        var tag = usertags[index];
                        return QuerySelectionTagElement(
                            onTap: () {
                              TagService.instance.toggleQueryTag(tag);
                              searchQueryController.clear();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            elementColor: queryTags.contains(tag)
                                ? kSelectedTag
                                : kGreyLighter,
                            icon: tagIcon(tag),
                            iconColor: tagIconColor(tag),
                            tagTitle: shorten(tagTitle(tag), context));
                      }),
                )),
          ],
        )),
        floatingActionButton: Align(
          alignment: const Alignment(0.11, 1),
          child: FloatingActionButton.extended(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pushReplacementNamed(context, 'home');
            },
            backgroundColor: kAltoBlue,
            label: queryInProgress == true
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('See ' + queryResult['total'].toString() + ' pivs',
                    style: kSelectAllButton),
          ),
        ),
      ),
    );
  }
}

class QuerySelectionTagElement extends StatelessWidget {
  const QuerySelectionTagElement({
    Key? key,
    required this.elementColor,
    required this.icon,
    required this.iconColor,
    required this.tagTitle,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;
  final Color elementColor;
  final IconData icon;
  final Color iconColor;
  final String tagTitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: elementColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    right: SizeService.instance.screenWidth(context) < 380
                        ? 8
                        : 12.0),
                child: FaIcon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              Text(
                tagTitle,
                style: kLookingAtText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
