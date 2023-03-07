import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../models/allmodel.dart';
import '../../helper.dart';
import '../../programlistmodels.dart';
import '../../widgets/widgets.dart';

class CheckClassProgramController extends GetxController {
  var itemList = <Class>[];
  var filteredItemList = <Class>[];
  String filteredText = '';

  Class? selectedItem;

  bool isPageLoading = true;

  Map? data;

  var formKey = GlobalKey<FormState>();
  TimeTableSettings timeTableSettings = TimeTableSettings();

  late Map _fullProgram;
  CheckClassProgramController({Class? initialItem}) {
    itemList = AppVar.appBloc.classService!.dataList;
    Future.delayed(const Duration(milliseconds: 10)).then((_) {
      if (AppVar.appBloc.schoolTimesService!.dataList.isEmpty || AppVar.appBloc.schoolTimesService!.dataList.last.activeDays == null) {
        Get.back();
        OverAlert.show(type: AlertType.danger, message: 'schooltimeswarning'.translate);
      } else {
        _fullProgram = ProgramHelper.getLastSturdyProgram();

        isPageLoading = false;

        if (initialItem != null) {
          filteredText = initialItem.name.toSearchCase();
          selectClass(initialItem);
        }
        makeFilter(filteredText);
        update();
      }
    });
  }

  VisibleScreen visibleScreen = VisibleScreen.main;
  @override
  void onInit() {
    super.onInit();
  }

  int filteredClassType = 0;
  void makeFilter(String text) {
    filteredText = text.toSearchCase();
    // if (filteredText == '') {
    //   filteredItemList = itemList;
    // } else {
    //   filteredItemList = itemList.where((e) => e.getSearchText.contains(filteredText)).toList();
    // }

    if (filteredText == '' && filteredClassType == -1) {
      filteredItemList = itemList;
    } else {
      filteredItemList = itemList.where((e) => e.getSearchText.contains(filteredText)).where((item) => filteredClassType == -1 || filteredClassType == item.classType).toList();
    }
  }

  Map? getClassProgram(String? classKey) {
    Map? _result = _fullProgram[classKey];
    return jsonDecode(jsonEncode(_result ?? {}));
  }

  @override
  void onClose() {
    super.onClose();
  }

  void detailBackButtonPressed() {
    selectedItem = null;
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.main;
    update();
  }

