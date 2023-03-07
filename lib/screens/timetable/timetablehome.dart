import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/glassicons.dart';
import 'homework/summaryhomework.dart';
import 'usertimetable/studenttimetablenew.dart';
import 'usertimetable/teachertimetablenew.dart';

class TimeTableHome extends StatefulWidget {
  final bool forMiniScreen;
  TimeTableHome({
    this.forMiniScreen = true,
  });
  @override
  _TimeTableHomeState createState() => _TimeTableHomeState();
}

class _TimeTableHomeState extends State<TimeTableHome> {
  StreamSubscription? _refresher;
  StreamSubscription? _refresher2;
  var _refreshKey = GlobalKey();

  @override
  void initState() {
    _refresher = AppVar.appBloc.tableProgramService?.stream.listen((event) {
      setState(() {
        _refreshKey = GlobalKey();
      });
    });
    _refresher2 = AppVar.appBloc.portfolioService?.stream.listen((event) {
      setState(() {
        _refreshKey = GlobalKey();
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _refresher?.cancel();
    _refresher2?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((AppVar.appBloc.lessonService?.dataList.length ?? 0) < 1) return AppScaffold(topBar: TopBar(leadingTitle: 'menu1'.translate), body: Body.child(child: EmptyState()));
    return Padding(
      key: _refreshKey,
      padding: EdgeInsets.zero,
      child: AppScaffold(
        isFullScreenWidget: widget.forMiniScreen ? true : false,
        scaffoldBackgroundColor: widget.forMiniScreen ? null : Colors.transparent,
        topBar: TopBar(
            hideBackButton: !widget.forMiniScreen,
            leadingTitle: 'menu1'.translate,
            middle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(GlassIcons.timetable2.imgUrl!, height: 24),
                3.widthBox,
                'mylessons'.translate.text.color(GlassIcons.timetable2.color!).bold.make(),
              ],
            ),
            trailingActions: [
              MyPopupMenuButton(
                  child: MdiIcons.dotsHorizontalCircleOutline.icon.color(Fav.design.primaryText).make(),
                  onSelected: (value) async {
                    if (value == 1) {
                      Fav.writeSeasonCache('seeListTypeTimeTable', !Fav.readSeasonCache<bool>('seeListTypeTimeTable', false)!);
                      AppVar.appBloc.tableProgramService!.refresh();
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(value: 1, child: Text(Fav.readSeasonCache<bool>('seeListTypeTimeTable', false)! ? 'seeTableType'.translate : 'seeListType'.translate, style: TextStyle(color: Fav.design.primaryText))),
                    ];
                  })
            ]),
        // topActions: TopActionsTitle(
        //   title: 'mylessons'.translate,
        // ),
        body: Body.child(
          child:
              //context.screenWidth > 800 && false
              // ? Row(
              //     children: <Widget>[
              //       Expanded(
              //         flex: 3,
              //         child: Column(
              //           children: <Widget>[
              //             AppVar.appBloc.hesapBilgileri.gtS ? StudentTimeTableNew() : TeacherTimeTable(),
              //             RehberlikWidget(),
              //           ],
              //         ),
              //       ),
              //       Expanded(flex: 2, child: SummaryHomework())
              //     ],
              //   )
              // :

              Column(
            children: <Widget>[
              2.heightBox,
              if (AppVar.appBloc.hesapBilgileri.gtS) StudentTimeTableNew(),
              if (AppVar.appBloc.hesapBilgileri.gtT) TeacherTimeTableNew(),
              Expanded(child: SummaryHomework()),
            ],
          ),
        ),
      ),
    );
  }
}
