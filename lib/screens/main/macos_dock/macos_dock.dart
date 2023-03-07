import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../models/notification.dart';
import '../../dailyreport/dailyreport.dart';
import '../../eders/livebroadcast/livebroadcastmain.dart';
import '../../eders/videochat/videochatmain.dart';
import '../../portfolio/eager_portfolio_main.dart';
import '../../rollcall/helper.dart';
import '../../stickers/stickerspage.dart';
import '../controller.dart';

part 'controller.dart';
part 'enums.dart';

const _kAnimationDuration = Duration(milliseconds: 150);

class SmallScreenDockItems extends GetView<MacOSDockController> {
  SmallScreenDockItems({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (controller.miniScreenItems.isEmpty) return Container();

    return GridView.count(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      childAspectRatio: 0.88,
      crossAxisSpacing: 16,
      children: [
        ...controller.miniScreenItems.map((e) {
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: e.dockItem.child),
                4.heightBox,
                SizedBox(height: 30, child: e.dockItem.name.text.center.maxLines(2).autoSize.make()),
              ],
            ),
            onTap: () {
              controller.miniScreenOnTap(e);
            },
          );
        }).toList()
      ],
    );
  }
}

class MacOSDockPageWidget extends GetView<MacOSDockController> {
  @override
  Widget build(BuildContext context) {
    if (controller.bigScreenItems.isEmpty) return Container();
    bool isMini = context.deviceIsMobileAndLandscape;
    Widget _current = TabBarView(
      //! Eger bu ozelligi hapatirsan scrool yaptikca olusan degiskeni dock a aktarmalisin
      physics: NeverScrollableScrollPhysics(),
      children: controller.bigScreenItems.where((element) => element.dockItemButtonType == DockItemButtonType.bigScreenInTabViewMiniScreenOpenNewTarget).map((e) {
        return Container(
            decoration: BoxDecoration(
              color: (e.backgroundColor ?? Fav.design.others['widget.primaryBackground']),
              border: Border.all(
                color: e.borderColor ?? Fav.design.primaryText.withAlpha(20),
                width: MacOSDockTheme.tabBorderWidth(isMini),
              ),
            ),
            child: e.childBuilder(DockButtonLocation.dock));
      }).toList(),
      controller: controller.pageController,
    );

    _current = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _current,
    );

    return SizedBox(
      key: controller.macOSDockKey,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: MacOSDockTheme.containerHeight(isMini) + 4,
            top: 0,
            child: Padding(
              padding: EdgeInsets.only(left: MacOSDockTheme.tabBarHorizontalPadding(isMini), right: MacOSDockTheme.tabBarHorizontalPadding(isMini), top: 8, bottom: 0),
              child: _current,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: MacOSDock(
              initialIndex: controller.initialIndex,
              items: controller.bigScreenItems,
            ),
          ).px8,
        ],
      ),
    );
  }
}

//Buton dock icersindeyse yada rasgele bi yerdeyse pencereyi nasil olusturacagini buyuk ekranmi kucuk ekranmi bildirmek icin kullababilirsin
enum DockButtonLocation {
  dock,
  free,
}

//?Bu duyurular sosyal ag gibi kucuk ekranda ana menude olanlarin gozukmemesi icin
enum DockItemVisibleScreen { mini, big, both }

enum DockItemButtonType {
  buttonAndOpenNewTarget,
  bigScreenInTabViewMiniScreenOpenNewTarget,
}

class MacOSDockPageItem {
  final Widget Function(DockButtonLocation) childBuilder;
  final DockItem dockItem;
  final DockItemButtonType dockItemButtonType;
  final DockItemVisibleScreen dockItemVisibleScreen;

  final Color? backgroundColor;
  final Color? borderColor;
  MacOSDockPageItem({
    required this.childBuilder,
    required this.dockItem,
    this.dockItemButtonType = DockItemButtonType.bigScreenInTabViewMiniScreenOpenNewTarget,
    required this.dockItemVisibleScreen,
    this.backgroundColor,
    this.borderColor,
  });
}

//? Bu sadece dock olarakta kullanilabilir [MacosDockPageWidget] icindede pagewidget olarakta kullanilabilir
class MacOSDock extends StatelessWidget {
  final List<MacOSDockPageItem> items;
  final int initialIndex;

  MacOSDock({required this.items, Key? key, this.initialIndex = 0}) : super(key: key);

