// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../exams/model.dart';
import '../../examtypes/model.dart';
import 'my_column_chart.dart';

class InstutionScoreGraphics extends StatelessWidget {
  final Map<String?, ResultModel?>? kurumAllStudentResults;
  final ExamType? examType;
  InstutionScoreGraphics({this.kurumAllStudentResults, this.examType});

  double maxValue = 0;
  double minValue = 0;
  Map<String?, Map<String, double>> init() {
    Map<String?, Map<String, double>> values = {};

    final scoreResult = kurumAllStudentResults!.entries.first.value;

    for (var i = 0; i < examType!.scoring!.length; i++) {
      final score = examType!.scoring![i];
      if ((score.maxValue ?? 500) > maxValue) maxValue = score.maxValue ?? 500;
      if ((score.minValue ?? -100) < minValue) minValue = score.minValue ?? -100;
      values[score.name] ??= {};
      values[score.name]!['school'.translate] = scoreResult!.scoreResults![score.key]!.schoolAwerage!.toDouble();
      values[score.name]!['general'.translate] = scoreResult.scoreResults![score.key]!.generalAwerage!.toDouble();
    }

    return values;
  }

  @override
  Widget build(BuildContext context) {
    return MyColumnChart(
      chartHeight: 333,
      chartName: 'instutuioncompression'.translate,
      values: init(),
      minYvalue: minValue,
      maxYvalue: maxValue,
    );
  }
}
