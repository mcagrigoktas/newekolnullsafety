import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../appbloc/minifetchers.dart';
import '../../../../models/allmodel.dart';
import '../../../../screens/announcements/shareannouncements.dart';
import '../../../../services/dataservice.dart';
import '../../../../supermanager/schoolreview/helpers.dart';
import '../../../../supermanager/supermanagerbloc.dart';
import '../examresultcalcalculator.dart';
import '../examresultpage/controller.dart';
import '../examresultpage/examresultreview.dart';
import '../examtypes/controller.dart';
import '../examtypes/model.dart';
import '../helper.dart';
import '../opticformtypes/controller.dart';
import '../opticformtypes/model.dart';
import 'bookletdefine/model.dart';
import 'examstatewidget.dart';
import 'model.dart';

class ExamController extends GetxController {
  final EvaulationUserType girisTuru;
  ExamController(this.girisTuru);

  VisibleScreen visibleScreen = VisibleScreen.main;
  bool isPageLoading = true;
  bool isLoading = false;
  MiniFetcher<Exam>? allSchoolExams;
  MiniFetcher<Exam>? allGlobalExams;
  ExamTypeController get _examTypeController => Get.find<ExamTypeController>();
  OpticFormDefineController get _opticFormDefineController => Get.find<OpticFormDefineController>();

  List<ExamType> get allExamType => _examTypeController.allExamType;
  List<OpticFormModel> get allOpticFormType => _opticFormDefineController.allOpticForm;
  // MiniFetcher<ExamType> allExamsTypes;
  // MiniFetcher<OpticFormModel> allOpticForms;
  GlobalKey<FormState> formKey = GlobalKey();
  Exam? selectedItem;

  bool get dataIsNew => selectedItem != null && selectedItem!.key == null;
  bool elementIsVisible(Exam element) {
    if (girisTuru == EvaulationUserType.school) {
      return element.kurumIdList!.contains(AppVar.appBloc.hesapBilgileri.kurumID);
    }
    if (girisTuru == EvaulationUserType.supermanager) {
      return element.savedBy == Get.find<SuperManagerController>().hesapBilgileri.kurumID;
    }
    return true;
  }

  bool elementCanBeChange(Exam? element) {
    if (girisTuru == EvaulationUserType.school) {
      return element!.userType == EvaulationUserType.school;
    }
    if (girisTuru == EvaulationUserType.supermanager) {
      return element!.savedBy == Get.find<SuperManagerController>().hesapBilgileri.kurumID;
    }
    return true;
  }

  StreamSubscription? subscription;
  StreamSubscription? subscription2;
  @override
  void onInit() {
    super.onInit();
    fetchAndSubscribeData();
  }

  @override
  void onClose() {
    subscription?.cancel();
    subscription2?.cancel();
    Get.delete<ExamTypeController>(force: true);
    Get.delete<OpticFormDefineController>(force: true);
    super.onClose();
  }

  void fetchAndSubscribeData() {
    if (girisTuru == EvaulationUserType.school) {
      allSchoolExams = MiniFetchers.getFetcher(MiniFetcherKeys.allSchoolExams) as MiniFetcher<Exam>?;
    }
    allGlobalExams = MiniFetchers.getFetcher(MiniFetcherKeys.allGlobalExams) as MiniFetcher<Exam>?;

    subscription = allSchoolExams?.stream.listen((state) {
      isPageLoading = false;
      _finalList = null;
      update();
    });
    subscription2 = allGlobalExams!.stream.listen((state) {
      isPageLoading = false;
      _finalList = null;
      update();
    });
    // allExamsTypes = MiniFetchers.getFetcher(MiniFetcherKeys.allExamType);
    // allOpticForms = MiniFetchers.getFetcher(MiniFetcherKeys.allOpticformType);
    Get.put<ExamTypeController>(ExamTypeController(girisTuru));
    Get.put<OpticFormDefineController>(OpticFormDefineController(null, girisTuru));
  }

