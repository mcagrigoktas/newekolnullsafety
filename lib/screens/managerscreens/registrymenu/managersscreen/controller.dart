import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../models/allmodel.dart';
import '../../../../services/dataservice.dart';
import '../../../../services/smssender.dart';

class ManagerListController extends GetxController {
  StreamSubscription? _refreshSubscription;
  var itemList = <Manager>[];
  var filteredItemList = <Manager>[];
  String filteredText = '';

  Manager? newItem;
  Manager? selectedItem;
  Manager? get itemData => newItem ?? selectedItem;
  bool isSaving = false;
  bool isPageLoading = true;

  var formKey = GlobalKey<FormState>();

  ManagerListController({Manager? initialItem}) {
    if (initialItem != null) {
      filteredText = initialItem.name.toSearchCase();
      Future.delayed(200.milliseconds).then((value) {
        selectPerson(initialItem);
      });
    }
  }

  VisibleScreen visibleScreen = VisibleScreen.main;
  @override
  void onInit() {
    _refreshSubscription = AppVar.appBloc.managerService!.stream.listen((event) {
      itemList = AppVar.appBloc.managerService!.dataList;
      makeFilter(filteredText);
      isPageLoading = false;
      update();
    });

    super.onInit();
  }

  void makeFilter(String text) {
    filteredText = text.toSearchCase();
    if (filteredText == '') {
      filteredItemList = itemList;
    } else {
      filteredItemList = itemList.where((e) => e.getSearchText.contains(filteredText)).toList();
    }
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

  void selectPerson(Manager item) {
    selectedItem = item;
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  void clickNewItem() {
    formKey = GlobalKey<FormState>();
    selectedItem = null;
    visibleScreen = VisibleScreen.detail;
    newItem = Manager.create(7.makeKey);
    update();
  }

  void cancelNewEntry() {
    visibleScreen = VisibleScreen.main;
    newItem = null;
    update();
  }

  Future<void> save() async {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    if (Fav.noConnection()) return;

    if (formKey.currentState!.checkAndSave()) {
      isSaving = true;
      update();
      final _item = newItem ?? selectedItem!;
      await ManagerService.saveManager(_item, _item.key).then((a) {
        OverAlert.saveSuc();
        newItem = null;
        update();
      }).catchError((err) {
        OverAlert.show(message: "saveerruser".translate, type: AlertType.danger);
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
      await ManagerService.deleteManager(selectedItem!.key).then((a) {
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

  Map<String, String> availebleAuthority() {
    return {
      "yetki1": "yetki1".translate,
      "yetki4": "yetki4".translate,
      "yetki10": "yetki10".translate,
      "yetki12": "yetki12".translate,
      "yetki13": "yetki13".translate,
      "yetki8": "yetki8".translate,
      "yetki6": "yetki6".translate,
      "yetki7": "yetki7".translate,
      "yetki9": "yetki9".translate,
      "yetki11": "yetki11".translate,
      "yetki3": "yetki3".translate,
      "yetki2": "yetki2".translate,
      "yetki5": "yetki5".translate,
    };
  }

  bool get isPasswordMustHide => newItem == null && selectedItem!.passwordChangedByUser == true && selectedItem!.password.safeLength >= 6;

  Future<void> sendSMS() async {
    if (selectedItem == null) return;
    formKey.currentState!.save();

    List<String?> recipents = [];
    if ((selectedItem!.phone ?? '').length > 5) {
      recipents.add(selectedItem!.phone);
    }

    List<UserAccountSmsModel> smsModelList = [];
    smsModelList.add(UserAccountSmsModel(username: selectedItem!.username, password: selectedItem!.password, numbers: recipents, kurumId: AppVar.appBloc.hesapBilgileri.kurumID));

    await SmsSender.sendUserAccountWithSms(smsModelList);
  }
}
