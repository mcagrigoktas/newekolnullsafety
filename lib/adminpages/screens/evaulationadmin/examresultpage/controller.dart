// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:pdf/src/pdf/color.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../appbloc/appvar.dart';
import '../../../../screens/portfolio/model.dart';
import '../../../../screens/portfolio/widgets/portfolio_items/examreportwidget.dart';
import '../../../../services/smssender.dart';
import '../examresultcalcalculator.dart';
import '../exams/model.dart';
import '../examtypes/model.dart';
import '../helper.dart';
import '../widgets.dart';
import 'graphics/studentresultgraphic1.dart';

class ExamResultViewController extends GetxController {
  final Exam? exam;
  final ExamType? examType;
  EvaulationUserType? girisTuru;
  String? kurumId;
  int sortColumnIndex = 1;
  bool showTrueFalse = true;
  ExamResultBigData? examResultBigData;
  Map<String?, Map<String?, ResultModel?>?>? get allKurumAllStudentResults => examResultBigData!.examResult;
  ExamResultViewController({this.examResultBigData, this.girisTuru, this.examType, this.exam});

  List<String> lessonSettingsList = ['eds', 'eys', 'ebs', 'ens', 'ewds', 'ewys', 'ewbs', 'etga', 'etsa', 'etca', 'ep', 'esa'];
  List<double> lessonSettingsWidthList = [60, 60, 60, 60, 60, 60, 60, 90, 90, 90, 100, 250];
  List<String> totalResultList = ['eds', 'eys', 'ebs', 'ens', 'ewds', 'ewys', 'ewbs'];
  List<double> totalResultWidthList = [60, 60, 60, 60, 60, 60, 60];
  List<String> scoreSettingsList = ['ess', 'esga', 'essa', 'esca', 'esgo', 'esso', 'esco'];
  List<double> scoreSettingsWidthList = [120, 90, 90, 90, 60, 60, 60];
  List<String>? filterSettings = ['eds', 'eys', 'ens', 'etga'];
  List<String>? scoreSettings = ['ess', 'esgo'];

  List<String> filtrLessonList = [];
  List<String> filteredClassList = ['all'];
  String? errorText;
  @override
  void onInit() {
    super.onInit();

    if (girisTuru == EvaulationUserType.school) {
      kurumId = AppVar.appBloc.hesapBilgileri.kurumID;
    } else {
      kurumId = allKurumAllStudentResults!.keys.first;
    }
    filtrLessonList = examType!.lessons!.map((e) => e.key!).toList();

    ///burda kurum sayfasi icin  sinif listsi cachlaniyor
    if (girisTuru == EvaulationUserType.school) {
      final studentKeyResultModelMap = allKurumAllStudentResults![kurumId];
      if (studentKeyResultModelMap == null) {
        errorText = 'examforinsterr'.translate;
      } else {
        final resultModelList = studentKeyResultModelMap.values.toList();
        resultModelList.forEach((element) {
          allClassList.add(element!.rSClass);
        });
      }
    }
  }

  Set<String?> allClassList = {};

  ///[no,name,class,booklettype,lessonresult,scoreresult]
  static const List<double?> cellWidthList = [100, 200, 100, 50, null, 40, 50];
  static const List<double> cellHeightList = [55, 30];

  double get lessonWidth => filterSettings!.fold<double>(0.0, (p, e) => p + lessonSettingsWidthList[lessonSettingsList.indexOf(e)]);
  double get scoreWidth => scoreSettings!.fold<double>(0.0, (p, e) => p + scoreSettingsWidthList[scoreSettingsList.indexOf(e)]);
  double get totalResultWidh => filterSettings!.where((element) => totalResultList.contains(element)).fold<double>(0.0, (p, e) => p + totalResultWidthList[totalResultList.indexOf(e)]);

