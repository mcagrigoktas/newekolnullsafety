import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../exams/model.dart';
import '../../examtypes/model.dart';
import 'my_column_chart.dart';

class ClassNetGraphics extends StatelessWidget {
  final Map<String?, ResultModel?>? kurumAllStudentResults;
  final ExamType? examType;
  ClassNetGraphics({this.kurumAllStudentResults, this.examType});

  Map<String, Map<String, double>> init() {
    Map<String, Map<String, double>> values = {};

    final allScoreResultEntries = kurumAllStudentResults!.entries.toList();

    for (var s = 0; s < examType!.lessons!.length; s++) {
      final lesson = examType!.lessons![s];
      for (var i = 0; i < allScoreResultEntries.length; i++) {
        final result = allScoreResultEntries[i].value!;

        values[lesson.name!] ??= {};
        values[lesson.name]![result.rSClass!] = //result.testResults[lesson.key].n;
            (100 * result.testResults![lesson.key]!.n! ~/ lesson.questionCount!).toDouble();
      }
    }

    return values;
  }

  // double getMaxY() {
  //   int max = 0;
  //   examType.lessons.forEach((element) {
  //     if (element.questionCount > max) max = element.questionCount;
  //   });
  //   return max.toDouble();
  // }

  @override
  Widget build(BuildContext context) {
    return MyColumnChart(
      chartHeight: 333,
      chartName: 'classnetcompression'.translate + ' (%)',
      values: init(),
      maxYvalue: 100,
      minYvalue: -20,
    );
  }
}
