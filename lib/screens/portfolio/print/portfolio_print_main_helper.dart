import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../appbloc/appvar.dart';
import '../../../helpers/glassicons.dart';
import '../../../helpers/print/pdf_widgets.dart';
import '../../../helpers/print/printhelper.dart';
import '../../../models/allmodel.dart';
import '../../p2p/freestyle/model.dart';
import '../../rollcall/model.dart';
import '../../timetable/homework/homework_check_helper.dart';
import '../../timetable/hwwidget.helper.dart';
import '../model.dart';

class PortfolioPrintHelper {
  PortfolioPrintHelper._();
  static Future<void> print(List<Portfolio> dataList, Map<PortfolioType, String> portfolioMap, Student? student) async {
    final _typeList = await _chooseTypes(portfolioMap);
    if (_typeList.isEmpty) return;

    final doc = pw.Document();
    List<pw.Widget> widgetList = [
      PrintWidgetHelper.myTextContainer(color: GlassIcons.portfolio.color!.toPdfColor.flatten(), text: 'portfolio'.translate.toUpperCase(), bold: true, padding: 4),
    ];
    widgetList.add(await _headerWidget(student!));
    if (_typeList.contains(PortfolioType.examreport)) widgetList.addAll(_examWidgets(portfolioMap[PortfolioType.examreport]!, dataList.where((element) => element.portfolioType == PortfolioType.examreport).map((e) => e.data<PortfolioExamReport>()).toList()).toList());
    if (_typeList.contains(PortfolioType.p2p)) widgetList.addAll(_p2pWidgets(portfolioMap[PortfolioType.p2p]!, dataList.where((element) => element.portfolioType == PortfolioType.p2p).map((e) => e.data<P2PModel>()).toList()).toList());
    if (_typeList.contains(PortfolioType.rollcall)) widgetList.addAll(_rollCallWidgets(portfolioMap[PortfolioType.rollcall]!, dataList.where((element) => element.portfolioType == PortfolioType.rollcall).map((e) => e.data<RollCallStudentModel>()).toList()).toList());
    if (_typeList.contains(PortfolioType.homeworkCheck)) widgetList.addAll(_homeWorkWidgets(portfolioMap[PortfolioType.homeworkCheck]!, dataList.where((element) => element.portfolioType == PortfolioType.homeworkCheck).map((e) => e.data<HomeWorkCheck>()).toList()).toList());
    if (_typeList.contains(PortfolioType.examCheck)) widgetList.addAll(_homeWorkWidgets(portfolioMap[PortfolioType.examCheck]!, dataList.where((element) => element.portfolioType == PortfolioType.examCheck).map((e) => e.data<HomeWorkCheck>()).toList()).toList());

    await PrintHelper.printMultiplePagePdf(widgetList, doc: doc);
  }

  static List<pw.Widget> _homeWorkWidgets(String menuName, List<HomeWorkCheck?> itemList) {
    List<pw.Widget> widgetList = [];
    widgetList.add(pw.SizedBox(height: 4));
    widgetList.add(PrintWidgetHelper.myTextContainer(color: GlassIcons.homework.color!.toPdfColor.flatten(), text: menuName, bold: true, padding: 4));
    final _headerWidget = pw.Row(children: [
      ...[
        ['date'.translate, 3],
        ['lesson'.translate, 2],
        ['header'.translate, 3],
        ['content'.translate, 4],
        ['result'.translate, 4],
      ]
          .map(
            (e) => pw.Expanded(
                flex: e[1] as int,
                child: PrintWidgetHelper.myBorderedContainer(
                  padding: 2,
                  text: e.first as String,
                  height: 20,
                  bold: true,
                  maxLines: 1,
                  alignmentIsCenter: true,
                  fontSize: 10,
                  textAlign: pw.TextAlign.center,
                )),
          )
          .toList(),
    ]);
    widgetList.add(_headerWidget);

    for (var i = 0; i < itemList.length; i++) {
      final homeWorkItem = itemList[i]!;
      final _lesson = AppVar.appBloc.lessonService!.dataListItem(homeWorkItem.lessonKey!);

      final _itemWidget = pw.Row(children: [
        ...[
          [homeWorkItem.date?.dateFormat('d-MMM-yyyy') ?? '', 3],
          [_lesson?.longName ?? '', 2],
          [homeWorkItem.title, 3],
          [homeWorkItem.content.firstXcharacter(100), 4],
          [HomeWorkWidgetHelper.getNoteForPdf(homeWorkItem.noteText!), 4],
        ]
            .map(
              (e) => pw.Expanded(
                  flex: e[1] as int,
                  child: e.first is String
                      ? PrintWidgetHelper.myBorderedContainer(
                          padding: 2,
                          text: e.first as String? ?? '',
                          height: 20,
                          bold: false,
                          maxLines: 1,
                          alignmentIsCenter: true,
                          fontSize: 8,
                          textAlign: pw.TextAlign.center,
                        )
                      : e.first as pw.Widget),
            )
            .toList(),
      ]);
      widgetList.add(_itemWidget);
    }

    return widgetList;
  }

