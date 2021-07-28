library dropdown_below;

import 'dart:math' as math;

import 'package:flutter/material.dart';

const Duration _kDropdownMenuDuration = Duration(milliseconds: 300);

/// *[_kDropdownMenuDuration] which is dropdown button's drop down duration.

const double _kMenuItemHeight = 48.0;

/// *[_kMenuItemHeight] which is dropdown item's default height

const EdgeInsets _kMenuItemPadding = EdgeInsets.symmetric(horizontal: 16.0);

/// *[_kMenuItemPadding] which is dropdown item's default padding.

const EdgeInsets _kAlignedMenuMargin = EdgeInsets.zero;

/// *[_kAlignedMenuMargin] which is dropdown item's default margin

const EdgeInsetsGeometry _kUnalignedMenuMargin =
    EdgeInsetsDirectional.only(start: 16.0, end: 24.0);

/// *[_kAlignedMenuMargin] which is dropdown item's default margin for align rule.

class _DropdownMenuPainter extends CustomPainter {
  _DropdownMenuPainter({
    this.color,
    this.elevation,
    this.selectedIndex,
    this.resize,
  })  : _painter = BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: kElevationToShadow[elevation!])
            .createBoxPainter(),
        super(repaint: resize);

  final Color? color;

  /// *[color] which is dropdown item's background color

  final int? elevation;

  /// *[elevation] which is dropdown whole item list's elevation

  final int? selectedIndex;

  /// *[selectedIndex] which is selected item's index

  final Animation<double>? resize;

  /// *[resize] which is resized animation value

  final BoxPainter _painter;

  /// *[_painter] which is panting value

  @override
  void paint(Canvas canvas, Size size) {
    final double selectedItemOffset =
        selectedIndex! * _kMenuItemHeight + kMaterialListPadding.top;
    final Tween<double> top = Tween<double>(
      begin: selectedItemOffset.clamp(0.0, size.height - _kMenuItemHeight),
      end: 0.0,
    );

    final Tween<double> bottom = Tween<double>(
      begin:
          (top.begin! + _kMenuItemHeight).clamp(_kMenuItemHeight, size.height),
      end: size.height,
    );

    final Rect rect = Rect.fromLTRB(
        0.0, top.evaluate(resize!), size.width, bottom.evaluate(resize!));

    _painter.paint(canvas, rect.topLeft, ImageConfiguration(size: rect.size));
  }

  @override
  bool shouldRepaint(_DropdownMenuPainter oldPainter) {
    return oldPainter.color != color ||
        oldPainter.elevation != elevation ||
        oldPainter.selectedIndex != selectedIndex ||
        oldPainter.resize != resize;
  }
}

class _DropdownScrollBehavior extends ScrollBehavior {
  const _DropdownScrollBehavior();

  @override
  TargetPlatform getPlatform(BuildContext context) =>
      Theme.of(context).platform;

  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

class _DropdownMenu<T> extends StatefulWidget {
  const _DropdownMenu({
    Key? key,
    this.padding,
    this.route,
  }) : super(key: key);

  final _DropdownRoute<T>? route;

  final EdgeInsets? padding;

  @override
  _DropdownMenuState<T> createState() => _DropdownMenuState<T>();
}

class _DropdownMenuState<T> extends State<_DropdownMenu<T>> {
  late CurvedAnimation _fadeOpacity;
  CurvedAnimation? _resize;

