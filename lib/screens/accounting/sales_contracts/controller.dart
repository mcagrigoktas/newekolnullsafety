import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_database/firestore/fire_box.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../appbloc/minifetchers.dart';
import '../../../services/reference_service.dart';
import '../../managerscreens/registrymenu/personslist/model.dart';
import '../contracts/model.dart';
import 'model.dart';

class SalesContractsController extends GetxController {
  var personList = <ContractPerson>[];
  var filteredItemList = <SalesContract>[];
  String filteredText = '';

  SalesContract? newContract;
  SalesContract? selectedContract;

  SalesContract? get itemData => newContract ?? selectedContract;
  SalesInstallament? selectedInstallament;
  bool isSaving = false;
  bool isPageLoading = true;
  PkgFireBox? dataPackage;
  var newContracAmountTotal = 0.0.obs;
  var newContracInstallamentTotal = 0.0.obs;

  var formKey = GlobalKey<FormState>();
  var payFormKey = GlobalKey<FormState>();

  SalesContractsController();

  VisibleScreen visibleScreen = VisibleScreen.main;
  String filterDropdownValue = 'teacher';

  StreamSubscription? _contratListFetcherListener;

//* Burasi  bir taksit secildikten sonra odeme yapilirken kullanilacak bilgileri tutar
  SalesPayOff? payOff;

  @override
  void onInit() {
    _init();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    _contratListFetcherListener?.cancel();
    dataPackage?.dispose();
  }

  Future<void> _init() async {
    final _personFetcher = MiniFetchers.getFetcher<Person>(MiniFetcherKeys.schoolPersons);

    dataPackage = PkgFireBox(
        boxKeyWithoutVersionNo: ReferenceService.salesContractCollectionRef().removeNonEnglishCharacter!,
        collectionPath: ReferenceService.salesContractCollectionRef(),
        fetchType: FetchType.LISTEN,
        filterDeletedData: true,
        parsePkg: (key, value) => SalesContract.fromJson(value, key),
        removeIfHasntThis: ['startDate'],
        sortFunction: (a, b) => (a as SalesContract).startDate! - (b as SalesContract).startDate!);
    await dataPackage!.init();

    _contratListFetcherListener = dataPackage!.refresh.listen((value) {
      makeFilter(filteredText);
      isPageLoading = false;
      update();
    });
    await 500.wait;

    personList = [
      ...AppVar.appBloc.teacherService!.dataList.map((teacher) => ContractPerson(teacher: teacher)).toList(),
      ...AppVar.appBloc.managerService!.dataList.where((element) => element.key != 'Manager1').map((manager) => ContractPerson(manager: manager)).toList(),
      ...(_personFetcher.dataList).map((person) => ContractPerson(person: person)).toList(),
    ];
    makeFilter(filteredText);
    isPageLoading = false;
    update();
  }

  void makeFilter(String text) {
    filteredText = text.toLowerCase();
    if (filteredText == '') {
      filteredItemList = dataPackage!.dataList<SalesContract>();
    } else {
      filteredItemList = dataPackage!.dataList<SalesContract>().where((e) => e.getSearchText.contains(filteredText)).toList();
    }
  }

  void detailBackButtonPressed() {
    resetPage();
  }

  void resetPage() {
    selectedContract = null;
    newContract = null;
    visibleScreen = VisibleScreen.main;
    selectedInstallament = null;
    update();
  }

  void selectContract(SalesContract item) {
    selectedContract = item;
    selectedInstallament = null;
    visibleScreen = VisibleScreen.detail;
    update();
  }

  void selectInstallamnet(installament) {
    //  if (installament.kalan < 1.0) return;
    selectedInstallament = installament;
    payOff = SalesPayOff.create();
    payFormKey = GlobalKey<FormState>();

    update();
  }

  void clickNewItem() {
    selectedInstallament = null;
    selectedContract = null;
    visibleScreen = VisibleScreen.detail;
    newContract = SalesContract.createNew();
    newContracAmountTotal.value = 0.0;
    update();
  }

  void cancelNewEntry() {
    visibleScreen = VisibleScreen.main;
    newContract = null;
    update();
  }

  Future<void> payDelete(SalesPayOff? odeme) async {
    if ((await Over.sure(message: 'deletepaidwarning'.translate)) != true) return;
    selectedInstallament!.odemeler!.remove(odeme);
    await save();
  }

  Future<void> pay() async {
    if (formKey.currentState!.validate() && payFormKey.currentState!.validate()) {
      payFormKey.currentState!.save();
      selectedInstallament!.odemeler ??= [];
      selectedInstallament!.odemeler!.add(payOff);
      final _result = await save();
      if (_result == false) selectedInstallament!.odemeler!.remove(payOff);
    } else {
      OverAlert.fillRequired();
    }
  }

  Future<bool> save({bool completed = false}) async {
    if (formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return false;
      if (!itemData!.saveValidate(completed: completed)) return false;
      isSaving = true;
      update();
      itemData!.personName = personList.firstWhereOrNull((element) => element.key == itemData!.personKey)?.name;

      final _completer = Completer<bool>();
      await AppVar.appBloc.firestore.setItemInPkg(ReferenceService.salesContractCollectionRef() + ReferenceService.getDocName(itemData!.key!, 15), 'data', itemData!.key!, itemData!.toJson()).then((value) async {
        AppVar.appBloc.firestore.setItemInPkg(ReferenceService.accountLogRef() + ReferenceService.getDocName(itemData!.key!), 'data', itemData!.key!, itemData!.toLog(), addParentDocName: false).catchError(log).unawaited;

        selectedInstallament = null;
        newContract = null;
        OverAlert.saveSuc();
        isSaving = false;
        update();
        _completer.complete(true);
      }).catchError((err) {
        log(err);
        isSaving = false;
        update();
        OverAlert.saveErr();
        _completer.complete(false);
      });
      return _completer.future;
    }
    return false;
  }

  Future<void> delete() async {
    if (itemData!.installaments.any((installament) => installament.paid > 0)) {
      OverAlert.show(message: 'contractdeleteerr1'.translate, type: AlertType.danger);
    } else {
      final sure = await Over.sure();
      if (sure) {
        itemData!.aktif = false;
        final _result = await save();
        if (_result == true) {
          resetPage();
        } else {
          itemData!.aktif = true;
        }
      }
    }
  }

  Future<void> complete() async {
    if (itemData!.installaments.any((installament) => installament.kalan > 0.01)) {
      OverAlert.show(message: 'contractcompleteerr1'.translate, type: AlertType.danger);
      return;
    }

    final sure = await Over.sure(message: 'contractcompletehint1'.translate + '. ' + (itemData!.totalKalan > 0.01 ? 'contractcompletehint2'.argTranslate(itemData!.totalKalan.toStringAsFixed(2)) : ''));
    if (sure) {
      itemData!.isCompleted = true;
      final _result = await save(completed: true);
      if (_result == true) {
        resetPage();
      } else {
        itemData!.isCompleted = false;
      }
    }
  }
}
