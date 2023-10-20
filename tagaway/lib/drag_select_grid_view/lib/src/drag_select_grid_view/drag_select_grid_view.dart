// Copyright (c) 2019 Simon Lightfoot
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart' hide SelectionChangedCallback;

import '../auto_scroll/auto_scroller_mixin.dart';
import '../drag_select_grid_view/selectable.dart';
import 'drag_select_grid_view_controller.dart';
import 'selection.dart';

/// Function signature for creating widgets based on the index and whether
/// it is selected or not.
typedef SelectableWidgetBuilder = Widget Function(
  BuildContext context,
  int index,
  bool selected,
);

/// Grid that supports both dragging and tapping to select its items.
///
/// By default, a long-press enables selection. The user may select/unselect any
/// item by tapping on it. Dragging allows cascade select/unselect. The flag
/// [triggerSelectionOnTap] allows selection to be enabled by tapping.
///
/// Through auto-scroll, this widget adds the ability to select items that go
/// beyond screen bounds without having to stop the drag. To do so, this widget
/// creates two imaginary zones that, if reached by the pointer while dragging,
/// triggers the auto-scroll.
///
/// The first zone is at the top, and triggers backward auto-scrolling.
/// The second is at the bottom, and triggers forward auto-scrolling.
class DragSelectGridView extends StatefulWidget {
  /// Default height of the hotspot that enables auto-scroll.
  static const defaultAutoScrollHotspotHeight = 64.0;

  /// Creates a grid that supports both dragging and tapping to select its
  /// items.
  ///
  /// It is possible to customize the height of the hotspot that enables
  /// auto-scroll by specifying [autoScrollHotspotHeight].
  ///
  /// The [gridController] provides information that can be used to update the
  /// UI to indicate whether there are selected items and how many are selected,
  /// besides allowing to directly update the selected items.
  ///
  /// By leaving [unselectOnWillPop] false, the items won't get unselected when
  /// the user tries to pop the route.
  ///
  /// The [itemBuilder] must be used to create widgets based on the index and
  /// whether they are selected or not.
  ///
  /// For information about the clause of the other parameters, refer to
  /// [GridView.builder].
  DragSelectGridView({
    Key? key,
    double? autoScrollHotspotHeight,
    ScrollController? scrollController,
    this.gridController,
    this.triggerSelectionOnTap = false,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    required this.gridDelegate,
    required this.itemBuilder,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.impliesAppBarDismissal = true,
  })  : autoScrollHotspotHeight =
            autoScrollHotspotHeight ?? defaultAutoScrollHotspotHeight,
        scrollController = scrollController ?? ScrollController(),
        super(key: key);

  /// The height of the hotspot that enables auto-scroll.
  ///
  /// This value is used for both top and bottom hotspots. The width is going to
  /// match the width of the widget.
  ///
  /// Defaults to [defaultAutoScrollHotspotHeight].
  final double autoScrollHotspotHeight;

  /// Refer to [ScrollView.controller].
  final ScrollController scrollController;

  /// Controller of the grid.
  ///
  /// Provides information that can be used to update the UI to indicate whether
  /// there are selected items and how many are selected.
  ///
  /// Also allows to directly update the selected items.
  ///
  /// This controller may not be used after [DragSelectGridViewState] disposes,
  /// since [DragSelectGridViewController.dispose] will get called and the
  /// listeners are going to be cleaned up.
  final DragSelectGridViewController? gridController;

  /// Whether should start selection by tapping instead of long-pressing.
  ///
  /// Defaults to false.
  final bool triggerSelectionOnTap;

  /// Refer to [ScrollView.reverse].
  final bool reverse;

  /// Refer to [ScrollView.primary].
  final bool? primary;

  /// Refer to [ScrollView.physics].
  final ScrollPhysics? physics;

  /// Refer to [ScrollView.shrinkWrap].
  final bool shrinkWrap;

  /// Refer to [BoxScrollView.padding].
  final EdgeInsetsGeometry? padding;

  /// Refer to [GridView.gridDelegate].
  final SliverGridDelegate gridDelegate;

  /// Called whenever a child needs to be built.
  ///
  /// The client should use this to build the children dynamically, based on
  /// the index and whether it is selected or not.
  ///
  /// Also refer to [SliverChildBuilderDelegate.builder].
  final SelectableWidgetBuilder itemBuilder;

  /// Refer to [SliverChildBuilderDelegate.childCount].
  final int? itemCount;

  /// Refer to [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Refer to [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Refer to [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Refer to [ScrollView.cacheExtent].
  final double? cacheExtent;

  /// Refer to [ScrollView.semanticChildCount].
  final int? semanticChildCount;

  /// Refer to [ScrollView.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// Refer to [ScrollView.keyboardDismissBehavior].
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Refer to [ScrollView.restorationId].
  final String? restorationId;

  /// Refer to [ScrollView.clipBehavior].
  final Clip clipBehavior;

  /// Refer to [LocalHistoryEntry.impliesAppBarDismissal].
  final bool impliesAppBarDismissal;

  @override
  DragSelectGridViewState createState() => DragSelectGridViewState();
}

