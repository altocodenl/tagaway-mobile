// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:core';
import 'dart:typed_data';
import 'dart:async';
import 'package:photo_manager/photo_manager.dart';
import 'package:tuple/tuple.dart';
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

//Regarding the selectedList event issue:
// [NOPE] Option 1: try to solve it through provider
// Option 2: Create a Controller Class of the stream, add a subscriber in Grid and try to go for a controller.add() to try and add data to the stream. Then change it to broadcast
// [NOPE] Option 3: Create the StreamController inside Grid and try to access it through a subscriber in BottomRow
// Option 4: Inherited Widget + streams. Create a broadcast through a StreamController in a InheritedWidget and then reference it from Grid to add to sink
// Option 5: Provider to send the value of selectedList.length upstream and then make it downstream through a broadcast

// List ALL the cases where events will be needed in this view. Otherwise you'll go bananas.
//selectedList.length > that will go for:
//                                        Counter at BottomRow
//                                        If selectedList.length > 0, then TopRow changes to selectionMode
// all == true; must turn selectedList = List.from(itemList);
// Through events can I avoid the setState() of 'all' in SelectedAsset()?
// click of 'Cancel' in TopRow must call selectedList.clear();
//

class ProviderController extends ChangeNotifier {
  Object redrawObject = Object();
  redraw() {
    redrawObject = Object();
  }

  bool all = false;
  void selectAllTapped(bool newValue) {
    all = newValue;
    notifyListeners();
  }

  bool isSelectionInProcess = false;
  void selectionInProcess(bool newValue) {
    isSelectionInProcess = newValue;
    notifyListeners();
  }

  bool isUploadingInProcess = false;
  void showUploadingProcess() {
    isUploadingInProcess = !isUploadingInProcess;
    notifyListeners();
  }
}

class GridPage extends StatefulWidget {
  @override
  _GridPageState createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  final selectedListLengthController = StreamController<int>.broadcast();

  // TODO: Would it make sense to use a StreamProvider<T> class for this Broadcast?

  @override
  void dispose() {
    selectedListLengthController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return ChangeNotifierProvider<ProviderController>(
      create: (_) => ProviderController(),
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Grid(
                selectedListLengthStreamController:
                    selectedListLengthController,
              ),
              TopRow(),
              BottomRow(
                selectedListLengthStreamController:
                    selectedListLengthController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Grid
class Grid extends StatefulWidget {
  final StreamController<int> selectedListLengthStreamController;
  Grid({@required this.selectedListLengthStreamController});

  @override
  _GridState createState() => _GridState();
}

class Item {
  Item({@required this.imgUrl, @required this.position});
  String imgUrl;
  int position;
}

class _GridState extends State<Grid> {
  List<AssetEntity> itemList;
  List<AssetEntity> selectedList;

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
      final option = FilterOption();
      return FilterOptionGroup()
        ..addOrderOption(
            OrderOption(type: OrderOptionType.createDate, asc: false));
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
    print('Drawing entire view');
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: SizedBox.expand(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Selector<ProviderController, Tuple2<Function, bool>>(
            selector: (context, providerController) =>
                Tuple2(providerController.redraw(), providerController.all),
            builder: (context, providerData, child) {
              print('Drawing GridView Builder');
              return GridView.builder(
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
                  key: ValueKey<Object>(providerData.item1),

                  // Provider.of<ProviderController>(context).redrawObject),
                  itemBuilder: (BuildContext context, index) {
                    print('Drawing GridItem');
                    return GridItem(
                      item: itemList[index],
                      all: providerData.item2,
                      isSelected: (bool value) {
                        if (value) {
                          selectedList.add(itemList[index]);
                          widget.selectedListLengthStreamController.sink
                              .add(selectedList.length);
                        } else {
                          selectedList.remove(itemList[index]);
                          widget.selectedListLengthStreamController.sink
                              .add(selectedList.length);
                        }
                        // setState(() {
                        //   if (value) {
                        //     selectedList.add(itemList[index]);
                        //   } else {
                        //     selectedList.remove(itemList[index]);
                        //   }
                        // });
                        // print("$index : $value");
                        print(selectedList.length);
                      },
                      key: Key(itemList[index].toString()),
                    );
                  });
            },
          ),
        ),
      ),
    );
  }
}

//Top Row
class TopRow extends StatefulWidget {
  @override
  _TopRowState createState() => _TopRowState();
}

class _TopRowState extends State<TopRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 10),
      child: Visibility(
        visible:
            !(Provider.of<ProviderController>(context).isUploadingInProcess),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Visibility(
              visible: !(Provider.of<ProviderController>(context)
                  .isSelectionInProcess),
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
                  Provider.of<ProviderController>(context, listen: false)
                      .selectAllTapped(false);
                  Provider.of<ProviderController>(context, listen: false)
                      .redraw();
                  Provider.of<ProviderController>(context, listen: false)
                      .selectionInProcess(false);

                  // setState(() {
                  //   selectedList.clear();
                  // });
                },
                child: Text(
                  'Cancel',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Bottom Row

class BottomRow extends StatefulWidget {
  final StreamController<int> selectedListLengthStreamController;
  BottomRow({@required this.selectedListLengthStreamController});

  @override
  _BottomRowState createState() => _BottomRowState();
}

class _BottomRowState extends State<BottomRow> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Visibility(
                visible: !(Provider.of<ProviderController>(context)
                    .isUploadingInProcess),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Color(0xFF5b6eff),
                    minimumSize: Size(40, 40),
                    side: BorderSide(width: 1, color: Color(0xFF5b6eff)),
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
                    Provider.of<ProviderController>(context, listen: false)
                        .selectAllTapped(true);
                    Provider.of<ProviderController>(context, listen: false)
                        .redraw();
                    Provider.of<ProviderController>(context, listen: false)
                        .selectionInProcess(true);

                    // setState(() {
                    //   selectedList = List.from(itemList);
                    // });
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
                visible: !(Provider.of<ProviderController>(context)
                    .isUploadingInProcess),
                child: StreamBuilder(
                  stream: widget.selectedListLengthStreamController.stream
                      .asBroadcastStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return Text('There\'s been an error');
                    else if (snapshot.connectionState ==
                        ConnectionState.waiting)
                      return Text(
                        'No files selected',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      );
                    return Text(
                        snapshot.data < 1
                            ? 'No files selected'
                            : '${snapshot.data} files selected',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ));
                  },
                ),
                // replacement: Text(
                //   // 'X / ${selectedList.length} files uploaded so far...',
                //   'X/X files uploaded so far...',
                //   style: TextStyle(
                //     fontFamily: 'Montserrat',
                //     fontSize: 12,
                //     fontWeight: FontWeight.bold,
                //     color: Color(0xFF333333),
                //   ),
                // ),
              ),
              Visibility(
                visible: !(Provider.of<ProviderController>(context)
                    .isUploadingInProcess),
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
                    Provider.of<ProviderController>(context, listen: false)
                        .showUploadingProcess();
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
                    Provider.of<ProviderController>(context, listen: false)
                        .showUploadingProcess();
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
    );
  }
}
