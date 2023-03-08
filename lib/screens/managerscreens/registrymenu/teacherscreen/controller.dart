import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../models/allmodel.dart';
import '../../../../services/dataservice.dart';
import '../../../../services/smssender.dart';

class TeacherListController extends GetxController {
  StreamSubscription? _refreshSubscription;
  var itemList = <Teacher>[];
  var filteredItemList = <Teacher>[];
  String filteredText = '';

  Teacher? newItem;
  Teacher? selectedItem;
  Teacher? get itemData => newItem ?? selectedItem;
  bool isSaving = false;
  bool isPageLoading = true;

  var formKey = GlobalKey<FormState>();

  TeacherListController({Teacher? initialItem}) {
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
    _refreshSubscription = AppVar.appBloc.teacherService!.stream.listen((event) {
      itemList = AppVar.appBloc.teacherService!.dataList;
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

  void selectPerson(Teacher item) {
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
      newDataKey = 5.makeKey;
    } while (AppVar.appBloc.teacherService!.dataList.any((teacher) => teacher.key == newDataKey));
    newItem = Teacher.create(newDataKey);
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

      await TeacherService.saveTeacher(_item, _item.key).then((value) {
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
//! hedef donemde zaten kopyala olunca buna gerek olmayabilir
  // Future<void> copy() async {
  //   FocusScope.of(Get.context).requestFocus(FocusNode());
  //   if (Fav.noConnection()) return;

  //   var snapshot = await GetDataService.dbTermsRef().once(orderByChild: "aktif", equalTo: true);
  //   if (snapshot == null) return;
  //   Map terms = snapshot.value;

  //   List<SheetAction> _actions = [];
  //   (terms.entries.toList()..sort((a, b) => a.value["name"].compareTo(b.value["name"]))).forEach((value) {
  //     _actions.add(
  //       SheetAction(
  //           title: value.value['name'],
  //           onPressed: () {
  //             Get.back(result: value.value['name']);
  //           }),
  //     );
  //   });

  //   final _result = await Sheet.make(actions: _actions, cancelAction: SheetAction.cancel(), title: 'selectcopyterm'.translate);
  //   if (_result == null) return;

  //   Fav.showLoading();
  //   await SetDataService.saveTeacher(selectedItem, selectedItem.key, _result).then((a) {
  //     Fav.removeLoading();
  //     OverAlert.saveSuc();
  //   }).catchError((error) {
  //     Fav.removeLoading();
  //     OverAlert.saveErr();
  //   });
  // }

  Future<void> delete() async {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    if (Fav.noConnection()) return;

    if (selectedItem != null) {
      isSaving = true;
      update();
      await TeacherService.deleteTeacher(selectedItem!.key).then((a) {
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

  Future<void> sendSMS() async {
    if (selectedItem == null) return;
    formKey.currentState!.save();

    List<String> recipents = [];
    if ((selectedItem!.phone ?? '').length > 5) {
      recipents.add(selectedItem!.phone!);
    }

    List<UserAccountSmsModel> smsModelList = [];
    smsModelList.add(UserAccountSmsModel(username: selectedItem!.username, password: selectedItem!.password, numbers: recipents, kurumId: AppVar.appBloc.hesapBilgileri.kurumID));

    await SmsSender.sendUserAccountWithSms(smsModelList);
  }

  bool get isPasswordMustHide => newItem == null && selectedItem!.passwordChangedByUser == true && selectedItem!.password.safeLength >= 6;
}
