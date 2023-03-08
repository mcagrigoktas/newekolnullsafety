import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../models/allmodel.dart';
import '../../../../timetable/lessondetail/lessondetailteacher.dart';
import '../../helper.dart';
import '../../programlistmodels.dart';
import '../../widgets/widgets.dart';

class CheckTeacherProgramController extends GetxController {
  var itemList = <Teacher>[];
  var filteredItemList = <Teacher>[];
  String filteredText = '';

  Teacher? selectedItem;

  bool isPageLoading = true;

  // time,[classKey,Lesson]
  List<ProgramItem> data = [];

  var formKey = GlobalKey<FormState>();
  TimeTableSettings timeTableSettings = TimeTableSettings();

  CheckTeacherProgramController({Teacher? initialItem}) {
    itemList = AppVar.appBloc.teacherService!.dataList;
    Future.delayed(const Duration(milliseconds: 10)).then((_) {
      if (AppVar.appBloc.schoolTimesService!.dataList.isEmpty || AppVar.appBloc.schoolTimesService!.dataList.last.activeDays == null) {
        Get.back();
        OverAlert.show(type: AlertType.danger, message: 'schooltimeswarning'.translate);
      } else {
        isPageLoading = false;

        if (initialItem != null) {
          filteredText = initialItem.name.toSearchCase();
          selectTeacher(initialItem);
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

  void makeFilter(String text) {
    filteredText = text.toLowerCase();
    if (filteredText == '') {
      filteredItemList = itemList;
    } else {
      filteredItemList = itemList.where((e) => e.getSearchText.contains(filteredText)).toList();
    }
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

  void selectTeacher(Teacher item) {
    selectedItem = item;

    final _sturdyProgram = ProgramHelper.getLastSturdyProgram();
    data = ProgramHelper.getTeacherAllLessonFromTimeTable(item.key, _sturdyProgram);

    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  int toplamDersSaati = 0;
  Map sinifSaatSayisi = {};
  Widget getCell(int day, int lessonNo) {
    final data2 = data.firstWhereOrNull((element) => element.day == day && element.lessonNo == lessonNo);

    if (data2 != null) {
      toplamDersSaati++;
      var sinifAdi = AppVar.appBloc.classService!.dataList.singleWhereOrNull((sinif) => data2.lesson!.classKey == sinif.key)?.name ?? '-';
      sinifSaatSayisi[sinifAdi] = (sinifSaatSayisi[sinifAdi] ?? 0) + 1;
    }

    Widget current = TimeTableContainer(
      alignment: Alignment.center,
      color: data2 == null ? const Color(0xff24262A) : data2.lesson!.color.parseColor,
      borderRadius: 4,
      width: timeTableSettings.cellWidth,
      height: timeTableSettings.cellHeight,
      horizantalMargin: 1,
      verticalMargin: 1,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          TextSpan(text: AppVar.appBloc.classService!.dataList.singleWhereOrNull((sinif) => sinif.key == (data2?.lesson?.classKey))?.name ?? '', style: TextStyle(color: Colors.white, fontSize: 14)),
          TextSpan(text: data2 == null ? '' : ('\n' + data2.lesson!.name), style: TextStyle(color: Colors.white, fontSize: 11)),
        ]),
      ),
    );

    if (data2 != null) {
      current = GestureDetector(
        onTap: () {
          Fav.to(LessonDetailTeacher(lesson: data2.lesson, classKey: data2.lesson!.classKey));
        },
        child: current,
      );
    }

    return current;
  }

  Widget getTeacherProgram() {
    toplamDersSaati = 0;
    return Column(
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
              width: timeTableSettings.cellWidth,
              height: timeTableSettings.lessonNumberHeight + 13,
              horizantalMargin: 1,
              verticalMargin: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('$i', style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
                  //       MaterialAndPrintWidget.Text('${timeToString(AppVar.appBloc.schoolTimesService.dataList.last.weekdaysLessonTimes[i - 1].first ?? 0)}', widgetType: widgetType, printTextColor: PdfColors.black, materialTextColor: Fav.design.primaryText, fontSize: 8),
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
                borderRadius: 4,
                width: timeTableSettings.cellWidth,
                height: timeTableSettings.cellHeight,
                horizantalMargin: 1,
                verticalMargin: 1,
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

            //    decoration: BoxDecoration(border: Border.all(color:  Fav.design.primaryText.withAlpha(20),width: 0.5)),
            alignment: Alignment.center,
            //  child: Text(  'weekends'),style: TextStyle(color:  Fav.design.accentText,fontSize:8,fontWeight: FontWeight.bold),),
          ),
          for (var i = 1; i < AppVar.appBloc.schoolTimesService!.dataList.last.getWeekEndLessonCountForUse! + 1; i++)
            TimeTableContainer(
              alignment: Alignment.center,
              color: Fav.design.bottomNavigationBar.background,
              borderRadius: 4,
              width: timeTableSettings.cellWidth,
              height: timeTableSettings.lessonNumberHeight + 13,
              horizantalMargin: 1,
              verticalMargin: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('$i', style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
                  //       MaterialAndPrintWidget.Text('${timeToString(AppVar.appBloc.schoolTimesService.dataList.last.weekendsLessonTimes[i - 1].first ?? 0)}', widgetType: widgetType, printTextColor: PdfColors.black, fontSize: 8, materialTextColor: Fav.design.primaryText),
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
                borderRadius: 4,
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
    );
  }

  Widget getDetailWidget() {
    var keys = sinifSaatSayisi.keys.toList();
    keys.sort((a, b) => a.compareTo(b));
    return Wrap(
      spacing: 8,
      children: [
        for (var i = 0; i < keys.length; i++)
          MyKeyValueText(
            textKey: keys[i],
            value: sinifSaatSayisi[keys[i]].toString(),
            fontSize: 12,
            color: Fav.design.primaryText,
          ),
      ],
    );
  }

  Widget getDetailWidget2() {
    return MyKeyValueText(
      textKey: 'totallessoncount'.translate,
      value: toplamDersSaati.toString(),
      fontSize: 15,
      color: Fav.design.primaryText,
    );
  }
}
