import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../helpers/print_and_export_helper.dart';
import '../../../library_helper/syncfusion_flutter_charts/eager.dart';
import '../../../library_helper/syncfusion_flutter_charts/models.dart';
import '../model.dart';

class ExamComparator {
  ExamComparator._();
  static void compare({required List<PortfolioExamReport> examListWithResults, PortfolioExamReport? currentReport, String? studentName}) {
    remoOtherTypeExams(examListWithResults, currentReport);

    if (examListWithResults.length < 2) {
      OverAlert.show(message: 'min2examforcompare'.translate);
      return;
    }
    final _examType = currentReport!.examType;
    final Widget child = SingleChildScrollView(
      child: Column(
        children: [
          ...getScoreByScoreGraphics(examListWithResults),
          getAllLessonGraphics(examListWithResults),
          ...getLessonByLessonGraphics(examListWithResults),
        ],
      ),
    );

    QuickPage.openFullPage(
      child: child,
      title: _examType.name!,
      maxWidth: 1080,
      trailingActions: [
        Icons.print.icon
            .onPressed(() {
              printCompareResults(examListWithResults, currentReport, studentName!);
            })
            .color(Fav.design.primaryText)
            .make(),
      ],
    );
  }

  static String getExamLegandName(PortfolioExamReport report) {
    return report.exam.date!.dateFormat('dd-MM-yyyy');
  }

  static void remoOtherTypeExams(List<PortfolioExamReport> examListWithResults, PortfolioExamReport? currentReport) {
    //!Aslinda sinav tipinin examtype keyi tutmazsada yapilabilir fakat sinav tipinin examtype keyi eklenmemis 3 ekim 2022 de ekledi gelecek senelerde bu filtre yerine keyden filtreletebilirsin
    //! burada dersler tipatip ayni ise ayni sinav tipi sayiyor buda guzel
    examListWithResults.removeWhere((item) {
      return item.examType.lessons!.map((e) => e.key).any((lesson) => !currentReport!.examType.lessons!.map((e) => e.key).contains(lesson));
    });
  }

  static Widget getAllLessonGraphics(List<PortfolioExamReport> examListWithResults) {
    final List<MultiLineChartData> _dataList = [];
    final Map<String?, bool> _olegandNames = {};
    int? maxValue;

    examListWithResults.forEach((e) {
      Map<String?, double> _chartDataValues = {};

      for (var l = 0; l < e.examType.lessons!.length; l++) {
        final item = e.examType.lessons![l];
        final result = e.result.testResults![item.key];
        // if (item != null) {
        if (item.questionCount! > (maxValue ?? 0)) maxValue = item.questionCount;
        _chartDataValues[item.name] = result?.n ?? 0;
        _olegandNames[item.name] = true;
        //  }
      }
      // log(_chartDataValues);
      _dataList.add(MultiLineChartData(
        name: getExamLegandName(e),
        values: _chartDataValues,
      ));
    });
    return MultiLineChart(
      chartTitle: 'alllessons'.translate,
      data: _dataList,
      olegandNames: _olegandNames,
      lineWidth: 2,
      maxValue: maxValue?.toDouble(),
    );
  }

  static List<Widget> getLessonByLessonGraphics(List<PortfolioExamReport> examListWithResults) {
    List<Widget> widgetList = [];

    for (var l = 0; l < examListWithResults.first.examType.lessons!.length; l++) {
      final lesson = examListWithResults.first.examType.lessons![l];
      //  if (lesson == null) continue;
      final List<MultiLineChartData> _dataList = [];
      final Map<String?, bool> _olegandNames = {};
      int? maxValue;

      for (var r = 0; r < examListWithResults.length; r++) {
        Map<String, double> _chartDataValues = {};
        final results = examListWithResults[r];
        final result = results.result.testResults![lesson.key];

        if (lesson.questionCount! > (maxValue ?? 0)) maxValue = lesson.questionCount;
        _chartDataValues[getExamLegandName(results)] = result?.n ?? 0;
        _olegandNames[lesson.name] = true;

        _dataList.add(MultiLineChartData(
          name: getExamLegandName(results),
          values: _chartDataValues,
        ));
      }

      widgetList.add(MultiLineChart(
        chartTitle: lesson.name,
        data: _dataList,
        olegandNames: _olegandNames,
        lineWidth: 2,
        maxValue: maxValue?.toDouble(),
      ));
    }

    return widgetList;
  }

  static List<Widget> getScoreByScoreGraphics(List<PortfolioExamReport> examListWithResults) {
    List<Widget> widgetList = [];

    for (var l = 0; l < examListWithResults.first.examType.scoring!.length; l++) {
      final score = examListWithResults.first.examType.scoring![l];
      //   if (score == null) continue;
      final List<MultiLineChartData> _dataList = [];
      final Map<String?, bool> _olegandNames = {};
      int? maxValue;

      for (var r = 0; r < examListWithResults.length; r++) {
        Map<String, double> _chartDataValues = {};
        final results = examListWithResults[r];
        final result = results.result.scoreResults![score.key];

        if ((score.maxValue ?? 0.0) > (maxValue ?? 0)) maxValue = score.maxValue!.toInt();
        _chartDataValues[getExamLegandName(results)] = result?.score ?? 0;
        _olegandNames[score.name] = true;

        _dataList.add(MultiLineChartData(
          name: getExamLegandName(results),
          values: _chartDataValues,
        ));
      }

      widgetList.add(MultiLineChart(
        chartTitle: score.name,
        data: _dataList,
        olegandNames: _olegandNames,
        lineWidth: 2,
        maxValue: maxValue?.toDouble(),
      ));
    }

    return widgetList;
  }

  static void printCompareResults(List<PortfolioExamReport> examListWithResults, PortfolioExamReport currentReport, String studentName) {
    List<String> columnNames = ['', 'average'.translate];
    List<List<String?>> rows = [];
    examListWithResults.forEach((element) {
      //? Column Name ler yaziliyor
      columnNames.add(getExamLegandName(element));
    });

    currentReport.examType.scoring!.forEach((score) {
      List<String?> row = [score.name];
      final _totalScoreListForAverage = <double>[];
      examListWithResults.forEach((report) {
        final _score = report.result.scoreResults![score.key]!.score;
        _totalScoreListForAverage.add(_score);
        row.add(_score.toStringAsFixedRemoveZero(3));
      });
      row.insert(1, _totalScoreListForAverage.average.toStringAsFixedRemoveZero(3));
      rows.add(row);
    });

    currentReport.examType.lessons!.forEach((lesson) {
      List<String?> row = [lesson.name];
      final _totalScoreListForAverage = <double>[];
      examListWithResults.forEach((report) {
        final _score = report.result.testResults![lesson.key]!.n!;
        _totalScoreListForAverage.add(_score);
        row.add(_score.toStringAsFixedRemoveZero(2));
      });
      row.insert(1, _totalScoreListForAverage.average.toStringAsFixedRemoveZero(2));
      rows.add(row);
    });

    PrintAndExportHelper.printPdf(
      flexList: [2],
      data: PrintAndExportModel(columnNames: columnNames, rows: rows),
      pdfHeaderName: studentName + ' - ' + examListWithResults.first.examType.name!,
      isLandscape: true,
    );
  }
}
