import 'package:mcg_extension/mcg_extension.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../supermanager/supermanagerbloc.dart';
import '../examtypes/model.dart';
import '../helper.dart';

class OpticFormModel {
  bool? aktif;
  bool? isPublished;
  String? key;
  dynamic lastUpdate;
  String? name;
  String? explanation;
  int? seisonNo;

  DataStartEnd? studentNameData;
  DataStartEnd? studentIdData;
  DataStartEnd? studentNumberData;
  DataStartEnd? studentClassData;
  DataStartEnd? studentSectionData;
  DataStartEnd? bookletTypeData;

  Map<String?, DataStartEnd>? lessonsData;
  String? examTypeKey;

  EvaulationUserType? userType;
  String? savedBy;

  OpticFormModel.create(ExamType examType, this.userType, {this.seisonNo = 1}) {
    aktif = true;
    isPublished = false;
    name = '';
    explanation = '';

    studentNameData = DataStartEnd(dataName: 'student'.translate + ' ' + 'name'.translate, start: 0, end: 0);
    studentIdData = DataStartEnd(dataName: 'student'.translate + ' ' + 'tc'.translate, start: 0, end: 0);
    studentNumberData = DataStartEnd(dataName: 'studentno'.translate, start: 0, end: 0);
    studentClassData = DataStartEnd(dataName: 'student'.translate + ' ' + 'class'.translate, start: 0, end: 0);
    studentSectionData = DataStartEnd(dataName: 'student'.translate + ' ' + 'section'.translate, start: 0, end: 0);
    bookletTypeData = DataStartEnd(dataName: 'booklettype'.translate, start: 0, end: 0);
    //  key = 10.makeKey;
    lessonsData = {};
    for (var i = 0; i < examType.lessons!.length; i++) {
      final lesson = examType.lessons![i];
      if (lesson.seisonNo == seisonNo) {
        lessonsData![lesson.key] = DataStartEnd(dataName: lesson.name!, start: 0, end: 0);

        for (var j = 0; j < lesson.wQuestionCount!; j++) {
          lessonsData![lesson.key! + '-w${j + 1}'] = DataStartEnd(dataName: lesson.name! + '-w${j + 1}:', start: 0, end: 0);
        }
      }
    }

    savedBy = userType == EvaulationUserType.school
        ? AppVar.appBloc.hesapBilgileri.uid
        : userType == EvaulationUserType.supermanager
            ? Get.find<SuperManagerController>().hesapBilgileri.kurumID
            : userType.toString();
    examTypeKey = examType.key;
  }

  OpticFormModel.fromJson(Map snapshot) {
    aktif = snapshot['aktif'] ?? true;
    key = snapshot['key'];
    isPublished = snapshot['isPublished'] ?? false;
    lastUpdate = snapshot['lastUpdate'];
    name = snapshot['name'];
    explanation = snapshot['explanation'];

    studentNameData = DataStartEnd.fromJson(snapshot['snd']);
    studentIdData = snapshot['sId'] == null ? DataStartEnd(start: 0, end: 0, dataName: 'student'.translate + ' ' + 'tc'.translate) : DataStartEnd.fromJson(snapshot['sId']);
    studentNumberData = DataStartEnd.fromJson(snapshot['snod']);
    studentClassData = DataStartEnd.fromJson(snapshot['scd']);
    studentSectionData = DataStartEnd.fromJson(snapshot['ssd']);
    bookletTypeData = DataStartEnd.fromJson(snapshot['bt']);

    lessonsData = ((snapshot['lessonsData'] as Map?) ?? {}).map((k, v) => MapEntry(k, DataStartEnd.fromJson(v)));

    examTypeKey = snapshot['examTypeKey'];
    userType = EvaulationUserType.values.singleWhereOrNull((element) => element.toString() == snapshot['userType']) ?? EvaulationUserType.admin;
    savedBy = snapshot['savedBy'] ?? EvaulationUserType.admin.toString();
    seisonNo = snapshot['seisonNo'];
  }

  Map<String, dynamic> mapForSave() {
    return {
      "aktif": aktif ?? true,
      "key": key,
      "isPublished": isPublished ?? false,
      "lastUpdate": lastUpdate,
      "name": name,
      "explanation": explanation,
      "snd": studentNameData!.mapForSave(),
      "sId": studentIdData!.mapForSave(),
      "snod": studentNumberData!.mapForSave(),
      "scd": studentClassData!.mapForSave(),
      "ssd": studentSectionData!.mapForSave(),
      "bt": bookletTypeData!.mapForSave(),
      "lessonsData": lessonsData?.map((k, v) => MapEntry(k, v.mapForSave())),
      "examTypeKey": examTypeKey,
      "savedBy": savedBy,
      "userType": userType.toString(),
      "seisonNo": seisonNo,
    };
  }

  bool get notGood => savedBy.safeLength < 1 || userType == null;
}

class DataStartEnd {
  String dataName;
  int start;
  int end;

  DataStartEnd({required this.dataName, required this.start, required this.end});

  DataStartEnd.fromJson(Map snapshot)
      : dataName = snapshot['dataName'],
        start = snapshot['start'],
        end = snapshot['end'];

  Map<String, dynamic> mapForSave() {
    return {
      "dataName": dataName,
      "start": start,
      "end": end,
    };
  }
}
