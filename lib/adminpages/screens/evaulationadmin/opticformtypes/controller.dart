import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../appbloc/minifetchers.dart';
import '../../../../services/dataservice.dart';
import '../../../../supermanager/supermanagerbloc.dart';
import '../examtypes/model.dart';
import '../helper.dart';
import 'model.dart';

class OpticFormDefineController extends GetxController {
  EvaulationUserType girisTuru;
  VisibleScreen visibleScreen = VisibleScreen.main;
  bool isPageLoading = true;
  bool isLoading = false;
  MiniFetcher<OpticFormModel>? allOpticForms;
  MiniFetcher<OpticFormModel>? allSchoolOpticForms;
  List<OpticFormModel> get allOpticForm {
    if (girisTuru == EvaulationUserType.admin) {
      return [
        ...allOpticForms!.dataList.where((element) => element.userType == EvaulationUserType.admin),
      ];
    }
    if (girisTuru == EvaulationUserType.supermanager) {
      return [
        ...allOpticForms!.dataList.where((element) => (element.userType == EvaulationUserType.admin && element.isPublished == true) || (girisTuru == EvaulationUserType.supermanager && element.savedBy == Get.find<SuperManagerController>().hesapBilgileri.kurumID)),
      ];
    }
    if (girisTuru == EvaulationUserType.school) {
      return [
        ...allOpticForms!.dataList.where((element) => (element.userType == EvaulationUserType.admin && element.isPublished == true)),
        ...allSchoolOpticForms!.dataList.where((element) => true),
      ];
    }
    return [];
  }

  GlobalKey<FormState> formKey = GlobalKey();
  OpticFormModel? selectedItem;

  bool get dataIsNew => selectedItem != null && selectedItem!.key == null;

  bool elementCanBeChange(OpticFormModel? element) {
    if (girisTuru == EvaulationUserType.admin) {
      return element!.userType == EvaulationUserType.admin;
    }
    if (girisTuru == EvaulationUserType.school) {
      return element!.userType == EvaulationUserType.school && element.savedBy == AppVar.appBloc.hesapBilgileri.uid;
    }
    if (girisTuru == EvaulationUserType.supermanager) {
      return element!.userType == EvaulationUserType.supermanager && element.savedBy == Get.find<SuperManagerController>().hesapBilgileri.kurumID;
    }
    return true;
  }

  StreamSubscription? subscription;
  StreamSubscription? subscription2;
  ExamType? examType;

  OpticFormDefineController(this.examType, this.girisTuru);

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
    allOpticForms = MiniFetchers.getFetcher(MiniFetcherKeys.allOpticformType) as MiniFetcher<OpticFormModel>?;
    subscription = allOpticForms!.stream.listen((state) {
      isPageLoading = false;
      update();
    });
    if (girisTuru == EvaulationUserType.school) {
      allSchoolOpticForms = MiniFetchers.getFetcher(MiniFetcherKeys.schoolOpticformTypes) as MiniFetcher<OpticFormModel>?;
      subscription2 = allSchoolOpticForms!.stream.listen((state) {
        isPageLoading = false;
        update();
      });
    }
  }

  void addItem() {
    if (isLoading || isPageLoading) return;
    selectedItem = OpticFormModel.create(examType!, girisTuru);
    formKey = GlobalKey();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  void selectItem(OpticFormModel item) {
    if (isLoading || isPageLoading) return;
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

  List<OpticFormModel> getFilteredAllOpticFormList() {
    return allOpticForm.where((element) {
      return element.examTypeKey == examType!.key;
    }).toList();
  }

  Future<void> saveItem() async {
    if (formKey.currentState!.checkAndSave()) {
      isLoading = true;
      update();
      if (dataIsNew) selectedItem!.key ??= 10.makeKey;

      if (selectedItem!.key.safeLength < 5) return;
      selectedItem!.lastUpdate = databaseTime;

      if (selectedItem!.notGood) {
        OverAlert.saveErr();
        return;
      }

      if (selectedItem!.userType == EvaulationUserType.school) {
        await ExamService.saveSchoolOpticForm(selectedItem!.mapForSave(), selectedItem!.key!);
      } else if (selectedItem!.userType == EvaulationUserType.admin) {
        await ExamService.saveAdminOpticForm(selectedItem!.mapForSave(), selectedItem!.key!);
      } else if (selectedItem!.userType == EvaulationUserType.supermanager) {
        await ExamService.saveAdminOpticForm(selectedItem!.mapForSave(), selectedItem!.key!);
      } else {
        throw Exception('Bilinmeyen giiris turu');
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
      await ExamService.saveSchoolOpticForm(selectedItem!.mapForSave(), selectedItem!.key!);
    } else if (girisTuru == EvaulationUserType.admin) {
      await ExamService.saveAdminOpticForm(selectedItem!.mapForSave(), selectedItem!.key!);
    } else if (girisTuru == EvaulationUserType.supermanager) {
      await ExamService.saveAdminOpticForm(selectedItem!.mapForSave(), selectedItem!.key!);
    } else {
      throw Exception('Bilinmeyen giiris turu');
    }
    isLoading = false;
    deSelectItem();
  }
}