/// The state for a grid that supports both dragging and tapping to select its
/// items.
@visibleForTesting
class DragSelectGridViewState extends State<DragSelectGridView>
    with AutoScrollerMixin<DragSelectGridView> {
  final _elements = <SelectableElement>{};
  final _selectionManager = SelectionManager();
  LongPressMoveUpdateDetails? _lastMoveUpdateDetails;
  LocalHistoryEntry? _historyEntry;

  DragSelectGridViewController? get _gridController => widget.gridController;

  /// Indexes selected by dragging or tapping.
  Set<int> get selectedIndexes => _selectionManager.selectedIndexes;

  /// Whether any item got selected.
  bool get isSelecting => selectedIndexes.isNotEmpty;

  /// Whether drag gesture is being performed.
  bool get isDragging =>
      (_selectionManager.dragStartIndex != -1) &&
      (_selectionManager.dragEndIndex != -1);

  @override
  double get autoScrollHotspotHeight => widget.autoScrollHotspotHeight;

  @override
  ScrollController get scrollController => widget.scrollController;

  @override
  void handleScroll() {
    final details = _lastMoveUpdateDetails;
    if (details != null) _handleLongPressMoveUpdate(details);
  }

  @override
  void initState() {
    super.initState();
    final controller = _gridController;
    if (controller != null) {
      controller.addListener(_onSelectionChanged);
      _selectionManager.selectedIndexes = controller.value.selectedIndexes;
    }
  }

  @override
  void dispose() {
    _gridController?.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTapUp: _handleTapUp,
      onLongPressStart: _handleLongPressStart,
      onLongPressMoveUpdate: _handleLongPressMoveUpdate,
      onLongPressEnd: _handleLongPressEnd,
      behavior: HitTestBehavior.translucent,
      child: IgnorePointer(
        ignoring: isDragging,
        child: GridView.builder(
          controller: widget.scrollController,
          reverse: widget.reverse,
          primary: widget.primary,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          padding: widget.padding,
          gridDelegate: widget.gridDelegate,
          itemCount: widget.itemCount,
          addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
          addRepaintBoundaries: widget.addRepaintBoundaries,
          addSemanticIndexes: widget.addSemanticIndexes,
          cacheExtent: widget.cacheExtent,
          semanticChildCount: widget.semanticChildCount,
          dragStartBehavior: widget.dragStartBehavior,
          keyboardDismissBehavior: widget.keyboardDismissBehavior,
          restorationId: widget.restorationId,
          clipBehavior: widget.clipBehavior,
          itemBuilder: (context, index) {
            return IgnorePointer(
              ignoring: isSelecting || widget.triggerSelectionOnTap,
              child: Selectable(
                index: index,
                onMountElement: _elements.add,
                onUnmountElement: _elements.remove,
                child: widget.itemBuilder(
                  context,
                  index,
                  selectedIndexes.contains(index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onSelectionChanged() {
    final controller = _gridController;
    if (controller != null) {
      final controllerSelectedIndexes = controller.value.selectedIndexes;
      if (!setEquals(controllerSelectedIndexes, selectedIndexes)) {
        _selectionManager.selectedIndexes = controllerSelectedIndexes;
        _updateLocalHistory();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (isSelecting || widget.triggerSelectionOnTap) {
      final tapIndex = _findIndexOfSelectable(details.localPosition);

      if (tapIndex != -1) {
        // MONKEY PATCHED
        // setState(() => _selectionManager.tap(tapIndex));
        _notifySelectionChange();
        _updateLocalHistory();
      }
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    final pressIndex = _findIndexOfSelectable(details.localPosition);

    if (pressIndex != -1) {
      // MONKEY PATCHED
      // setState(() => _selectionManager.startDrag(pressIndex));
      _notifySelectionChange();
      _updateLocalHistory();
    }
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!isDragging) return;

    _lastMoveUpdateDetails = details;
    final dragIndex = _findIndexOfSelectable(details.localPosition);

    if ((dragIndex != -1) && (dragIndex != _selectionManager.dragEndIndex)) {
      // MONKEY PATCHED
      // setState(() => _selectionManager.updateDrag(dragIndex));
      _notifySelectionChange();
    }

    if (isInsideUpperAutoScrollHotspot(details.localPosition)) {
      if (widget.reverse) {
        startAutoScrollingForward();
      } else {
        startAutoScrollingBackward();
      }
    } else if (isInsideLowerAutoScrollHotspot(details.localPosition)) {
      if (widget.reverse) {
        startAutoScrollingBackward();
      } else {
        startAutoScrollingForward();
      }
    } else {
      stopScrolling();
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    // MONKEY PATCHED
    // setState(_selectionManager.endDrag);
    stopScrolling();
  }

  void _updateLocalHistory() {
    final route = ModalRoute.of(context);
    if (route == null) return;

    if (isSelecting) {
      if (_historyEntry == null) {
        final entry = LocalHistoryEntry(
          impliesAppBarDismissal: widget.impliesAppBarDismissal,
          onRemove: () {
            // MONKEY PATCHED
            // setState(_selectionManager.clear);
            _notifySelectionChange();
            _historyEntry = null;
          },
        );
        route.addLocalHistoryEntry(entry);
        _historyEntry = entry;
      }
    } else {
      final entry = _historyEntry;
      if (entry != null) {
        route.removeLocalHistoryEntry(entry);
        _historyEntry = null;
      }
    }
  }

  int _findIndexOfSelectable(Offset offset) {
    final ancestor = context.findRenderObject();
    var elementFinder = Set.of(_elements).firstWhereOrNull;

    // Conceptually, `Set.singleWhere()` is the safer option, however we're
    // avoiding to iterate over the whole `Set` to improve the performance.
    assert(() {
      elementFinder = Set.of(_elements).singleWhereOrNull;
      return true;
    }());

    final element = elementFinder(
      (element) => element.containsOffset(ancestor, offset),
    );

    return (element == null) ? -1 : element.widget.index;
  }

  void _notifySelectionChange() {
    _gridController?.value = Selection(_selectionManager.selectedIndexes);
  }
}
