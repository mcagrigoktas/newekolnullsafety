import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcpages/reponsive_page/controller.dart';

class EarningItem extends ResponsivePageBaseItem {
  dynamic lastUpdate;
  String? content;
  bool? aktif;

  EarningItem({this.lastUpdate});

  EarningItem.create() {
    key = 6.makeKey;
    content = '';
    aktif = true;
    name = '';
  }

  EarningItem.fromJson(Map snapshot, String key) {
    super.key = key;
    super.name = snapshot['name'];
    lastUpdate = snapshot['lastUpdate'];
    content = snapshot['content'];
    aktif = snapshot['aktif'];
  }

  Map<String, dynamic> toJson() {
    return {
      'lastUpdate': lastUpdate,
      'content': content,
      'aktif': aktif,
      'name': name,
    };
  }

  @override
  String? get getSearchText => name;
}
