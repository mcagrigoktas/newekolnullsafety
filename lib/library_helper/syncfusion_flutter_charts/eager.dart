import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import 'deferred.dart' deferred as eager;
import 'models.dart';

const _pref_syncfusion_charts_loaded = 'd_syncfusion_charts';

class MultiLineChart extends StatefulWidget {
  final String? chartTitle;
  final List<MultiLineChartData> data;
  final Map<String?, bool> olegandNames;
  final double lineWidth;
  final double? maxValue;
  final double? minValue;
  MultiLineChart({
    this.chartTitle = 'Chart',
    required this.data,
    required this.olegandNames,
    this.lineWidth = 2,
    this.minValue,
    this.maxValue,
  });

  @override
  State<MultiLineChart> createState() => _MultiLineChartState();
}

class _MultiLineChartState extends State<MultiLineChart> {
  bool _libraryIsLoading = true;
  @override
  void initState() {
    if (Fav.readSeasonCache(_pref_syncfusion_charts_loaded) == true) {
      _libraryIsLoading = false;
    } else {
      eager.loadLibrary().then((value) {
        Fav.writeSeasonCache(_pref_syncfusion_charts_loaded, true);
        setState(() {
          _libraryIsLoading = false;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_libraryIsLoading) return MyProgressIndicator(isCentered: true);
    return eager.DeferredMultiLineChart(
      data: widget.data,
      chartTitle: widget.chartTitle,
      olegandNames: widget.olegandNames,
      lineWidth: widget.lineWidth,
      maxValue: widget.maxValue,
      minValue: widget.minValue,
    );
  }
}

//************************* */

class MultiColumnChart extends StatefulWidget {
  final List<MultiColumnChartData> data;

  final Map<String?, bool> olegandNames;
  final String? title;
  final double? maxValue;
  final double? minValue;

  MultiColumnChart({
    required this.data,
    required this.olegandNames,
    this.maxValue,
    this.minValue,
    this.title,
  });

  @override
  State<MultiColumnChart> createState() => _MultiColumnChartState();
}

class _MultiColumnChartState extends State<MultiColumnChart> {
  bool _libraryIsLoading = true;
  @override
  void initState() {
    if (Fav.readSeasonCache(_pref_syncfusion_charts_loaded) == true) {
      _libraryIsLoading = false;
    } else {
      eager.loadLibrary().then((value) {
        Fav.writeSeasonCache(_pref_syncfusion_charts_loaded, true);
        setState(() {
          _libraryIsLoading = false;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_libraryIsLoading) return MyProgressIndicator(isCentered: true);
    return eager.DeferredMultiColumnChart(
      data: widget.data,
      olegandNames: widget.olegandNames,
      maxValue: widget.maxValue,
      minValue: widget.minValue,
      title: widget.title,
    );
  }
}

//************************* */
class PieChart extends StatefulWidget {
  final String? title;
  final List<PieChartSampleData> data;
  final bool showLegand;

  const PieChart({
    required this.data,
    this.title,
    this.showLegand = true,
  });

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  bool _libraryIsLoading = true;

  @override
  void initState() {
    if (Fav.readSeasonCache(_pref_syncfusion_charts_loaded) == true) {
      _libraryIsLoading = false;
    } else {
      eager.loadLibrary().then((value) {
        Fav.writeSeasonCache(_pref_syncfusion_charts_loaded, true);
        setState(() {
          _libraryIsLoading = false;
        });
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_libraryIsLoading) return MyProgressIndicator(isCentered: true);
    return eager.DeferredPieChart(
      data: widget.data,
      title: widget.title,
      showLegand: widget.showLegand,
    );
  }
}
