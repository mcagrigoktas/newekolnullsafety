class MultiLineChartData {
  final Map<String, double> values;
  final String name;

  MultiLineChartData({required this.values, required this.name});
}

class MultiColumnChartData {
  final Map<String, double> values;
  final String name;

  MultiColumnChartData({required this.values, required this.name});
}

class PieChartSampleData {
  String name;
  String text;
  double value;
  PieChartSampleData({required this.name, required this.text, required this.value});
}
