import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../appbloc/minifetchers.dart';
import '../../../../services/dataservice.dart';
import '../helper.dart';
import 'model.dart';

class ExamTypeController extends GetxController {
  EvaulationUserType girisTuru;
  VisibleScreen visibleScreen = VisibleScreen.main;
  bool pageLoading = true;
  bool isLoading = false;
  MiniFetcher<ExamType>? allExamTypes;
  MiniFetcher<ExamType>? schoolExamTypes;
  List<ExamType> get allExamType {
    return [
      ...allExamTypes!.dataList.where((element) => girisTuru == EvaulationUserType.admin || element.isPublished == true),
      if (girisTuru == EvaulationUserType.school) ...schoolExamTypes!.dataList.where((element) => true),
    ];
  }

  bool elementCanBeChange(ExamType element) {
    if (girisTuru == EvaulationUserType.admin) {
      return element.userType == EvaulationUserType.admin;
    }
    if (girisTuru == EvaulationUserType.school) {
      return element.userType == EvaulationUserType.school;
      //  && element.savedBy == AppVar.appBloc.hesapBilgileri.uid;
    }
    return false;
  }

  bool get advanceMenu => girisTuru == EvaulationUserType.admin;

  GlobalKey<FormState> formKey = GlobalKey();
  ExamType? selectedItem;

  bool get dataIsNew => selectedItem != null && selectedItem!.key == null;
  StreamSubscription? subscription;
  StreamSubscription? subscription2;

  ExamTypeController(this.girisTuru);

  @override
  void onInit() {
    super.onInit();
    fetchAndSubscribeData();
  }

  @override
  void onClose() {
    subscription?.cancel();
    subscription2?.cancel();
    super.onClose();
  }

  void fetchAndSubscribeData() {
    allExamTypes = MiniFetchers.getFetcher(MiniFetcherKeys.allExamType) as MiniFetcher<ExamType>?;
    subscription = allExamTypes!.stream.listen((state) {
      pageLoading = false;
      update();
    });
    if (girisTuru == EvaulationUserType.school) {
      schoolExamTypes = MiniFetchers.getFetcher(MiniFetcherKeys.schoolExamTypes) as MiniFetcher<ExamType>?;
      subscription2 = schoolExamTypes!.stream.listen((state) {
        pageLoading = false;
        update();
      });
    }
  }

  void addItem() {
    if (isLoading || pageLoading) return;
    selectedItem = ExamType();
    formKey = GlobalKey();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  void selectItem(ExamType item) {
    if (isLoading || pageLoading) return;
    selectedItem = item;
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

  Future<void> saveItem() async {
    if (formKey.currentState!.checkAndSave()) {
      isLoading = true;
      update();
      if (dataIsNew) {
        selectedItem!.userType = girisTuru;
        selectedItem!.savedBy = girisTuru == EvaulationUserType.admin
            ? girisTuru.toString()
            : girisTuru == EvaulationUserType.school
                ? AppVar.appBloc.hesapBilgileri.uid
                : null;
        if (selectedItem!.savedBy == null) throw Exception('Simdillik super manager sayfasindan optic form tanimlanmiyot');
        selectedItem!.key ??= 10.makeKey;
      }
      if (selectedItem!.key.safeLength < 5) return;
      selectedItem!.lastUpdate = databaseTime;
      if (girisTuru == EvaulationUserType.school) {
        await ExamService.saveSchoolExamType(selectedItem!.mapForSave(), selectedItem!.key!);
      } else if (girisTuru == EvaulationUserType.admin) {
        await ExamService.saveAdminExamType(selectedItem!.mapForSave(), selectedItem!.key!);
      } else {
        throw Exception('Bilinmeyen  kullanici  tipi');
      }

      isLoading = false;
      deSelectItem();
    }
  }

  Future<void> deleteItem() async {
    isLoading = true;
    update();
    if (selectedItem!.key.safeLength < 5) return;
    selectedItem!.aktif = false;
    selectedItem!.lastUpdate = databaseTime;
    if (girisTuru == EvaulationUserType.school) {
      await ExamService.saveSchoolExamType(selectedItem!.mapForSave(), selectedItem!.key!);
    } else if (girisTuru == EvaulationUserType.admin) {
      await ExamService.saveAdminExamType(selectedItem!.mapForSave(), selectedItem!.key!);
    } else {
      throw Exception('Bilinmeyen  kullanici  tipi');
    }

    isLoading = false;
    deSelectItem();
  }

  void addNewLesson() {
    selectedItem!.lessons ??= [];
    selectedItem!.lessons!.add(ExamTypeLesson.create());
    update();
  }

  void clearLesson(ExamTypeLesson lesson) {
    update();
    selectedItem!.lessons!.remove(lesson);
  }

  void addNewScoring() {
    selectedItem!.scoring ??= [];
    selectedItem!.scoring!.add(Scoring.create());
    update();
  }

  void clearScoring(Scoring scor) {
    update();
    selectedItem!.scoring!.remove(scor);
  }
}