  Widget get headerWidget {
    filterSettings!.sort((a, b) => lessonSettingsList.indexOf(a).compareTo(lessonSettingsList.indexOf(b)));
    scoreSettings!.sort((a, b) => scoreSettingsList.indexOf(a).compareTo(scoreSettingsList.indexOf(b)));
    return Row(children: [
      SizedBox(width: cellWidthList[6]),
      SizedBox(
        width: cellWidthList[5]! * 2,
        height: cellHeightList[0],
      ),
      CellWidget(
        width: cellWidthList[0],
        height: cellHeightList[0],
        background: Fav.design.primaryText.withAlpha(20),
        text: 'studentno'.translate,
        icon: Icons.sort,
        iconDataActive: sortColumnIndex == 0,
        onTap: () {
          sortColumnIndex = 0;
          update();
        },
      ),
      CellWidget(
        width: cellWidthList[1],
        height: cellHeightList[0],
        background: Fav.design.primaryText.withAlpha(20),
        text: 'name'.translate,
        icon: Icons.sort,
        iconDataActive: sortColumnIndex == 1,
        onTap: () {
          sortColumnIndex = 1;
          update();
        },
      ),
      CellWidget(
        width: cellWidthList[2],
        height: cellHeightList[0],
        background: Fav.design.primaryText.withAlpha(20),
        text: 'class'.translate,
        icon: Icons.sort,
        iconDataActive: sortColumnIndex == 2,
        onTap: () {
          sortColumnIndex = 2;
          update();
        },
      ),
      CellWidget(
        width: cellWidthList[3],
        height: cellHeightList[0],
        background: Fav.design.primaryText.withAlpha(20),
        text: 'booklettype'.translate,
      ),
      for (var l = 0; l < examType!.lessons!.length; l++)
        if (filtrLessonList.contains(examType!.lessons![l].key))
          Column(
            children: [
              CellWidget(
                width: lessonWidth,
                height: cellHeightList[0] - 20,
                background: Fav.design.primaryText.withAlpha(20),
                text: examType!.lessons![l].name,
                icon: Icons.sort,
                iconDataActive: sortColumnIndex == l + 4,
                onTap: () {
                  sortColumnIndex = l + 4;
                  update();
                },
              ),
              SizedBox(
                width: lessonWidth,
                height: 20,
                child: Row(
                  children: filterSettings!.map((e) => MiniCellWidget(width: lessonSettingsWidthList[lessonSettingsList.indexOf(e)], text: e.translate, height: 30, background: Fav.design.primaryText.withAlpha(20))).toList(),
                ),
              )
            ],
          ),
      Column(
        children: [
          CellWidget(
            width: totalResultWidh,
            height: cellHeightList[0] - 20,
            background: Fav.design.primaryText.withAlpha(20),
            text: 'total'.translate,
            icon: Icons.sort,
            iconDataActive: sortColumnIndex == 1000,
            onTap: () {
              sortColumnIndex = 1000;
              update();
            },
          ),
          SizedBox(
            width: totalResultWidh,
            height: 20,
            child: Row(
              children: filterSettings!.where((element) => totalResultList.contains(element)).map((e) => MiniCellWidget(width: lessonSettingsWidthList[lessonSettingsList.indexOf(e)], text: e.translate, height: 30, background: Fav.design.primaryText.withAlpha(20))).toList(),
            ),
          )
        ],
      ),
      for (var s = 0; s < examType!.scoring!.length; s++)
        Column(
          children: [
            CellWidget(
              width: scoreWidth,
              height: cellHeightList[0] - 20,
              background: Fav.design.primaryText.withAlpha(20),
              text: examType!.scoring![s].name,
              icon: Icons.sort,
              iconDataActive: sortColumnIndex == s + examType!.lessons!.length + 4,
              onTap: () {
                sortColumnIndex = s + examType!.lessons!.length + 4;
                update();
              },
            ),
            SizedBox(
              width: scoreWidth,
              height: 20,
              child: Row(
                children: scoreSettings!.map((e) => MiniCellWidget(width: scoreSettingsWidthList[scoreSettingsList.indexOf(e)], text: e.translate, height: 30, background: Fav.design.primaryText.withAlpha(20))).toList(),
              ),
            )
          ],
        ),
    ]);
  }

  int _resultModelSortFunction(ResultModel? a, ResultModel? b) {
    if (sortColumnIndex == 0) return a!.rSNo!.compareTo(b!.rSNo!);
    if (sortColumnIndex == 1) return a!.rSName!.compareTo(b!.rSName!);
    if (sortColumnIndex == 2) return a!.rSClass!.compareTo(b!.rSClass!);
    if (sortColumnIndex == 1000) return b!.totalNet.compareTo(a!.totalNet);
    //   if (sortColumnIndex == 3) return a.bookletType.compareTo(b.bookletType);

    if (sortColumnIndex > 3 && sortColumnIndex < examType!.lessons!.length + 4) return b!.testResults![examType!.lessons![sortColumnIndex - 4].key]!.n!.compareTo(a!.testResults![examType!.lessons![sortColumnIndex - 4].key]!.n!);

    if (sortColumnIndex > examType!.lessons!.length + 3 && sortColumnIndex < examType!.lessons!.length + examType!.scoring!.length + 4) {
      return b!.scoreResults![examType!.scoring![sortColumnIndex - 4 - examType!.lessons!.length].key]!.score.compareTo(a!.scoreResults![examType!.scoring![sortColumnIndex - 4 - examType!.lessons!.length].key]!.score);
    }

    return 1;
  }

  bool _isThisClassFiltered(String? classKey) {
    if (filteredClassList.isEmpty) return true;
    if (!filteredClassList.contains('all') && !filteredClassList.contains(classKey)) return true;
    return false;
  }

