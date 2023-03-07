// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../../library_helper/syncfusion_flutter_charts/eager.dart';
import '../../../../../library_helper/syncfusion_flutter_charts/models.dart';

class MyColumnChart extends StatelessWidget {
  final String chartName;
  final double maxYvalue;
  final double minYvalue;
  final double chartHeight;
  final bool minMaxYAuto;
  final Map<String?, Map<String?, double?>> values;

  MyColumnChart({
    required this.chartName,
    required this.maxYvalue,
    required this.minYvalue,
    required this.chartHeight,
    required this.values,
    this.minMaxYAuto = false,
  });

  final List<MultiColumnChartData> rawBarGroups = [];
  final List<String?> xLegandNames = [];
  final Map<String?, bool> oLegandNames = {};

  double? max = 0;
  double? getMax() {
    double current = (max! * 1.5).toInt().toDouble();
    return minMaxYAuto == true ? current : maxYvalue;
  }

  double chartWidth = 0;
  final double lineWidth = 8;
  final double lineMargin = 7;
  double? min = 0;
  double? getMin() {
    double current = (min! > 0 ? min! * 0.8 : min! * 1.2).toInt().toDouble();

    return minMaxYAuto == true ? current : minYvalue;
  }

  void init() {
    rawBarGroups.clear();
    xLegandNames.clear();
    oLegandNames.clear();

    chartWidth = 0;
    final entries = values.entries.toList();

    for (var i = 0; i < entries.length; i++) {
      var val = entries[i].value.entries.toList();
      xLegandNames.add(entries[i].key);

      final Map<String?, double?> barRods = {};
      for (var d = 0; d < val.length; d++) {
        oLegandNames[val[d].key] = true;

        if (val[d].value! > max!) max = val[d].value;
        if (val[d].value! < min!) min = val[d].value;
        chartWidth += lineWidth + lineMargin;
        barRods[val[d].key] = val[d].value;
      }
      chartWidth += lineMargin * 4;
      rawBarGroups.add(MultiColumnChartData(
        name: entries[i].key,
        values: barRods,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    init();
    return SizedBox(
      height: chartHeight,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: const Color(0xff2c4260),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[Icons.graphic_eq.icon.color(Colors.white).make(), 8.widthBox, chartName.text.color(Colors.white).fontSize(18).make()],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                        width: chartWidth.clamp(250.0, 2500.0),
                        child: MultiColumnChart(
                          olegandNames: oLegandNames,
                          data: rawBarGroups,
                          maxValue: getMax(),
                          minValue: getMin(),
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
