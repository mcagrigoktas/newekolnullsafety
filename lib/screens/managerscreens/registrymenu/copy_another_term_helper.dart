import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../adminpages/screens/evaulationadmin/examtypes/model.dart';
import '../../../adminpages/screens/evaulationadmin/opticformtypes/model.dart';
import '../../../appbloc/appvar.dart';
import '../../../appbloc/minifetchers.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';
import '../../../supermanager/schoolreview/helpers.dart';

class CopyFromAnotherTermHelper {
  CopyFromAnotherTermHelper._();

  static Future<void> copyLessons() async {
    final String? _targetClassKey = await (OverPage.openChoosebleListViewFromMap(data: AppVar.appBloc.classService!.dataList.fold<Map>({}, (p, e) => p..[e.key] = e.name), title: 'toclasslist'.translate));
    if (_targetClassKey == null) return;
    final _result = await _getTargetTerm();
    if (_result == null) return;
    OverLoading.show();
    final _lessonListFetcher = SuperManagerMiniFetchers.lessonMiniFetchers(AppVar.appBloc.hesapBilgileri.kurumID, _result);
    final _classListFetcher = SuperManagerMiniFetchers.classMiniFetchers(AppVar.appBloc.hesapBilgileri.kurumID, _result);
    await 2500.wait;
    final _fullClassList = _classListFetcher.dataList;
    final _fullLessonList = _lessonListFetcher.dataList;

    await OverLoading.close();
    final String? _fromClassKey = await (OverPage.openChoosebleListViewFromMap(data: _fullClassList.fold<Map>({}, (p, e) => p..[e.key] = e.name), title: 'fromclasslist'.translate));
    if (_fromClassKey == null) return;
    final _filteredLessonList = _fullLessonList.where((lesson) => lesson.classKey == _fromClassKey).toList();
    final List? _lessonKeyList = await (OverPage.openMultipleChoosebleListViewFromMap(
      data: _filteredLessonList.fold<Map>({}, (p, e) => p..[e.key] = e.name),
      title: 'copylessonlisthint'.translate,
      showSelectAllItemIcon: true,
    ));

    if (_lessonKeyList == null) return;
    final _lessonListMustCopy = _lessonKeyList.map((e) => _fullLessonList.firstWhere((element) => element.key == e)).toList();
    String _errorText = '';
    _lessonListMustCopy.forEach((lesson) {
      String newDataKey;
      do {
        newDataKey = 3.makeKey;
      } while (AppVar.appBloc.lessonService!.dataList.any((lesson) => lesson.key == newDataKey));
      lesson.key = newDataKey;
      lesson.classKey = _targetClassKey;
      lesson.teacher = null;
      final _existingLesson = AppVar.appBloc.lessonService!.dataList.firstWhereOrNull((s) => s.key == lesson.key || (s.classKey == _targetClassKey && s.name.toSearchCase() == lesson.name.toSearchCase()));
      if (_existingLesson != null) _errorText += '\n${_existingLesson.name}';
    });
    if (_errorText.safeLength > 5) {
      OverAlert.show(message: 'savecopyusererr2'.translate + _errorText, autoClose: false);
      return;
    }
    if (_lessonListMustCopy.isEmpty) {
      OverAlert.nothingFoundToSave();
      return;
    }
    OverLoading.show();
    await LessonService.saveMultipleLesson(_lessonListMustCopy).then((a) {
      OverAlert.saveSuc();
    }).catchError((error) {
      OverAlert.show(message: 'saveerruser'.translate);
    });
    await OverLoading.close();
  }

