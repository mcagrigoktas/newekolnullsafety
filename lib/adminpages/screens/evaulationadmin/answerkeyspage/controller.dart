import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../library_helper/excel/eager.dart';
import '../../../../screens/importpages/excel_helper.dart';
import '../../../../services/dataservice.dart';
import '../../../../supermanager/supermanagerbloc.dart';
import '../exams/model.dart';
import '../examtypes/model.dart';
import '../helper.dart';
import 'earning_list_define/model.dart';
import 'model.dart';

class AnswerKeyController extends GetxController {
  Exam? exam;
  ExamType? get examType => exam!.examType;
  AnswerKeyModel? answerEarningMap;
  GlobalKey<FormState> formKey = GlobalKey();
  EvaulationUserType girisTuru;
  AnswerKeyController(this.exam, this.girisTuru);
  MiniFetcher<EarningItem>? allEarningItems;

  String drowdownValueKeyPrefix = 6.makeKey;

  bool isLoading = false;

  void changeBookLetCount(value) {
    answerEarningMap!.bookLetCount = value;
    update();
  }

  void changeEarningIsActive(dynamic value) {
    answerEarningMap!.earningsIsActive = value as bool?;
    update();
  }

  void changeAnswerKeyLocation(AnswerKeyLocation value) {
    answerEarningMap!.answerKeyLocation = value;
    update();
  }

