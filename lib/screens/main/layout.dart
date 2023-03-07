import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../announcements/announcementspage.dart';
import '../mesagging/chatpreview.dart';
import '../notification_and_agenda/layout.dart';
import '../social/socialpage.dart';
import 'controller.dart';
import 'macos_dock/macos_dock.dart';
import 'menu_list_helper.dart';
import 'tree_view/tree_view.dart' as t;
import 'widgets/app_stopped.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'widgets/main_screen_background.dart';
import 'widgets/main_screen_topbar.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(builder: (controller) {
      debugPrint('Update: Widget layout update oldu');
      if (controller.logoGosterilecek) {
        return Container(
          color: Fav.design.scaffold.background,
          width: double.infinity,
          height: double.infinity,
        );
      }
      final bool _isSmallLayoutEnable = context.screenWidth < 720 || (isMobile && context.orientation == Orientation.portrait);
      controller.macOSDockController.isSmallLayoutEnable = _isSmallLayoutEnable;

      Widget _current = _isSmallLayoutEnable ? _SmallLayout() : _LargeLayoutNew();

      if (AppVar.appBloc.schoolInfoService!.singleData!.aktif == false) {
        _current = Stack(
          children: [
            Positioned.fill(child: _current),
            Positioned.fill(child: AppStoped()),
          ],
        );
      }

      return _current;
    });
  }
}

class _LargeLayoutNew extends StatelessWidget {
  _LargeLayoutNew();
  @override
  Widget build(BuildContext context) {
    Widget _current = Column(
      children: [
        MainScreenTopBar(),
        Expanded(
          child: Row(
            children: [
              SizedBox(width: 212, child: t.AppTreeView()),
              _VerticalLine(),
              Expanded(child: Padding(padding: EdgeInsets.only(bottom: context.screenBottomPadding), child: MacOSDockPageWidget())),
            ],
          ),
        ),
      ],
    );

    _current = MainScreenBackgroundWidget(child: _current);
    return _current;
  }
}

class _SmallLayout extends StatelessWidget {
  _SmallLayout();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<MainController>();

    if (MenuList.fullMenuList() == null || MenuList.fullMenuList()!.isEmpty) return SizedBox();

    final _screen3 = Stack(
      children: [
        Positioned(
          left: 16,
          right: 16,
          bottom: 0,
          top: context.screenTopPadding + 2 + 44,
          child: NotificationAndAgendaMiniScreenWidget(),
        ),
        Positioned(top: 0, left: 0, right: 0, child: MainScreenTopBar()),
      ],
    );

    List<Widget> _screens = [
      AnnouncementsPage(forMiniScreen: true),
      if (MenuList.hasSocialNetwork()) SocialPage(forMiniScreen: true),
      _screen3,
      if (MenuList.hasMessages()) ChatPreview(forMiniScreen: true),
      t.AppTreeView(fromBigDashboard: false),
    ];

    Widget _currentWidget = TabBarView(children: _screens);

    //_currentWidget = MainScreenBackgroundWidget(child: _currentWidget);

    _controller.navigationIndex ??= MenuList.hasSocialNetwork() ? 2 : 1;

    _currentWidget = Scaffold(
      backgroundColor: Fav.design.scaffold.background,
      body: _currentWidget,
      extendBody: true,
      bottomNavigationBar: EkolBottomNavBarCurved(),
    );

    _currentWidget = DefaultTabController(
      initialIndex: _controller.navigationIndex!.clamp(0, _screens.length - 1),
      key: ValueKey('DefaultTabController${_screens.length}'),
      length: _screens.length,
      child: _currentWidget,
    );
    return _currentWidget;
  }
}

class _VerticalLine extends StatelessWidget {
  _VerticalLine();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
        Fav.design.others['widget.primaryBackground']!.withAlpha(0),
        Fav.design.others['widget.primaryBackground']!.withAlpha(200),
        Fav.design.others['widget.primaryBackground']!.withAlpha(0),
      ])),
      width: 1,
    );
  }
}
// En eski tasarimdaki hooku koymak istrersen baslangic icin kullanabilirsin
// class _HookWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//         height: 34,
//         width: 10,
//         child: Stack(
//           children: <Widget>[
//             Align(
//               alignment: Alignment.topCenter,
//               child: Container(
//                 width: 9.8,
//                 height: 10,
//                 decoration: ShapeDecoration(color: Fav.design.customColors1[2], shape: const CircleBorder()),
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 width: 8.1,
//                 height: 10,
//                 decoration: ShapeDecoration(color: Fav.design.customColors1[2], shape: const CircleBorder()),
//               ),
//             ),
//             Align(
//               alignment: Alignment.center,
//               child: Container(
//                 width: 4.3,
//                 height: 26,
//                 decoration: ShapeDecoration(color: Fav.design.customColors1[1], shape: const StadiumBorder()),
//               ),
//             ),
//           ],
//         ));
//   }
// }
// final _screen3 = Padding(
//       padding: EdgeInsets.only(top: context.screenTopPadding + 8),
//       child: Stack(
//         children: [
//           Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               height: 84,
//               child: Container(
//                   margin: Inset.h(16),
//                   decoration: BoxDecoration(color: Fav.design.others['widget.primaryBackground'], borderRadius: BorderRadius.circular(24), boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xff2C2E60).withOpacity(0.01),
//                       blurRadius: 2,
//                       spreadRadius: 2,
//                       offset: const Offset(0, 0),
//                     ),
//                   ]),
//                   child: MainScreenTopBar())),
//           Positioned(
//               left: 16,
//               right: 16,
//               bottom: 0,
//               top: 88,
//               child: NotificationAndAgendaMiniScreenWidget(
//                 child: SmallScreenDockItems(),
//               )),
//           Positioned(left: 32.0, top: 67.0, height: 34.0, child: _HookWidget()),
//           Positioned(right: 32.0, top: 67.0, height: 34.0, child: _HookWidget()),
//         ],
//       ),
//     );