  static List<pw.Widget> _rollCallWidgets(String menuName, List<RollCallStudentModel?> itemList) {
    List<pw.Widget> widgetList = [];
    widgetList.add(pw.SizedBox(height: 4));
    widgetList.add(PrintWidgetHelper.myTextContainer(color: GlassIcons.dailyReport.color!.toPdfColor.flatten(), text: menuName, bold: true, padding: 4));
    final _headerWidget = pw.Row(children: [
      ...[
        ['date'.translate, 1],
        ['lesson'.translate, 4],
      ]
          .map(
            (e) => pw.Expanded(
                flex: e[1] as int,
                child: PrintWidgetHelper.myBorderedContainer(
                  padding: 2,
                  text: e.first as String,
                  height: 20,
                  bold: true,
                  maxLines: 1,
                  alignmentIsCenter: true,
                  fontSize: 10,
                  textAlign: pw.TextAlign.center,
                )),
          )
          .toList(),
    ]);
    widgetList.add(_headerWidget);
    Map<String, String> _dataMap = {};

    for (var i = 0; i < itemList.length; i++) {
      final rollCallItem = itemList[i]!;
      if (rollCallItem.value == 0) continue;
      _dataMap[rollCallItem.date!.dateFormat('d-MMM-yyyy')] ??= '';
      _dataMap[rollCallItem.date!.dateFormat('d-MMM-yyyy')] = (_dataMap[rollCallItem.date!.dateFormat('d-MMM-yyyy')] as String) + ' ${rollCallItem.lessonName}' + '-' + 'rollcall${rollCallItem.value}'.translate;
    }
    _dataMap.entries.forEach((element) {
      final _itemWidget = pw.Row(children: [
        ...[
          [element.key, 1],
          [element.value.trim(), 4],
        ]
            .map(
              (e) => pw.Expanded(
                  flex: e[1] as int,
                  child: PrintWidgetHelper.myBorderedContainer(
                    padding: 2,
                    text: e.first as String,
                    height: 20,
                    bold: false,
                    maxLines: 1,
                    alignmentIsCenter: true,
                    fontSize: 8,
                    textAlign: pw.TextAlign.center,
                  )),
            )
            .toList(),
      ]);
      widgetList.add(_itemWidget);
    });

    return widgetList;
  }

