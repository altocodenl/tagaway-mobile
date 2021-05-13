import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import 'grid.dart';


class GridItem extends StatefulWidget {
  final Key key;
  final AssetEntity item;
  final ValueChanged<bool> isSelected;
  final bool isSelectViewVisible;
  final bool isUploadViewVisible;
  final bool all;
  final ValueChanged<bool> onChanged;


  GridItem({
    this.key,
    this.item,
    this.isSelected,
    this.isSelectViewVisible,
    this.isUploadViewVisible,
    this.all,
    this.onChanged
  });

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem>
    with AutomaticKeepAliveClientMixin {
  bool isSelected = false;

  @override
  void initState(){
    widget.all ? isSelected = true : false;
    super.initState();
  }

  void selectItem() {
    setState(() {
      isSelected = !isSelected;
      widget.isSelected(isSelected);
    });
  }

  String parseVideoDuration (Duration duration){
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<Uint8List> (
      future: widget.item.thumbData,
      builder: (_, snapshot){
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return CircularProgressIndicator(valueColor:AlwaysStoppedAnimation<Color>(Color(0xFF5b6eff)),);
        // If there's data, display it as an image
        return GestureDetector(
          // if isSelectViewVisible == false && isUploadViewVisible = true then you can select items. If not, you can't.
          // Probably streaming the state of the bool's is the best option, since that way I can manipulate how the GridItem behaves.
          onTap: () {
            isSelectViewVisible == false && isUploadingInProcess == true
                ? selectItem()
                : null;
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF8b8b8b),
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Color(0xFF5b6eff).withOpacity(isSelected ? .2 : 0),
                        BlendMode.srcOver),
                    image: MemoryImage(bytes),
                  ),
                ),
              ),
              widget.item.type == AssetType.video ? Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 5.0, bottom: 5),
                  child: Text(parseVideoDuration(Duration(seconds: widget.item.duration)),
                    style: TextStyle(color: Colors.white, fontSize: 14),),
                ),
              ) : Container(),
              isSelected
                  ? Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.circle,
                  size: 25,
                  color: Color(0xFF5b6eff),
                ),
              )
                  : Container(),
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
