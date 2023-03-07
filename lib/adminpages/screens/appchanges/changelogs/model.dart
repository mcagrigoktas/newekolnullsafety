import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import 'controller.dart';

class ChangeLogPostItem extends DatabaseItem {
  String? key;
  String? content;
  String? title;
  List<String>? imgList;
  String? targetLang;
  int? timeStamp;
  String? youtubeLink;

  ChangeLogPostType? postype;
  ChangeLogAppTarget? appTarget;

  ChangeLogPostItem();

  ChangeLogPostItem.fromJson(Map snapshot, this.key) {
    timeStamp = snapshot['timeStamp'];
    youtubeLink = snapshot['youtubeLink'];
    content = snapshot['content'];
    title = snapshot['title'];
    targetLang = snapshot['targetLang'];
    imgList = snapshot['imgList'] == null ? null : List<String>.from(snapshot['imgList']);

    postype = ChangeLogPostType.values.singleWhere((element) => element.name == snapshot['postype']);
    appTarget = ChangeLogAppTarget.values.singleWhere((element) => element.name == snapshot['appTarget']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      "timeStamp": timeStamp,
      "title": title,
      "content": content,
      "imgList": imgList,
      "youtubeLink": youtubeLink,
      "targetLang": targetLang,
      "postype": postype!.name,
      "appTarget": appTarget!.name,
    };

    return data;
  }

  String get getDateText => timeStamp!.dateFormat("d-MMM-yyyy");

  @override
  bool active() => true;
}
