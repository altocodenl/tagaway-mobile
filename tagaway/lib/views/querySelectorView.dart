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

  dynamic queryTags = [];
  dynamic queryResult = {'total': 0, 'tags': {}};
  dynamic years = [];

  @override
  void initState() {
    super.initState();
    cancelListener =
        StoreService.instance.listen(['queryTags', 'queryResult'], (v1, v2) {
      setState(() {
        if (v1 != '') queryTags = v1;
        if (v2 != '') {
           queryResult = v2;
           years = queryResult['tags'].keys.where((tag) => RegExp('^d::[0-9]').hasMatch(tag)).toList ();
           years.sort ();
        }
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
                  var year = years [index];
                  return QuerySelectionTagElement(
                    onTap: () {
                       TagService.instance.toggleQueryTag (year);
                    },
                    elementColor: kGreyLighter,
                    icon: kClockIcon,
                    iconColor: kGreyDarker,
                    tagTitle: year.substring(3)
                  );
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
                  icon: kClockIcon,
                  iconColor: kGreyDarker,
                  tagTitle: 'Jan',
                ),
                QuerySelectionTagElement(
                  onTap: () {},
                  elementColor: kGreyLighter,
                  icon: kClockIcon,
                  iconColor: kGreyDarker,
                  tagTitle: 'Feb',
                ),
                QuerySelectionTagElement(
                  onTap: () {},
                  elementColor: kSelectedTag,
                  icon: kClockIcon,
                  iconColor: kGreyDarker,
                  tagTitle: 'Mar',
                ),
                QuerySelectionTagElement(
                  onTap: () {},
                  elementColor: kGreyLighter,
                  icon: kClockIcon,
                  iconColor: kGreyDarker,
                  tagTitle: 'Apr',
                ),
                QuerySelectionTagElement(
                  onTap: () {},
                  elementColor: kGreyLighter,
                  icon: kClockIcon,
                  iconColor: kGreyDarker,
                  tagTitle: 'May',
                ),
                QuerySelectionTagElement(
                  onTap: () {},
                  elementColor: kGreyLighter,
                  icon: kClockIcon,
                  iconColor: kGreyDarker,
                  tagTitle: 'Jun',
                ),
                QuerySelectionTagElement(
                  onTap: () {},
                  elementColor: kGreyLighter,
                  icon: kClockIcon,
                  iconColor: kGreyDarker,
                  tagTitle: 'Jul',
                ),
                QuerySelectionTagElement(
                  onTap: () {},
                  elementColor: kGreyLighter,
                  icon: kClockIcon,
                  iconColor: kGreyDarker,
                  tagTitle: 'Aug',
                ),
                QuerySelectionTagElement(
                  onTap: () {},
                  elementColor: kGreyLighter,
                  icon: kClockIcon,
                  iconColor: kGreyDarker,
                  tagTitle: 'Sep',
                ),
                QuerySelectionTagElement(
                  onTap: () {},
                  elementColor: kGreyLighter,
                  icon: kClockIcon,
                  iconColor: kGreyDarker,
                  tagTitle: 'Oct',
                ),
                QuerySelectionTagElement(
                  onTap: () {},
                  elementColor: kGreyLighter,
                  icon: kClockIcon,
                  iconColor: kGreyDarker,
                  tagTitle: 'Nov',
                ),
                QuerySelectionTagElement(
                  onTap: () {},
                  elementColor: kGreyLighter,
                  icon: kClockIcon,
                  iconColor: kGreyDarker,
                  tagTitle: 'Dec',
                ),
              ],
            ),
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
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 4,
                ),
                itemBuilder: (BuildContext context, index) {
                  return QuerySelectionTagElement(
                    onTap: () {},
                    elementColor: kGreyLighter,
                    icon: kLocationDotIcon,
                    iconColor: kGreyDarker,
                    tagTitle: 'AR',
                  );
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
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 4,
                ),
                itemBuilder: (BuildContext context, index) {
                  return QuerySelectionTagElement(
                    onTap: () {},
                    elementColor: kGreyLighter,
                    icon: kLocationPinIcon,
                    iconColor: kGreyDarker,
                    tagTitle: 'Ayacucho',
                  );
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
                itemCount: 12,
                itemBuilder: (BuildContext context, index) {
                  return QuerySelectionTagElement(
                    onTap: () {},
                    elementColor: kGreyLighter,
                    icon: kTagIcon,
                    iconColor: kTagColor1,
                    tagTitle: 'Lorem ipsum dolor',
                  );
                }),
          ),
        ],
      )),
      floatingActionButton: Align(
        alignment: const Alignment(0.11, 1),
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: kAltoBlue,
          label: const Text('See XXX results', style: kSelectAllButton),
        ),
      ),
    );
  }
}