  static Future<void> copyFromAnotherSameTermClassLessons() async {
    final _fullClassList = AppVar.appBloc.classService!.dataList.map((e) => Class.fromJson(e.mapForSave(e.key), e.key)).toList();
    final _fullLessonList = AppVar.appBloc.lessonService!.dataList.map((e) => Lesson.fromJson(e.mapForSave(e.key), e.key)).toList();

    final String? _targetClassKey = await (OverPage.openChoosebleListViewFromMap(data: _fullClassList.fold<Map>({}, (p, e) => p..[e.key] = e.name), title: 'toclasslist'.translate));
    if (_targetClassKey == null) return;
    final String? _fromClassKey = await (OverPage.openChoosebleListViewFromMap(data: _fullClassList.where((element) => element.key != _targetClassKey).fold<Map>({}, (p, e) => p..[e.key] = e.name), title: 'fromclasslist'.translate));
    if (_fromClassKey == null) return;
    final _filteredLessonList = _fullLessonList.where((lesson) => lesson.classKey == _fromClassKey).toList();
    final List? _lessonKeyList = await (OverPage.openMultipleChoosebleListViewFromMap(
      data: _filteredLessonList.fold<Map>({}, (p, e) => p..[e.key] = e.name),
      title: 'copylessonlisthint'.translate,
      showSelectAllItemIcon: true,
    ));

    if (_lessonKeyList == null) return;
    final _lessonListMustCopy = _lessonKeyList.map((e) => _fullLessonList.firstWhere((element) => element.key == e)).toList();
    String _errorText = '';
    _lessonListMustCopy.forEach((lesson) {
      String newDataKey;
      do {
        newDataKey = 3.makeKey;
      } while (AppVar.appBloc.lessonService!.dataList.any((lesson) => lesson.key == newDataKey));
      lesson.classKey = _targetClassKey;
      lesson.key = newDataKey;
      final _existingLesson = AppVar.appBloc.lessonService!.dataList.firstWhereOrNull((s) => s.classKey == _targetClassKey && s.name.toSearchCase() == lesson.name.toSearchCase());
      if (_existingLesson != null) _errorText += '\n${_existingLesson.name}';
    });
    if (_errorText.safeLength > 5) {
      OverAlert.show(message: 'savecopyusererr2'.translate + _errorText, autoClose: false);
      return;
    }
    if (_lessonListMustCopy.isEmpty) {
      OverAlert.nothingFoundToSave();
      return;
    }
    OverLoading.show();
    await LessonService.saveMultipleLesson(_lessonListMustCopy).then((a) {
      OverAlert.saveSuc();
    }).catchError((error) {
      log(error);
      OverAlert.show(message: 'saveerruser'.translate);
    });
    await OverLoading.close();
  }

  static Future<void> copyClass() async {
    final _result = await _getTargetTerm();
    if (_result == null) return;
    OverLoading.show();
    final _fetcher = SuperManagerMiniFetchers.classMiniFetchers(AppVar.appBloc.hesapBilgileri.kurumID, _result);
    await 2500.wait;
    final _fullClassList = _fetcher.dataList;
    await OverLoading.close();
    final List? _classKeyList = await (OverPage.openMultipleChoosebleListViewFromMap(
      data: _fullClassList.fold<Map>({}, (p, e) => p..[e.key] = e.name),
      title: 'classlist'.translate,
      showSelectAllItemIcon: true,
    ));

    if (_classKeyList == null) return;
    final _classList = _classKeyList.map((e) => _fullClassList.firstWhere((element) => element.key == e)).toList();
    String _errorText = '';
    _classList.forEach((sinif) {
      sinif.classTeacher = null;
      sinif.classTeacher2 = null;
      final _existingClass = AppVar.appBloc.classService!.dataList.firstWhereOrNull((s) => s.key == sinif.key);
      if (_existingClass != null) _errorText += '\n${_existingClass.name}';
    });
    if (_errorText.safeLength > 5) {
      OverAlert.show(message: 'savecopyusererr2'.translate + _errorText, autoClose: false);
      return;
    }
    if (_classList.isEmpty) {
      OverAlert.nothingFoundToSave();
      return;
    }
    OverLoading.show();
    await ClassService.saveMultipleClass(_classList).then((a) {
      OverAlert.saveSuc();
    }).catchError((error) {
      log(error);
      OverAlert.show(message: 'saveerruser'.translate);
    });
    await OverLoading.close();
  }

