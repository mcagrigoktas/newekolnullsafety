import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../assets.dart';
import '../../../helpers/glassicons.dart';
import '../controller.dart';
import '../macos_dock/macos_dock.dart';
import '../menu_list_helper.dart';
import 'bottom_navigation_bar_clipper.dart';

class EkolBottomNavBarCurved extends StatefulWidget {
  const EkolBottomNavBarCurved({Key? key}) : super(key: key);

  @override
  _EkolBottomNavBarCurvedState createState() => _EkolBottomNavBarCurvedState();
}

class _EkolBottomNavBarCurvedState extends State<EkolBottomNavBarCurved> {
  final _controller = Get.find<MainController>();
  TabController? _tabController;

  late Function() _tabListener;
  int? _index;

  final _announcementIndex = 0;
  final _socialTabIndex = 1;
  final _floatingActionButtonIndex = 1 + ((MenuList.hasSocialNetwork() ? 1 : 0));
  final _messagesIndex = 2 + ((MenuList.hasSocialNetwork() ? 1 : 0));
  final _optionIndex = 2 + ((MenuList.hasSocialNetwork() ? 1 : 0)) + ((MenuList.hasMessages() ? 1 : 0));

  @override
  void initState() {
    super.initState();
    _controller.macOSDockController.smallScreenGoToPageFromTag = goToPageFromTag;
    _index = _controller.navigationIndex;
    _tabListener = () {
      if (mounted && _index != _tabController!.index) {
        setState(() {
          _index = _tabController!.index;
          _controller.navigationIndex = _index;
        });
      }
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController!.addListener(_tabListener);
    });
  }

  @override
  void dispose() {
    _tabController?.removeListener(_tabListener);
    //  _tabController?.dispose();
    super.dispose();
  }

  void goToPageFromTag(DockItemTag tag) {
    if (tag == DockItemTag.announcement) changeIndex(_announcementIndex);
    if (tag == DockItemTag.social) changeIndex(_socialTabIndex);
    if (tag == DockItemTag.messages) changeIndex(_messagesIndex);
  }

  void changeIndex(int _index) {
    setState(() {
      _tabController!.animateTo(_index);
      _index = _index;
      _controller.navigationIndex = _index;
    });
  }

  final double _navigationBarHeight = 68;

  @override
  Widget build(BuildContext context) {
    _tabController ??= DefaultTabController.of(context);

    Size size = MediaQuery.of(context).size;

    double _height = _navigationBarHeight + context.screenBottomPadding;

    return Stack(
      children: [
        CustomPaint(
          painter: MyCustomPainter(),
          child: ClipPath(
            clipper: MyCustomClipper(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: size.width,
                height: _height,
                color: Fav.design.bottomNavigationBar.background,
              ),
            ),
          ),
        ),
        Center(
          heightFactor: 0.6,
          child: EkolCurverBotomNavigationFAB(
            selected: _index == _floatingActionButtonIndex,
            onPressed: () {
              changeIndex(_floatingActionButtonIndex);
            },
          ),
        ),
        Container(
          margin: Inset.b(context.screenBottomPadding),
          height: _navigationBarHeight,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: EkolCurvedBottomNavBarButton(
                        name: 'announcements'.translate,
                        imgAsset: GlassIcons.announcementIcon.imgUrl,
                        icon: MdiIcons.bookmarkMultiple,
                        icon2: MdiIcons.bookmarkMultipleOutline,
                        selected: _index == _announcementIndex,
                        selectedColor: GlassIcons.announcementIcon.color,
                        onPressed: () {
                          changeIndex(_announcementIndex);
                        },
                      ),
                    ),
                    if (MenuList.hasSocialNetwork())
                      Expanded(
                        child: EkolCurvedBottomNavBarButton(
                          name: 'social'.translate,
                          imgAsset: GlassIcons.social.imgUrl,
                          icon: MdiIcons.video,
                          icon2: MdiIcons.imageMultipleOutline,
                          selectedColor: GlassIcons.social.color,
                          selected: _index == _socialTabIndex,
                          onPressed: () {
                            changeIndex(_socialTabIndex);
                          },
                        ),
                      ),
                  ],
                ).px8,
              ),
              SizedBox(width: 56),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (MenuList.hasMessages())
                      Expanded(
                        child: EkolCurvedBottomNavBarButton(
                          name: 'messages'.translate,
                          imgAsset: GlassIcons.messagesIcon.imgUrl,
                          icon: MdiIcons.messageText,
                          icon2: MdiIcons.messageOutline,
                          selected: _index == _messagesIndex,
                          selectedColor: GlassIcons.messagesIcon.color,
                          onPressed: () {
                            changeIndex(_messagesIndex);
                          },
                        ),
                      ),
                    Expanded(
                      child: EkolCurvedBottomNavBarButton(
                        name: 'options'.translate,
                        imgAsset: GlassIcons.bag.imgUrl,
                        icon: MdiIcons.bagPersonal,
                        icon2: MdiIcons.cogOutline,
                        selectedColor: GlassIcons.bag.color,
                        selected: _index == _optionIndex,
                        onPressed: () {
                          changeIndex(_optionIndex);
                        },
                      ),
                    ),
                  ],
                ).px8,
              )
            ],
          ),
        ),
      ],
    );
  }
}