  void addItem() {
    if (isLoading || isPageLoading) return;
    selectedItem = Exam()..userType = girisTuru;
    formKey = GlobalKey();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  String? filteredText;
  List<int>? dateFilter;
  String? filteredExamTypeKey;
  List<Exam> getFinalList() {
    return _prepareFinalList()!.where((element) {
      if (filteredText.safeLength > 0 && !element.getSearchText.contains(filteredText!)) return false;
      if (filteredExamTypeKey.safeLength > 0 && element.examTypeKey != filteredExamTypeKey) return false;
      if (dateFilter != null && (element.date! < dateFilter!.first || element.date! > dateFilter!.last)) return false;
      return true;
    }).toList()
      ..sort((i1, i2) => (i2.date ?? i2.lastUpdate).compareTo(i1.date ?? i1.lastUpdate));
  }

  List<Exam>? _finalList;
  List<Exam>? _prepareFinalList() {
    if (_finalList != null) return _finalList;
    _finalList = <Exam>[
      ...(allSchoolExams?.dataList ?? []),
      ...(allGlobalExams?.dataList ?? []),
    ].where(elementIsVisible).toList();
    //   ..sort((i1, i2) => i2.lastUpdate.compareTo(i1.lastUpdate));
    return _finalList;
  }

  void selectItem(Exam item) {
    if (isLoading || isPageLoading) return;
    selectedItem = item;

    ///exam type degismisse yenisini koymak icin
    if (_examTypeController.allExamType.singleWhereOrNull((element) => element.key == (item.examTypeKey)) != null) {
      item.examTypeData = _examTypeController.allExamType.singleWhere((element) => element.key == (item.examTypeKey)).mapForSave();
    }

    formKey = GlobalKey();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  void deSelectItem() {
    selectedItem = null;
    formKey = GlobalKey();
    visibleScreen = VisibleScreen.main;
    update();
  }

  Future<bool> saveItem({bool alert = true}) async {
    if (formKey.currentState!.checkAndSave()) {
      //    if (dataIsNew && selectedItem.seisonDatFiles.isEmpty) selectedItem.addExamDatFiles();

      if (dataIsNew && girisTuru == EvaulationUserType.school) selectedItem!.kurumIdList = [AppVar.appBloc.hesapBilgileri.kurumID];

      if (dataIsNew) {
        selectedItem!.userType = girisTuru;

        if (girisTuru == EvaulationUserType.school) {
          selectedItem!.savedBy = AppVar.appBloc.hesapBilgileri.uid;
        } else if (girisTuru == EvaulationUserType.supermanager) {
          selectedItem!.savedBy = Get.find<SuperManagerController>().hesapBilgileri.kurumID;
        } else {
          throw Exception('Admin sayfasinda sinav su an aktif degil');
        }
      }

      if (dataIsNew) selectedItem!.key ??= 15.makeKey;

      if (selectedItem!.key.safeLength < 5) return false;
      selectedItem!.lastUpdate = databaseTime;

      if (selectedItem!.notGood) {
        OverAlert.saveErr();
        return false;
      }
      isLoading = true;
      update();
      if (selectedItem!.userType == EvaulationUserType.school) await ExamService.saveSchoollExam(selectedItem!.mapForSave(), selectedItem!.key!);
      if (selectedItem!.userType == EvaulationUserType.supermanager) await ExamService.saveGlobalExams(selectedItem!.mapForSave(), selectedItem!.key!);
      if (selectedItem!.userType == EvaulationUserType.admin) throw Exception('Admin sayfasinda sinav su an aktif degil');
      isLoading = false;
      update();
      if (alert) OverAlert.saveSuc();
      return true;
    }
    return false;
  }

  Future<bool> copyExamGlobalToSchool() async {
    final _newExam = Exam.fromJson(selectedItem!.mapForSave(), selectedItem!.key);

    _newExam.kurumIdList = [AppVar.appBloc.hesapBilgileri.kurumID];
    _newExam.userType = EvaulationUserType.school;
    _newExam.savedBy = AppVar.appBloc.hesapBilgileri.uid;

    _newExam.key = 'copy' + selectedItem!.key!;
    _newExam.name = '* ' + selectedItem!.name!.trim() + ' *';

    _newExam.lastUpdate = databaseTime;

    if (_newExam.notGood) {
      OverAlert.saveErr();
      return false;
    }

    if (_finalList!.any((element) => element.key == _newExam.key)) {
      OverAlert.saveErr();
      return false;
    }
    isLoading = true;
    update();
    await ExamService.saveSchoollExam(_newExam.mapForSave(), _newExam.key!);
    isLoading = false;
    update();
    OverAlert.saveSuc();
    return true;
  }

  Future<void> deleteItem() async {
    isLoading = true;
    update();
    if (selectedItem!.key.safeLength < 5) return;
    selectedItem!.aktif = false;
    selectedItem!.lastUpdate = databaseTime;
    if (girisTuru == EvaulationUserType.school) await ExamService.saveSchoollExam(selectedItem!.mapForSave(), selectedItem!.key!);
    if (girisTuru == EvaulationUserType.supermanager) await ExamService.saveGlobalExams(selectedItem!.mapForSave(), selectedItem!.key!);
    isLoading = false;
    deSelectItem();
  }

  Future<void> addexambookletfile() async {
    var fileType = await {
      ExamFileType.file: 'file'.translate,
      ExamFileType.url: 'link'.translate,
      ExamFileType.youtubeVideo: 'youtubelink'.translate,
    }.selectOne<ExamFileType>(title: 'type'.translate);
    if (fileType == null) return;
    selectedItem!.examBookLetFiles.add(ExamFile(name: '', url: '', examFileType: fileType));
    update();
  }

  Future<void> calcResult() async {
    if (Fav.noConnection()) return;
    if (selectedItem!.resultsUrl.safeLength > 3) {
      var sure = await Over.sure(message: 'sureexamcalc'.translate);
      if (sure != true) return;
    }

    Map<String, List<Student>> allKurumStudents;
    Map<String, List<Class>> allKurumClass;
    String saveLocation;
    if (girisTuru == EvaulationUserType.school) {
      allKurumStudents = {
        AppVar.appBloc.hesapBilgileri.kurumID: AppVar.appBloc.studentService!.dataList,
      };
      allKurumClass = {
        AppVar.appBloc.hesapBilgileri.kurumID: AppVar.appBloc.classService!.dataList,
      };
      saveLocation = "${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/ExamFiles";
    } else if (girisTuru == EvaulationUserType.supermanager) {
      OverLoading.show();
      allKurumStudents = {};
      allKurumClass = {};

      for (var k = 0; k < selectedItem!.kurumIdList!.length; k++) {
        final kurumId = selectedItem!.kurumIdList![k];
        Map? schoolInfoMap = await SuperManagerHelpers.getSchoolInfoMap(kurumId);

        if (schoolInfoMap == null) {
          OverAlert.show(message: 'kurumiderror'.argTranslate(kurumId));
          throw Exception(kurumId + ' Kurum Idsi  bulunamadi');
        }
        final String? termKey = schoolInfoMap['activeTerm'];
        final comleter1 = Completer();
        final comleter2 = Completer();
        var studentFecther = SuperManagerMiniFetchers.studentMiniFetchers(kurumId, termKey, getValueAfterOnlyDatabaseQuery: (_) => comleter1.complete());
        var classFecther = SuperManagerMiniFetchers.classMiniFetchers(kurumId, termKey, getValueAfterOnlyDatabaseQuery: (_) => comleter2.complete());
        await Future.wait([comleter1.future, comleter2.future]);
        await 50.wait;
        allKurumStudents[kurumId] = studentFecther.dataList;
        allKurumClass[kurumId] = classFecther.dataList;
      }

      saveLocation = '${Get.find<SuperManagerController>().hesapBilgileri.kurumID}/ExamFiles';
      await OverLoading.close();
    } else {
      throw Exception('Admin puan hesaplayamaz');
    }

    if (selectedItem!.answerEarningData == null) {
      'hasanswerdata1'.translate.showAlert();
      return;
    }

    String? url;
    try {
      OverLoading.show(style: OverLoadingWidgetStyle(text: 'examresultcalculating'.translate));
      url = await ExamResultCalculator.calcresult(
        examType: selectedItem!.examType!,
        opticForms: selectedItem!.formType.isOpticFormActive ? selectedItem!.opticFormData!.map((key, value) => MapEntry(key, OpticFormModel.fromJson(value))) : null,
        answerEarningData: selectedItem!.answerEarningData!,
        allKurumDatFiles: selectedItem!.seisonDatFiles,
        allKurumStudents: allKurumStudents,
        allKurumClass: allKurumClass,
        saveLocation: saveLocation,
        exam: selectedItem!,
      );
    } catch (err) {
      'examcalculateerr'.translate.toString().showAlert();
      log(err);
    } finally {
      await OverLoading.close();
    }

    if (url != null) {
      selectedItem!.resultsUrl = url;
      await saveItem();
      await viewResult();
    }
  }

  Future<ExamResultBigData?> _getResult() async {
    if (Fav.noConnection()) return null;

    if (selectedItem!.resultsUrl.safeLength < 3) {
      OverAlert.show(message: 'examresulterr'.translate);
      return null;
    }
    OverLoading.show();
    final data = await (DownloadManager.downloadThenCache(url: selectedItem!.resultsUrl!));
    final String stringData = DownloadManager.convertText(data!.byteData, allowMalformed: true);

    await OverLoading.close();

    final Map mapData = json.decode(stringData);
    return ExamResultBigData.fromJson(mapData);
  }

  Future<void> viewResult() async {
    final data = await _getResult();
    if (data == null) return;
    if (data.examResult == null) {
      OverAlert.show(message: 'examresulterr'.translate);
      return;
    }
    await Fav.to(ExamResultReview(), binding: BindingsBuilder(() => Get.put<ExamResultViewController>(ExamResultViewController(examResultBigData: data, girisTuru: girisTuru, examType: selectedItem!.examType!, exam: selectedItem!))));
  }

  Future<void> sendResult() async {
    if (girisTuru != EvaulationUserType.school) {
      OverAlert.show(message: 'examresultsendonlyschool'.translate, autoClose: false);
      return;
    }
    if (selectedItem!.resultSendedToStudent![AppVar.appBloc.hesapBilgileri.kurumID] == true) {
      var sure = await Over.sure(message: 'suredatasenderr'.translate);
      if (sure != true) return;
    }
    final data = await _getResult();
    if (data == null) return;

    ///KurumId
    ///      -> student key data
    final Map<String?, Map<String, Map>> willSend = {};

    Map<String, String?> reversedEarninKeyMap = {};
    if (data.earningIsActive!) {
      reversedEarninKeyMap = data.earninKeyMap!.map((key, value) => MapEntry(value, key));
    }

    data.examResult![AppVar.appBloc.hesapBilgileri.kurumID]!.forEach((studentKey, studentData) {
      if (!studentData!.studentKey!.startsWith('??')) {
        willSend[studentData.studentKey] = {};
        willSend[studentData.studentKey]!['examData'] = studentData.mapForSave();
        willSend[studentData.studentKey]!['examType'] = selectedItem!.examType!.mapForStudent();
        willSend[studentData.studentKey]!['exam'] = selectedItem!.mapForStudent();
        if (data.earningIsActive == true) willSend[studentData.studentKey]!['earningResultKeyMap'] = reversedEarninKeyMap;
      }
    });
    OverLoading.show();
    await ExamService.sendExamResultInPortfollio(willSend, selectedItem!.key!, selectedItem!.name!).then((_) async {
      selectedItem!.resultSendedToStudent![AppVar.appBloc.hesapBilgileri.kurumID] = true;
      await saveItem();
    }).catchError((e) {
      OverAlert.saveErr();
    });
    await OverLoading.close();
  }

  Future<void> makeannouncement() async {
    if (girisTuru == EvaulationUserType.school) {
      if ((await saveItem(alert: false)) == false) return;
      if (selectedItem!.examBookLetFiles.isNotEmpty || selectedItem!.bookLetsData?.isNotEmpty == true) {
        var res = await Get.dialog(Center(
          child: SingleChildScrollView(
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  Card(
                    child: Column(
                      children: [
                        if (selectedItem!.examBookLetFiles.isNotEmpty) 'examfiles'.translate.text.bold.make().p8,
                        ...selectedItem!.examBookLetFiles
                            .map((e) => AdvanceDropdown<bool>(
                                  name: e.name,
                                  onChanged: (value) => e.isPublish = value,
                                  initialValue: e.isPublish ?? false,
                                  iconData: Icons.attach_file_outlined,
                                  items: [
                                    DropdownItem(value: true, name: 'showinannouncement'.translate),
                                    DropdownItem(value: false, name: 'showinannouncement2'.translate),
                                  ],
                                ))
                            .toList(),
                      ],
                    ),
                  ).pb16,
                  if (selectedItem!.bookLetsData?.isNotEmpty == true) ExamStateWidget(selectedItem),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MyRaisedButton(
                          onPressed: () {
                            Get.back();
                          },
                          color: Colors.redAccent,
                          text: 'cancel'.translate),
                      MyRaisedButton(
                          onPressed: () {
                            Get.back(result: true);
                          },
                          color: Colors.green,
                          text: 'next'.translate)
                    ],
                  )
                ],
              ),
            ).p12,
          ),
        ));
        if (res == null) return;
      }

      final announcement = Announcement.create(selectedItem!.key!)
        ..title = selectedItem!.existinAnnouncementData['title'] ?? selectedItem!.name
        ..content = selectedItem!.existinAnnouncementData['content'] ?? selectedItem!.explanation
        ..targetList = selectedItem!.existinAnnouncementData['targetList'] == null ? null : List<String>.from(selectedItem!.existinAnnouncementData['targetList'])
        ..aktif = true
        ..isPublish = true
        ..senderKey = AppVar.appBloc.hesapBilgileri.kurumID
        ..senderName = AppVar.appBloc.hesapBilgileri.name;

      announcement.extraData ??= {};
      announcement.extraData!['examInfo'] = {
        'date': selectedItem!.date,
        'name': selectedItem!.name,
      };

      selectedItem!.examBookLetFiles.where((element) => element.isPublish == true).forEach((element) {
        announcement.extraData!['examFileList'] ??= [];
        (announcement.extraData!['examFileList'] as List).add(element.mapForSave());
      });

      if (selectedItem!.formType.isOnlineFormActive && selectedItem!.bookLetsData != null) {
        selectedItem!.bookLetsData!.forEach((key, value) {
          if (value!.notificationRole.bookletMustAdded) {
            announcement.extraData!['onlineForms'] ??= {};
            announcement.extraData!['onlineForms'][key] = value.mapForStudent();
            announcement.extraData!['examType'] = selectedItem!.examType!.mapForStudent();
          }
        });
      }

      var result = await Fav.guardTo(ShareAnnouncements(existingAnnouncement: announcement));
      if (result == true) {
        selectedItem!.existinAnnouncementData['title'] = announcement.title;
        selectedItem!.existinAnnouncementData['content'] = announcement.content;
        selectedItem!.existinAnnouncementData['targetList'] = announcement.targetList;
        await saveItem();
      }
    } else if (girisTuru == EvaulationUserType.supermanager && selectedItem!.userType == EvaulationUserType.supermanager) {
    } else {
      'notauthorized'.translate.showAlert();
    }
  }
}
