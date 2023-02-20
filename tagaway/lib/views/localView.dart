import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/ui_elements/material_elements.dart';
import 'package:tagaway/views/localGridItemView.dart';

class LocalView extends StatefulWidget {
  const LocalView({Key? key}) : super(key: key);

  @override
  State<LocalView> createState() => _LocalViewState();
}

class _LocalViewState extends State<LocalView> {
  final TextEditingController newTagName = TextEditingController();

  @override
  void initState() {
    PhotoManager.requestPermissionExtend();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Grid(),
        const TopRow(),
        // Align(
        //   alignment: const Alignment(0.8, .9),
        //   child: FloatingActionButton.extended(
        //     onPressed: () {},
        //     backgroundColor: kAltoBlue,
        //     label: const Text('Done', style: kSelectAllButton),
        //     icon: const Icon(Icons.done),
        //   ),
        // )
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox.expand(
            child: DraggableScrollableSheet(
                snap: true,
                initialChildSize: .07,
                minChildSize: .07,
                maxChildSize: .77,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: ListView(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        controller: scrollController,
                        children: [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: FaIcon(
                                FontAwesomeIcons.anglesUp,
                                color: kGrey,
                                size: 16,
                              ),
                            ),
                          ),
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8),
                              child: Text(
                                'Swipe to start tagging',
                                style: kPlainTextBold,
                              ),
                            ),
                          ),
                          // const Center(
                          //   child: Padding(
                          //     padding: EdgeInsets.only(top: 8.0),
                          //     child: FaIcon(
                          //       FontAwesomeIcons.anglesDown,
                          //       color: kGrey,
                          //       size: 16,
                          //     ),
                          //   ),
                          // ),
                          // const Center(
                          //   child: Padding(
                          //     padding: EdgeInsets.only(top: 8.0, bottom: 8),
                          //     child: Text(
                          //       'Tag your pics and videos',
                          //       style: TextStyle(
                          //           fontFamily: 'Montserrat',
                          //           fontWeight: FontWeight.bold,
                          //           fontSize: 20,
                          //           color: kAltoBlue),
                          //     ),
                          //   ),
                          // ),
                          // const Center(
                          //   child: Padding(
                          //     padding: EdgeInsets.only(top: 8.0, bottom: 8),
                          //     child: Text(
                          //       'Choose a tag and select the pics & videos you want!',
                          //       textAlign: TextAlign.center,
                          //       style: kPlainTextBold,
                          //     ),
                          //   ),
                          // ),
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
                    ),
                  );
                }),
          ),
        ),
        // Container(
        //   height: double.infinity,
        //   width: double.infinity,
        //   color: kAltoBlue.withOpacity(.8),
        // ),
        // Center(
        //     child: Padding(
        //   padding: const EdgeInsets.only(left: 12, right: 12),
        //   child: Container(
        //     height: 200,
        //     width: double.infinity,
        //     decoration: const BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.all(Radius.circular(20)),
        //     ),
        //     child: Column(
        //       children: [
        //         const Padding(
        //           padding: EdgeInsets.only(top: 20.0),
        //           child: Text(
        //             'Create a new tag',
        //             style: TextStyle(
        //                 fontFamily: 'Montserrat',
        //                 fontWeight: FontWeight.bold,
        //                 fontSize: 20,
        //                 color: kAltoBlue),
        //           ),
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.only(left: 12, right: 12, top: 20),
        //           child: TextField(
        //             controller: newTagName,
        //             autofocus: true,
        //             textAlign: TextAlign.center,
        //             enableSuggestions: true,
        //             decoration: const InputDecoration(
        //               hintText: 'Insert the name of your new tag here…',
        //               contentPadding: EdgeInsets.symmetric(
        //                   vertical: 10.0, horizontal: 10.0),
        //               border: OutlineInputBorder(
        //                 borderRadius: BorderRadius.all(Radius.circular(25)),
        //               ),
        //             ),
        //           ),
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.only(top: 30.0, right: 20),
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.end,
        //             children: const [
        //               Padding(
        //                 padding: EdgeInsets.only(right: 30.0),
        //                 child: Text(
        //                   'Cancel',
        //                   style: TextStyle(
        //                       fontFamily: 'Montserrat',
        //                       fontWeight: FontWeight.bold,
        //                       fontSize: 16,
        //                       color: kAltoBlue),
        //                 ),
        //               ),
        //               Text(
        //                 'Create',
        //                 style: TextStyle(
        //                     fontFamily: 'Montserrat',
        //                     fontWeight: FontWeight.bold,
        //                     fontSize: 16,
        //                     color: kAltoBlue),
        //               ),
        //             ],
        //           ),
        //         )
        //       ],
        //     ),
        //   ),
        // ))
        // Center(
        //     child: Padding(
        //   padding: const EdgeInsets.only(left: 12, right: 12),
        //   child: Container(
        //     height: 180,
        //     width: double.infinity,
        //     decoration: const BoxDecoration(
        //       color: kAltoBlue,
        //       borderRadius: BorderRadius.all(Radius.circular(20)),
        //     ),
        //     child: Column(
        //       children: [
        //         const Padding(
        //           padding: EdgeInsets.only(
        //               top: 20.0, right: 15, left: 15, bottom: 10),
        //           child: Text(
        //             'Your pics will backup as you tag them',
        //             textAlign: TextAlign.center,
        //             style: kWhiteSubtitle,
        //           ),
        //         ),
        //         Center(
        //             child: WhiteRoundedButton(
        //                 title: 'Start tagging', onPressed: () {}))
        //       ],
        //     ),
        //   ),
        // ))
      ],
    );
  }
}