  Future<void> save() async {
    if (Fav.noConnection()) return;
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isLoading = true;
      update();

      if (girisTuru == EvaulationUserType.school) await ExamService.saveSchoolExamAnswerEarningData(answerEarningMap!.mapForSave(), exam!.key!);
      if (girisTuru == EvaulationUserType.supermanager) await ExamService.saveGlobalExamAnswerEarningData(answerEarningMap!.mapForSave(), exam!.key!);
      if (girisTuru == EvaulationUserType.admin) throw Exception('admin sayfasi sinav tanimlamaya hazir degil');
      exam!.answerEarningData = answerEarningMap;
      isLoading = false;
      Get.back();
    }
  }

  int? get bookLetCounnt => answerEarningMap!.bookLetCount;
  bool? get earningsIsActive => answerEarningMap!.earningsIsActive;
  AnswerKeyLocation get answerKeyLocation => answerEarningMap!.answerKeyLocation ?? AnswerKeyLocation.menu;

  StreamSubscription? _allEarningItemsSubscription;
  @override
  void onInit() {
    super.onInit();

    if (girisTuru == EvaulationUserType.admin) throw Exception('admin sayfasi sinav tanimlamaya hazir degil');

    exam!.answerEarningData ??= AnswerKeyModel(bookLetCount: 2, earningsIsActive: false, answerKeyLocation: AnswerKeyLocation.menu);
    answerEarningMap = exam!.answerEarningData;

//todo bunu sorun cikartirsa  Minifetcherlistesine tasiyabilirsin
    allEarningItems = MiniFetcher<EarningItem>(girisTuru == EvaulationUserType.school ? '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}allEarningList' : '${Get.find<SuperManagerController>().hesapBilgileri.kurumID}allEarningList', FetchType.LISTEN,
        multipleData: true,
        jsonParse: (key, value) => EarningItem.fromJson(value, key),
        lastUpdateKey: 'lastUpdate',
        sortFunction: (EarningItem i1, EarningItem i2) => i2.name!.compareTo(i1.name!),
        queryRef: girisTuru == EvaulationUserType.school ? ExamService.dbSchoollEarningItemList() : ExamService.dbGlobalEarningItemList(Get.find<SuperManagerController>().hesapBilgileri.kurumID),
        filterDeletedData: true,
        removeFunction: (a) => a.name == null);
    _allEarningItemsSubscription = allEarningItems!.stream.listen((state) {
      update();
    });
  }

  Map<int, String?> earningListContent = {};

  Future<void> downloadExcelFile() async {
    List<List> data = [
      [
        'testname'.translate,
        noToBooklet(1)! + ' - ' + 'questionno'.translate,
        noToBooklet(2)! + ' - ' + 'questionno'.translate,
        'answer'.translate,
        'earningtext'.translate,
        noToBooklet(3)! + ' - ' + 'questionno'.translate,
        noToBooklet(4)! + ' - ' + 'questionno'.translate,
      ]
    ];

    exam!.examType!.lessons!.forEach((lesson) {
      for (var i = 0; i < lesson.questionCount!; i++) {
        data.add([
          lesson.name,
          i + 1,
          '',
          '',
          '',
          '',
          '',
        ]);
      }
      for (var i = 0; i < lesson.wQuestionCount!; i++) {
        data.add([
          lesson.name! + '-w',
          i + 1,
          '',
          '',
          '',
          '',
          '',
        ]);
      }
    });

    await ExcelLibraryHelper.export(data, (exam!.examType?.name ?? exam!.name ?? '') + 'answerkey'.translate + ' ' + 'earninglist'.translate);
  }

  Future<void> uploadExcelFile() async {
    final _dataStringList = await ExcelHelper.chooseFileThenConvertToList();
    if (_dataStringList == null) return;

    final _rows = _dataStringList.map((e) {
      String _testName = e[0];

//! Ilginc bir sekilde icinde turkce karakter olan dersleri exceldeki ile eslestirmiyordu bu yuzden turkce karakterler cikmis hali eslesiyorsa ayni ders sayildi
      if (_dataStringList.indexOf(e) != 0 && exam!.examType!.lessons!.every((element) => element.name != _testName)) {
        final _benzerIsimliTest = exam!.examType!.lessons!.firstWhereOrNull((element) {
          return element.name.removeNonEnglishCharacter == _testName.removeNonEnglishCharacter;
        });
        if (_benzerIsimliTest != null) _testName = _benzerIsimliTest.name!;
      }
      //!
      final _model = AnswerKeyImportModel(
        aNo: int.tryParse(e[1]) ?? 0,
        bNo: int.tryParse(e[2]) ?? 0,
        cNo: int.tryParse(e.length > 5 ? e[5] : '?') ?? 0,
        dNo: int.tryParse(e.length > 6 ? e[6] : '?') ?? 0,
        answer: e[3].safeLength > 0 ? e[3] : '?',
        earningText: e[4].safeLength > 0 ? e[4] : '?',
        testName: _testName,
      );
      return _model;
    }).toList();

    exam!.examType!.lessons!.forEach((lesson) {
      final _lessonRows = _rows.where((element) {
        return element.testName == lesson.name;
      }).toList();

      for (var b = 1; b < answerEarningMap!.bookLetCount! + 1; b++) {
        final _bookletName = noToBooklet(b);
        String _currentAnswerValue = answerEarningMap!.datas['bookLet$_bookletName' + lesson.key! + 'answers'] ?? '';
        while (_currentAnswerValue.length < lesson.questionCount!) {
          _currentAnswerValue += ' ';
        }
        for (var i = 0; i < lesson.questionCount!; i++) {
          final _answerModel = _lessonRows.firstWhereOrNull((element) {
            if (b == 1) return element.aNo == i + 1;
            if (b == 2) return element.bNo == i + 1;
            if (b == 3) return element.cNo == i + 1;
            if (b == 4) return element.dNo == i + 1;
            return false;
          });

          if (_answerModel == null) {
            OverAlert.show(
                message: 'answerkeyimporterr1'.argsTranslate({
                  'bookletName': _bookletName,
                  'lessonName': lesson.name,
                  'questionNo': i + 1,
                }),
                type: AlertType.danger,
                autoClose: false);
            throw ('ErrorCode:4980 $_bookletName${lesson.name}${i + 1}');
          }
          final _characterOrder = b == 1
              ? _answerModel.aNo!
              : b == 2
                  ? _answerModel.bNo!
                  : b == 3
                      ? _answerModel.cNo!
                      : b == 4
                          ? _answerModel.dNo!
                          : -1;
          _currentAnswerValue = _currentAnswerValue.changeCharacter(_characterOrder - 1, _answerModel.answer);
        }
        answerEarningMap!.datas['bookLet$_bookletName' + lesson.key! + 'answers'] = _currentAnswerValue;
        answerEarningMap!.datas['bookLet$_bookletName' + lesson.key! + 'earnings'] = (_lessonRows
              ..sort((i1, i2) {
                return b == 1
                    ? i1.aNo! - i2.aNo!
                    : b == 2
                        ? i1.bNo! - i2.bNo!
                        : b == 3
                            ? i1.cNo! - i2.cNo!
                            : b == 4
                                ? i1.dNo! - i2.dNo!
                                : 0;
              }))
            .where((element) => element.testName == lesson.name)
            .fold<String>('', (p, e) => p += ((e.earningText ?? '') + '\n'));
      }
      final _wlessonRows = _rows.where((element) => element.testName == lesson.name! + '-w').toList();
      for (var b = 1; b < answerEarningMap!.bookLetCount!; b++) {
        final _bookletName = noToBooklet(b);

        for (var i = 0; i < lesson.wQuestionCount!; i++) {
          final _answerModel = _wlessonRows.firstWhereOrNull((element) {
            if (b == 1) return element.aNo == i + 1;
            if (b == 2) return element.bNo == i + 1;
            if (b == 3) return element.cNo == i + 1;
            if (b == 4) return element.dNo == i + 1;
            return false;
          });
          if (_answerModel == null) {
            OverAlert.show(
                message: 'answerkeyimporterr1'.argsTranslate({
                  'bookletName': _bookletName,
                  'lessonName': lesson.name! + '-w',
                  'questionNo': i + 1,
                }),
                type: AlertType.danger,
                autoClose: false);
            throw ('ErrorCode:4981');
          }

          answerEarningMap!.datas['bookLet$_bookletName' +
              lesson.key! +
              '-w${b == 1 ? _answerModel.aNo : b == 2 ? _answerModel.bNo : b == 3 ? _answerModel.cNo : b == 4 ? _answerModel.dNo : 0}' +
              'answers'] = _answerModel.answer;
          answerEarningMap!.datas['bookLet$_bookletName' +
              lesson.key! +
              '-w${b == 1 ? _answerModel.aNo : b == 2 ? _answerModel.bNo : b == 3 ? _answerModel.cNo : b == 4 ? _answerModel.dNo : 0}' +
              'earnings'] = _answerModel.earningText;
        }
      }
    });
    formKey = GlobalKey();
    update();
  }

  @override
  void onClose() {
    _allEarningItemsSubscription?.cancel();
    super.onClose();
  }

  String? noToBooklet(int no) {
    if (no == 1) return 'A';
    if (no == 2) return 'B';
    if (no == 3) return 'C';
    if (no == 4) return 'D';
    return null;
  }
}

class AnswerKeyImportModel {
  String? testName;
  int? aNo;
  int? bNo;
  int? cNo;
  int? dNo;
  String? answer;
  String? earningText;
  AnswerKeyImportModel({this.aNo, this.bNo, this.cNo, this.dNo, this.answer, this.earningText, this.testName});

  @override
  String toString() {
    return 'TestName:$testName aNo:$aNo bNo:$bNo cNo:$cNo dNo:$dNo answer:$answer earningText:$earningText';
  }
}