class QBankBottomNavBarCurved extends StatefulWidget {
  const QBankBottomNavBarCurved({Key? key}) : super(key: key);

  @override
  _QBankBottomNavBarCurvedState createState() => _QBankBottomNavBarCurvedState();
}

class _QBankBottomNavBarCurvedState extends State<QBankBottomNavBarCurved> {
  TabController? _tabController;
  late Function() _tabListener;
  int _index = 1;

  @override
  void initState() {
    super.initState();

    _tabListener = () {
      if (mounted && _index != _tabController!.index) {
        setState(() {
          _index = _tabController!.index;
        });
      }
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController!.addListener(_tabListener);
    });
  }

  @override
  void dispose() {
    _tabController?.removeListener(_tabListener);
    //_tabController?.dispose();
    super.dispose();
  }

  void changeIndex(int _index) {
    setState(() {
      _tabController!.animateTo(_index);
      _index = _index;
    });
  }

  final double _navigationBarHeight = 68;

  @override
  Widget build(BuildContext context) {
    _tabController ??= DefaultTabController.of(context);

    Size size = MediaQuery.of(context).size;

    double _height = _navigationBarHeight + context.screenBottomPadding;

    return Stack(
      children: [
        CustomPaint(
          painter: MyCustomPainter(),
          child: ClipPath(
            clipper: MyCustomClipper(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: size.width,
                height: _height,
                color: Fav.design.bottomNavigationBar.background,
              ),
            ),
          ),
        ),
        Center(
          heightFactor: 0.6,
          child: QBankCurverBotomNavigationFAB(
            selected: _index == 1,
            onPressed: () {
              changeIndex(1);
            },
          ),
        ),
        Container(
          margin: Inset.b(context.screenBottomPadding),
          height: _navigationBarHeight,
          child: Row(
            children: [
              Expanded(
                child: Expanded(
                  child: QBankCurvedBottomNavBarButton(
                    name: 'mybooks'.translate,
                    imgAsset: Assets.images.notecPNG,
                    imgAsset2: Fav.design.brightness == Brightness.dark ? Assets.images.notedPNG : Assets.images.notewPNG,
                    selected: _index == 0,
                    selectedColor: Color(0xffEBD38B),
                    onPressed: () {
                      changeIndex(0);
                    },
                  ),
                ).px8,
              ),
              SizedBox(width: 56),
              Expanded(
                child: Expanded(
                  child: QBankCurvedBottomNavBarButton(
                    name: 'settings'.translate,
                    imgAsset: Assets.images.setcPNG,
                    imgAsset2: Fav.design.brightness == Brightness.dark ? Assets.images.setdPNG : Assets.images.setlPNG,
                    selectedColor: Color(0xff8BD9E0),
                    selected: _index == 2,
                    onPressed: () {
                      changeIndex(2);
                    },
                  ),
                ).px8,
              )
            ],
          ),
        ),
      ],
    );
  }
}