class Grid extends StatefulWidget {
  const Grid({Key? key}) : super(key: key);

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  late List<AssetEntity> itemList;
  late List<AssetEntity> selectedList;

  @override
  void initState() {
    loadList();
    super.initState();
  }

  loadList() {
    itemList = [];
    selectedList = [];
    _fetchAssets();
  }

  _fetchAssets() async {
    FilterOptionGroup makeOption() {
      // final option = FilterOption();
      return FilterOptionGroup()
        ..addOrderOption(
            const OrderOption(type: OrderOptionType.createDate, asc: false));
    }

    final option = makeOption();
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(
        onlyAll: true, filterOption: option);
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
    final recentAssets = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 1000000, // end at a very big index (to get all the assets)
    );

    // Update the state and notify UI
    setState(() => itemList = recentAssets);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: SizedBox.expand(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: GridView.builder(
            reverse: true,
            shrinkWrap: true,
            cacheExtent: 50,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 1,
              crossAxisSpacing: 1,
            ),
            itemCount: itemList.length,
            itemBuilder: (BuildContext context, index) {
              return LocalGridItem(
                  item: itemList[index],
                  isSelected: (bool value) {
                    if (value) selectedList.add(itemList[index]);
                    else       selectedList.remove(itemList[index]);
                  },
                );
            }
          )
        ),
      ),
    );
  }
}

class TopRow extends StatefulWidget {
  const TopRow({Key? key}) : super(key: key);

  @override
  State<TopRow> createState() => _TopRowState();
}

class _TopRowState extends State<TopRow> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Align(
                          alignment: Alignment(0.29, .9),
                          child: Text(
                            '2022',
                            textAlign: TextAlign.center,
                            style: kLocalYear,
                          ),
                        ),
                      ),
                      Icon(
                        kSearchIcon,
                        color: Colors.white,
                        size: 25,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Icon(
                          kSlidersIcon,
                          color: Colors.white,
                          size: 25,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SizedBox(
                    height: 80,
                    child: ListView(
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 1,
                          crossAxisSpacing: 0,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          childAspectRatio: 1.11,
                          children: const [
                            GridMonthElement(
                              roundedIcon: kSolidCircleIcon,
                              roundedIconColor: kGreyDarker,
                              month: 'Jul',
                              whiteOrAltoBlueDashIcon: Colors.white,
                            ),
                            GridMonthElement(
                              roundedIcon: kCircleCheckIcon,
                              roundedIconColor: kAltoOrganized,
                              month: 'Aug',
                              whiteOrAltoBlueDashIcon: Colors.white,
                            ),
                            GridMonthElement(
                              roundedIcon: kEmptyCircle,
                              roundedIconColor: kGreyDarker,
                              month: 'Sep',
                              whiteOrAltoBlueDashIcon: Colors.white,
                            ),
                            GridMonthElement(
                              roundedIcon: kCircleCheckIcon,
                              roundedIconColor: kAltoOrganized,
                              month: 'Oct',
                              whiteOrAltoBlueDashIcon: Colors.white,
                            ),
                            GridMonthElement(
                              roundedIcon: kSolidCircleIcon,
                              roundedIconColor: kGreyDarker,
                              month: 'Nov',
                              whiteOrAltoBlueDashIcon: Colors.white,
                            ),
                            GridMonthElement(
                              roundedIcon: FontAwesomeIcons.solidCircleCheck,
                              roundedIconColor: kAltoOrganized,
                              month: 'Dec',
                              whiteOrAltoBlueDashIcon: kAltoBlue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          height: 60,
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(width: 1, color: kGreyLighter)),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Row(
              children: const [
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Text(
                    'Now tagging with',
                    style: kLookingAtText,
                  ),
                ),
                GridTagElement(
                  gridTagElementIcon: kTagIcon,
                  iconColor: kTagColor1,
                  gridTagName: 'Vacations',
                ),
                Expanded(
                  child: Text(
                    '4,444',
                    textAlign: TextAlign.right,
                    style: kOrganizedAmountOfPivs,
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
