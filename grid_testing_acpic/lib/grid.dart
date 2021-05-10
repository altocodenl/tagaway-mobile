// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:core';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io' show Platform;

// IMPORT UI ELEMENTS
// import 'package:acpic/ui_elements/cupertino_elements.dart';
// import 'package:acpic/ui_elements/android_elements.dart';
// import 'package:acpic/ui_elements/material_elements.dart';

//TODO: Make this view the default view until user logs out or revokes permission to access photos
//https://api.flutter.dev/flutter/widgets/Flexible-class.html
//https://api.flutter.dev/flutter/cupertino/CupertinoPageScaffold-class.html
//https://api.flutter.dev/flutter/cupertino/CupertinoScrollbar-class.html
//https://api.flutter.dev/flutter/widgets/OrientationBuilder-class.html
import 'grid_item.dart';

class Grid extends StatefulWidget {
  @override
  _GridState createState() => _GridState();
}

class Item {
  Item({@required this.imgUrl, @required this.position});
  String imgUrl;
  int position;
}

bool isSelectViewVisible = true;
bool isUploadViewVisible = true;
bool isUploadingInProcess = true;

class _GridState extends State<Grid> {
  List<AssetEntity> itemList;
  List<AssetEntity> selectedList;

  bool _all = false;
  Object redrawObject = Object();

  void _selectAllTapped (bool newValue){
    setState(() {
      _all = newValue;
    });
  }
  redraw(){
    setState(() {
      redrawObject = Object();
    });
  }

  void showSelectView() {
    setState(() {
      isSelectViewVisible = !isSelectViewVisible;
    });
  }

  void showUploadingView() {
    setState(() {
      isUploadViewVisible = !isUploadViewVisible;
    });
  }

  void showUploadingProcess() {
    setState(() {
      isUploadingInProcess = !isUploadingInProcess;
    });
  }

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
    FilterOptionGroup makeOption(){
      final option = FilterOption();
      return FilterOptionGroup()
        ..addOrderOption(OrderOption(type: OrderOptionType.createDate, asc: false));
    }
    final option = makeOption();

    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(onlyAll: true, filterOption: option);
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: SizedBox.expand(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: GridView.builder(
                      //TODO: Fix case for when there are less than 30 images (it should always start from the top in reverse order)
                      reverse: true,
                      shrinkWrap: true,
                      cacheExtent: 50,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                      ),
                      itemCount: itemList.length,
                      key: ValueKey<Object>(redrawObject),
                      itemBuilder: (BuildContext context, index) {
                        return GridItem(
                          item: itemList[index],
                          isSelectViewVisible: isSelectViewVisible,
                          isUploadViewVisible: isUploadViewVisible,
                          all: _all,
                          onChanged: _selectAllTapped,
                          isSelected: (bool value) {
                            setState(() {
                              if (value) {
                                selectedList.add(itemList[index]);
                              } else {
                                selectedList.remove(itemList[index]);
                              }
                            });
                            // print("$index : $value");
                          },
                          key: Key(itemList[index].toString()),
                        );
                      }),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 10),
              child: Visibility(
                visible: isUploadingInProcess,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Visibility(
                      visible: isSelectViewVisible,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF5b6eff),
                          minimumSize: Size(40, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          textStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          showSelectView();
                        },
                        child: Text(
                          'Select',
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isSelectViewVisible,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Color(0xFF5b6eff),
                          ),
                          child: IconButton(
                              // TODO: add the Android function
                              icon: Icon(Icons.more_horiz_rounded),
                              color: Colors.white,
                              onPressed: () {
                                // showCupertinoModalPopup(
                                //   context: context,
                                //   builder: (context) => CupertinoLogOut(),
                                // );
                              }),
                        ),
                      ),
                      replacement: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF8b8b8b),
                          minimumSize: Size(40, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          textStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          showSelectView();
                          _selectAllTapped(false);
                          redraw();
                          setState(() {
                            selectedList.clear();
                          });
                        },
                        child: Text(
                          'Cancel',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  child: Visibility(
                    visible: !isSelectViewVisible,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Visibility(
                          visible: isUploadViewVisible,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Color(0xFF5b6eff),
                              minimumSize: Size(40, 40),
                              side: BorderSide(
                                  width: 1, color: Color(0xFF5b6eff)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              textStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              _selectAllTapped(true);
                              redraw();
                              setState(() {
                                selectedList = List.from(itemList);
                              });
                            },
                            child: Row(
                              children: <Widget>[
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Image.asset(
                                      'images/icon-guide--upload.png',
                                      scale: 16,
                                    ),
                                    Positioned.fill(
                                      top: -2,
                                      right: -2,
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Icon(
                                          Icons.circle,
                                          size: 10,
                                          color: Color(0xFF5b6eff),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 1),
                                  child: Text(
                                    'Select all',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isUploadViewVisible,
                          child: Text(
                            selectedList.length < 1
                                ? 'No files selected'
                                : selectedList.length < 2
                                    ? '1 file selected'
                                    : '${selectedList.length} files selected',
                            // '444,444 files selected',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          replacement: Text(
                            'X / ${selectedList.length} files uploaded so far...',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isUploadViewVisible,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF5b6eff),
                              minimumSize: Size(40, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              textStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              showUploadingView();
                              showUploadingProcess();
                            },
                            child: Text(
                              'Upload',
                            ),
                          ),
                          replacement: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF8b8b8b),
                              minimumSize: Size(40, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              textStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              showUploadingView();
                              showUploadingProcess();
                            },
                            child: Text(
                              'Cancel',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