  static List<pw.Widget> _p2pWidgets(String menuName, List<P2PModel?> itemList) {
    List<pw.Widget> widgetList = [];
    widgetList.add(pw.SizedBox(height: 4));
    widgetList.add(PrintWidgetHelper.myTextContainer(color: GlassIcons.announcementIcon.color!.toPdfColor.flatten(), text: menuName, bold: true, padding: 4));
    final _headerWidget = pw.Row(children: [
      ...[
        ['date'.translate, 3],
        ['duration'.translate, 2],
        ['teacher'.translate, 5],
        ['lesson'.translate, 4],
        ['rollcall'.translate, 2],
        ['content'.translate, 6],
      ]
          .map(
            (e) => pw.Expanded(
                flex: e[1] as int,
                child: PrintWidgetHelper.myBorderedContainer(
                  padding: 2,
                  text: e.first as String,
                  height: 20,
                  bold: true,
                  maxLines: 1,
                  alignmentIsCenter: true,
                  fontSize: 10,
                  textAlign: pw.TextAlign.center,
                )),
          )
          .toList(),
    ]);
    widgetList.add(_headerWidget);

    for (var i = 0; i < itemList.length; i++) {
      //? Bu kisim [P2PMiniWidget] icerisindede var
      final p2pItem = itemList[i]!;
      if (p2pItem.aktif == false) continue;
      final _teacher = AppVar.appBloc.teacherService!.dataListItem(p2pItem.teacherKey!);

      if (_teacher == null) continue;

      String? branchText;
      if (AppVar.appBloc.hesapBilgileri.gtMT && p2pItem.studentRequestLessonKey != null) {
        final _lesson = AppVar.appBloc.lessonService!.dataListItem(p2pItem.studentRequestLessonKey!);
        if (_lesson != null) {
          branchText = (_lesson.branch ?? _lesson.name);
        }
      }
      if (branchText == null && _teacher.branches != null && _teacher.branches!.isNotEmpty) {
        branchText = _teacher.branches!.first;
      }
      //? Buraya kadar

      final _itemWidget = pw.Row(children: [
        ...[
          [p2pItem.startTimeFullText, 3],
          [p2pItem.duration.toString(), 2],
          [_teacher.name, 5],
          [branchText?.toString() ?? '', 4],
          [
            p2pItem.rollCall == true
                ? 'rollcall0'.translate
                : p2pItem.rollCall == false
                    ? 'rollcall1'.translate
                    : '',
            2
          ],
          [p2pItem.note?.firstXcharacter(25) ?? '', 6],
        ]
            .map(
              (e) => pw.Expanded(
                  flex: e[1] as int,
                  child: PrintWidgetHelper.myBorderedContainer(
                    padding: 2,
                    text: e.first as String,
                    height: 20,
                    bold: false,
                    maxLines: 1,
                    alignmentIsCenter: true,
                    fontSize: 8,
                    textAlign: pw.TextAlign.center,
                  )),
            )
            .toList(),
      ]);
      widgetList.add(_itemWidget);
    }

    return widgetList;
  }

  static List<pw.Widget> _examWidgets(String menuName, List<PortfolioExamReport?> reports) {
    List<pw.Widget> widgetList = [];
    widgetList.add(PrintWidgetHelper.myTextContainer(color: GlassIcons.exam.color!.toPdfColor.flatten(), text: menuName, bold: true, padding: 4));

//? Aslinda exam types uzerinden ayni sinav tipi olup olmadigi hesaplanmali fakat examtypekey 3 aralik 2022 de kondu bu ozelligi 2023 agustostan sonra degistirebilirsin
    // final Set<String> examTypes = {};
    // reports.forEach((element) {
    //   examTypes.add(element.exam.examType.key);
    // });
    final Set<String> examTypesFromLessons = {};
    reports.forEach((element) {
      examTypesFromLessons.add((element!.examType.lessons!.map((e) => e.key).toList()..sort()).join());
    });

    examTypesFromLessons.forEach((examKey) {
      final _thisExamTypeReports = reports.where((element) => (element!.examType.lessons!.map((e) => e.key).toList()..sort()).join() == examKey);
      final examtype = _thisExamTypeReports.first!.examType;
      final _examtypeNameWidget = PrintWidgetHelper.myTextContainer(color: GlassIcons.exam.color!.toPdfColor.flatten(), text: examtype.name!, bold: true, padding: 4);
      widgetList.add(pw.SizedBox(height: 2));
      widgetList.add(_examtypeNameWidget);

      final useVerticalNames = examtype.lessons!.length + examtype.scoring!.length > 11;
      final _examtypeHeaderWidget = pw.Row(children: [
        pw.SizedBox(width: 120),
        ...[
          ...examtype.lessons!.map((e) => e.name!).toList(),
          ...examtype.scoring!.map((e) => e.name!).toList(),
        ]
            .map(
              (e) => pw.Expanded(
                  child: PrintWidgetHelper.myBorderedContainer(
                padding: 2,
                text: e,
                height: 40,
                bold: true,
                maxLines: useVerticalNames ? 1 : 2,
                alignmentIsCenter: true,
                fontSize: useVerticalNames ? 7 : 8,
                textAlign: pw.TextAlign.center,
                rotate: useVerticalNames ? 1 : 0,
                // useFittedBox: rowItemCount < 12,
              )),
            )
            .toList(),
      ]);
      widgetList.add(_examtypeHeaderWidget);
      _thisExamTypeReports.forEach((examInfo) {
        final _examInfoWidget = pw.Row(children: [
          pw.SizedBox(width: 120, height: 30, child: PrintWidgetHelper.myBorderedContainer(padding: 2, text: examInfo!.exam.name!, height: 30, bold: true, alignmentIsCenter: true, fontSize: 10, textAlign: pw.TextAlign.center, maxLines: 2)),
          ...[
            ...examtype.lessons!.map((lesson) {
              final result = examInfo.result.testResults![lesson.key]!;
              return result.n!.toStringAsFixed(2);
            }).toList(),
            ...examtype.scoring!.map((score) {
              final result = examInfo.result.scoreResults![score.key]!;
              return result.score.toStringAsFixed(2);
            }).toList(),
          ]
              .map(
                (e) => pw.Expanded(child: PrintWidgetHelper.myBorderedContainer(padding: 2, text: e, height: 30, bold: false, alignmentIsCenter: true, fontSize: useVerticalNames ? 7 : 11, rotate: useVerticalNames ? 1 : 0, useFittedBox: !useVerticalNames)),
              )
              .toList(),
        ]);
        widgetList.add(_examInfoWidget);
      });
    });

    return widgetList;
  }

