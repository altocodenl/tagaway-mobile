import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tagaway/ui_elements/constants.dart';
import 'package:tagaway/services/uploadService.dart';
import 'package:tagaway/services/storeService.dart';
import 'package:tagaway/services/tagService.dart';

class LocalGridItem extends StatelessWidget {
  final AssetEntity asset;
  const LocalGridItem(this.asset);

  // String parseVideoDuration(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, "0");
  //   String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  //   return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize.square(1000)),
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kAltoBlue),
          );
        }
        return GestureDetector(
            onTap: () {
              var currentlyTagging = StoreService.instance.get ('currentlyTagging');
              if (currentlyTagging == '') StoreService.instance.set ('startTaggingModal', true, true);
              else                        TagService.instance.togglePiv (asset, currentlyTagging);
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: MemoryImage(bytes),
                    ),
                  ),
                ),
                asset.type == AssetType.video
                    ? const Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.0, bottom: 5),
                          child: Icon(
                            kVideoIcon,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      )
                    : Container(),
                Align(
                    alignment: const Alignment(0.9, -.9),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white, width: 2)),
                      child: LocalGridItemSelection (asset)
                    )),
              ],
            ));
      },
    );
  }
}

class LocalGridItemSelection extends StatefulWidget {
  final AssetEntity asset;
  const LocalGridItemSelection(this.asset);

  @override
  State<LocalGridItemSelection> createState() => _LocalGridItemSelectionState(this.asset);
}

class _LocalGridItemSelectionState extends State<LocalGridItemSelection> {
  dynamic cancelListener;
  final AssetEntity asset;
  bool selected = false;

  _LocalGridItemSelectionState(this.asset);

  @override
  void initState() {
    super.initState();
    cancelListener = StoreService.instance.listen (['pivMap:' + asset.id, 'tagMap:' + asset.id, 'currentlyTagging'], (v1, v2, v3) {
      setState(() {
        if (v3 == '') selected = v1 != '';
        else          selected = v2 != '';
      });
    });
  }

  @override
  void dispose () {
     super.dispose ();
     cancelListener ();
  }

  @override
  Widget build(BuildContext context) {
     return Icon(
       selected ? kCircleCheckIcon : kSolidCircleIcon,
       color: selected ? kAltoOrganized : kGreyDarker,
       size: 25,
     );
  }
}

//
// class SelectedAsset extends StatefulWidget {
//   final StreamController<int> selectedListLengthStreamController;
//   final ValueChanged<bool> isSelected;
//   final AssetEntity item;
//
//   SelectedAsset(
//       {this.isSelected, this.item, this.selectedListLengthStreamController});
//
//   @override
//   _SelectedAssetState createState() => _SelectedAssetState();
// }
//
// class _SelectedAssetState extends State<SelectedAsset>
//     with AutomaticKeepAliveClientMixin {
//   bool isSelected = false;
//
//   @override
//   void initState() {
//     // --- If 'all' is true, all items are selected ---
//     if (Provider.of<ProviderController>(context, listen: false).all == true) {
//       isSelected = true;
//     }
//     // IF UPLOAD WAS CANCELLED RESTATE THE SELECTED THUMBNAILS
//     SharedPreferencesService.instance
//         .getStringListValue('selectedListID')
//         .then((value) async {
//       if (value == null) {
//         return;
//       } else if (value.contains(widget.item.id)) {
//         setState(() {
//           isSelected = !isSelected;
//         });
//         Provider.of<ProviderController>(context, listen: false)
//             .selectionInProcess(true);
//         // NOW DENOMINATOR IS PROVIDED AT UPLOADHANDLER()
//         // widget.selectedListLengthStreamController.add(value.length);
//       }
//     });
//     super.initState();
//   }
//
//   void selectItem() {
//     setState(() {
//       isSelected = !isSelected;
//       widget.isSelected(isSelected);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return GestureDetector(
//       onTap: () {
//         if (Provider.of<ProviderController>(context, listen: false)
//             .isUploadingInProcess ==
//             false) {
//           selectItem();
//         }
//       },
//       onLongPress: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) {
//             if (widget.item.type == AssetType.image) {
//               return ImageBig(imageFile: widget.item.file);
//             } else {
//               return VideoBig(videoFile: widget.item.file);
//             }
//           }),
//         );
//       },
//       child: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color:
//               isSelected ? kAltoBlue.withOpacity(.3) : Colors.transparent,
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           isSelected
//               ? Align(
//             alignment: Alignment.topRight,
//             child: Icon(
//               Icons.circle,
//               size: 25,
//               color: kAltoBlue,
//             ),
//           )
//               : Container(),
//         ],
//       ),
//     );
//   }
//
//   @override
//   bool get wantKeepAlive => true;
// }
