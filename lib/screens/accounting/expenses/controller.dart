import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../appbloc/minifetchers.dart';
import '../../../services/reference_service.dart';
import '../../managerscreens/registrymenu/personslist/model.dart';
import 'model.dart';

class ExpensesController extends GetxController {
  StreamSubscription? _refreshSubscription;
  var itemList = <Expense>[];
  var filteredItemList = <Expense>[];
  List<Person> personList = [];
  String filteredText = '';
  late PkgFireBox dataPackage;
  Expense? newItem;
  Expense? selectedItem;
  Expense? get itemData => newItem ?? selectedItem;
  bool isSaving = false;
  bool isPageLoading = true;
  var totalValueChanged = ''.obs;

  var formKey = GlobalKey<FormState>();

  ExpensesController();

  VisibleScreen visibleScreen = VisibleScreen.main;
  @override
  void onInit() {
    _init();

    super.onInit();
  }

  Future<void> _init() async {
    final _personFetcher = MiniFetchers.getFetcher(MiniFetcherKeys.schoolPersons);

    dataPackage = PkgFireBox(
        boxKeyWithoutVersionNo: ReferenceService.expensesCollectionRef().removeNonEnglishCharacter!,
        collectionPath: ReferenceService.expensesCollectionRef(),
        fetchType: FetchType.LISTEN,
        filterDeletedData: true,
        parsePkg: (key, value) => Expense.fromJson(value, key),
        removeIfHasntThis: ['d'],
        sortFunction: (a, b) => (a as Expense).date! - (b as Expense).date!);
    await dataPackage.init();

    _refreshSubscription = dataPackage.refresh.listen((value) {
      itemList = dataPackage.dataList<Expense>();
      makeFilter(filteredText);
      isPageLoading = false;
      update();
    });
    await 500.wait;

    personList = (_personFetcher.dataList as List<Person>? ?? []);
    isPageLoading = false;
    update();
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

  void selectPerson(Expense item) {
    selectedItem = item;
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  void clickNewItem() {
    formKey = GlobalKey<FormState>();
    selectedItem = null;
    visibleScreen = VisibleScreen.detail;
    newItem = Expense.create();
    update();
  }

  void cancelNewEntry() {
    visibleScreen = VisibleScreen.main;
    newItem = null;
    update();
  }

  Future<void> save() async {
    FocusScope.of(Get.context!).requestFocus(FocusNode());

    if (itemData!.items == null || itemData!.items!.isEmpty) return OverAlert.nothingFoundToSave();

    if (formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      isSaving = true;
      update();

      await AppVar.appBloc.firestore.setItemInPkg(ReferenceService.expensesCollectionRef() + ReferenceService.getDocName(itemData!.key, 15), 'data', itemData!.key!, itemData!.toJson()).then((value) {
        AppVar.appBloc.firestore.setItemInPkg(ReferenceService.accountLogRef() + ReferenceService.getDocName(itemData!.key), 'data', itemData!.key!, itemData!.toLog(), addParentDocName: false).catchError(log);

        isSaving = false;
        OverAlert.saveSuc();
        newItem = null;
        update();
      }).catchError((err) {
        log(err);
        isSaving = false;
        update();
        OverAlert.saveErr();
      });
    }
  }

  Future<void> delete() async {
    itemData!.aktif = false;
    await save();
    visibleScreen = VisibleScreen.main;
    selectedItem = null;
    OverAlert.deleteSuc();
    update();
  }
}
