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

class ContractsController extends GetxController {
  var personList = <ContractPerson>[];
  var filteredPersonList = <ContractPerson>[];
  String filteredText = '';

  Contract? newContract;
  Contract? selectedContract;
  List<Contract> contractListOfSelectedPerson = [];
  ContractPerson? selectedPerson;
  Contract? get itemData => newContract ?? selectedContract;
  Installament? selectedInstallament;
  bool isSaving = false;
  bool isPageLoading = true;
  PkgFireBox? dataPackage;
  var newContracTotal = 0.0.obs;

  var formKey = GlobalKey<FormState>();
  var payFormKey = GlobalKey<FormState>();

  ContractsController();

  VisibleScreen visibleScreen = VisibleScreen.main;
  String filterDropdownValue = 'teacher';

  StreamSubscription? _contratListFetcherListener;

//* Burasi  bir taksit secildikten sonra odeme yapilirken kullanilacak bilgileri tutar
  PayOff? payOff;

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
    final _personFetcher = MiniFetchers.getFetcher(MiniFetcherKeys.schoolPersons);

    dataPackage = PkgFireBox(
        boxKeyWithoutVersionNo: ReferenceService.userContractCollectionRef().removeNonEnglishCharacter!,
        collectionPath: ReferenceService.userContractCollectionRef(),
        fetchType: FetchType.LISTEN,
        filterDeletedData: true,
        parsePkg: (key, value) => Contract.fromJson(value, key),
        removeIfHasntThis: ['startDate'],
        sortFunction: (a, b) => (a as Contract).startDate! - (b as Contract).startDate!);
    await dataPackage!.init();

    _contratListFetcherListener = dataPackage!.refresh.listen((value) {
      formKey = GlobalKey<FormState>();
      update();
    });
    await 500.wait;

    personList = [
      ...AppVar.appBloc.teacherService!.dataList.map((teacher) => ContractPerson(teacher: teacher)).toList(),
      ...AppVar.appBloc.managerService!.dataList.where((element) => element.key != 'Manager1').map((manager) => ContractPerson(manager: manager)).toList(),
      ...(_personFetcher.dataList as List<Person>).map((person) => ContractPerson(person: person)).toList(),
    ];
    makeFilter(filteredText);
    isPageLoading = false;
    update();
  }

  void makeFilter(String text) {
    filteredText = text.toLowerCase();
    if (filteredText == '') {
      filteredPersonList = personList;
    } else {
      filteredPersonList = personList.where((e) => e.getSearchText!.contains(filteredText)).toList();
    }
    filteredPersonList = filteredPersonList
        .where((element) => filterDropdownValue == 'teacher'
            ? element.isTeacher
            : filterDropdownValue == 'manager'
                ? element.isManager
                : element.isPerson)
        .toList();
  }

  void detailBackButtonPressed() {
    resetPage();
  }

  void resetPage() {
    selectedPerson = null;
    selectedContract = null;
    newContract = null;
    contractListOfSelectedPerson.clear();
    visibleScreen = VisibleScreen.main;
    selectedInstallament = null;
    update();
  }

  void selectPerson(ContractPerson? item) {
    selectedPerson = item;
    selectedContract = null;
    selectedInstallament = null;
    _setContractListOfSelectedUser();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  void selectContract(Contract value) {
    selectedContract = value;
    selectedInstallament = null;
    update();
  }

  void selectInstallamnet(installament) {
    //  if (installament.kalan < 1.0) return;
    selectedInstallament = installament;
    payOff = PayOff.create();
    payFormKey = GlobalKey<FormState>();

    update();
  }

  void _setContractListOfSelectedUser() {
    contractListOfSelectedPerson.clear();
    contractListOfSelectedPerson.addAll(dataPackage!.dataListOfThisDocs<Contract>(selectedPerson!.key!));
    if (contractListOfSelectedPerson.isNotEmpty) selectedContract = contractListOfSelectedPerson.first;
  }

  void clickNewItem() {
    selectedInstallament = null;
    visibleScreen = VisibleScreen.detail;
    newContract = Contract.createNew(selectedPerson!.key, selectedPerson!.name);
    update();
  }

  void cancelNewEntry() {
    visibleScreen = VisibleScreen.main;
    newContract = null;
    update();
  }

  Future<void> payDelete(PayOff? odeme) async {
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

  Future<bool> save() async {
    if (formKey.currentState!.checkAndSave()) {
      final _completer = Completer<bool>();
      if (Fav.noConnection()) return false;
      if (!itemData!.saveValidate()) return false;
      isSaving = true;
      update();

      await dataPackage!.sendDatabase(selectedPerson!.key!, 'data', itemData!.key!, itemData!.toJson()).then((value) async {
        AppVar.appBloc.firestore.setItemInPkg(ReferenceService.accountLogRef() + ReferenceService.getDocName(itemData!.key!), 'data', itemData!.key!, itemData!.toLog(), addParentDocName: false).catchError(log).unawaited;

        if (newContract != null) {
          await 1500.wait;
          final _person = selectedPerson;
          resetPage();
          selectPerson(_person);
        }
        selectedInstallament = null;
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

    final sure = await Over.sure(message: 'contractcompletehint1'.translate);
    if (sure) {
      itemData!.isCompleted = true;
      final _result = await save();
      if (_result == true) {
        resetPage();
      } else {
        itemData!.isCompleted = false;
      }
    }
  }
}
