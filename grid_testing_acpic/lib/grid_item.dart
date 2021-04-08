import 'package:flutter/material.dart';
import 'grid.dart';

class GridItem extends StatefulWidget {
  final Key key;
  final Item item;
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

  //TODO: BUG: if 'Select all" button is clicked and then individual items are clicked, those items are added to the selectedList
  // (making selectedList.length > itemList.length which is incorrect). Also, when deselecting all,
  // the items that were individually selected do not get deselected with the other items

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                image: AssetImage(widget.item.imgUrl),
              ),
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

//when selectAll is turned to true, isSelected must be turned to true. When an item is clicked, isSelected is
// turned to false and the normal 'false' should occur for that item.
// Probably this time there's no way to avoid a Stream. Also, take a look at the async package, since you
// might have to merge 2 streams together (selectAllItems() and deselectAllItems() ).
