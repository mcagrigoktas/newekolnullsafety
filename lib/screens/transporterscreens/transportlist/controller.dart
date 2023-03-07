import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../services/dataservice.dart';
import 'transporter.dart';

class TransporterListController extends GetxController {
  StreamSubscription? _refreshSubscription;
  var itemList = <Transporter>[];
  var filteredItemList = <Transporter>[];
  String filteredText = '';

  Transporter? newItem;
  Transporter? selectedItem;
  Transporter? get itemData => newItem ?? selectedItem;
  bool isSaving = false;
  bool isPageLoading = true;

  var formKey = GlobalKey<FormState>();

  VisibleScreen visibleScreen = VisibleScreen.main;
  @override
  void onInit() {
    _refreshSubscription = AppVar.appBloc.transporterService!.stream.listen((event) {
      itemList = AppVar.appBloc.transporterService!.dataList;
      makeFilter(filteredText);
      isPageLoading = false;
      update();
    });

    super.onInit();
  }

  void makeFilter(String text) {
    filteredText = text.toLowerCase();
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

  void selectPerson(Transporter item) {
    selectedItem = item;
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  void clickNewItem() {
    formKey = GlobalKey<FormState>();
    selectedItem = null;
    visibleScreen = VisibleScreen.detail;
    newItem = Transporter()..key = 7.makeKey;
    update();
  }

  void cancelNewEntry() {
    visibleScreen = VisibleScreen.main;
    newItem = null;
    update();
  }

  Future<void> save({bool delete = false}) async {
    //todo burda unfocus yapabilir misin
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    if (formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      isSaving = true;
      update();
      final _transporter = newItem ?? selectedItem;
      if (delete) _transporter!.aktif = false;
      await TransportService.saveMultipleTransport([_transporter]).then((value) {
        OverAlert.saveSuc();
        newItem = null;
        if (delete) visibleScreen = VisibleScreen.main;
        update();
      }).catchError((err) {
        OverAlert.saveErr();
      });
      isSaving = false;
      update();
    }
  }

//! Ilerleyen zamanlarda ogrenci ve ogretmen listesinde oldugu gibi hedef termden cektri
  // Future<void> copy() async {
  //   FocusScope.of(Get.context).requestFocus(FocusNode());
  //   if (Fav.noConnection()) return;

  //   var snapshot = await GetDataService.dbTermsRef().once(orderByChild: 'aktif', equalTo: true);
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
  //   await SetDataService.saveMultipleTransport([selectedItem], _result).then((a) {
  //     Fav.removeLoading();
  //     OverAlert.saveSuc();
  //   }).catchError((error) {
  //     Fav.removeLoading();
  //     OverAlert.saveErr();
  //   });
  // }
}
