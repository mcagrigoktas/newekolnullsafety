class MultiLineChartData {
  final Map<String?, double>? values;
  final String? name;

  MultiLineChartData({this.values, this.name});
}

class MultiColumnChartData {
  final Map<String?, double?>? values;
  final String? name;

  MultiColumnChartData({this.values, this.name});
}

class PieChartSampleData {
  String name;
  String text;
  double value;
  PieChartSampleData({required this.name, required this.text, required this.value});
}