  void selectClass(Class item) {
    selectedItem = item;

    data = getClassProgram(selectedItem!.key);

    ///Burada birlestirilmis siniflarin datasi eklenecek
    final _data = ProgramHelper.getClassTypeAndClassAnalyseData()!;

    final _classReletaionList = _data[selectedItem!.key] ?? {};
    _classReletaionList.forEach((concatenatedClass) {
      final _concatenatedClassProgram = getClassProgram(concatenatedClass);

      final _otherClass = AppVar.appBloc.classService!.dataListItem(concatenatedClass!);

      if (_otherClass != null) {
        final _classTypeName = AppVar.appBloc.schoolInfoService!.singleData!.filteredClassType!['t' + _otherClass.classType.toString()];

        _concatenatedClassProgram!.entries.forEach((programItemEntry) {
          if (_otherClass.classType != null && _classTypeName != null) {
            if (data![programItemEntry.key] == null || (data![programItemEntry.key] is String && AppVar.appBloc.lessonService!.dataList.singleWhereOrNull((lesson) => lesson.key == data![programItemEntry.key]) == null)) {
              data![programItemEntry.key] = [_classTypeName];
            } else if (data![programItemEntry.key] is String) {
              //Bisey Yapma
            } else if (data![programItemEntry.key] is List) {
              data![programItemEntry.key] = {...(data![programItemEntry.key] as List), _classTypeName}.toList();
            }
          }
        });
      }
    });

    ///Birlestirilmis sinif islemi bitti Bitti

    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  Map sinifSaatSayisi = {};
  Widget getCell(int day, int lessonNo) {
    final _lessonKey = data!['$day-$lessonNo'];

    ///Liste geldiyse birlestirilmis siniflarin isimleri gelmistir
    if (_lessonKey is List) {
      final _name = _lessonKey.fold<String>('', (p, classTypeName) {
        return p.contains(classTypeName) ? p : (p += ' $classTypeName');
      });
      return TimeTableContainer(
        alignment: Alignment.center,
        color: _name.safeLength < 1 ? const Color(0xff24262A) : Colors.deepPurpleAccent,
        borderRadius: 4,
        width: timeTableSettings.cellWidth,
        height: timeTableSettings.cellHeight,
        horizantalMargin: 1,
        verticalMargin: 1,
        child: _name.text.maxLines(2).autoSize.color(Colors.white).center.make(),
      );
    } else {
      var lesson = AppVar.appBloc.lessonService!.dataList.singleWhereOrNull((lesson) => lesson.key == _lessonKey);

      if (lesson != null) {
        final String name = lesson.name!;
        final String teacherName = AppVar.appBloc.teacherService!.dataList.singleWhere((teacher) => lesson.teacher == teacher.key, orElse: () => Teacher()..name = '-').name!;
        sinifSaatSayisi[name + '*-*' + teacherName] = (sinifSaatSayisi[name + '*-*' + teacherName] ?? 0) + 1;
      }

      return TimeTableContainer(
        alignment: Alignment.center,
        color: lesson == null ? const Color(0xff24262A) : Color(int.tryParse('0xff${lesson.color}')!),
        borderRadius: 4,
        width: timeTableSettings.cellWidth,
        height: timeTableSettings.cellHeight,
        horizantalMargin: 1,
        verticalMargin: 1,
        child: Text(lesson == null ? '' : lesson.name!, style: TextStyle(color: Colors.white)),
      );
    }
  }

  Widget getTeacherProgram() {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              TimeTableContainer(
                width: timeTableSettings.cellWidth,
                height: timeTableSettings.lessonNumberHeight,
                horizantalMargin: 1,
                verticalMargin: 1,
                alignment: Alignment.center,
              ),
              for (var i = 1; i < AppVar.appBloc.schoolTimesService!.dataList.last.getWeekDaysLessonCountForUse! + 1; i++)
                TimeTableContainer(
                  alignment: Alignment.center,
                  color: Fav.design.bottomNavigationBar.background,
                  borderRadius: 4,
                  //   decoration: BoxDecoration(color:  Fav.design.bottomNavigationBar.background, borderRadius: BorderRadius.circular(4.0), boxShadow: [BoxShadow(color:  Fav.design.bottomNavigationBar.background.withAlpha(180), blurRadius: 1)]),
                  width: timeTableSettings.cellWidth,
                  height: timeTableSettings.lessonNumberHeight + 13,
                  horizantalMargin: 1,
                  verticalMargin: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('$i', style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
                      //  MaterialAndPrintWidget.Text('${timeToString(AppVar.appBloc.schoolTimesService.dataList.last.weekdaysLessonTimes[i - 1].first ?? 0)}', widgetType: widgetType, fontSize: 8, materialTextColor: Fav.design.primaryText, printTextColor: PdfColors.black),
                    ],
                  ),
                )
            ]),
            ...[1, 2, 3, 4, 5].map((day) {
              final dayName = DateTime(2019, 7, day).dateFormat('EEE');
              return Row(
                children: [
                  TimeTableContainer(
                    alignment: Alignment.center,
                    color: Fav.design.bottomNavigationBar.background,
                    borderRadius: 4.0,
                    verticalMargin: 1,
                    horizantalMargin: 1,
                    width: timeTableSettings.cellWidth,
                    height: timeTableSettings.cellHeight,
                    child: Text(dayName, style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
                  ),
                  for (var i = 1; i < AppVar.appBloc.schoolTimesService!.dataList.last.getWeekDaysLessonCountForUse! + 1; i++) getCell(day, i)
                ],
              );
            }).toList(),
            SizedBox(height: 8),
            Row(children: [
              TimeTableContainer(
                horizantalMargin: 1,
                verticalMargin: 1,
                width: timeTableSettings.cellWidth,
                height: timeTableSettings.lessonNumberHeight,
                alignment: Alignment.center,
              ),
              for (var i = 1; i < AppVar.appBloc.schoolTimesService!.dataList.last.getWeekEndLessonCountForUse! + 1; i++)
                TimeTableContainer(
                  alignment: Alignment.center,
                  color: Fav.design.bottomNavigationBar.background,
                  borderRadius: 4.0,
                  width: timeTableSettings.cellWidth,
                  height: timeTableSettings.lessonNumberHeight + 13,
                  horizantalMargin: 1,
                  verticalMargin: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('$i', style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
                      //       MaterialAndPrintWidget.Text('${timeToString(AppVar.appBloc.schoolTimesService.dataList.last.weekendsLessonTimes[i - 1].first ?? 0)}', widgetType: widgetType, materialTextColor: Fav.design.primaryText, fontSize: 8),
                    ],
                  ),
                )
            ]),
            ...[6, 7].map((day) {
              final dayName = DateTime(2019, 7, day).dateFormat('EEE');
              return Row(
                children: [
                  TimeTableContainer(
                    alignment: Alignment.center,
                    color: Fav.design.bottomNavigationBar.background,
                    borderRadius: 4.0,
                    width: timeTableSettings.cellWidth,
                    height: timeTableSettings.cellHeight,
                    horizantalMargin: 1,
                    verticalMargin: 1,
                    child: Text(dayName, style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
                  ),
                  for (var i = 1; i < AppVar.appBloc.schoolTimesService!.dataList.last.getWeekEndLessonCountForUse! + 1; i++) getCell(day, i)
                ],
              );
            }).toList()
          ],
        ),
      ],
    );
  }

  Widget getDetailWidget() {
    var keys = sinifSaatSayisi.keys.toList();
    return Wrap(
      spacing: 8,
      children: [for (var i = 0; i < keys.length; i++) MyKeyValueText(textKey: (keys[i] as String).split('*-*').first + ' (' + sinifSaatSayisi[keys[i]].toString() + ')', value: (keys[i] as String).split('*-*').last, fontSize: 12, color: Fav.design.primaryText)],
    );
  }
}
