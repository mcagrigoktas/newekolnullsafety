import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../helpers/glassicons.dart';
import '../../library_helper/screenshot/eager.dart';
import '../../models/allmodel.dart';
import 'helper.dart';

class DailyReportStudentScreen extends StatefulWidget {
  final bool forMiniScreen;
  DailyReportStudentScreen({
    this.forMiniScreen = true,
  });
  @override
  _DailyReportStudentScreenState createState() => _DailyReportStudentScreenState();
}

class _DailyReportStudentScreenState extends State<DailyReportStudentScreen> {
  int? _studentDayIndex = 0;
  int _dateMillis = DateTime.now().millisecondsSinceEpoch;

  @override
  void dispose() {
    DailyReportHelper.saveLastLoginTime();
    //  AppVar.appBloc.dailyReportService.refresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dailyWidgets = [];
    List<Widget> educationWidgets = [];
    List<Widget> children = [];

    Map<int, Widget> pickerDayList = {
      0: "today".translate,
      1: "yesterday".translate,
      2: (DateTime.now().millisecondsSinceEpoch - 86400000 * 2).dateFormat("EE"),
      3: (DateTime.now().millisecondsSinceEpoch - 86400000 * 3).dateFormat("EE"),
      4: (DateTime.now().millisecondsSinceEpoch - 86400000 * 4).dateFormat("EE"),
    }.map(((key, value) => MapEntry(key, ConstrainedBox(constraints: BoxConstraints(maxWidth: context.screenWidth / 5 - 2), child: Align(alignment: Alignment.center, child: Text(value, maxLines: 1))))) as MapEntry<int, Widget> Function(int, dynamic));

    final _daysSegmentedWidget = CupertinoSlidingSegmentedControl<int>(
      children: pickerDayList,
      onValueChanged: (value) {
        setState(() {
          _dateMillis = DateTime.now().millisecondsSinceEpoch - value! * 86400000;
          _studentDayIndex = value;
        });
      },
      groupValue: _studentDayIndex,
    );

    final Map? data = DailyReportHelper.dailyReportThisDate(_dateMillis);

    if (data == null) {
      children.add(Expanded(child: Center(child: EmptyState(text: "nosaveddailyreportprofile".translate))));

      return AppScaffold(
        isFullScreenWidget: widget.forMiniScreen ? true : false,
        scaffoldBackgroundColor: widget.forMiniScreen ? null : Colors.transparent,
        topBar: TopBar(
          leadingTitle: 'menu1'.translate,
          hideBackButton: !widget.forMiniScreen,
        ),
        topActions: TopActionsTitleWithChild(title: TopActionsTitle(title: "dailyreport".translate, imgUrl: GlassIcons.dailyReport.imgUrl, color: GlassIcons.dailyReport.color), child: _daysSegmentedWidget),
        body: Body(child: Column(children: children)),
      );
    }

    final List dataList = data.entries.toList();
    if (data.containsKey('sortinglist')) {
      List? sortingList = data['sortinglist'];
      dataList.sort((e1, e2) {
        return sortingList!.indexOf(e1.key).compareTo(sortingList.indexOf(e2.key));
      });
    }

    dataList.forEach((item) {
      if (!['timeStamp', 'sortinglist', 'aktif'].contains(item.key)) {
        item.key == "teacherNote"
            ? children.add(Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: <Widget>[
                    8.widthBox,
                    Icon(
                      MdiIcons.sticker,
                      color: Fav.design.primary,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "teachernote".translate + ":",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Fav.design.primaryText),
                          ),
                          Text(
                            item.value == null || item.value == '' ? '---' : item.value,
                            style: TextStyle(color: Fav.design.primaryText),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ))
            : (item.value["tur"] == 0 ? dailyWidgets : educationWidgets).add(Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: <Widget>[
                    MyCachedImage(
                      width: 38.0,
                      height: 38.0,
                      imgUrl: DailyReport(iconName: item.value["icon"]).iconUrl,
                      alignment: Alignment.center,
                    ),
                    16.widthBox,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.key + ":",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Fav.design.primaryText),
                          ),
                          Text(
                            (item.value["value"] ?? '-'),
                            style: TextStyle(color: Fav.design.primaryText),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ));
      }
    });

    // günlük widgterlara başlık ekler

    dailyWidgets.insert(
        0,
        Text(
          "dailyreportsname1".translate,
          style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 17.0),
        ).p8);

    // Eğitim widgetlara balşık ekler
    if (educationWidgets.isNotEmpty) {
      educationWidgets.insert(
          0,
          Text(
            "dailyreportsname2".translate,
            style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 17.0),
          ).p8);
    }

    children.add(AnimatedGroupWidget(
      crossAxisAlignment: WrapCrossAlignment.start,
      children: <Widget>[
        Column(children: dailyWidgets),
        Column(children: educationWidgets),
      ],
    ));

    return AppScaffold(
      isFullScreenWidget: widget.forMiniScreen ? true : false,
      scaffoldBackgroundColor: widget.forMiniScreen ? null : Colors.transparent,
      topBar: TopBar(leadingTitle: 'menu1'.translate, hideBackButton: !widget.forMiniScreen, trailingActions: [
        MdiIcons.downloadBox.icon
            .onPressed(() async {
              OverLoading.show();
              await 300.wait;
              final _data = await ScreenShotLibraryHelper.captureFromWidget(
                  Scaffold(
                      backgroundColor: Fav.design.scaffold.background,
                      body: Center(
                        child: SingleChildScrollView(
                          child: Column(children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(GlassIcons.dailyReport.imgUrl!, height: 24),
                                16.widthBox,
                                Flexible(child: ("dailyreport".translate + ' / ' + _dateMillis.dateFormat()).text.color(GlassIcons.dailyReport.color!).autoSize.fontSize(20).maxLines(1).bold.make()),
                              ],
                            ),
                            ...children
                          ]),
                        ),
                      )),
                  context: context);
              await DownloadManager.saveImageToGallery(data: _data, fileName: "dailyreport".translate + ' ' + _dateMillis.dateFormat() + '.png');
              await OverLoading.close();
              isWeb ? OverAlert.saveSuc() : OverAlert.show(message: 'savedasphoto'.translate);
            })
            .color(Fav.design.appBar.text)
            .make()
      ]),
      topActions: TopActionsTitleWithChild(
        title: TopActionsTitle(
          title: "dailyreport".translate,
          imgUrl: GlassIcons.dailyReport.imgUrl,
          color: GlassIcons.dailyReport.color,
        ),
        child: _daysSegmentedWidget,
      ),
      body: Body(singleChildScroll: Column(children: children)),
    );
  }
}