  final _controller = Get.find<MacOSDockController>();
  @override
  Widget build(BuildContext context) {
    bool isMini = context.deviceIsMobileAndLandscape;
    final _itemWidgets = Obx(
      () {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            items.length,
            (index) {
              final _pageItem = items[index];
              final _item = _pageItem.dockItem;
              Widget _current = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_controller.hoveredIndex.value == index)
                    SizedBox(
                      height: MacOSDockTheme.nameHeight(isMini),
                      width: MacOSDockTheme.baseItemHeight(isMini),
                      child: OverflowBox(
                        maxWidth: (MacOSDockTheme.bigItemHeight(isMini) - MacOSDockTheme.nameHeight(isMini)),
                        child: Container(
                          alignment: Alignment.center,
                          padding: Inset.hv(2, 1),
                          decoration: ShapeDecoration(color: Fav.design.scaffold.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: Fav.design.primaryText.withAlpha(30)))),
                          child: _item.name.text.center.autoSize.maxLines(1).fontSize(13).make(),
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    transformAlignment: Alignment.bottomCenter,
                    duration: _kAnimationDuration,
                    height: _controller.hoveredIndex.value == index ? (MacOSDockTheme.bigItemHeight(isMini) - MacOSDockTheme.nameHeight(isMini)) : MacOSDockTheme.baseItemHeight(isMini),
                    width: _controller.hoveredIndex.value == index ? (MacOSDockTheme.bigItemHeight(isMini) - MacOSDockTheme.nameHeight(isMini)) : MacOSDockTheme.baseItemHeight(isMini),
                    alignment: AlignmentDirectional.bottomCenter,
                    child: AnimatedScale(
                      alignment: Alignment.bottomCenter,
                      duration: _kAnimationDuration,
                      scale: _controller.hoveredIndex.value == index ? (MacOSDockTheme.bigItemHeight(isMini) - MacOSDockTheme.nameHeight(isMini)) / MacOSDockTheme.baseItemHeight(isMini) : 1,
                      child: _item.child,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color:

                          //  _controller.dockIconHasBadge(_item.tag)
                          //     ? (_item.primaryColor)
                          //     :

                          index == _controller.selectedIndex.value ? _item.primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    width: MacOSDockTheme.extraItemHeight(isMini) - 2,
                    height: MacOSDockTheme.extraItemHeight(isMini) - 2,
                  )
                ],
              );

              if (isWeb) {
                _current = GestureDetector(
                  onTap: () {
                    _controller.bigScreenOnChanged(_pageItem);
                  },
                  child: _current,
                );

                _current = MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: ((event) {
                    _controller.hoveredIndex.value = index;
                  }),
                  onExit: (event) {
                    _controller.hoveredIndex.value = -1;
                  },
                  child: _current,
                );
              } else {
                _current = GestureDetector(
                  onTapDown: (_) {
                    _controller.hoveredIndex.value = index;
                  },
                  onTapCancel: () {
                    _controller.hoveredIndex.value = -1;
                  },
                  onTapUp: (_) {
                    _controller.hoveredIndex.value = -1;
                  },
                  onTap: () {
                    _controller.bigScreenOnChanged(_pageItem);
                  },
                  child: _current,
                );
              }

              _current = Padding(
                padding: EdgeInsets.symmetric(horizontal: MacOSDockTheme.itemsPadding(isMini)),
                child: _current,
              );

              return _current;
            },
          ).toList(),
        );
      },
    );

    Widget _current = Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          top: MacOSDockTheme.containerVerticalPadding(isMini) + MacOSDockTheme.bigItemHeight(isMini) - 2 * MacOSDockTheme.containerVerticalPadding(isMini) - MacOSDockTheme.baseItemHeight(isMini),
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: MacOSDockTheme.dockBackgroundColor(),
              border: Border.all(
                color: Fav.design.primaryText.withAlpha(20),
                width: 0.8,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: MacOSDockTheme.containerVerticalPadding(isMini), left: MacOSDockTheme.itemsPadding(isMini) * 2, right: MacOSDockTheme.itemsPadding(isMini) * 2),
          child: _itemWidgets,
        ),
      ],
    );

    return SizedBox(
      height: MacOSDockTheme.hoveredContainerHeight(isMini),
      child: Padding(
        padding: EdgeInsets.only(top: MacOSDockTheme.widgetTopPadding(isMini), bottom: MacOSDockTheme.widgetBottomPadding(isMini)),
        child: _current,
      ),
    );
  }
}

class DockItem {
  final Widget child;
  final String name;
  //? Kendine ait yazi rengi yada badge rengi falan istersen
  final Color? primaryColor;
  //? Badge icin hangi keye  bakilmali
  final DockItemTag tag;

  DockItem({required this.child, required this.name, required this.primaryColor, required this.tag});
}
//! gonderdigin itemlerin boyutuda [baseItemHeight] ile ayni olmali

class MacOSDockTheme {
  MacOSDockTheme._();
  static const _kMiniFactor = 0.55;
  static double baseItemHeight(bool isMini) => 50 * (isMini ? _kMiniFactor : 1.0);
  static double bigItemHeight(bool isMini) => 100 * (isMini ? _kMiniFactor : 1.0);
  static double containerVerticalPadding(bool isMini) => 4 * (isMini ? _kMiniFactor : 1.0);
  static double tabBarHorizontalPadding(bool isMini) => 8 * (isMini ? _kMiniFactor : 1.0);
  static double widgetTopPadding(bool isMini) => 2 * (isMini ? _kMiniFactor : 1.0);
  static double widgetBottomPadding(bool isMini) => 8 * (isMini ? _kMiniFactor : 1.0);
  static double itemsPadding(bool isMini) => 7 * (isMini ? _kMiniFactor : 1.0);
  static double extraItemHeight(bool isMini) => 7 * (isMini ? _kMiniFactor : 1.0);
  static Color dockBackgroundColor() => Fav.design.primaryText.withAlpha(10);
  static double tabBorderRadius(bool isMini) => 16 * (isMini ? _kMiniFactor : 1.0);
  static double tabBorderWidth(bool isMini) => 1 * (isMini ? _kMiniFactor : 1.0);
  static double nameHeight(bool isMini) => 22 * (isMini ? _kMiniFactor : 1.0);

  static double hoveredContainerHeight(bool isMini) => widgetTopPadding(isMini) + widgetBottomPadding(isMini) + containerVerticalPadding(isMini) + bigItemHeight(isMini) + extraItemHeight(isMini);
  static double containerHeight(bool isMini) => baseItemHeight(isMini) + 2 * containerVerticalPadding(isMini) + extraItemHeight(isMini) + widgetBottomPadding(isMini) + widgetTopPadding(isMini);
}
