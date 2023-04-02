import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/BottomNavigationBar.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';

class QuerySelectorView extends StatefulWidget {
  static const String id = 'querySelector';

  const QuerySelectorView({Key? key}) : super(key: key);

  @override
  State<QuerySelectorView> createState() => _QuerySelectorViewState();
}

class _QuerySelectorViewState extends State<QuerySelectorView> {
  dynamic cancelListener;
  dynamic cancelListener2;

  dynamic queryTags = [];
  dynamic queryResult = {'total': 0, 'tags': {}};
  dynamic years = [];
  dynamic months = [];
  dynamic countries = [];
  dynamic cities = [];
  dynamic usertags = [];

  @override
  void initState() {
    super.initState();
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
    ], (v1) {
      if (v1 != '')
        setState(() {
          queryResult = v1;
          years = queryResult['tags']
              .keys
              .where((tag) => RegExp('^d::[0-9]').hasMatch(tag))
              .toList();
          years.sort();
          months = queryResult['tags']
              .keys
              .where((tag) => RegExp('^d::M').hasMatch(tag))
              .toList();
          months.sort();
          countries = queryResult['tags']
              .keys
              .where((tag) => RegExp('^g::[A-Z]{2}').hasMatch(tag))
              .toList();
          countries.sort();
          cities = queryResult['tags']
              .keys
              .where((tag) =>
                  RegExp('^g::').hasMatch(tag) && !countries.contains(tag))
              .toList();
          cities.sort();
          usertags = queryResult['tags']
              .keys
              .where((tag) => !RegExp('^[a-z]::').hasMatch(tag))
              .toList();
          usertags.sort();
        });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancelListener();
    cancelListener2();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kAltoBlue),
        leadingWidth: 70,
        leading: IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.circleXmark,
              color: kGreyDarker,
              size: 25,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, BottomNavigationView.id);
            }),
        title: const Text('Filter', style: kSubPageAppBarTitle),
        actions: const [
          Padding(
            padding: EdgeInsets.only(top: 18, right: 20),
            child: Text(
              'Reset',
              style: kPlainTextBold,
            ),
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
              // TODO: why does this conditional work when it's the other way around? Visibility should be on != null
              visible: queryResult['tags']['u::'] == null,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    shrinkWrap: true,
                    childAspectRatio: 4,
                    children: [
                      QuerySelectionTagElement(
                        onTap: () {},
                        elementColor: kGreyLighter,
                        icon: kTagIcon,
                        iconColor: kGrey,
                        tagTitle: 'Untagged',
                      ),
                      QuerySelectionTagElement(
                        onTap: () {},
                        elementColor: kGreyLighter,
                        icon: kBoxArchiveIcon,
                        iconColor: kGrey,
                        tagTitle: 'To Organize',
                      ),
                      QuerySelectionTagElement(
                        onTap: () {},
                        elementColor: kGreyLighter,
                        icon: kCircleCheckIcon,
                        iconColor: kAltoOrganized,
                        tagTitle: 'Organized',
                      ),
                    ]),
              )),
          const Text('Years',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: kGreyDarker,
              )),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: years.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 4,
                ),
                itemBuilder: (BuildContext context, index) {
                  var year = years[index];
                  return QuerySelectionTagElement(
                      onTap: () {
                        TagService.instance.toggleQueryTag(year);
                      },
                      elementColor: queryTags.contains(year)
                          ? kSelectedTag
                          : kGreyLighter,
                      icon: kClockIcon,
                      iconColor: kGreyDarker,
                      tagTitle: year.substring(3));
                }),
          ),
          const Text('See more years',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: kGrey,
              )),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text('Months',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: kGreyDarker,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: months.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 4,
                ),
                itemBuilder: (BuildContext context, index) {
                  var month = months[index];
                  var monthNames = [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec'
                  ];
                  var displayName =
                      monthNames[int.parse(month.substring(4)) - 1];
                  return QuerySelectionTagElement(
                    onTap: () {
                      TagService.instance.toggleQueryTag(month);
                    },
                    elementColor:
                        queryTags.contains(month) ? kSelectedTag : kGreyLighter,
                    icon: kClockIcon,
                    iconColor: kGreyDarker,
                    tagTitle: displayName,
                  );
                }),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text('Geo',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: kGreyDarker,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: countries.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 4,
                ),
                itemBuilder: (BuildContext context, index) {
                  var country = countries[index];
                  return QuerySelectionTagElement(
                      onTap: () {
                        TagService.instance.toggleQueryTag(country);
                      },
                      elementColor: queryTags.contains(country)
                          ? kSelectedTag
                          : kGreyLighter,
                      icon: kLocationDotIcon,
                      iconColor: kGreyDarker,
                      tagTitle: country.substring(3));
                }),
          ),
          const Text('See more countries',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: kGrey,
              )),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text('Cities',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: kGreyDarker,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: cities.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      },
                      elementColor: queryTags.contains(city)
                          ? kSelectedTag
                          : kGreyLighter,
                      icon: kLocationPinIcon,
                      iconColor: kGreyDarker,
                      tagTitle: city.substring(3));
                }),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text('Your tags',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: kGreyDarker,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      },
                      elementColor:
                          queryTags.contains(tag) ? kSelectedTag : kGreyLighter,
                      icon: kTagIcon,
                      iconColor: kTagColor1,
                      tagTitle: tag);
                }),
          ),
        ],
      )),
      floatingActionButton: Align(
        alignment: const Alignment(0.11, 1),
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: kAltoBlue,
          label: Text('See ' + queryResult['total'].toString() + ' results',
              style: kSelectAllButton),
        ),
      ),
    );
  }
}
