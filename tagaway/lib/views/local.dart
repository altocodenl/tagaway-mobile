// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/views/grid_item.dart';

class LocalView extends StatefulWidget {
  const LocalView({Key? key}) : super(key: key);

  @override
  State<LocalView> createState() => _LocalViewState();
}

class _LocalViewState extends State<LocalView> {
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
        Align(
          alignment: const Alignment(0.8, .9),
          child: FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: kAltoBlue,
            label: const Text('Done', style: kSelectAllButton),
            icon: const Icon(Icons.done),
          ),
        )
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
                return GridItem(
                    item: itemList[index],
                    isSelected: (bool value) {
                      if (value) {
                        selectedList.add(itemList[index]);
                      } else {
                        selectedList.remove(itemList[index]);
                      }
                    });
              }),
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
          // height: 190,
          width: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                const Text(
                  '2022',
                  textAlign: TextAlign.center,
                  style: kLocalYear,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20.0),
                  child: SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 40.0),
                          child: Column(
                            children: const [
                              FaIcon(
                                FontAwesomeIcons.solidCircleCheck,
                                color: kAltoOrganized,
                                size: 16,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text('Jul', style: kHorizontalMonth),
                              ),
                              FaIcon(
                                FontAwesomeIcons.minus,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 40.0),
                          child: Column(
                            children: const [
                              FaIcon(
                                FontAwesomeIcons.solidCircle,
                                color: kGreyDarker,
                                size: 16,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Aug',
                                  style: kHorizontalMonth,
                                ),
                              ),
                              FaIcon(
                                FontAwesomeIcons.minus,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 40.0),
                          child: Column(
                            children: const [
                              FaIcon(
                                FontAwesomeIcons.solidCircleCheck,
                                color: kAltoOrganized,
                                size: 16,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Sep',
                                  style: kHorizontalMonth,
                                ),
                              ),
                              FaIcon(
                                FontAwesomeIcons.minus,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 40.0),
                          child: Column(
                            children: const [
                              FaIcon(
                                FontAwesomeIcons.solidCircleCheck,
                                color: kAltoOrganized,
                                size: 16,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Oct',
                                  style: kHorizontalMonth,
                                ),
                              ),
                              FaIcon(
                                FontAwesomeIcons.minus,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 40.0),
                          child: Column(
                            children: const [
                              FaIcon(
                                FontAwesomeIcons.circle,
                                color: kGreyDarker,
                                size: 16,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Nov',
                                  style: kHorizontalMonth,
                                ),
                              ),
                              FaIcon(
                                FontAwesomeIcons.minus,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 0.0),
                          child: Column(
                            children: const [
                              FaIcon(
                                FontAwesomeIcons.solidCircle,
                                color: kGreyDarker,
                                size: 16,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Dec',
                                  style: kHorizontalMonth,
                                ),
                              ),
                              FaIcon(
                                FontAwesomeIcons.minus,
                                color: kAltoBlue,
                              ),
                            ],
                          ),
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
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Text(
                    'Now tagging with',
                    style: kLookingAtText,
                  ),
                ),
                Container(
                  height: 40,
                  width: 180,
                  decoration: const BoxDecoration(
                      color: kGreyLighter,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      children: const <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: FaIcon(
                            FontAwesomeIcons.tag,
                            color: kTagColor1,
                            size: 20,
                          ),
                        ),
                        Text('Vacations', style: kGridTagListElement),
                      ],
                    ),
                  ),
                ),
                const Expanded(
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
