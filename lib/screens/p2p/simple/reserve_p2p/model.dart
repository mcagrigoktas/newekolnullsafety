import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../appbloc/appvar.dart';
import '../../freestyle/model.dart';
import '../edit_p2p_draft/model.dart';

class P2PSimpleWeekData {
  late List<P2PSimpleWeekDataItem> allItem;
  final Map _data;
  P2PSimpleWeekData.fromJson(this._data) {
    allItem = _data.entries.map((e) => P2PSimpleWeekDataItem.fromJson(e.value, e.key)).toList();
  }

  P2PSimpleWeekDataItem? getWeekRecordForThisItem(SimpeP2PDraftItem p2pDraftItem, String? teacherKey, int? week) {
    return allItem.firstWhereOrNull((element) => element.key == 'w$week' + '_p_' + teacherKey! + '_p_' + p2pDraftItem.key);
  }

  int howManyP2PThereThisStudent(String? studentKey) => allItem.where((element) => element.studentListData!.containsKey(studentKey)).length;
  int howManyP2PThereThisStudentThisTeacher(String? studentKey, String? teacherKey) => allItem.where((element) => element.teacherKey == teacherKey && element.studentListData!.containsKey(studentKey)).length;
  int howManyP2PThereThisStudentThisTeacherSameDay(String? studentKey, String? teacherKey, int? dayNo) => allItem.where((element) => element.teacherKey == teacherKey && element.studentListData!.containsKey(studentKey) && element.dayNo == dayNo).length;
}

class P2PSimpleWeekDataItem {
  //{'studentKey':'studentName'}
  Map<String, String>? studentListData;
  //w1_p_teacherkey_p_p2pDraftItemKey   [p2pDraftItemKey]=>L_${_dayNo}_${_controlTime}_${_controlTime + _lessonDuration}
  String key;

//? Su an bu data kullanilmiyor. Eger birebir alinirken ogrenciye not ekletmek istersen budatayi kullanailirsin
//? Simdilik ogrenci not eklerken baska birisi rezerve ederse diye sure gecirmemek icin konmadi
//? Bunu onlemek icin istersen ogrenci sureye tiklar tiklamaz rezerve edip isterse iptal edebilecek sekilde senaryo ayarlanabilir
  String? note;

  // Rezerve edebilecek maksimum ogrenci sayisi
  int? maxStudentCount;
  List<String>? targetList;

  int? get week => int.tryParse(key.split('_p_')[0].replaceAll('w', ''));
  String get teacherKey => key.split('_p_')[1];

  String get p2pDraftItemKey => key.split('_p_').last;
  int? get dayNo => int.tryParse(p2pDraftItemKey.split('_')[1]);
  int? get lessonStartTime => int.tryParse(p2pDraftItemKey.split('_')[2]);
  int? get lessonEndTime => int.tryParse(p2pDraftItemKey.split('_')[3]);

  P2PSimpleWeekDataItem.create(this.key) {
    studentListData = {};
    maxStudentCount = 1;
    note = '';
  }

  P2PSimpleWeekDataItem.fromJson(Map snapshot, this.key) {
    studentListData = snapshot['sL'] == null ? {} : Map<String, String>.from(snapshot['sL']);
    maxStudentCount = snapshot['mC'] ?? 1;
    targetList = snapshot['tL'] == null ? null : List<String>.from(snapshot['tL']);
    note = snapshot['n'];
  }

  Map<String, dynamic> toJson() {
    return {
      'n': note,
      'sL': studentListData,
      if (maxStudentCount != null && maxStudentCount != 1) 'mC': maxStudentCount,
      if (targetList != null && !targetList!.contains('all')) 'tL': targetList,
    };
  }

  bool get isFull => studentListData!.length >= maxStudentCount!;
  bool get hasMaxCapacityError => studentListData!.length > maxStudentCount!;
  bool get studentListIncludeMe {
    return studentListData!.keys.contains(AppVar.appBloc.hesapBilgileri.uid);
  }

  void addThisStudents(Map<String, String> studentKeyNameData) {
    studentListData!.addAll(studentKeyNameData);
  }

  void removeThisStudent(String? studentKey) {
    studentListData!.remove(studentKey);
  }

  Map<String, dynamic> mapForPortFolioSave() {
    final model = P2PModel();
    model.lastUpdate = databaseTime;
    model.week = week;
    model.day = dayNo! - 1;
    model.startTime = lessonStartTime;
    model.duration = lessonEndTime! - lessonStartTime!;
    model.channel = key;
    model.teacherKey = teacherKey;
    //? Bu aktif edilmesi gerekebilir silme
    // model.studentRequestLessonKey = ;
    return model.mapForStudentSave();
  }

  Map<String, dynamic> mapForTeacherSave() {
    final model = P2PModel();
    model.aktif = studentListData!.isNotEmpty;
    model.lastUpdate = databaseTime;
    model.week = week;
    model.day = dayNo! - 1;
    model.startTime = lessonStartTime;
    model.duration = lessonEndTime! - lessonStartTime!;
    model.channel = key;
    model.studentList = List<String>.from(studentListData!.keys);
    model.teacherKey = teacherKey;
    //? Bu aktif edilmesi gerekebilir silme
    // model.studentRequestKey = ;
    //? Bu aktif edilmesi gerekebilir silme
    // model.studentRequestLessonKey = ;
    model.note = note;
    return model.mapForSave();
  }
}
