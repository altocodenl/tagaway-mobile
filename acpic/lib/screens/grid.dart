// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:core';
import 'dart:async';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter_isolate/flutter_isolate.dart';
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/cupertino_elements.dart';
import 'package:acpic/ui_elements/android_elements.dart';
import 'package:acpic/ui_elements/constants.dart';
import 'package:acpic/ui_elements/material_elements.dart';
//IMPORT SCREENS
import 'grid_item.dart';
//IMPORT SERVICES
import 'package:acpic/services/local_vars_shared_prefsService.dart';
import 'package:acpic/services/deviceInfoService.dart';
import 'package:acpic/services/uploadService.dart';

class ProviderController extends ChangeNotifier {
  List<AssetEntity> selectedItems;

  int uploadProgress = 0;
  void uploadProgressFunction(int newValue) {
    uploadProgress = newValue;
    notifyListeners();
  }

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
  void showUploadingProcess(bool newValue) {
    isUploadingInProcess = newValue;
    notifyListeners();
  }

  bool isUploadingPaused = false;
  void uploadingPausePlay(bool newValue) {
    isUploadingPaused = newValue;
    notifyListeners();
  }
}

class GridPage extends StatefulWidget {
  static const String id = 'grid_screen';
  @override
  _GridPageState createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  final selectedListLengthController = StreamController<int>.broadcast();

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
                      selectedListLengthController),
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
      // final option = FilterOption();
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

  selectAll() {
    if (Provider.of<ProviderController>(context, listen: false).all == true) {
      selectedList = List.from(itemList);
      selectedListStreamSink();
    } else if (Provider.of<ProviderController>(context, listen: false)
            .isSelectionInProcess ==
        false) {
      selectedList.clear();
      selectedListStreamSink();
    }
  }

  // --- Copy the contents of selectedList to the Provider List selectedList ---
  feedSelectedListProvider() {
    Provider.of<ProviderController>(context, listen: false).selectedItems =
        List.from(selectedList);
  }

  // --- Add the selectedList length to the Broadcast Stream ---
  selectedListStreamSink() {
    widget.selectedListLengthStreamController.sink.add(selectedList.length);
    feedSelectedListProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: SizedBox.expand(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Selector<ProviderController, Object>(
            selector: (context, providerController) =>
                (providerController.redrawObject),
            builder: (context, providerData, child) {
              // print("hello rebuild");
              selectAll();
              return GridView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  cacheExtent: 50,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  itemCount: itemList.length,
                  key: ValueKey<Object>(providerData),
                  itemBuilder: (BuildContext context, index) {
                    // --- Upon change of the key GridItem gets redrawn. selectAll is called to check if the bool 'all' has been called to fill or clear selectedList ---
                    // selectAll();
                    // print("I am getting called $index");
                    return GridItem(
                      selectedListLengthStreamController:
                          widget.selectedListLengthStreamController,
                      item: itemList[index],
                      isSelected: (bool value) {
                        if (value) {
                          selectedList.add(itemList[index]);
                          selectedListStreamSink();
                        } else {
                          selectedList.remove(itemList[index]);
                          selectedListStreamSink();
                        }
                        selectedList.length > 0
                            ? Provider.of<ProviderController>(context,
                                    listen: false)
                                .selectionInProcess(true)
                            : Provider.of<ProviderController>(context,
                                    listen: false)
                                .selectionInProcess(false);
                        // print("$index : $value");
                      },
                      // key: Key(itemList[index].toString()),
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
                    color: kAltoBlue,
                  ),
                  child: Platform.isIOS ? CupertinoLogOut() : AndroidLogOut(),
                ),
              ),
              replacement: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: kAltoGrey,
                  minimumSize: Size(40, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  textStyle: kButtonText,
                ),
                onPressed: () {
                  Provider.of<ProviderController>(context, listen: false)
                      .selectAllTapped(false);
                  Provider.of<ProviderController>(context, listen: false)
                      .redraw();
                  Provider.of<ProviderController>(context, listen: false)
                      .selectionInProcess(false);
                  SharedPreferencesService.instance
                      .removeValue('selectedListID');
                  UploadService.instance.assetEntityList.clear();
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

class BottomRow extends StatefulWidget {
  final StreamController<int> selectedListLengthStreamController;

  BottomRow({@required this.selectedListLengthStreamController});

  @override
  _BottomRowState createState() => _BottomRowState();
}

class _BottomRowState extends State<BottomRow> {
  // static const platform = MethodChannel('nl.altocode.acpic/iosupload');
  String _cookie;
  String _csrf;
  String _model;
  int _id;
  int selectedListLength;
  List<String> _tags;
  List<AssetEntity> _list;
  List<String> _idList;
  FlutterIsolate isolate;
  bool uploadCancelled = false;

  uploadHandler(List<AssetEntity> list) async {
    // --- FIRST CHECK IF THERE'S A SAVED ID LIST FROM A KILLED UPLOAD ---
    SharedPreferencesService.instance
        .getStringListValue('selectedListID')
        .then((value) async {
      if (value == null) {
        //--- NO SAVED LIST ---
        await UploadService.instance.uploadIDListing(_list);
        _idList = List.from(UploadService.instance.idList);
        // --- SAVE UPLOAD LIST LOCALLY IN CASE APP IS KILLED ---
        SharedPreferencesService.instance
            .setStringListValue('selectedListID', List.from(_idList));
        // ---
        // --- GET THE DENOMINATOR VALUE FOR THE UPLOAD COUNTER
        selectedListLength =
            Provider.of<ProviderController>(context, listen: false)
                .selectedItems
                .length;
        // --- SAVE DENOMINATOR VALUE FOR THE UPLOAD COUNTER IN CASE APP IS KILLED
        SharedPreferencesService.instance
            .setIntegerValue('selectedListLengthLocal', selectedListLength);
      } else {
        //--- THERE'S A SAVED LIST ---
        _idList = List.from(value);

        // --- POPULATE SELECTED ITEMS LIST WITH ASSET ENTITY FROM THE SAVED ID LIST IN ORDER TO KEEP COUNT---
        Provider.of<ProviderController>(context, listen: false).selectedItems =
            List.from(UploadService.instance.assetEntityList);
      }
      // if (Platform.isIOS) {
      //   // String value;
      //   SharedPreferencesService.instance.removeValue('selectedListID');
      //   try {
      //     SharedPreferencesService.instance.removeValue('selectedListID');
      //     value = await platform.invokeMethod(
      //         'iosUpload', [_idList, _cookie, _id, _csrf, _tags.toString()]);
      //   } catch (e) {
      //     print('Error is $e');
      //   }
      //   UploadService.instance.uiCancelReset(context);
      //   UploadService.instance.idList.clear();
      //   UploadService.instance.assetEntityList.clear();
      //   _idList.clear();
      //   // UploadService.instance.uploadEnd('cancel', _csrf, _id, _cookie);
      //   SharedPreferencesService.instance.removeValue('selectedListID');
      //   uploadCancelled = false;
      //   SnackBarGlobal.buildSnackBar(context, 'Upload cancelled.', 'green');
      //   // print('$value');
      // } else {
      var receivePort = ReceivePort();
      //--- CALL THE ISOLATE ---
      isolate = await FlutterIsolate.spawn(isolateUpload,
          [_idList, _cookie, _id, _csrf, _tags, receivePort.sendPort]);
      //--- LISTEN TO THE ISOLATE ---
      receivePort.listen((message) {
        if (message is SendPort) {
          if (uploadCancelled == true) {
            message.send('cancel');
          }
        } else if (message == 'done') {
          receivePort.close();
          isolate.kill();
          print('Isolate killed');
          uiResetFunction();
          UploadService.instance.uploadEnd('complete', _csrf, _id, _cookie);
        } else if (message == 'cancelled') {
          receivePort.close();
          isolate.kill();
          print('Isolate killed');
          UploadService.instance.idList.clear();
          UploadService.instance.assetEntityList.clear();
          _idList.clear();
          UploadService.instance.uploadEnd('cancel', _csrf, _id, _cookie);
          uploadCancelled = false;
          uiResetFunction();
          SnackBarGlobal.buildSnackBar(context, 'Upload cancelled.', 'green');
        } else if (message == 'capacityError') {
          receivePort.close();
          isolate.kill();
          print('Isolate killed');
          uiResetFunction();
          SnackBarGlobal.buildSnackBar(
              context, 'You\'ve run out of space.', 'red');
        } else if (message == 'completeError') {
          receivePort.close();
          isolate.kill();
          print('Isolate killed');
          uiResetFunction();
          SnackBarGlobal.buildSnackBar(
              context, 'Your upload was already completed.', 'red');
        } else if (message == 'cancelledError') {
          receivePort.close();
          isolate.kill();
          print('Isolate killed');
          uiResetFunction();
          SnackBarGlobal.buildSnackBar(
              context, 'Your upload was cancelled.', 'red');
        } else if (message == 'errorError') {
          receivePort.close();
          isolate.kill();
          print('Isolate killed');
          uiResetFunction();
          SnackBarGlobal.buildSnackBar(
              context, 'There was an error in your upload.', 'red');
        } else if (message == 'serverError') {
          receivePort.close();
          isolate.kill();
          print('Isolate killed');
          uiResetFunction();
          SnackBarGlobal.buildSnackBar(
              context, 'Something is wrong on our side. Sorry.', 'red');
        } else if (message == 'offline') {
          Provider.of<ProviderController>(context, listen: false)
              .uploadingPausePlay(true);
        } else if (message == 'online') {
          Provider.of<ProviderController>(context, listen: false)
              .uploadingPausePlay(false);
        } else {
          // DELETE UPLOADED ITEM FROM _IDLIST
          _idList.removeWhere((element) => element == message);

          // UPDATE LOCALLY SAVED _IDLIST IN CASE UPLOAD CRASHES
          SharedPreferencesService.instance
              .setStringListValue('selectedListID', List.from(_idList));

          // CHECK IF THERE'S A SAVED SELECTEDLISTLENGTH
          SharedPreferencesService.instance
              .getIntegerValue('selectedListLengthLocal')
              .then((value) async {
            if (value == null) {
              // UPLOAD NUMERATOR CALCULATION
              Provider.of<ProviderController>(context, listen: false)
                  .uploadProgressFunction(selectedListLength - _idList.length);
            } else {
              // ESTABLISH DENOMINATOR FOR UPLOAD
              widget.selectedListLengthStreamController.add(value);
              // UPLOAD NUMERATOR CALCULATION
              Provider.of<ProviderController>(context, listen: false)
                  .uploadProgressFunction(value - _idList.length);
            }
          });
        }
      });
      // }
    });
  }

  uiResetFunction() {
    SharedPreferencesService.instance.removeValue('selectedListID');
    SharedPreferencesService.instance.removeValue('uploadID');
    SharedPreferencesService.instance.removeValue('selectedListLengthLocal');
    UploadService.instance.idList.clear();
    UploadService.instance.assetEntityList.clear();
    _idList.clear();
    UploadService.instance.uiReset(context);
  }

  @override
  void initState() {
    SharedPreferencesService.instance.getStringValue('cookie').then((value) {
      setState(() {
        _cookie = value;
      });
    });
    SharedPreferencesService.instance.getStringValue('csrf').then((value) {
      setState(() {
        _csrf = value;
      });
    });
    Platform.isIOS
        ? DeviceInfoService.instance.iOSInfo().then((value) {
            setState(() {
              _model = value;
            });
          })
        : DeviceInfoService.instance.androidInfo().then((value) {
            setState(() {
              _model = value;
            });
          });
    // AUTOMATIC UPLOAD LOGIC
    SharedPreferencesService.instance
        .getStringListValue('selectedListID')
        .then((value) async {
      //    NO AUTOMATIC UPLOAD
      if (value == null || value.length < 1) {
        return;
        //  AUTOMATIC UPLOAD STARTS
      } else {
        SixSecondSnackBar.buildSnackBar(
            context,
            '${Platform.isIOS ? 'iOS' : 'Android'} cancelled your upload. It will automatically restart...',
            'yellow');
        // --- GENERATE ASSET ENTITY LIST FROM ID LIST  ---
        //This call modifies value.length, so we create another reference to it.
        await UploadService.instance.assetEntityCreator(value);
        // --- SWITCH UI TO UPLOADING VIEW ---
        Provider.of<ProviderController>(context, listen: false)
            .showUploadingProcess(true);
        // SEND WAIT TO RESTART THE UPLOAD PROCESS WITH THE SAVED UPLOAD ID
        SharedPreferencesService.instance
            .getIntegerValue('uploadID')
            .then((value) async {
          UploadService.instance
              .uploadEnd('wait', _csrf, value, _cookie)
              .then((response) {
            // --- CHECK DEVICE IS NOT OFFLINE ---
            if (response == 0) {
              SnackBarGlobal.buildSnackBar(
                  context, 'You\'re offline. Check your connection.', 'red');
              UploadService.instance.uiCancelReset(context);
              UploadService.instance.assetEntityList.clear();
              return;
            }
            // --- CALL UPLOAD ISOLATE ---
            else if (response == 200) {
              _id = value;
              print('id is $_id');
              _tags = ['"' + _model + '"'];
              uploadHandler(_list);
              // --- SNACK BAR (Background upload for Android as of now) ---
              if (Platform.isAndroid) {
                WhiteSnackBar.buildSnackBar(context,
                    'Your files will keep uploading as long as ac;pic is running in the background.');
              } else {
                WhiteSnackBar.buildSnackBar(context,
                    'Please don\'t send ac;pic to background, your upload will stop. We\'re working on background upload for iOS.');
              }
            }
            // --- CHECK FOR SERVER ERROR ---
            else {
              SnackBarGlobal.buildSnackBar(
                  context, 'Something is wrong on our side. Sorry.', 'red');
              return;
            }
          });
        });
      }
    });
    // --- AUTOMATIC UPLOAD END ---
    super.initState();
  }

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
                    onPrimary: kAltoBlue,
                    minimumSize: Size(40, 40),
                    side: BorderSide(width: 1, color: kAltoBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    textStyle: kSelectAllButton,
                  ),
                  onPressed: () {
                    Provider.of<ProviderController>(context, listen: false)
                        .selectAllTapped(true);
                    Provider.of<ProviderController>(context, listen: false)
                        .redraw();
                    Provider.of<ProviderController>(context, listen: false)
                        .selectionInProcess(true);
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
                                color: kAltoBlue,
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
                    stream: widget.selectedListLengthStreamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return Text('There\'s been an error');
                      else if (snapshot.connectionState ==
                          ConnectionState.waiting)
                        return Text(
                          'Loading your files',
                          style: kGridBottomRowText,
                        );
                      return Text(
                          (snapshot.data) < 1
                              ? 'No files selected'
                              : (snapshot.data) == 1
                                  ? '${snapshot.data} file selected'
                                  : '${snapshot.data} files selected',
                          style: kGridBottomRowText);
                    },
                  ),
                  replacement: StreamBuilder(
                      stream: widget.selectedListLengthStreamController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError)
                          return Text('There\'s been an error');
                        else if (snapshot.connectionState ==
                            ConnectionState.waiting)
                          return Text(
                            'Loading your files',
                            style: kGridBottomRowText,
                          );
                        return Visibility(
                          visible: !(Provider.of<ProviderController>(context)
                              .isUploadingPaused),
                          child: Text(
                              Provider.of<ProviderController>(context,
                                              listen: false)
                                          .uploadProgress ==
                                      0
                                  ? 'Preparing your files...'
                                  : 'Uploading ${Provider.of<ProviderController>(context, listen: false).uploadProgress} of ${snapshot.data} files...',
                              style: kGridBottomRowText),
                          replacement: Text('Upload paused. You\'re offline.',
                              style: kGridBottomRowText),
                        );
                      })),
              Visibility(
                visible: !(Provider.of<ProviderController>(context)
                    .isUploadingInProcess),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: kAltoBlue,
                    minimumSize: Size(40, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    textStyle: kButtonText,
                  ),
                  onPressed: () {
                    //--------- UPLOAD PROCESSES STARTS ---------

                    // --- PREVENTS UPLOAD CANCELLED FLAG REMAINED TRUE FROM A PREVIOUS CANCEL  ---
                    uploadCancelled = false;
                    // --- CHECK THAT SELECTED ITEMS IS NOT EMPTY  ---
                    if (Provider.of<ProviderController>(context, listen: false)
                            .selectedItems
                            .length >
                        0) {
                      // --- SELECTED ITEMS BECOMES '_LIST' ---
                      _list = List.from(Provider.of<ProviderController>(context,
                              listen: false)
                          .selectedItems);
                      // --- SWITCH UI TO UPLOADING VIEW ---
                      Provider.of<ProviderController>(context, listen: false)
                          .showUploadingProcess(true);
                      // --- UPLOAD START CALL ---
                      UploadService.instance
                          .uploadStart(
                              'start', _csrf, [_model], _cookie, _list.length)
                          .then((value) {
                        // --- CHECK DEVICE IS NOT OFFLINE ---
                        if (value == 'offline') {
                          SnackBarGlobal.buildSnackBar(context,
                              'You\'re offline. Check your connection.', 'red');
                          UploadService.instance.uiCancelReset(context);
                          _list.clear();
                          return;
                        }
                        // --- CHECK FOR SERVER ERROR ---
                        else if (value == 'error') {
                          SnackBarGlobal.buildSnackBar(context,
                              'Something is wrong on our side. Sorry.', 'red');
                          return;
                        }
                        // --- CALL UPLOAD ISOLATE ---
                        else {
                          _id = int.parse(value);
                          // print('id is $_id');
                          // LOCALLY SAVE ID IN CASE UPLOAD IS KILLED
                          SharedPreferencesService.instance
                              .setIntegerValue('uploadID', int.parse(value));
                          _tags = ['"' + _model + '"'];
                          uploadHandler(_list);
                        }
                        // --- SNACK BAR (Background upload for Android as of now) ---
                        if (Platform.isAndroid) {
                          WhiteSnackBar.buildSnackBar(context,
                              'Your files will keep uploading as long as ac;pic is running in the background.');
                        } else {
                          WhiteSnackBar.buildSnackBar(context,
                              'Please don\'t send ac;pic to background, your upload will stop. We\'re working on iOS background upload.');
                        }
                      });
                    }
                  },
                  child: Text(
                    'Upload',
                  ),
                ),
                replacement: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: kAltoGrey,
                    minimumSize: Size(40, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    textStyle: kButtonText,
                  ),
                  onPressed: () {
                    //----- CANCEL UPLOAD PROCESS -----
                    uploadCancelled = true;
                    UploadService.instance.uiCancelReset(context);
                    SnackBarGlobal.buildSnackBar(
                        context, 'Cancelling your upload...', 'yellow');
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
//TODO 3: Background upload iOS.
//TODO 4: Implement hash engine.
//TODO 5: After app crash, implement upload from where it left off
//TODO 6: (Mono) when the upload is finished or cancelled (but pivs where uploaded) send email to user
