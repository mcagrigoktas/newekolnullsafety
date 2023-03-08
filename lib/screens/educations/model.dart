import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mcg_extension/mcg_extension.dart';

class Education {
  int? lastUpdate;
  String? key;
  String? name;
  String? exp;
  List? data;
  List<String>? serverIdList;

  /// [fullServerIdList] daha once gonderilmis ama listeden kaldirilmis server id leride icerir
  List<String>? fullServerIdList;
  List<String>? classLevelList;
  String? pdf1;
  String? saver;
  bool? aktif;
  String? imgUrl;
  EducationType? type;

  Education({this.lastUpdate});

  Education.create() {
    key = 10.makeKey;
    name = '';
    exp = '';
    pdf1 = '';
    serverIdList = [];
    fullServerIdList = [];
    type = EducationType.ekol;
    classLevelList = ['0'];
  }

  Education.fromJson(Map snapshot, this.key) {
    lastUpdate = (snapshot['lastUpdate'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
    name = snapshot['name'];
    exp = snapshot['exp'];

    data = snapshot['data'];
    pdf1 = snapshot['pdf1'];
    serverIdList = List<String>.from(snapshot['serverIdList'] ?? []);
    fullServerIdList = List<String>.from(snapshot['fServerIdList'] ?? serverIdList!);
    classLevelList = List<String>.from(snapshot['classLevelList'] ?? ['0']);
    aktif = snapshot['aktif'];
    saver = snapshot['saver'];
    imgUrl = snapshot['imgUrl'];
    type = J.jEnum(snapshot['type'], EducationType.values, EducationType.ekol);
  }

  Map<String, dynamic> toJson() {
    return {
      'imgUrl': imgUrl,
      'saver': saver,
      'aktif': aktif,
      'name': name,
      'exp': exp,
      'data': data,
      'pdf1': pdf1,
      'serverIdList': serverIdList,
      'fServerIdList': fullServerIdList,
      'classLevelList': classLevelList,
      'type': type!.name,
    };
  }

  Map<String, dynamic> toFavoriteItem() {
    return {
      'imgUrl': imgUrl,
      'name': name,
    };
  }

  Education.fromFavoriteItem(Map snapshot, this.key) {
    name = snapshot['name'];
    imgUrl = snapshot['imgUrl'];
  }

  String get searchText => (name! + exp!).toSearchCase();
}

enum EducationType {
  ekol,
  qbank,
}