  static Future<pw.Widget> _headerWidget(Student student) async {
    final _studentImgUrl = student.imgUrl.safeLength > 6 ? student.imgUrl! : AppVar.appBloc.schoolInfoService!.singleData!.logoUrl!;
    return pw.Padding(
        padding: pw.EdgeInsets.symmetric(vertical: 8),
        child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Image(pw.MemoryImage((await DownloadManager.downloadThenCache(url: _studentImgUrl))!.byteData), width: 100, height: 100, alignment: pw.Alignment.center, fit: pw.BoxFit.contain),
          pw.SizedBox(width: 16),
          pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
            PrintWidgetHelper.myTextContainer(color: GlassIcons.portfolio.color!.toPdfColor.flatten(), text: 'studentinfo'.translate, bold: true, padding: 4),
            ...[
              ['namesurname'.translate, student.name],
              ['studentno'.translate, student.no],
              ['schoolname'.translate, AppVar.appBloc.schoolInfoService!.singleData!.name],
              ['class'.translate, AppVar.appBloc.classService!.dataListItem(student.class0!)?.name ?? ''],
            ]
                .map((e) => pw.Row(children: [
                      pw.Expanded(child: PrintWidgetHelper.myBorderedContainer(padding: 4, text: e.first as String, height: 24, bold: true, fontSize: 10), flex: 2),
                      pw.Expanded(child: PrintWidgetHelper.myBorderedContainer(padding: 4, text: e.last as String, height: 24, bold: false, alignmentIsCenter: false, fontSize: 10), flex: 5),
                    ]))
                .toList(),
          ])),
          pw.SizedBox(width: 16),
          pw.Image(pw.MemoryImage((await DownloadManager.downloadThenCache(url: AppVar.appBloc.schoolInfoService!.singleData!.logoUrl!))!.byteData), width: 100, height: 100, alignment: pw.Alignment.center, fit: pw.BoxFit.contain),
        ]));
  }

  static Future<List<PortfolioType>> _chooseTypes(Map<PortfolioType, String> portfolioMap) async {
    final List? _selectedItems = await (OverBottomSheet.show(BottomSheetPanel.multipleSelectList(
        okButtonText: 'print'.translate.toUpperCase(),
        initialValue: portfolioMap.entries.map((item) => item.key).toList(),
        items: portfolioMap.entries
            .map((item) => BottomSheetItem(
                  name: item.value,
                  value: item.key,
                ))
            .toList())));
    return _selectedItems?.cast<PortfolioType>() ?? [];
  }
}