  static Future<void> copyStudent() async {
    final _result = await _getTargetTerm();
    if (_result == null) return;
    OverLoading.show();
    final _fetcher = SuperManagerMiniFetchers.studentMiniFetchers(AppVar.appBloc.hesapBilgileri.kurumID, _result);
    await 2500.wait;
    final _fullStudentList = _fetcher.dataList;
    await OverLoading.close();
    final List? _studentKeyList = await (OverPage.openMultipleChoosebleListViewFromMap(
      data: _fullStudentList.fold<Map>({}, (p, e) => p..[e.key] = e.name),
      title: 'studentlist'.translate,
      showSelectAllItemIcon: true,
    ));

    if (_studentKeyList == null) return;
    final _studentList = _studentKeyList.map((e) => _fullStudentList.firstWhere((element) => element.key == e)).toList();
    String _errorText = '';
    _studentList.forEach((student) {
      student.class0 = null;
      student.groupList.clear();
      final _existingUsernamePerson = AppVar.appBloc.studentService!.dataList.firstWhereOrNull((s) => s.username == student.username || s.key == student.key);
      if (_existingUsernamePerson != null) _errorText += '\n${_existingUsernamePerson.name}';
    });
    if (_errorText.safeLength > 5) {
      OverAlert.show(message: 'savecopyusererr1'.translate + _errorText, autoClose: false);
      return;
    }
    if (_studentList.isEmpty) {
      OverAlert.nothingFoundToSave();
      return;
    }
    OverLoading.show();
    await StudentService.saveMultipleStudent(_studentList).then((a) {
      OverAlert.saveSuc();
    }).catchError((error) {
      log(error);
      OverAlert.show(message: 'saveerruser'.translate);
    });
    await OverLoading.close();
  }

  static Future<void> copyTeacher() async {
    final _result = await _getTargetTerm();
    if (_result == null) return;
    OverLoading.show();
    final _fetcher = SuperManagerMiniFetchers.teacherMiniFetchers(AppVar.appBloc.hesapBilgileri.kurumID, _result);
    await 2500.wait;
    final _fullTeacherList = _fetcher.dataList;
    await OverLoading.close();
    final List? _teacherKeyList = await (OverPage.openMultipleChoosebleListViewFromMap(
      data: _fullTeacherList.fold<Map>({}, (p, e) => p..[e.key] = e.name),
      title: Words.teacherList,
      showSelectAllItemIcon: true,
    ));

    if (_teacherKeyList == null) return;
    final _teacherList = _teacherKeyList.map((e) => _fullTeacherList.firstWhere((element) => element.key == e)).toList();
    String _errorText = '';
    _teacherList.forEach((teacher) {
      final _existingUsernamePerson = AppVar.appBloc.teacherService!.dataList.firstWhereOrNull((t) => t.username == teacher.username || t.key == teacher.key);
      if (_existingUsernamePerson != null) _errorText += '\n${_existingUsernamePerson.name}';
    });
    if (_errorText.safeLength > 5) {
      OverAlert.show(message: 'savecopyusererr1'.translate + _errorText, autoClose: false);
      return;
    }
    if (_teacherList.isEmpty) {
      OverAlert.nothingFoundToSave();
      return;
    }
    OverLoading.show();
    await TeacherService.saveMultipleTeacher(_teacherList).then((a) {
      OverAlert.saveSuc();
    }).catchError((error) {
      log(error);
      OverAlert.show(message: 'saveerruser'.translate);
    });
    await OverLoading.close();
  }

  static Future<String?> _getTargetTerm() async {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    if (Fav.noConnection()) return null;

    var snapshot = await SchoolDataService.dbTermsRef().once(orderByChild: "aktif", equalTo: true);
    if (snapshot == null) return null;
    Map terms = snapshot.value;
    List<BottomSheetItem> _items = [];
    (terms.entries.toList()..sort((a, b) => a.value["name"].compareTo(b.value["name"]))).forEach((value) {
      if (value.value['name'] != AppVar.appBloc.hesapBilgileri.termKey) {
        _items.add(BottomSheetItem(name: value.value['name'], value: value.value['name']));
      }
    });
    final _result = await OverBottomSheet.show(BottomSheetPanel.simpleList(
      items: _items,
      title: 'selectcopyterm'.translate,
    ));

    return _result;
  }

