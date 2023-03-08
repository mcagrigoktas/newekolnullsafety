import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcpages/reponsive_page/controller.dart';

import '../../../appbloc/appvar.dart';

class CaseRecordModel extends ResponsivePageBaseItem {
  dynamic lastUpdate;
  List<String>? targetList;
  String? content;
  bool? aktif;
  bool targetListIsClassList = false;
  List<String>? teacherList;
  int? startDate;
  int? endDate;
  bool? isClosed;
  CaseRecordItemStarter? caseRecordItemStarter;
  CaseRecordOpenReason? openReason;
  String? closeReason;
  List<CaseRecordItem>? items;
  bool? hasSensitiveData;

  CaseRecordModel.create(String defaultTeacherKey) {
    key = 6.makeKey;
    content = '';
    aktif = true;
    name = '';
    targetList = [];
    teacherList = [defaultTeacherKey];
    items = [];
    startDate = DateTime.now().millisecondsSinceEpoch;
    isClosed = false;
    caseRecordItemStarter = CaseRecordItemStarter.mentor;
    hasSensitiveData = true;
    openReason = CaseRecordOpenReason.other;
    lastUpdate = DateTime.now().millisecondsSinceEpoch;
  }

  CaseRecordModel.fromJson(Map snapshot, String key) {
    super.key = key;

    lastUpdate = snapshot['lastUpdate'];
    hasSensitiveData = snapshot['hSD'];
    aktif = snapshot['aktif'];
    final decryptedData = (snapshot['enc'] as String?)!.decrypt(key)!;
    name = decryptedData['n'] ?? '';
    content = decryptedData['c'] ?? '';
    targetList = List<String>.from(decryptedData['sL'] ?? []);
    teacherList = List<String>.from(decryptedData['tL'] ?? []);
    targetListIsClassList = decryptedData['tIC'] ?? false;
    startDate = decryptedData['sD'];
    endDate = decryptedData['eD'];
    isClosed = decryptedData['iC'];

    closeReason = decryptedData['cR'];
    caseRecordItemStarter = CaseRecordItemStarter.values.singleWhere((element) => element.name == decryptedData['cRS'], orElse: () => CaseRecordItemStarter.mentor);
    openReason = CaseRecordOpenReason.values.singleWhere((element) => element.name == decryptedData['oR'], orElse: () => CaseRecordOpenReason.other);
    items = decryptedData['i'] == null ? [] : (decryptedData['i'] as List).map((e) => CaseRecordItem.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = {
      'lastUpdate': lastUpdate,
      'aktif': aktif,
      'hSD': hasSensitiveData,
    };
    data['enc'] = {
      'n': name,
      "c": content,
      "sL": targetList,
      "tL": teacherList,
      "tIC": targetListIsClassList,
      "sD": startDate,
      "eD": endDate,
      "iC": isClosed,
      "cRS": caseRecordItemStarter!.name,
      "oR": openReason!.name,
      "cR": closeReason,
      "i": items?.map((e) => e.toJson()).toList(),
    }.encrypt(key!);

    return data;
  }

  String get listTileName {
    return targetList!
            .map<String>((e) {
              return targetListIsClassList ? (AppVar.appBloc.classService!.dataListItem(e)?.name ?? '') : (AppVar.appBloc.studentService!.dataListItem(e)?.name ?? '');
            })
            .join('-')
            .safeSubString(0, 40)! +
        '\n' +
        name!;
  }

  @override
  String get getSearchText => name.toSearchCase();
}

enum CaseRecordItemStarter {
  mentor,
  student,
  parent,
  other,
}

enum CaseRecordOpenReason { other }

class CaseRecordItem {
  CaseRecordItemType? type;
  MeetingType? meetingType;
  int? date;
  String? imageUrl;
  String? fileUrl;
  String? documentUrl;
  String? content;
  int? duration;
  List<String?>? teacherList;
  List<String>? targetList;

  CaseRecordItem.create(this.type);

  CaseRecordItem.fromJson(Map snapshot) {
    type = CaseRecordItemType.values.singleWhere((element) => element.name == snapshot['t'], orElse: () => CaseRecordItemType.note);
    meetingType = MeetingType.values.singleWhere((element) => element.name == snapshot['mT'], orElse: () => MeetingType.p2p);
    date = snapshot['d'];
    imageUrl = snapshot['iU'];
    fileUrl = snapshot['fU'];
    documentUrl = snapshot['dU'];
    content = snapshot['c'];
    duration = snapshot['drt'];
    targetList = List<String>.from(snapshot['sL'] ?? []);
    teacherList = List<String>.from(snapshot['tL'] ?? []);
  }

  Map<String, dynamic> toJson() {
    return {
      't': type!.name,
      'mt': meetingType?.name,
      'd': date,
      'iU': imageUrl,
      'fU': fileUrl,
      'dU': documentUrl,
      'c': content,
      'drt': duration,
      "sL": targetList,
      "tL": teacherList,
    };
  }
}

enum CaseRecordItemType { documents, note, meeting }

enum MeetingType { online, p2p, phone, other }
