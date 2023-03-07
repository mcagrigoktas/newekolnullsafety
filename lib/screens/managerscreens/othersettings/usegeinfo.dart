import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/appfunctions.dart';
import '../../../helpers/print_and_export_helper.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';

class UsageInfo extends StatefulWidget {
  final Map? data;
  final bool hasScaffold;

//Supermanager sayfasindan gelirse
  final List<Student>? studentList;
  final List<Teacher>? teacherList;
  final List<Manager>? managerList;
  final String? schoolType;

  UsageInfo({this.data, this.hasScaffold = true, this.managerList, this.studentList, this.teacherList, this.schoolType});

  @override
  _UsageInfoState createState() => _UsageInfoState();
}

class _UsageInfoState extends State<UsageInfo> with AppFunctions {
  bool isLoading = false;
  int month = DateTime.now().month;
  Map? data;
  List<List<String>> myDataTable = [];
  @override
  void initState() {
    super.initState();

    if (widget.data == null) {
      var future1 = UserInfoService.dbUsageInfo().once();

      Future.wait([future1]).then((response) {
        if (mounted) {
          setState(() {
            data = response.first?.value ?? {};
            makeTable();
          });
        }
      });
    } else {
      data = widget.data;
      makeTable();
    }
  }

  String getMenuName(String key) {
    if (key == 'Announcements') {
      return 'announcementslogname'.translate;
    } else if (key == 'DailyReports') {
      return 'dailyreportslogname'.translate;
    } else if (key == 'Messages') {
      return 'sendmessagelogname'.translate;
    } else if (key == 'SocialNetwork') {
      return 'sendphotologname'.translate;
    } else if (key == 'Video') {
      return 'sendvideologname'.translate;
    } else if (key == 'GiveStars') {
      return 'givestarslogname'.translate;
    } else if (key == 'Survey') {
      return 'addsurveylogname'.translate;
    } else if (key == 'RollCall') {
      return 'addrollcalllogname'.translate;
    } else if (key == 'HomeWork') {
      return 'addhomeworklogname'.translate;
    }
    if (key == 'VideoLessonsTime') {
      return 'videolessontime'.translate;
    }
    return '---';
  }

  void makeTable() {
    myDataTable.clear();
    final Map usageData = data!['m:$month'] ?? {};

    usageData.forEach((menuname, value) {
      Map kullaniciData = value;
      kullaniciData.forEach((uid, count) {});
    });

    List<String> menuNames = ['Announcements', 'Messages', 'SocialNetwork', 'Video', 'Survey', 'RollCall', 'VideoLessonsTime'];
    if (widget.schoolType == 'ekid' || (AppVar.appBloc.hesapBilgileri.isEkid && widget.schoolType == null)) {
      menuNames.addAll(['DailyReports', 'GiveStars']);
    } else if (widget.schoolType == 'ekol' || (AppVar.appBloc.hesapBilgileri.isEkol && widget.schoolType == null)) {
      menuNames.addAll(['HomeWork']);
    } else if (widget.schoolType == 'uni' || (AppVar.appBloc.hesapBilgileri.isUni && widget.schoolType == null)) {
      menuNames.addAll(['HomeWork']);
    }

    //Tablo basliklari yaziliyor

    myDataTable.add(menuNames.map((itemhead) => getMenuName(itemhead)).toList()..insert(0, 'name'.translate));

    (widget.managerList ?? AppVar.appBloc.managerService!.dataList).forEach((user) {
      myDataTable.add(menuNames.map((itemhead) {
        final Map menuData = usageData[itemhead] ?? {};
        if (itemhead == 'VideoLessonsTime') {
          final int time = (menuData[user.key] ?? 0);
          return (time ~/ 3600).toString().padLeft(2, '0') + ":" + ((time % 3600) ~/ 3600).toString().padLeft(2, '0');
        }
        return (menuData[user.key] ?? 0).toString();
      }).toList()
        ..insert(0, user.name! /*whatIsThisName(AppVar.appBloc, user.key)*/));
    });

    (widget.teacherList ?? AppVar.appBloc.teacherService!.dataList).forEach((user) {
      myDataTable.add(menuNames.map((itemhead) {
        final Map menuData = usageData[itemhead] ?? {};
        if (itemhead == 'VideoLessonsTime') {
          final int time = (menuData[user.key] ?? 0);
          return (time ~/ 3600).toString().padLeft(2, '0') + ":" + ((time % 3600) ~/ 3600).toString().padLeft(2, '0');
        }
        return (menuData[user.key] ?? 0).toString();
      }).toList()
        ..insert(0, user.name! /*whatIsThisName(AppVar.appBloc, user.key)*/));
    });
    (widget.studentList ?? AppVar.appBloc.studentService!.dataList).forEach((user) {
      myDataTable.add(menuNames.map((itemhead) {
        final Map menuData = usageData[itemhead] ?? {};
        if (itemhead == 'VideoLessonsTime') {
          final int time = (menuData[user.key] ?? 0);
          return (time ~/ 3600).toString().padLeft(2, '0') + ":" + ((time % 3600) ~/ 3600).toString().padLeft(2, '0');
        }
        return (menuData[user.key] ?? 0).toString();
      }).toList()
        ..insert(0, user.name! /*whatIsThisName(AppVar.appBloc, user.key)*/));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (myDataTable.isEmpty) return Scaffold(body: MyProgressIndicator(isCentered: true));

    final _name = 'usageinfo'.translate + ' ' + DateTime.now().dateFormat('d-MMM-yyyy');

    final _bottomBar = BottomBar(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MyMiniRaisedButton(
          text: Words.print,
          onPressed: () {
            PrintAndExportHelper.printPdf(
              data: PrintAndExportModel(columnNames: myDataTable.first, rows: myDataTable.sublist(1).toList()),
              pdfHeaderName: _name,
              flexList: [3],
              isLandscape: true,
            );
          },
          iconData: Icons.print,
        ),
        16.widthBox,
        MyMiniRaisedButton(
          text: 'exportexcell'.translate,
          onPressed: () {
            PrintAndExportHelper.exportToExcel(
              data: PrintAndExportModel(columnNames: myDataTable.first, rows: myDataTable.sublist(1).toList()),
              excelName: _name,
            );
          },
          iconData: MdiIcons.fileExcel,
        ),
        16.widthBox,
      ],
    ));

    final _monthWidget = AdvanceDropdown(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      name: 'month'.translate,
      onChanged: (dynamic value) {
        setState(() {
          month = value;
          makeTable();
        });
      },
      iconData: Icons.timer,
      initialValue: month,
      items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
          .map(
            (item) => DropdownItem(
              name: DateTime(2019, item).dateFormat("MMMM"),
              value: item,
            ),
          )
          .toList(),
    );

    final _dataTable = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: MyDataTable(
        data: myDataTable,
        maxWidth: 100,
      ),
    );

    if (!widget.hasScaffold) {
      return Column(
        children: <Widget>[
          _monthWidget,
          8.heightBox,
          Expanded(child: _dataTable),
        ],
      );
    }

    return AppScaffold(
      topBar: TopBar(leadingTitle: 'menu1'.translate),
      topActions: TopActionsTitleWithChild(
        title: TopActionsTitle(title: 'usageinfo'.translate),
        child: _monthWidget,
      ),
      body: Body.child(
        child: _dataTable,
      ),
      bottomBar: _bottomBar,
    );
  }
}
