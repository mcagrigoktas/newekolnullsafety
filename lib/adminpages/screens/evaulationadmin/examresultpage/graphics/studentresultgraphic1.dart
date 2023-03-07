import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../exams/model.dart';
import '../../examtypes/model.dart';
import 'my_column_chart.dart';

class StudentLessonPerformanceGraphics extends StatelessWidget {
  final ResultModel resultModel;
  final ExamType examType;
  final bool comingFromStudentsChart;
  StudentLessonPerformanceGraphics({required this.resultModel, required this.examType, this.comingFromStudentsChart = true});

  Map<String, Map<String, double>> init() {
    Map<String, Map<String, double>> values = {};

    final entries = resultModel.testResults!.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final lesson = examType.lessons!.singleWhereOrNull((element) => element.key == entries[i].key);
      if (lesson == null) continue;
      values[lesson.name.firstXcharacter(8)!] ??= {};
      if (comingFromStudentsChart) values[lesson.name.firstXcharacter(8)]!['student'.translate] = (100 * entries[i].value.n! ~/ lesson.questionCount!).toDouble();
      values[lesson.name.firstXcharacter(8)]!['class'.translate] = (100 * entries[i].value.classAwerage! ~/ lesson.questionCount!).toDouble();
      values[lesson.name.firstXcharacter(8)]!['school'.translate] = (100 * entries[i].value.schoolAwerage! ~/ lesson.questionCount!).toDouble();
      values[lesson.name.firstXcharacter(8)]!['general'.translate] = (100 * entries[i].value.generalAwerage! ~/ lesson.questionCount!).toDouble();
    }
    return values;
  }

  @override
  Widget build(BuildContext context) {
    Widget current = MyColumnChart(
      chartHeight: 333,
      chartName: (comingFromStudentsChart ? resultModel.rSName! + '    ' : '') + 'lessonperformancecompression'.translate + ' (%)',
      values: init(),
      minYvalue: -20,
      maxYvalue: 100,
    );

    return current;
  }
}