  Widget get bodyWidget {
    final studentKeyResultModelMap = allKurumAllStudentResults![kurumId]!;
    final resultModelList = studentKeyResultModelMap.values.toList();
    resultModelList.sort(_resultModelSortFunction);
    return SizedBox(
      width: cellWidthList[6]! + cellWidthList[0]! + cellWidthList[1]! + cellWidthList[2]! + cellWidthList[3]! + lessonWidth * filtrLessonList.length + totalResultWidh + scoreWidth * examType!.scoring!.length + cellWidthList[5]! + cellWidthList[5]!,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: resultModelList.length,
        itemBuilder: (context, index) {
          final item = resultModelList[index]!;

          if (_isThisClassFiltered(item.rSClass)) return SizedBox();

          return Row(
            key: ObjectKey(item),
            children: [
              CellWidget(
                width: cellWidthList[6],
                height: cellHeightList[1],
                background: Fav.design.primaryText.withAlpha(index % 2 == 0 ? 10 : 25),
                text: (index + 1).toString(),
                padding: 0,
              ),
              CellWidget(
                padding: 0,
                width: cellWidthList[5],
                height: cellHeightList[1],
                background: Fav.design.primaryText.withAlpha(20),
                icon: Icons.info,
                iconDataActive: true,
                onTap: () {
                  Map<String, String?> reversedEarninKeyMap = {};
                  if (examResultBigData!.earningIsActive!) {
                    reversedEarninKeyMap = examResultBigData!.earninKeyMap!.map((key, value) => MapEntry(value, key));
                  }
                  //Burda yeni bottomsheete gececeksen full width lazim olabilir
                  Get.bottomSheet(
                    GestureDetector(
                        onTap: Get.back,
                        child: ExamReportWidget(PortfolioExamReport({
                          'examType': examType!.mapForStudent(),
                          'examData': item.mapForSave(),
                          'exam': exam!.mapForStudent(),
                          'earningResultKeyMap': reversedEarninKeyMap,
                        }))),
                  );
                },
              ),
              CellWidget(
                padding: 0,
                width: cellWidthList[5],
                height: cellHeightList[1],
                background: Fav.design.primaryText.withAlpha(20),
                icon: Icons.pie_chart,
                iconDataActive: true,
                onTap: () {
                  Get.bottomSheet(GestureDetector(onTap: Get.back, child: StudentLessonPerformanceGraphics(examType: examType, resultModel: item)));
                },
              ),
              CellWidget(
                padding: 0,
                width: cellWidthList[0],
                height: cellHeightList[1],
                background: Fav.design.primaryText.withAlpha(index % 2 == 0 ? 10 : 25),
                text: item.rSNo,
              ),
              CellWidget(
                padding: 0,
                width: cellWidthList[1],
                height: cellHeightList[1],
                background: Fav.design.primaryText.withAlpha(index % 2 == 0 ? 10 : 25),
                text: item.rSName,
              ),
              CellWidget(
                padding: 0,
                width: cellWidthList[2],
                height: cellHeightList[1],
                background: Fav.design.primaryText.withAlpha(index % 2 == 0 ? 10 : 25),
                text: item.rSClass,
              ),
              CellWidget(
                padding: 0,
                width: cellWidthList[3],
                height: cellHeightList[1],
                background: Fav.design.primaryText.withAlpha(index % 2 == 0 ? 10 : 25),
                text: item.bookletTypes?.fold<String>('', ((p, e) => p + e!)) ?? '',
              ),
              for (var l = 0; l < examType!.lessons!.length; l++)
                if (filtrLessonList.contains(examType!.lessons![l].key))
                  SizedBox(
                      width: lessonWidth,
                      child: Row(
                        children: [
                          if (filterSettings!.contains('eds'))
                            CellWidget(
                              padding: 0,
                              width: lessonSettingsWidthList[lessonSettingsList.indexOf('eds')],
                              height: cellHeightList[1],
                              background: Colors.green.withAlpha(20),
                              text: item.testResults![examType!.lessons![l].key]!.d.toString(),
                            ),
                          if (filterSettings!.contains('eys'))
                            CellWidget(
                              padding: 0,
                              width: lessonSettingsWidthList[lessonSettingsList.indexOf('eys')],
                              height: cellHeightList[1],
                              background: Colors.red.withAlpha(20),
                              text: item.testResults![examType!.lessons![l].key]!.y.toString(),
                            ),
                          if (filterSettings!.contains('ebs'))
                            CellWidget(
                              padding: 0,
                              width: lessonSettingsWidthList[lessonSettingsList.indexOf('ebs')],
                              height: cellHeightList[1],
                              background: Colors.white.withAlpha(20),
                              text: item.testResults![examType!.lessons![l].key]!.b.toString(),
                            ),
                          if (filterSettings!.contains('ens'))
                            CellWidget(
                              padding: 0,
                              width: lessonSettingsWidthList[lessonSettingsList.indexOf('ens')],
                              height: cellHeightList[1],
                              background: Colors.yellow.withAlpha(20),
                              text: item.testResults![examType!.lessons![l].key]!.n!.toStringAsFixed(2),
                            ),
                          if (filterSettings!.contains('ewds'))
                            CellWidget(
                              padding: 0,
                              width: lessonSettingsWidthList[lessonSettingsList.indexOf('ewds')],
                              height: cellHeightList[1],
                              background: Colors.green.withAlpha(20),
                              text: item.testResults![examType!.lessons![l].key]!.wd.toString(),
                            ),
                          if (filterSettings!.contains('ewys'))
                            CellWidget(
                              padding: 0,
                              width: lessonSettingsWidthList[lessonSettingsList.indexOf('ewys')],
                              height: cellHeightList[1],
                              background: Colors.red.withAlpha(20),
                              text: item.testResults![examType!.lessons![l].key]!.wy.toString(),
                            ),
                          if (filterSettings!.contains('ewbs'))
                            CellWidget(
                              padding: 0,
                              width: lessonSettingsWidthList[lessonSettingsList.indexOf('ewbs')],
                              height: cellHeightList[1],
                              background: Colors.white.withAlpha(20),
                              text: item.testResults![examType!.lessons![l].key]!.wb.toString(),
                            ),
                          if (filterSettings!.contains('etga'))
                            CellWidget(
                              padding: 0,
                              width: lessonSettingsWidthList[lessonSettingsList.indexOf('etga')],
                              height: cellHeightList[1],
                              background: Colors.deepOrangeAccent.withAlpha(20),
                              text: item.testResults![examType!.lessons![l].key]!.generalAwerage!.toStringAsFixed(2),
                            ),
                          if (filterSettings!.contains('etsa'))
                            CellWidget(
                              padding: 0,
                              width: lessonSettingsWidthList[lessonSettingsList.indexOf('etsa')],
                              height: cellHeightList[1],
                              background: Colors.brown.withAlpha(20),
                              text: item.testResults![examType!.lessons![l].key]!.schoolAwerage!.toStringAsFixed(2),
                            ),
                          if (filterSettings!.contains('etca'))
                            CellWidget(
                              padding: 0,
                              width: lessonSettingsWidthList[lessonSettingsList.indexOf('etca')],
                              height: cellHeightList[1],
                              background: Colors.lightGreenAccent.withAlpha(20),
                              text: item.testResults![examType!.lessons![l].key]!.classAwerage!.toStringAsFixed(2),
                            ),
                          if (filterSettings!.contains('ep'))
                            CellWidget(
                              padding: 0,
                              width: lessonSettingsWidthList[lessonSettingsList.indexOf('ep')],
                              height: cellHeightList[1],
                              background: Colors.lightGreenAccent.withAlpha(20),
                              text: ((item.testResults![examType!.lessons![l].key]!.n! / item.testResults![examType!.lessons![l].key]!.realAnswers!.length) * 100).toStringAsFixed(1) + '%',
                            ),
                          if (filterSettings!.contains('esa'))
                            SizedBox(
                              width: lessonSettingsWidthList[lessonSettingsList.indexOf('esa')],
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (var sa = 0; sa < item.testResults![examType!.lessons![l].key]!.studentAnswers!.length; sa++)
                                      CellWidget(
                                        width: 20,
                                        margin: 0,
                                        height: cellHeightList[1],
                                        background: item.testResults![examType!.lessons![l].key]!.studentAnswers![sa] == ' '
                                            ? Colors.amber
                                            : item.testResults![examType!.lessons![l].key]!.studentAnswers![sa] == item.testResults![examType!.lessons![l].key]!.realAnswers![sa]
                                                ? Colors.green
                                                : Colors.redAccent,
                                        fontSize: 8,
                                        padding: 0,
                                        text: '${sa + 1}\n' + item.testResults![examType!.lessons![l].key]!.studentAnswers![sa].toUpperCase(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      )),
              SizedBox(
                  width: totalResultWidh,
                  child: Row(
                    children: [
                      if (filterSettings!.contains('eds'))
                        CellWidget(
                          width: lessonSettingsWidthList[lessonSettingsList.indexOf('eds')],
                          height: cellHeightList[1],
                          background: Colors.green.withAlpha(20),
                          text: item.totalTrue.toString(),
                          padding: 0,
                        ),
                      if (filterSettings!.contains('eys'))
                        CellWidget(
                          width: lessonSettingsWidthList[lessonSettingsList.indexOf('eys')],
                          height: cellHeightList[1],
                          background: Colors.red.withAlpha(20),
                          text: item.totalFalse.toString(),
                          padding: 0,
                        ),
                      if (filterSettings!.contains('ebs'))
                        CellWidget(
                          width: lessonSettingsWidthList[lessonSettingsList.indexOf('ebs')],
                          height: cellHeightList[1],
                          background: Colors.white.withAlpha(20),
                          text: item.totalBlank.toString(),
                          padding: 0,
                        ),
                      if (filterSettings!.contains('ens'))
                        CellWidget(
                          width: lessonSettingsWidthList[lessonSettingsList.indexOf('ens')],
                          height: cellHeightList[1],
                          background: Colors.yellow.withAlpha(20),
                          text: item.totalNet.toStringAsFixed(2),
                          padding: 0,
                        ),
                      if (filterSettings!.contains('ewds'))
                        CellWidget(
                          width: lessonSettingsWidthList[lessonSettingsList.indexOf('ewds')],
                          height: cellHeightList[1],
                          background: Colors.green.withAlpha(20),
                          text: item.totalWTrue.toString(),
                          padding: 0,
                        ),
                      if (filterSettings!.contains('ewys'))
                        CellWidget(
                          width: lessonSettingsWidthList[lessonSettingsList.indexOf('ewys')],
                          height: cellHeightList[1],
                          background: Colors.red.withAlpha(20),
                          text: item.totalWFalse.toString(),
                          padding: 0,
                        ),
                      if (filterSettings!.contains('ewbs'))
                        CellWidget(
                          width: lessonSettingsWidthList[lessonSettingsList.indexOf('ewbs')],
                          height: cellHeightList[1],
                          background: Colors.white.withAlpha(20),
                          text: item.totalWBlank.toString(),
                          padding: 0,
                        ),
                    ],
                  )),
              for (var s = 0; s < examType!.scoring!.length; s++)
                SizedBox(
                    width: scoreWidth,
                    child: Row(
                      children: [
                        if (scoreSettings!.contains('ess'))
                          CellWidget(
                            padding: 0,
                            width: scoreSettingsWidthList[scoreSettingsList.indexOf('ess')],
                            height: cellHeightList[1],
                            background: Colors.green.withAlpha(20),
                            text: item.scoreResults![examType!.scoring![s].key]!.score.toStringAsFixed(3),
                          ),
                        if (scoreSettings!.contains('esga'))
                          CellWidget(
                            padding: 0,
                            width: scoreSettingsWidthList[scoreSettingsList.indexOf('esga')],
                            height: cellHeightList[1],
                            background: Colors.red.withAlpha(20),
                            text: item.scoreResults![examType!.scoring![s].key]!.generalAwerage!.toStringAsFixed(2),
                          ),
                        if (scoreSettings!.contains('essa'))
                          CellWidget(
                            padding: 0,
                            width: scoreSettingsWidthList[scoreSettingsList.indexOf('essa')],
                            height: cellHeightList[1],
                            background: Colors.brown.withAlpha(20),
                            text: item.scoreResults![examType!.scoring![s].key]!.schoolAwerage!.toStringAsFixed(2),
                          ),
                        if (scoreSettings!.contains('esca'))
                          CellWidget(
                            padding: 0,
                            width: scoreSettingsWidthList[scoreSettingsList.indexOf('esca')],
                            height: cellHeightList[1],
                            background: Colors.purple.withAlpha(20),
                            text: item.scoreResults![examType!.scoring![s].key]!.classAwerage!.toStringAsFixed(2),
                          ),
                        if (scoreSettings!.contains('esgo'))
                          CellWidget(
                            padding: 0,
                            width: scoreSettingsWidthList[scoreSettingsList.indexOf('esgo')],
                            height: cellHeightList[1],
                            background: Colors.blue.withAlpha(20),
                            text: item.scoreResults![examType!.scoring![s].key]!.generalOrder.toString(),
                          ),
                        if (scoreSettings!.contains('esso'))
                          CellWidget(
                            padding: 0,
                            width: scoreSettingsWidthList[scoreSettingsList.indexOf('esso')],
                            height: cellHeightList[1],
                            background: Colors.pinkAccent.withAlpha(20),
                            text: item.scoreResults![examType!.scoring![s].key]!.schoolOrder.toString(),
                          ),
                        if (scoreSettings!.contains('esco'))
                          CellWidget(
                            padding: 0,
                            width: scoreSettingsWidthList[scoreSettingsList.indexOf('esco')],
                            height: cellHeightList[1],
                            background: Colors.tealAccent.withAlpha(20),
                            text: item.scoreResults![examType!.scoring![s].key]!.classOrder.toString(),
                          ),
                      ],
                    )),
            ],
          );
        },
      ),
    ).pt4;
  }

  pw.Widget getPdfPrintHeader() {
    filterSettings!.sort((a, b) => lessonSettingsList.indexOf(a).compareTo(lessonSettingsList.indexOf(b)));
    scoreSettings!.sort((a, b) => scoreSettingsList.indexOf(a).compareTo(scoreSettingsList.indexOf(b)));
    const _height = 20.0;
    return pw.Column(children: [
      pw.Text((exam!.name ?? '') + ' ' + (exam!.date?.dateFormat() ?? ''), style: pw.TextStyle(fontSize: 10)),
      pw.Row(children: [
        pw.SizedBox(width: 15),
        PdfCellWidget.borderedContainer(
          width: 30,
          height: _height,
          background: PdfColor(0, 0, 0, 0.1),
          text: 'studentno'.translate,
        ),
        PdfCellWidget.borderedContainer(
          width: 100,
          height: _height,
          background: PdfColor(0, 0, 0, 0.1),
          text: 'name'.translate,
        ),
        PdfCellWidget.borderedContainer(
          width: 36,
          height: _height,
          background: PdfColor(0, 0, 0, 0.1),
          text: 'class'.translate,
        ),
        PdfCellWidget.borderedContainer(
          width: 10,
          height: _height,
          background: PdfColor(0, 0, 0, 0.1),
          text: ''.translate,
        ),
        for (var l = 0; l < examType!.lessons!.length; l++)
          if (filtrLessonList.contains(examType!.lessons![l].key))
            pw.Expanded(
                child: pw.SizedBox(
                    height: _height,
                    child: pw.Column(
                      children: [
                        PdfCellWidget.borderedContainer(
                          height: 2 * _height / 3,
                          background: PdfColor(0, 0, 0, 0.1),
                          text: examType!.lessons![l].name!,
                        ),
                        pw.SizedBox(
                          height: _height / 3,
                          child: pw.Row(
                            children: filterSettings!.map((e) => PdfCellWidget.borderedContainer(fontSize: 3, flex: 1, text: e.translate, height: _height / 3, background: PdfColor(0, 0, 0, 0.1))).toList(),
                          ),
                        )
                      ],
                    ))),
        pw.Expanded(
            child: pw.SizedBox(
                height: _height,
                child: pw.Column(
                  children: [
                    PdfCellWidget.borderedContainer(
                      height: 2 * _height / 3,
                      background: PdfColor(0, 0, 0, 0.1),
                      text: 'total'.translate,
                    ),
                    pw.SizedBox(
                      height: _height / 3,
                      child: pw.Row(
                        children: filterSettings!.where((element) => totalResultList.contains(element)).map((e) => PdfCellWidget.borderedContainer(fontSize: 3, flex: 1, text: e.translate, height: _height / 3, background: PdfColor(0, 0, 0, 0.1))).toList(),
                      ),
                    )
                  ],
                ))),
        for (var s = 0; s < examType!.scoring!.length; s++)
          pw.Expanded(
              child: pw.SizedBox(
                  height: _height,
                  child: pw.Column(
                    children: [
                      PdfCellWidget.borderedContainer(
                        height: 2 * _height / 3,
                        background: PdfColor(0, 0, 0, 0.1),
                        text: examType!.scoring![s].name!,
                      ),
                      pw.SizedBox(
                        height: _height / 3,
                        child: pw.Row(
                          children: scoreSettings!.map((e) => PdfCellWidget.borderedContainer(fontSize: 3, flex: 1, text: e.translate, height: _height / 3, background: PdfColor(0, 0, 0, 0.1))).toList(),
                        ),
                      )
                    ],
                  ))),
        //  pw.SizedBox(width: 32),
      ])
    ]);
  }

  List<pw.Widget> getPdfPrintBody() {
    final studentKeyResultModelMap = allKurumAllStudentResults![kurumId]!;
    final resultModelList = studentKeyResultModelMap.values.toList();
    resultModelList.sort(_resultModelSortFunction);
    List<pw.Widget> _itemList = [];

    resultModelList.forEach((item) {
      if (_isThisClassFiltered(item!.rSClass)) {
      } else {
        final index = resultModelList.indexOf(item);
        final backgroundColor = PdfColor(0, 0, 0, index % 2 == 0 ? 0.04 : 0.0);
        const _height = 10.0;
        _itemList.add(pw.Row(
          children: [
            PdfCellWidget.borderedContainer(
              width: 15,
              height: _height,
              background: backgroundColor,
              text: (index + 1).toString(),
            ),
            PdfCellWidget.borderedContainer(
              width: 30,
              height: _height,
              background: backgroundColor,
              text: item.rSNo!,
            ),
            PdfCellWidget.borderedContainer(
              width: 100,
              height: _height,
              background: backgroundColor,
              text: item.rSName!,
            ),
            PdfCellWidget.borderedContainer(
              width: 36,
              height: _height,
              background: backgroundColor,
              text: item.rSClass!,
            ),
            PdfCellWidget.borderedContainer(
              width: 10,
              height: _height,
              background: backgroundColor,
              text: item.bookletTypes?.fold<String>('', ((p, e) => p + e!)) ?? '',
            ),
            for (var l = 0; l < examType!.lessons!.length; l++)
              if (filtrLessonList.contains(examType!.lessons![l].key))
                pw.Expanded(
                    child: pw.Row(
                  children: [
                    if (filterSettings!.contains('eds'))
                      PdfCellWidget.borderedContainer(
                        flex: 1,
                        height: _height,
                        background: backgroundColor,
                        text: item.testResults![examType!.lessons![l].key]!.d.toString(),
                      ),
                    if (filterSettings!.contains('eys'))
                      PdfCellWidget.borderedContainer(
                        flex: 1,
                        height: _height,
                        background: backgroundColor,
                        text: item.testResults![examType!.lessons![l].key]!.y.toString(),
                      ),
                    if (filterSettings!.contains('ebs'))
                      PdfCellWidget.borderedContainer(
                        flex: 1,
                        height: _height,
                        background: backgroundColor,
                        text: item.testResults![examType!.lessons![l].key]!.b.toString(),
                      ),
                    if (filterSettings!.contains('ens'))
                      PdfCellWidget.borderedContainer(
                        flex: 1,
                        height: _height,
                        background: backgroundColor,
                        text: item.testResults![examType!.lessons![l].key]!.n!.toStringAsFixed(2),
                      ),
                    if (filterSettings!.contains('ewds'))
                      PdfCellWidget.borderedContainer(
                        flex: 1,
                        height: _height,
                        background: backgroundColor,
                        text: item.testResults![examType!.lessons![l].key]!.wd.toString(),
                      ),
                    if (filterSettings!.contains('ewys'))
                      PdfCellWidget.borderedContainer(
                        flex: 1,
                        height: _height,
                        background: backgroundColor,
                        text: item.testResults![examType!.lessons![l].key]!.wy.toString(),
                      ),
                    if (filterSettings!.contains('ewbs'))
                      PdfCellWidget.borderedContainer(
                        flex: 1,
                        height: _height,
                        background: backgroundColor,
                        text: item.testResults![examType!.lessons![l].key]!.wb.toString(),
                      ),
                    if (filterSettings!.contains('etga'))
                      PdfCellWidget.borderedContainer(
                        flex: 1,
                        height: _height,
                        background: backgroundColor,
                        text: item.testResults![examType!.lessons![l].key]!.generalAwerage!.toStringAsFixed(2),
                      ),
                    if (filterSettings!.contains('etsa'))
                      PdfCellWidget.borderedContainer(
                        flex: 1,
                        height: _height,
                        background: backgroundColor,
                        text: item.testResults![examType!.lessons![l].key]!.schoolAwerage!.toStringAsFixed(2),
                      ),
                    if (filterSettings!.contains('etca'))
                      PdfCellWidget.borderedContainer(
                        flex: 1,
                        height: _height,
                        background: backgroundColor,
                        text: item.testResults![examType!.lessons![l].key]!.classAwerage!.toStringAsFixed(2),
                      ),
                    if (filterSettings!.contains('ep'))
                      PdfCellWidget.borderedContainer(
                        flex: 1,
                        height: _height,
                        background: backgroundColor,
                        text: ((item.testResults![examType!.lessons![l].key]!.n! / item.testResults![examType!.lessons![l].key]!.realAnswers!.length) * 100).toStringAsFixed(1) + '%',
                      ),
                    if (filterSettings!.contains('esa')) PdfCellWidget.borderedContainer(flex: 1, height: _height, text: '', background: backgroundColor)
                    //!Burda sanirim cevap anahtari olmasi lazim ama koymayacagim
                    // SizedBox(
                    //   width: lessonSettingsWidthList[lessonSettingsList.indexOf('esa')],
                    //   child: SingleChildScrollView(
                    //     scrollDirection: Axis.horizontal,
                    //     child: Row(
                    //       children: [
                    //         for (var sa = 0; sa < item.testResults[examType.lessons[l].key].studentAnswers.length; sa++)
                    //           CellWidget(
                    //             width: 20,
                    //             margin: 0,
                    //             height: cellHeightList[1],
                    //             background: item.testResults[examType.lessons[l].key].studentAnswers[sa] == ' '
                    //                 ? Colors.amber
                    //                 : item.testResults[examType.lessons[l].key].studentAnswers[sa] == item.testResults[examType.lessons[l].key].realAnswers[sa]
                    //                     ? Colors.green
                    //                     : Colors.redAccent,
                    //             fontSize: 8,
                    //             padding: 1,
                    //             text: '${sa + 1}\n' + item.testResults[examType.lessons[l].key].studentAnswers[sa].toUpperCase(),
                    //           ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                )),
            pw.Expanded(
                child: pw.Row(
              children: [
                if (filterSettings!.contains('eds'))
                  PdfCellWidget.borderedContainer(
                    flex: 1,
                    height: _height,
                    background: backgroundColor,
                    text: item.totalTrue.toString(),
                  ),
                if (filterSettings!.contains('eys'))
                  PdfCellWidget.borderedContainer(
                    flex: 1,
                    height: _height,
                    background: backgroundColor,
                    text: item.totalFalse.toString(),
                  ),
                if (filterSettings!.contains('ebs'))
                  PdfCellWidget.borderedContainer(
                    flex: 1,
                    height: _height,
                    background: backgroundColor,
                    text: item.totalBlank.toString(),
                  ),
                if (filterSettings!.contains('ens'))
                  PdfCellWidget.borderedContainer(
                    flex: 1,
                    height: _height,
                    background: backgroundColor,
                    text: item.totalNet.toStringAsFixed(2),
                  ),
                if (filterSettings!.contains('ewds'))
                  PdfCellWidget.borderedContainer(
                    flex: 1,
                    height: _height,
                    background: backgroundColor,
                    text: item.totalWTrue.toString(),
                  ),
                if (filterSettings!.contains('ewys'))
                  PdfCellWidget.borderedContainer(
                    flex: 1,
                    height: _height,
                    background: backgroundColor,
                    text: item.totalWFalse.toString(),
                  ),
                if (filterSettings!.contains('ewbs'))
                  PdfCellWidget.borderedContainer(
                    flex: 1,
                    height: _height,
                    background: backgroundColor,
                    text: item.totalWBlank.toString(),
                  ),
              ],
            )),
            for (var s = 0; s < examType!.scoring!.length; s++)
              pw.Expanded(
                  child: pw.Row(
                children: [
                  if (scoreSettings!.contains('ess'))
                    PdfCellWidget.borderedContainer(
                      flex: 1,
                      height: _height,
                      background: backgroundColor,
                      text: item.scoreResults![examType!.scoring![s].key]!.score.toStringAsFixed(3),
                    ),
                  if (scoreSettings!.contains('esga'))
                    PdfCellWidget.borderedContainer(
                      flex: 1,
                      height: _height,
                      background: backgroundColor,
                      text: item.scoreResults![examType!.scoring![s].key]!.generalAwerage!.toStringAsFixed(2),
                    ),
                  if (scoreSettings!.contains('essa'))
                    PdfCellWidget.borderedContainer(
                      flex: 1,
                      height: _height,
                      background: backgroundColor,
                      text: item.scoreResults![examType!.scoring![s].key]!.schoolAwerage!.toStringAsFixed(2),
                    ),
                  if (scoreSettings!.contains('esca'))
                    PdfCellWidget.borderedContainer(
                      flex: 1,
                      height: _height,
                      background: backgroundColor,
                      text: item.scoreResults![examType!.scoring![s].key]!.classAwerage!.toStringAsFixed(2),
                    ),
                  if (scoreSettings!.contains('esgo'))
                    PdfCellWidget.borderedContainer(
                      flex: 1,
                      height: _height,
                      background: backgroundColor,
                      text: item.scoreResults![examType!.scoring![s].key]!.generalOrder.toString(),
                    ),
                  if (scoreSettings!.contains('esso'))
                    PdfCellWidget.borderedContainer(
                      flex: 1,
                      height: _height,
                      background: backgroundColor,
                      text: item.scoreResults![examType!.scoring![s].key]!.schoolOrder.toString(),
                    ),
                  if (scoreSettings!.contains('esco'))
                    PdfCellWidget.borderedContainer(
                      flex: 1,
                      height: _height,
                      background: backgroundColor,
                      text: item.scoreResults![examType!.scoring![s].key]!.classOrder.toString(),
                    ),
                ],
              )),
            //   pw.SizedBox(width: 32),
          ],
        ));
      }
    });
    return _itemList;
  }

  List<List<String?>> getExcelFile() {
    List<List<String?>> result = [];

    result.add([
      'studentno'.translate,
      'name'.translate,
      'class'.translate,
      'booklettype'.translate,
      for (var l = 0; l < examType!.lessons!.length; l++)
        if (filtrLessonList.contains(examType!.lessons![l].key)) ...filterSettings!.map((e) => examType!.lessons![l].name! + ' ' + e.translate).toList()
      //    for (var s = 0; s < lessonSettingsList.length; s++) examType.lessons[l].name + ' ' + lessonSettingsList[s].translate,
      ,
      // for (var s = 0; s < totalResultList.length; s++) 'total'.translate + ' ' + totalResultList[s].translate,
      ...filterSettings!.where((element) => totalResultList.contains(element)).map((e) => 'total'.translate + ' ' + e.translate).toList(),
      for (var l = 0; l < examType!.scoring!.length; l++) ...scoreSettings!.map((e) => examType!.scoring![l].name! + ' ' + e.translate).toList()
      // for (var s = 0; s < scoreSettingsList.length; s++) examType.scoring[l].name + ' ' + scoreSettingsList[s].translate,
    ]);

    final studentKeyResultModelMap = allKurumAllStudentResults![kurumId]!;
    final resultModelList = studentKeyResultModelMap.values.toList();
    resultModelList.sort(_resultModelSortFunction);

    resultModelList.forEach((item) {
      if (_isThisClassFiltered(item!.rSClass)) {
        //Sinif filtresinden dolayi gostermemek gerek
        //223 satir civarlarindada aynisi var
      } else {
        result.add([
          (item.rSNo ?? '').toString(),
          (item.rSName ?? '').toString(),
          (item.rSClass ?? '').toString(),
          (item.bookletTypes?.fold('', (dynamic p, e) => p + e) ?? '').toString(),
          for (var l = 0; l < examType!.lessons!.length; l++)
            if (filtrLessonList.contains(examType!.lessons![l].key)) ...[
              if (filterSettings!.contains('eds')) item.testResults![examType!.lessons![l].key]!.d.toString(),
              if (filterSettings!.contains('eys')) item.testResults![examType!.lessons![l].key]!.y.toString(),
              if (filterSettings!.contains('ebs')) item.testResults![examType!.lessons![l].key]!.b.toString(),
              if (filterSettings!.contains('ens')) item.testResults![examType!.lessons![l].key]!.n.toString(),
              if (filterSettings!.contains('ewds')) item.testResults![examType!.lessons![l].key]!.wd.toString(),
              if (filterSettings!.contains('ewys')) item.testResults![examType!.lessons![l].key]!.wy.toString(),
              if (filterSettings!.contains('ewbs')) item.testResults![examType!.lessons![l].key]!.wb.toString(),
              if (filterSettings!.contains('etga')) item.testResults![examType!.lessons![l].key]!.generalAwerage!.toStringAsFixed(2),
              if (filterSettings!.contains('etsa')) item.testResults![examType!.lessons![l].key]!.schoolAwerage!.toStringAsFixed(2),
              if (filterSettings!.contains('etca')) item.testResults![examType!.lessons![l].key]!.classAwerage!.toStringAsFixed(2),
              if (filterSettings!.contains('ep')) ((item.testResults![examType!.lessons![l].key]!.n! / item.testResults![examType!.lessons![l].key]!.realAnswers!.length) * 100).toStringAsFixed(1) + '%',
              if (filterSettings!.contains('esa')) item.testResults![examType!.lessons![l].key]!.studentAnswers,
            ],
          if (filterSettings!.contains('eds')) item.totalTrue.toString(),
          if (filterSettings!.contains('eys')) item.totalFalse.toString(),
          if (filterSettings!.contains('ebs')) item.totalBlank.toString(),
          if (filterSettings!.contains('ens')) item.totalNet.toString(),
          if (filterSettings!.contains('ewds')) item.totalWTrue.toString(),
          if (filterSettings!.contains('ewys')) item.totalWFalse.toString(),
          if (filterSettings!.contains('ewbs')) item.totalWBlank.toString(),
          for (var s = 0; s < examType!.scoring!.length; s++) ...[
            if (scoreSettings!.contains('ess')) item.scoreResults![examType!.scoring![s].key]!.score.toStringAsFixed(3),
            if (scoreSettings!.contains('esga')) item.scoreResults![examType!.scoring![s].key]!.generalAwerage!.toStringAsFixed(2),
            if (scoreSettings!.contains('essa')) item.scoreResults![examType!.scoring![s].key]!.schoolAwerage!.toStringAsFixed(2),
            if (scoreSettings!.contains('esca')) item.scoreResults![examType!.scoring![s].key]!.classAwerage!.toStringAsFixed(2),
            if (scoreSettings!.contains('esgo')) item.scoreResults![examType!.scoring![s].key]!.generalOrder.toString(),
            if (scoreSettings!.contains('esso')) item.scoreResults![examType!.scoring![s].key]!.schoolOrder.toString(),
            if (scoreSettings!.contains('esco')) item.scoreResults![examType!.scoring![s].key]!.classOrder.toString(),
          ]
        ]);
      }
    });

    return result;
  }

  List<SmsModel> getSmsList() {
    List<SmsModel> result = [];

    final studentKeyResultModelMap = allKurumAllStudentResults![kurumId]!;
    final resultModelList = studentKeyResultModelMap.values.toList();
    resultModelList.sort(_resultModelSortFunction);

    resultModelList.forEach((item) {
      if (_isThisClassFiltered(item!.rSClass)) {
        //Sinuf filtresinden dolayi gostermemek gerek
        //223 satir civarlarindada aynisi var
      } else {
        final _student = AppVar.appBloc.studentService!.dataListItem(item.studentKey ?? '-?-');

        if (_student != null) {
          String text = _student.name! + ' ' + exam!.name! + ' ';

          for (var l = 0; l < examType!.lessons!.length; l++) {
            text += examType!.lessons![l].name.safeSubString(0, 3)!.toUpperCase() + ':' + item.testResults![examType!.lessons![l].key]!.n!.toStringAsFixedRemoveZero(1) + ' ';
            //? Burada net disinda diger datalarida ekleyebilirsin
          }
          text += 'total'.translate.safeSubString(0, 3)!.toUpperCase() + ':' + item.totalNet.toStringAsFixedRemoveZero(1) + ' ';

          for (var s = 0; s < examType!.scoring!.length; s++) {
            text += examType!.scoring![s].name.safeSubString(0, 3)!.toUpperCase() + ':' + item.scoreResults![examType!.scoring![s].key]!.score.toStringAsFixedRemoveZero(1) + ' ';
            //? Burada puan disinda diger datalarida ekleyebilirsin
          }

          result.add(SmsModel(
            message: text.trim(),
            numbers: [
              if (_student.motherPhone.safeLength > 6) _student.motherPhone,
              if (_student.fatherPhone.safeLength > 6) _student.fatherPhone,
              if (_student.studentPhone.safeLength > 6) _student.studentPhone,
            ],
          ));
        }
      }
    });

    return result..removeWhere((element) => element.numbers!.isEmpty);
  }
}
