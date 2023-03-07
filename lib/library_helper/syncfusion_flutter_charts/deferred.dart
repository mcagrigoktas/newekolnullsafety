// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'models.dart';

//* Bazilarinda her iki eksende numara olabiliyor ona gore gelistirebilirsin burayi
class DeferredMultiLineChart extends StatelessWidget {
  final String? chartTitle;
  final List<MultiLineChartData> data;
  final Map<String?, bool> olegandNames;
  final double lineWidth;
  final double? maxValue;
  final double? minValue;
  DeferredMultiLineChart({
    this.chartTitle = 'Chart',
    required this.data,
    required this.olegandNames,
    this.lineWidth = 2,
    this.minValue,
    this.maxValue,
  });
  final bool isCardView = false;

  List<String?>? olegandNamesKeys;

  @override
  Widget build(BuildContext context) {
    olegandNamesKeys ??= olegandNames.keys.toList();
    final _legandColor = olegandNamesKeys!.length == 1 ? MyPalette.getSmartRandomColor() : null;
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      title: ChartTitle(text: chartTitle!, textStyle: TextStyle(color: _legandColor ?? Fav.design.primaryText)),
      legend: Legend(
        isVisible: olegandNamesKeys!.length > 1,
        position: LegendPosition.auto,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      primaryXAxis: CategoryAxis(labelRotation: 270, labelStyle: TextStyle(fontSize: 11)),
      primaryYAxis: NumericAxis(axisLine: const AxisLine(width: 0), majorTickLines: const MajorTickLines(color: Colors.transparent), minimum: minValue, maximum: maxValue),
      series: _getDefaultLineSeries(_legandColor),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  /// The method returns line series to chart.
  List<LineSeries<MultiLineChartData, String>> _getDefaultLineSeries(Color? _legandColor) {
    List<LineSeries<MultiLineChartData, String>> _data = [];
    for (var i = 0; i < olegandNamesKeys!.length; i++) {
      _data.add(LineSeries<MultiLineChartData, String>(
        width: lineWidth,
        dataSource: data,
        animationDuration: 555.0 + (111 * i),
        color: olegandNamesKeys!.length == 1 ? _legandColor : MyPalette.getChartColorFromCount(i),
        xValueMapper: (MultiLineChartData item, _) => item.name!.replaceAll(' ', '\n'),
        yValueMapper: (MultiLineChartData item, _) => item.values!.values.toList()[i],
        name: olegandNamesKeys![i],
        markerSettings: const MarkerSettings(isVisible: true),
      ));
    }

    return _data;
  }
}

//************************* */

class DeferredMultiColumnChart extends StatelessWidget {
  final List<MultiColumnChartData> data;

  final Map<String?, bool> olegandNames;
  final String? title;
  final double? maxValue;
  final double? minValue;

  final _columnWidth = 0.8;
  final _columnSpacing = 0.2;
  DeferredMultiColumnChart({
    required this.data,
    required this.olegandNames,
    this.maxValue,
    this.minValue,
    this.title,
  });

  List<String?>? olegandNamesKeys;
  @override
  Widget build(BuildContext context) {
    olegandNamesKeys ??= olegandNames.keys.toList();
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      title: ChartTitle(text: title ?? ''),
      primaryXAxis: CategoryAxis(labelRotation: 270, labelStyle: TextStyle(fontSize: 11)),
      primaryYAxis: NumericAxis(maximum: maxValue, minimum: minValue, interval: 10),
      series: _getDefaultColumn(),
      legend: Legend(isVisible: true, position: LegendPosition.right),
      margin: EdgeInsets.all(2),
    );
  }

  List<String>? names;

  List<ColumnSeries<MultiColumnChartData, String>> _getDefaultColumn() {
    List<ColumnSeries<MultiColumnChartData, String>> _data = [];
    for (var i = 0; i < olegandNamesKeys!.length; i++) {
      _data.add(
        ColumnSeries<MultiColumnChartData, String>(
            width: _columnWidth,
            spacing: _columnSpacing,
            dataSource: data,
            animationDuration: 555.0 + (111 * i),
            color: MyPalette.getChartColorFromCount(i),
            xValueMapper: (MultiColumnChartData item, _) => item.name!.replaceAll(' ', '\n'),
            yValueMapper: (MultiColumnChartData item, _) => item.values!.values.toList()[i],
            name: olegandNamesKeys![i],
            borderRadius: BorderRadius.circular(6)),
      );
    }

    return _data;
  }
}

//************************* */

class DeferredPieChart extends StatelessWidget {
  final String? title;
  final List<PieChartSampleData> data;
  final bool showLegand;

  const DeferredPieChart({
    required this.data,
    this.title,
    this.showLegand = true,
  });

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      title: title == null ? null : ChartTitle(text: title!),
      legend: Legend(isVisible: showLegand),
      series: _getDefaultPieSeries(),
      margin: EdgeInsets.all(0),
    );
  }

  List<PieSeries<PieChartSampleData, String>> _getDefaultPieSeries() {
    return <PieSeries<PieChartSampleData, String>>[
      PieSeries<PieChartSampleData, String>(
          legendIconType: LegendIconType.pentagon,
          explodeGesture: ActivationMode.singleTap,
          explode: true,
          explodeIndex: 0,
          explodeOffset: '5%',
          dataSource: data,
          xValueMapper: (PieChartSampleData data, _) => data.name,
          yValueMapper: (PieChartSampleData data, _) => data.value,
          dataLabelMapper: (PieChartSampleData data, _) => data.text,
          pointColorMapper: (PieChartSampleData data, index) => MyPalette.getChartColorFromCount(index),
          startAngle: 90,
          endAngle: 90,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
          )),
    ];
  }
}
