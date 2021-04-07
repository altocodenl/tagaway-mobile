// IMPORT FLUTTER PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:core';
import 'dart:io' show Platform;
// IMPORT UI ELEMENTS
import 'package:acpic/ui_elements/cupertino_elements.dart';
import 'package:acpic/ui_elements/android_elements.dart';
import 'package:acpic/ui_elements/material_elements.dart';

//TODO: Make this view the default view until user logs out or revokes permission to access photos
//https://api.flutter.dev/flutter/widgets/Flexible-class.html
//https://api.flutter.dev/flutter/cupertino/CupertinoPageScaffold-class.html
//https://api.flutter.dev/flutter/cupertino/CupertinoScrollbar-class.html
//https://api.flutter.dev/flutter/widgets/OrientationBuilder-class.html

final List<Map> myPhotos = List.generate(
    1000, (index) => {"id": index, "name": index % 2 == 0 ? 1 : 2}).toList();

class Grid extends StatefulWidget {
  @override
  _GridState createState() => _GridState();
}

class _GridState extends State<Grid> {
  bool _isSelectVisible = true;
  bool _isUploadingVisible = true;
  bool _isUploadingInProcess = true;

  void showSelectView() {
    setState(() {
      _isSelectVisible = !_isSelectVisible;
    });
  }

  void showUploadingView() {
    setState(() {
      _isUploadingVisible = !_isUploadingVisible;
    });
  }

  void showUploadingProcess() {
    setState(() {
      _isUploadingInProcess = !_isUploadingInProcess;
    });
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
              child: GridView.builder(
                  //TODO: Make the image selection https://medium.com/flutterdevs/selecting-multiple-item-in-list-in-flutter-811a3049c56f
                  reverse: true,
                  shrinkWrap: true,
                  cacheExtent: 50,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  itemCount: myPhotos.length,
                  itemBuilder: (BuildContext context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('images/img_' +
                              myPhotos[index]['name'].toString() +
                              '.jpg'),
                        ),
                        color: Color(0xFF8b8b8b),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 10),
              child: Visibility(
                visible: _isUploadingInProcess,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Visibility(
                      visible: _isSelectVisible,
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
                      visible: _isSelectVisible,
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
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) => CupertinoLogOut(),
                                );
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
                    visible: !_isSelectVisible,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Visibility(
                          visible: _isUploadingVisible,
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
                              /**/
                            },
                            child: Row(
                              children: [
                                Stack(
                                  overflow: Overflow.visible,
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
                          visible: _isUploadingVisible,
                          child: Text(
                            '444,444 files selected',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          replacement: Text(
                            '1 / X files uploaded so far...',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _isUploadingVisible,
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
