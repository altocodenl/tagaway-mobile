import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagaway/services/sizeService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';

class QuerySelectorView extends StatefulWidget {
  static const String id = 'querySelector';

  const QuerySelectorView({Key? key}) : super(key: key);

  @override
  State<QuerySelectorView> createState() => _QuerySelectorViewState();
}

class _QuerySelectorViewState extends State<QuerySelectorView> {
  dynamic cancelListener;
  dynamic cancelListener2;
  final TextEditingController searchQueryController = TextEditingController();

  dynamic queryTags = [];
  dynamic queryResult = {'total': 0, 'tags': {}};
  dynamic years = [];
  dynamic months = [];
  dynamic countries = [];
  dynamic cities = [];
  dynamic usertags = [];
  dynamic expandYears = false;
  dynamic expandCountries = false;
  dynamic filteredYears = [];
  dynamic filteredCountries = [];

  // This function will be called every time the text changes
  searchQueryChanged() {
    StoreService.instance.set('queryFilter', searchQueryController.text);
  }

  @override
  void initState() {
    super.initState();
    searchQueryController.addListener(searchQueryChanged);
    if (StoreService.instance.get('queryTags') == '')
      StoreService.instance.set('queryTags', []);
    // The listeners are separated because we don't want to query pivs again once queryResult is updated.
    cancelListener = StoreService.instance.listen(['queryTags'], (v1) {
      if (v1 == '') v1 = [];
      TagService.instance.queryPivs(v1);
      setState(() {
        queryTags = v1;
      });
    });
    cancelListener2 = StoreService.instance.listen([
      'queryResult',
      'queryFilter',
    ], (v1, v2) {
      bool matchFilter(String tag) {
        if (v2 == '' || queryTags.contains(tag)) return true;
        return tag.toLowerCase().contains(v2.toLowerCase());
      }

      if (v1 != '')
        setState(() {
          queryResult = v1;
          var queryTags = StoreService.instance.get('queryTags');
          if (queryTags == '') queryTags = [];
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
    cancelListener2();
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
                Navigator.pushReplacementNamed(context, 'bottomNavigation');
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
              padding: const EdgeInsets.only(top: 18, right: 20),
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      StoreService.instance.set('queryTags', []);
                      searchQueryController.clear();
                    });
                  },
                  child: const Text('Clear', style: kPlainTextBold)),
            ),
            // IconButton(icon: const Icon(Icons.add), onPressed: () {}),
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
                                  tagTitle: tagTitle(tag));
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
                            tagTitle: shorten(tagTitle(city)));
                      }),
                )),
            Visibility(
                visible: usertags.length > 0,
                child: const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('Your tags', style: kQuerySelectorSubtitles),
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
                            tagTitle: shorten(tagTitle(tag)));
                      }),
                )),
          ],
        )),
        floatingActionButton: Align(
          alignment: const Alignment(0.11, 1),
          child: FloatingActionButton.extended(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pushReplacementNamed(context, 'bottomNavigation');
              StoreService.instance.set('currentIndex', 2);
            },
            backgroundColor: kAltoBlue,
            label: Text('See ' + queryResult['total'].toString() + ' pivs',
                style: kSelectAllButton),
          ),
        ),
      ),
    );
  }
}