  static Future<void> copyOpticForm(ExamType? examType) async {
    if (examType == null) return;
    final _result = await _getTargetTerm();
    if (_result == null) return;
    OverLoading.show();

    final _thisTermOpticFormFetcher = MiniFetchers.getFetcher<OpticFormModel>(MiniFetcherKeys.schoolOpticformTypes);

    final _existingOpticFormFetcher = MiniFetcher<OpticFormModel>(
      '${AppVar.appBloc.hesapBilgileri.kurumID}${_result}opticFormTypes',
      FetchType.ONCE,
      multipleData: true,
      jsonParse: (key, value) => OpticFormModel.fromJson(value),
      lastUpdateKey: 'lastUpdate',
      sortFunction: (OpticFormModel i1, OpticFormModel i2) => i2.name!.compareTo(i1.name!),
      removeFunction: (a) => a.name == null,
      queryRef: ExamService.dbGetSchoollOpticFormType(_result),
      filterDeletedData: true,
    );
    await 2500.wait;

    await OverLoading.close();

    final String? _selectedOpticFormKey = await (OverPage.openChoosebleListViewFromMap(
      data: _existingOpticFormFetcher.dataList.where((element) {
        return element.examTypeKey == examType.key;
      }).fold<Map>({}, (p, e) => p..[e.key] = e.name),
      title: 'copyopticformhint'.argsTranslate({'name': examType.name}),
    ));
    if (_selectedOpticFormKey == null) return;
    final _selectedOpticForm = _existingOpticFormFetcher.dataListItem(_selectedOpticFormKey);

    if (_thisTermOpticFormFetcher.dataList.any((element) => element.key == _selectedOpticFormKey)) {
      OverAlert.show(message: 'savecopyusererr2'.translate);
      await _existingOpticFormFetcher.dispose();
      return;
    }

    OverLoading.show();

    await ExamService.saveSchoolOpticForm(_selectedOpticForm!.mapForSave(), _selectedOpticFormKey).then((value) {
      OverAlert.saveSuc();
    }).catchError((err) {
      OverAlert.saveErr();
    });
    await _existingOpticFormFetcher.dispose();
    await OverLoading.close();
  }

  static Future<void> copyExamType() async {
    final _result = await _getTargetTerm();
    if (_result == null) return;
    OverLoading.show();

    final MiniFetcher<ExamType>? _thisTermExamTypeFetcher = MiniFetchers.getFetcher<ExamType>(MiniFetcherKeys.schoolExamTypes);

    final _existingExamTypeFetcher = MiniFetcher<ExamType>(
      '${AppVar.appBloc.hesapBilgileri.kurumID}${_result}examTypes',
      FetchType.ONCE,
      multipleData: true,
      jsonParse: (key, value) => ExamType.fromJson(value, key),
      lastUpdateKey: 'lastUpdate',
      sortFunction: (ExamType i1, ExamType i2) => i2.name!.compareTo(i1.name!),
      removeFunction: (a) => a.name == null,
      queryRef: ExamService.dbGetSchoolExamTypes(_result),
      filterDeletedData: true,
    );
    await 2500.wait;

    await OverLoading.close();

    final String? _selectedExamTypeKey = await (OverPage.openChoosebleListViewFromMap(
      data: _existingExamTypeFetcher.dataList.fold<Map>({}, (p, e) => p..[e.key] = e.name),
      title: 'anitemchoose'.translate,
    ));
    if (_selectedExamTypeKey == null) return;
    final _selectedExamType = _existingExamTypeFetcher.dataListItem(_selectedExamTypeKey);

    if (_thisTermExamTypeFetcher!.dataList.any((element) => element.key == _selectedExamTypeKey)) {
      OverAlert.show(message: 'savecopyusererr2'.translate);
      await _existingExamTypeFetcher.dispose();
      return;
    }

    OverLoading.show();

    await ExamService.saveSchoolExamType(_selectedExamType!.mapForSave(), _selectedExamTypeKey).then((value) {
      OverAlert.saveSuc();
    }).catchError((err) {
      OverAlert.saveErr();
    });
    await _existingExamTypeFetcher.dispose();
    await OverLoading.close();
  }
}
