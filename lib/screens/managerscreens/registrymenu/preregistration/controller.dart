import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../services/dataservice.dart';
import '../studentscreen/layout.dart';
import 'model.dart';

class PreRegistrationListController extends GetxController {
  StreamSubscription? _refreshSubscription;
  var itemList = <PreRegisterModel>[];
  var filteredItemList = <PreRegisterModel>[];
  String filteredText = '';
  PreRegisterStatus filteredStatus = PreRegisterStatus.aktif;
  PreRegisterModel? newItem;
  PreRegisterModel? selectedItem;
  PreRegisterModel? get itemData => newItem ?? selectedItem;
  bool isSaving = false;
  bool isPageLoading = true;

  var formKey = GlobalKey<FormState>();

  VisibleScreen visibleScreen = VisibleScreen.main;
  @override
  void onInit() {
    _refreshSubscription = PreRegisterService.dbPreRegisterListRef().onValue().listen((event) {
      itemList.clear();
      (event?.value as Map?)?.forEach((key, value) {
        itemList.add(PreRegisterModel.fromJson(value, key));
      });
      makeFilter(filteredText);
      isPageLoading = false;
      update();
    });

    super.onInit();
  }

  void makeFilter(String text) {
    filteredText = text.toLowerCase();
    filteredItemList = itemList.where((e) => e.name!.contains(filteredText)).where((item) {
      return item.status == filteredStatus;
    }).toList();
  }

  @override
  void onClose() {
    _refreshSubscription?.cancel();
    super.onClose();
  }

  void detailBackButtonPressed() {
    selectedItem = null;
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.main;
    update();
  }

  void selectPerson(PreRegisterModel item) {
    selectedItem = item;
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  void clickNewItem() {
    formKey = GlobalKey<FormState>();
    selectedItem = null;
    visibleScreen = VisibleScreen.detail;

    String newDataKey;
    do {
      newDataKey = 8.makeKey;
    } while (AppVar.appBloc.teacherService!.dataList.any((teacher) => teacher.key == newDataKey));
    newItem = PreRegisterModel()
      ..key = newDataKey
      ..status = PreRegisterStatus.aktif;
    update();
  }

  void cancelNewEntry() {
    visibleScreen = VisibleScreen.main;
    newItem = null;
    update();
  }

  Future<void> save() async {
    //todo burda unfocus yapabilir misin
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    if (formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      isSaving = true;
      update();
      final _item = newItem ?? selectedItem!;

      await PreRegisterService.savePreRegister(_item.mapForSave(), _item.key).then((value) {
        OverAlert.saveSuc();
        newItem = null;
        update();
      }).catchError((err) {
        OverAlert.saveErr();
      });
      isSaving = false;
      update();
    }
  }

  Future<void> delete() async {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    if (Fav.noConnection()) return;

    if (selectedItem != null) {
      isSaving = true;
      update();
      await PreRegisterService.changePreRegisterStatus(selectedItem!.key, PreRegisterStatus.values.indexOf(PreRegisterStatus.cancelled)).then((a) {
        visibleScreen = VisibleScreen.main;
        selectedItem = null;
        OverAlert.deleteSuc();
      }).catchError((error) {
        OverAlert.deleteErr();
      });
      isSaving = false;
      update();
    }
  }

  Future<void> move() async {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    if (Fav.noConnection()) return;

    if (selectedItem != null) {
      OverLoading.show();
      await PreRegisterService.changePreRegisterStatus(selectedItem!.key, PreRegisterStatus.values.indexOf(PreRegisterStatus.saved)).then((a) {
        Fav.to(StudentList(preRegistrationData: selectedItem!.mapForSave()));
      }).catchError((error) {
        OverAlert.saveErr();
      });
      await OverLoading.close();
    }
  }
}
