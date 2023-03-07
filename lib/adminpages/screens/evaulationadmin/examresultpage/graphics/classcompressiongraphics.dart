import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../exams/model.dart';
import '../../examtypes/model.dart';
import 'my_column_chart.dart';

// ignore: must_be_immutable
class ClassScoreGraphics extends StatelessWidget {
  final Map<String?, ResultModel?> kurumAllStudentResults;
  final ExamType examType;
  ClassScoreGraphics({required this.kurumAllStudentResults, required this.examType});

  double maxValue = 0;
  double minValue = 0;
  Map<String?, Map<String?, double?>> init() {
    Map<String?, Map<String?, double?>> values = {};

    final allScoreResultEntries = kurumAllStudentResults.entries.toList();

    for (var s = 0; s < examType.scoring!.length; s++) {
      final score = examType.scoring![s];
      if ((score.maxValue ?? 500) > maxValue) maxValue = score.maxValue ?? 500;
      if ((score.minValue ?? -100) < minValue) minValue = score.minValue ?? -100;
      for (var i = 0; i < allScoreResultEntries.length; i++) {
        final result = allScoreResultEntries[i].value!;

        values[score.name] ??= {};
        values[score.name]![result.rSClass] = result.scoreResults![score.key]!.classAwerage;
      }
    }
    return values;
  }

  @override
  Widget build(BuildContext context) {
    return MyColumnChart(
      chartHeight: 333,
      chartName: 'classscorecompression'.translate,
      values: init(),
      minYvalue: minValue,
      maxYvalue: maxValue,
    );
  }
}