  @override
  void initState() {
    super.initState();
    _fadeOpacity = CurvedAnimation(
      parent: widget.route!.animation!,
      curve: Interval(0.0, 0.25),
      reverseCurve: Interval(0.75, 1.0),
    );
    _resize = CurvedAnimation(
      parent: widget.route!.animation!,
      curve: Interval(0.25, 0.5),
      reverseCurve: Threshold(0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final _DropdownRoute<T> route = widget.route!;
    final double unit = 0.5 / (route.items!.length + 1.5);
    final List<Widget> children = <Widget>[];
    for (int itemIndex = 0; itemIndex < route.items!.length; ++itemIndex) {
      CurvedAnimation opacity;
      if (itemIndex == route.selectedIndex) {
        opacity =
            CurvedAnimation(parent: route.animation!, curve: Threshold(0.0));
      } else {
        final double start = (0.5 + (itemIndex + 1) * unit).clamp(0.0, 1.0);
        final double end = (start + 1.5 * unit).clamp(0.0, 1.0);
        opacity = CurvedAnimation(
            parent: route.animation!, curve: Interval(start, end));
      }
      children.add(FadeTransition(
        opacity: opacity,
        child: InkWell(
          child: Container(
            padding: widget.padding,
            child: route.items![itemIndex],
          ),
          onTap: () => Navigator.pop(
            context,
            _DropdownRouteResult<T?>(route.items![itemIndex].value),
          ),
        ),
      ));
    }

    return FadeTransition(
      opacity: _fadeOpacity,
      child: CustomPaint(
        painter: _DropdownMenuPainter(
          color: Colors.white,
          elevation: 2,
          selectedIndex: route.selectedIndex,
          resize: _resize,
        ),
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: localizations.popupMenuLabel,
          child: Material(
            type: MaterialType.transparency,
            textStyle: route.style,
            child: ScrollConfiguration(
              behavior: _DropdownScrollBehavior(),
              child: Scrollbar(
                child: ListView(
                  controller: widget.route!.scrollController,
                  padding: kMaterialListPadding,
                  itemExtent: _kMenuItemHeight,
                  shrinkWrap: true,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownMenuRouteLayout<T> extends SingleChildLayoutDelegate {
  _DropdownMenuRouteLayout({
    required this.buttonRect,
    required this.menuTop,
    required this.menuHeight,
    required this.textDirection,
    required this.itemWidth,
  });

  final double? itemWidth;

  /// dropdown button's each item's width

  final Rect? buttonRect;

  /// dropdown button's whole list rect.

  final double menuTop;
  final double menuHeight;
  final TextDirection textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double maxHeight =
        math.max(0.0, constraints.maxHeight - 2 * _kMenuItemHeight);
    return new BoxConstraints(
      minWidth: itemWidth!,
      maxWidth: itemWidth!,
      minHeight: 0.0,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    assert(() {
      final Rect container = Offset.zero & size;
      if (container.intersect(buttonRect!) == buttonRect) {
        assert(menuTop >= 0.0);
        assert(menuTop + menuHeight <= size.height);
      }
      return true;
    }());
    late double left;
    switch (textDirection) {
      case TextDirection.rtl:
        left = buttonRect!.right.clamp(0.0, size.width) - childSize.width;
        break;
      case TextDirection.ltr:
        left = buttonRect!.left.clamp(0.0, size.width - childSize.width);
        break;
    }
    return new Offset(left + 15, menuTop + 13);
  }

  @override
  bool shouldRelayout(_DropdownMenuRouteLayout<T> oldDelegate) {
    return buttonRect != oldDelegate.buttonRect ||
        menuTop != oldDelegate.menuTop ||
        menuHeight != oldDelegate.menuHeight ||
        textDirection != oldDelegate.textDirection;
  }
}

class _DropdownRouteResult<T> {
  const _DropdownRouteResult(this.result);

  final T result;

  @override
  bool operator ==(dynamic other) {
    if (other is! _DropdownRouteResult<T>) return false;
    final _DropdownRouteResult<T> typedOther = other;
    return result == typedOther.result;
  }

  @override
  int get hashCode => result.hashCode;
}

class _DropdownRoute<T> extends PopupRoute<_DropdownRouteResult<T>> {
  _DropdownRoute({
    this.items,
    this.itemWidth,
    this.padding,
    this.buttonRect,
    this.selectedIndex,
    this.elevation = 8,
    required this.style,
    this.barrierLabel,
  });

  final List<DropdownMenuItem<T>>? items;

  /// item's list

  final EdgeInsetsGeometry? padding;

  final Rect? buttonRect;

  /// buttons rectangle

  final int? selectedIndex;

  /// selected Index

  final int elevation;

  final TextStyle style;

  ScrollController? scrollController;

  @override
  Duration get transitionDuration => _kDropdownMenuDuration;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  final String? barrierLabel;

  final double? itemWidth;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    assert(debugCheckHasDirectionality(context));
    final double screenHeight = MediaQuery.of(context).size.height;
    final double maxMenuHeight = screenHeight - 2.0 * _kMenuItemHeight;
    final double preferredMenuHeight =
        (items!.length * _kMenuItemHeight) + kMaterialListPadding.vertical;
    final double menuHeight = math.min(maxMenuHeight, preferredMenuHeight);

    final double buttonTop = buttonRect!.top;
    final double selectedItemOffset =
        selectedIndex! * _kMenuItemHeight + kMaterialListPadding.top;
    double menuTop = (buttonTop - selectedItemOffset) -
        (_kMenuItemHeight - buttonRect!.height) / 2.0;
    const double topPreferredLimit = _kMenuItemHeight;
    if (menuTop < topPreferredLimit)
      menuTop = math.min(buttonTop, topPreferredLimit);
    double bottom = menuTop + menuHeight;
    final double bottomPreferredLimit = screenHeight - _kMenuItemHeight;
    if (bottom > bottomPreferredLimit) {
      bottom = math.max(buttonTop + _kMenuItemHeight, bottomPreferredLimit);
      menuTop = bottom - menuHeight;
    }

    if (scrollController == null) {
      double scrollOffset = 0.0;
      if (preferredMenuHeight > maxMenuHeight)
        scrollOffset = selectedItemOffset - (buttonTop - menuTop);
      scrollController =
          new ScrollController(initialScrollOffset: scrollOffset);
    }

    final TextDirection textDirection = Directionality.of(context);
    Widget menu = _DropdownMenu<T>(
      route: this,
      padding: padding!.resolve(textDirection),
    );

    return new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
            delegate: _DropdownMenuRouteLayout<T>(
              itemWidth: itemWidth,
              buttonRect: buttonRect,
              menuTop: menuTop,
              menuHeight: menuHeight,
              textDirection: textDirection,
            ),
            child: menu,
          );
        },
      ),
    );
  }

  void _dismiss() {
    navigator?.removeRoute(this);
  }
}

class DropdownBelow<T> extends StatefulWidget {
  DropdownBelow(
      {Key? key,
      required this.items,
      this.value,
      this.hint,
      this.itemTextstyle,
      this.itemWidth,
      this.boxHeight,
      this.boxWidth,
      this.boxPadding,
      this.boxTextstyle,
      required this.onChanged,
      this.boxDecoration,
      this.elevation = 8,
      this.isDense = false,
      this.icon})
      : assert(value == null ||
            items
                    .where((DropdownMenuItem<T> item) => item.value == value)
                    .length ==
                1),
        super(key: key);

  final List<DropdownMenuItem<T>> items;

  /// item list

  final T? value;

  /// printed value

  final double? itemWidth;

  /// each item width

  final double? boxHeight;

  /// whole box height

  final double? boxWidth;

  /// whole box width

  final EdgeInsetsGeometry? boxPadding;

  /// default box padding

  final TextStyle? boxTextstyle;

  /// default box text style

  final TextStyle? itemTextstyle;

  /// default each item's text style

  final Widget? hint;

  /// default value that printed which has no touch to dropdown widget.

  final ValueChanged<T> onChanged;

  /// click item then, function triggered

  final BoxDecoration? boxDecoration;

  /// box decoration like border, borderRadius, color

  final int elevation;

  final Widget? icon;

  final bool isDense;

  @override
  _DropdownBelowState<T> createState() => new _DropdownBelowState<T>();
}

class _DropdownBelowState<T> extends State<DropdownBelow<T>>
    with WidgetsBindingObserver {
  int? _selectedIndex;
  _DropdownRoute<T>? _dropdownRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _removeDropdownRoute();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _removeDropdownRoute();
  }

  void _removeDropdownRoute() {
    _dropdownRoute?._dismiss();
    _dropdownRoute = null;
  }

  @override
  void didUpdateWidget(DropdownBelow<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    assert(widget.value == null ||
        widget.items
                .where((DropdownMenuItem<T> item) => item.value == widget.value)
                .length ==
            1);
    _selectedIndex = null;
    for (int itemIndex = 0; itemIndex < widget.items.length; itemIndex++) {
      if (widget.items[itemIndex].value == widget.value) {
        _selectedIndex = itemIndex;
        return;
      }
    }
  }

  void _handleTap() {
    final RenderBox itemBox = context.findRenderObject() as RenderBox;
    final Rect itemRect = itemBox.localToGlobal(Offset.zero) & itemBox.size;
    final TextDirection textDirection = Directionality.of(context);
    final EdgeInsetsGeometry menuMargin =
        ButtonTheme.of(context).alignedDropdown
            ? _kAlignedMenuMargin
            : _kUnalignedMenuMargin;

    assert(_dropdownRoute == null);
    _dropdownRoute = new _DropdownRoute<T>(
      itemWidth: widget.itemWidth,
      items: widget.items,
      buttonRect: menuMargin.resolve(textDirection).inflateRect(itemRect),
      padding: _kMenuItemPadding.resolve(textDirection),
      selectedIndex: -1,
      elevation: widget.elevation,
      style: widget.itemTextstyle ?? TextStyle(),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    );

    Navigator.push(context, _dropdownRoute!)
        .then<void>((_DropdownRouteResult<T>? newValue) {
      _dropdownRoute = null;
      if (!mounted || newValue == null) return;
      if (widget.onChanged != null) widget.onChanged(newValue.result);
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));

    final List<Widget> items = List<Widget>.from(widget.items);
    int? hintIndex;
    if (widget.hint != null) {
      hintIndex = items.length;
      items.add(DefaultTextStyle(
        style: widget.boxTextstyle!,
        child: IgnorePointer(
          child: widget.hint,
          ignoringSemantics: false,
        ),
      ));
    }

    Widget result = new DefaultTextStyle(
      style: widget.boxTextstyle!,
      child: new Container(
        decoration: widget.boxDecoration,
        width: widget.boxWidth,
        padding: widget.boxPadding,
        height: widget.boxHeight,
        child: widget.icon == null
            ? IndexedStack(
                index: _selectedIndex ?? hintIndex,
                alignment: AlignmentDirectional.centerStart,
                children: items,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex ?? hintIndex,
                      alignment: AlignmentDirectional.centerStart,
                      children: items,
                    ),
                  ),
                  widget.icon ?? Container()
                ],
              ),
      ),
    );

    if (!DropdownButtonHideUnderline.at(context)) {
      result = Stack(
        children: <Widget>[
          result,
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0,
            child: Container(
              height: 0.0,
            ),
          ),
        ],
      );
    }

    return new Semantics(
      button: true,
      child: GestureDetector(
          onTap: _handleTap, behavior: HitTestBehavior.opaque, child: result),
    );
  }
}
