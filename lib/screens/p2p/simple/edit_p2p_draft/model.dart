//? Okulun birebir biilgieri dataya gelince gerekli bilgieri duzenleme ve vermesi icin model yapildi


import '../../../../appbloc/appvar.dart';
import '../../../managerscreens/programsettings/helper.dart';
import '../../freestyle/model.dart';

//? [sDI] school draft Itames
//? ['tBI'] teacner Banned Items

//? Okulun Etud taslagi ile ilgili tum islemleri bu class ile yapabilirsin
class SimpleP2pDraft {
  final Map? _data;

  Map? toJson() {
    makeSturdy();
    return _data;
  }

  SimpleP2pDraft.fromJson(this._data) {
    makeSturdy();
  }

  void addSchoolP2pDraftItems(List<SimpeP2PDraftItem> items) {
    final Map _existingData = _data!['sDI'];
    _existingData.addEntries(items.map((e) => MapEntry(e.key, e.toJson())));
    _data!['sDI'] = _existingData;
  }

  void clearSchoolP2pDraftItems() => _data!['sDI'] = {};

  List<SimpeP2PDraftItem> get p2pSchoolDraftItems => (_data!['sDI'] as Map).entries.map((e) => SimpeP2PDraftItem.fromJson(e.value, e.key)).toList()..sort((i1, i2) => i1.startTime! - i2.startTime!);
  List<SimpeP2PDraftItem> getDayP2pSchoolDraftItems(int day) => p2pSchoolDraftItems.where((element) => element.dayNo == day).toList();

  void removeItemInSchoolDraftItems(String key) => (_data!['sDI'] as Map).remove(key);

  List<SimpeP2PDraftItem> p2pTeacherTimesDraftItems(String? teacherKey) {
    final _teacherItemListFromProgram = ProgramHelper.getTeacherEventListFromProgram(teacherKey);
    final _schoolDraftItems = p2pSchoolDraftItems;

    _schoolDraftItems.forEach((element) {
      if (_data!['tBI'][teacherKey][element.key] == false) {
        element.disableType = P2PDisableType.disable;
      } else if (ogretmeninDersProgramiIleEtudSaatiCakisiyormu(element, _teacherItemListFromProgram)) {
        element.disableType = P2PDisableType.program;
      }
    });
    return _schoolDraftItems;
  }

  void toggleTeacherDisabledValue(String teacherKey, String itemKey) {
    if (_data!['tBI'][teacherKey][itemKey] == false) {
      _data!['tBI'][teacherKey][itemKey] = null;
    } else {
      _data!['tBI'][teacherKey][itemKey] = false;
    }
  }

  void makeSturdy() {
    //? Eksik olan datalar yaziliyor
    _data!['sDI'] ??= {};
    _data!['tBI'] ??= {};
    AppVar.appBloc.teacherService!.dataList.forEach((teacher) {
      _data!['tBI'][teacher.key] ??= {};
    });
    //? Okul data taslak listesinde olmayan bir key bir sekilde girmisse ogretmen data listesinden siler
    final _schoolDraftItemKEYList = List<String>.from((_data!['sDI'] as Map).keys);
    AppVar.appBloc.teacherService!.dataList.forEach((teacher) {
      final _teacherData = _data!['tBI'][teacher.key] as Map;
      List<String> _teacherDataKeys = List<String>.from(_teacherData.keys);
      _teacherDataKeys.forEach((itemKey) {
        if (!_schoolDraftItemKEYList.contains(itemKey)) (_data!['tBI'][teacher.key] as Map).remove(itemKey);
      });
    });
  }
}

extension on SimpleP2pDraft {
  bool ogretmeninDersProgramiIleEtudSaatiCakisiyormu(SimpeP2PDraftItem etudItem, List<TimeTableP2PEvent> programItemList) {
    return programItemList.any((programItem) {
      if (programItem.day! + 1 != etudItem.dayNo) return false;
      if (programItem.startMinute == etudItem.startTime) return true;
      if (programItem.endMinute == etudItem.endTime) return true;
      if (programItem.startMinute > etudItem.startTime!) {
        if (programItem.startMinute < etudItem.endTime!) return true;
      } else {
        if (etudItem.startTime! < programItem.endMinute) return true;
      }
      return false;
    });
  }
}

//? Basit birebir listesinde okul etud saatlerinin modeli
class SimpeP2PDraftItem {
  int? startTime;
  int? endTime;
  String key;
  int? dayNo;
  P2PDisableType disableType = P2PDisableType.active;

  SimpeP2PDraftItem({required this.startTime, required this.endTime, required this.key, required this.dayNo});

  SimpeP2PDraftItem.fromJson(Map snapshot, this.key) {
    startTime = snapshot['s'];
    endTime = snapshot['e'];
    dayNo = snapshot['d'];
  }

  Map<String, dynamic> toJson() {
    return {
      's': startTime,
      'e': endTime,
      'd': dayNo,
    };
  }
}

enum P2PDisableType {
  program,
  disable,
  active,
}
