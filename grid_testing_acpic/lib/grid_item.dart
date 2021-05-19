import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import 'grid.dart';

class GridItem extends StatelessWidget {
  final Key key;
  final AssetEntity item;
  final ValueChanged<bool> isSelected;
  final bool all;
  final ValueChanged<bool> onChanged;

  GridItem({this.key, this.item, this.isSelected, this.all, this.onChanged});

  String parseVideoDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: item.thumbData,
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null)
          return CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5b6eff)),
          );
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: MemoryImage(bytes),
                ),
              ),
            ),
            item.type == AssetType.video
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0, bottom: 5),
                      child: Text(
                        parseVideoDuration(Duration(seconds: item.duration)),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  )
                : Container(),
            SelectedAsset(),
          ],
        );
      },
    );
  }
}

class SelectedAsset extends StatefulWidget {
  // final ValueChanged<bool> isSelected;
  // final bool all;
  // final ValueChanged<bool> onChanged;
  //
  // SelectedAsset({this.isSelected, this.all, this.onChanged});

  @override
  _SelectedAssetState createState() => _SelectedAssetState();
}

class _SelectedAssetState extends State<SelectedAsset> {
  bool isSelected = false;

  @override
  void initState() {
    // widget.all ? isSelected = true : false;
    super.initState();
  }

  void selectItem() {
    setState(() {
      isSelected = !isSelected;
      // widget.isSelected(isSelected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        selectItem();
      },
      child: Stack(
        children: [
          Expanded(
            child: Container(
              color: isSelected
                  ? Color(0xFF5b6eff).withOpacity(.3)
                  : Colors.transparent,
            ),
          ),
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
  }
}

//
// class GridItem extends StatefulWidget {
//   final Key key;
//   final AssetEntity item;
//   final ValueChanged<bool> isSelected;
//   final bool all;
//   final ValueChanged<bool> onChanged;
//
//   GridItem({this.key, this.item, this.isSelected, this.all, this.onChanged});
//
//   @override
//   _GridItemState createState() => _GridItemState();
// }
//
// class _GridItemState extends State<GridItem>
//     with AutomaticKeepAliveClientMixin {
//   bool isSelected = false;
//
//   // @override
//   // void initState() {
//   //   widget.all ? isSelected = true : false;
//   //   super.initState();
//   // }
//   //
//   // void selectItem() {
//   //   setState(() {
//   //     isSelected = !isSelected;
//   //     widget.isSelected(isSelected);
//   //   });
//   // }
//
//   String parseVideoDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return FutureBuilder<Uint8List>(
//       future: widget.item.thumbData,
//       builder: (_, snapshot) {
//         final bytes = snapshot.data;
//         if (bytes == null)
//           return CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5b6eff)),
//           );
//         return Stack(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 image: DecorationImage(
//                   fit: BoxFit.cover,
//                   image: MemoryImage(bytes),
//                 ),
//               ),
//             ),
//             widget.item.type == AssetType.video
//                 ? Align(
//                     alignment: Alignment.bottomRight,
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 5.0, bottom: 5),
//                       child: Text(
//                         parseVideoDuration(
//                             Duration(seconds: widget.item.duration)),
//                         style: TextStyle(color: Colors.white, fontSize: 14),
//                       ),
//                     ),
//                   )
//                 : Container(),
//             SelectedAsset(),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   bool get wantKeepAlive => true;
// }
