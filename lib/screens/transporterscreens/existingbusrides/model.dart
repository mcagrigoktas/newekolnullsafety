import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

class BusRideModel extends ResponsivePageBaseItem {
  final String? transporterUid;
  final Map? data;
  BusRideModel({this.transporterUid, String? name, String? key, this.data}) {
    this.name = name;
    this.key = key;
  }

  int? get lastUpdate => data!['lastUpdate'];
  String? get timeText => data!['time'];
  String get seferNoText => 'busridetype${data!["no"]}'.translate;
  Map<String, int>? get studentKeyValue => data!['data'].map<String, int>((key, value) => MapEntry<String, int>(key as String, (value as Map)['s'] as int));

  @override
  String get getSearchText => name.toSearchCase();
}
