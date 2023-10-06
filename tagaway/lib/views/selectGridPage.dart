import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/ui_elements/constants.dart';

class SelectGridPage extends StatefulWidget {
  @override
  _SelectGridPageState createState() => _SelectGridPageState();
}

class _SelectGridPageState extends State<SelectGridPage> {
  final GlobalKey gridPositionKey = GlobalKey ();
  final ScrollController scrollController = ScrollController();

  List<AssetEntity> itemList = [];
  bool isSelected = false;
  RenderBox getBox() => context.findRenderObject() as RenderBox;

  @override
  void initState() {
    super.initState();
    PhotoManager.requestPermissionExtend();
    loadLocalPivs();
  }

  loadLocalPivs() async {
    FilterOptionGroup makeOption() {
      return FilterOptionGroup()
        ..addOrderOption(
            const OrderOption(type: OrderOptionType.createDate, asc: false));
    }

    final option = makeOption();

    final albums = await PhotoManager.getAssetPathList(
        onlyAll: true, filterOption: option);
    final recentAlbum = albums.first;

    var localPivs = await recentAlbum.getAssetListRange(
      start: 0, // start at index 0
      end: 5, // end at a very big index (to get all the assets)
    );
    localPivs =
        List.generate(4, (int index) => localPivs).expand((x) => x).toList();

    setState(() {
      itemList = localPivs;
    });
  }

  dynamic lastDraggedPivIndex;
  dynamic selection = {};
  dynamic selecting;

  int getIndex (dynamic details) {
    final RenderBox? box = gridPositionKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || gridPositionKey.currentContext == null) return -1;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final gridSize = box.size;

    // We need to invert our local position because the grid is shown in inverted order
    var invertedLocalPosition = [gridSize.width - localPosition.dx, gridSize.height - localPosition.dy];
    // Add up the scroll offset
    invertedLocalPosition [1] += scrollController.offset;
    // There seems to be an extra Y offset that we need to substract.
    invertedLocalPosition [1] -= 33;
    //debug (['INVERTED LOCAL POSITION', invertedLocalPosition]);

    // localPosition now contains the coordinates of the gesture relative to this grid item.
    // Do what you want with the coordinates.

    int crossAxisCount = 3; // This is your grid cross axis count
    double childWidth = getBox().size.width / crossAxisCount;
    double childHeight = childWidth; // This assumes square children

    int rowIndex = (invertedLocalPosition [1] / childHeight).floor();
    int columnIndex = (invertedLocalPosition [0] / childWidth).floor();

    int index = rowIndex * crossAxisCount + columnIndex;
    return index;
  }

  void onPanDown(DragDownDetails details) {
    var index = getIndex (details).toString ();
    if (selection [index] == null || selection [index] == false) selection [index] = true;
    else selection [index] = null;
    selecting = selection [index];
    onPanUpdate(DragUpdateDetails(
        globalPosition: details.globalPosition, delta: Offset.zero));
  }

  void onPanEnd(DragEndDetails details) {
    lastDraggedPivIndex = null;
  }

  void onPanUpdate(DragUpdateDetails details) {
     var index = getIndex (details);
    if (index != lastDraggedPivIndex) {
      selection [index] = selecting;
      lastDraggedPivIndex = index;
      debug (['selection', selection]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('this is a test'),
      ),
      body: SizedBox.expand(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: GestureDetector(
            key: gridPositionKey,
            onPanDown: (details) => onPanDown(details),
            onPanEnd: (details) => onPanEnd(details),
            onPanUpdate: (details) => onPanUpdate(details),
            child: GridView.builder(
                      controller: scrollController,
                      reverse: true,
                      addAutomaticKeepAlives: true,
                      cacheExtent: 50,
                      shrinkWrap: true,
                      itemCount: itemList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                      ),
                      itemBuilder: (context, index) {
                        return Thumbnail(
                          asset: itemList[index],
                          isSelected: isSelected,
                        );
                      }),
          ),
        ),
      ),
    );
  }
}

class Thumbnail extends StatelessWidget {
  final AssetEntity asset;
  final bool isSelected;
  const Thumbnail({Key? key, required this.asset, required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize.square(400)),
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const CircularProgressIndicator();
        }
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: MemoryImage(bytes),
                ),
              ),
            ),
            // SelectableItemWidget(
            //   isSelected: isSelected,
            //   key: Key(asset.id),
            // ),
          ],
        );
      },
    );
  }
}

class SelectableItemWidget extends StatefulWidget {
  final bool isSelected;

  const SelectableItemWidget({
    Key? key,
    required this.isSelected,
  }) : super(key: key);

  @override
  _SelectableItemWidgetState createState() => _SelectableItemWidgetState();
}

class _SelectableItemWidgetState extends State<SelectableItemWidget> {
  @override
  Widget build(BuildContext context) => Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: widget.isSelected ? Colors.purple : Colors.transparent,
        // borderRadius: BorderRadius.circular(10),
      ));
}
