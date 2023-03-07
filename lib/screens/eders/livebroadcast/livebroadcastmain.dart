import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/glassicons.dart';
import '../../../models/models.dart';
import 'helper.dart';
import 'livebroadcastitem.dart';
import 'makeprogram/makebroadcastprogram.dart';

class LiveBroadcastMain extends StatelessWidget {
  final bool forMiniScreen;
  LiveBroadcastMain({
    this.forMiniScreen = true,
  });
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AppVar.appBloc.liveBroadcastService!.stream,
        builder: (context, snapshot) {
          return Padding(padding: EdgeInsets.zero, key: GlobalKey(), child: LiveBroadcastList(forMiniScreen: forMiniScreen));
        });
  }
}

class LiveBroadcastList extends StatefulWidget {
  final bool forMiniScreen;
  LiveBroadcastList({
    this.forMiniScreen = true,
  });

  @override
  LiveBroadcastListState createState() => LiveBroadcastListState();
}

class LiveBroadcastListState extends State<LiveBroadcastList> {
  String? _teacherKey = 'all';
  List<LiveBroadcastModel> _filteredList = [];

//  Stream<bool> get streamStudentisSpeaker => subjectStudentisSpeaker.stream;
//  final BehaviorSubject<bool> subjectStudentisSpeaker = BehaviorSubject<bool>();

  void _filterData() {
    setState(() {
      _filteredList = LiveBroadcastMainHalper.getData(_teacherKey);
    });
  }

  @override
  void dispose() {
    LiveBroadcastMainHalper.saveLastLoginTime();
    super.dispose();
  }

  @override
  void initState() {
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      _teacherKey = AppVar.appBloc.hesapBilgileri.uid;
    }
    _filterData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isFullScreenWidget: widget.forMiniScreen ? true : false,
      scaffoldBackgroundColor: widget.forMiniScreen ? null : Colors.transparent,
      topBar: TopBar(leadingTitle: 'menu1'.translate, hideBackButton: !widget.forMiniScreen, trailingActions: <Widget>[
        if (AppVar.appBloc.hesapBilgileri.gtMT && AppVar.appBloc.teacherService!.dataList.isNotEmpty)
          IconButton(
            onPressed: () {
              Fav.guardTo(MakeLiveBroadcastProgram());
            },
            icon: Icon(Icons.add, color: Fav.design.appBar.text),
          ),
        8.widthBox
      ]),
      topActions: TopActionsTitleWithChild(
        childIsPinned: false,
        title: TopActionsTitle(imgUrl: GlassIcons.liveBroadcastIcon.imgUrl, color: GlassIcons.liveBroadcastIcon.color, title: "elesson".translate),
        child: AdvanceDropdown(
          initialValue: _teacherKey,
          searchbarEnableLength: 30,
          onChanged: (dynamic value) {
            _teacherKey = value;
            _filterData();
          },
          name: "teacher".translate,
          iconData: MdiIcons.humanMaleBoard,
          items: AppVar.appBloc.teacherService!.dataList.map((teacher) {
            return DropdownItem(value: teacher.key, name: teacher.name);
          }).toList()
            ..insert(0, DropdownItem(value: 'all', name: 'all'.translate)),
        ),
      ),
      body: _teacherKey == null
          ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
          : _filteredList.isEmpty
              ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS))
              : Body.staggeredGridViewBuilder(
                  crossAxisCount: context.screenWidth > 600 ? 2 : 1,
                  itemBuilder: (BuildContext context, int index) => LiveBroadcastItem(item: _filteredList[index]),
                  itemCount: _filteredList.length,
                  maxWidth: 720,
                ),
    );
  }
}

// class VideoChatListWidget extends StatelessWidget {
//   final List<LiveBroadcastModel> dataList;

//   VideoChatListWidget({this.dataList});

//   @override
//   Widget build(BuildContext context) {
//     return context.screenWidth > 600
//         ? StaggeredGridView.countBuilder(
//             padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0, bottom: 4.0),
//             physics: const BouncingScrollPhysics(),
//             crossAxisCount: 2,
//             itemCount: dataList.length,
//             itemBuilder: (BuildContext context, int index) => LiveBroadcastItem(
//               item: dataList[index],
//             ),
//             staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//           )
//         : ListView.builder(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
//             itemCount: dataList.length,
//             itemBuilder: (context, index) {
//               return LiveBroadcastItem(
//                 item: dataList[index],
//               );
//             });
//   }
// }
