import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../appbloc/appvar.dart';
import '../../../services/reference_service.dart';
import '../../models.dart';
import '../supermanagerpages/models.dart';
import 'school_group.dart';

class MakeSchoolGroupController extends GetxController {
  StreamSubscription? _refreshSubscription;
  var itemList = <SchoolGroup>[];
  var filteredItemList = <SchoolGroup>[];
  String filteredText = '';

  SchoolGroup? newItem;
  SchoolGroup? selectedItem;
  SchoolGroup? get itemData => newItem ?? selectedItem;
  bool isSaving = false;
  bool isPageLoading = true;

  var formKey = GlobalKey<FormState>();

  MakeSchoolGroupController();

  late PkgFireBox dataPackage;
  final List<SuperManagerModel> superManagerList = [];
  final List<ServerListItemModel> serverList = [];

  VisibleScreen visibleScreen = VisibleScreen.main;
  @override
  void onInit() {
    _init();

    AppVar.appBloc.database1.once('SuperManagers').then((snapshot) {
      superManagerList.clear();
      if (snapshot?.value != null) {
        (snapshot!.value as Map).forEach((k, v) {
          superManagerList.add(SuperManagerModel.fromJson(v, k));
        });
        update();
      }
    });
    AppVar.appBloc.database1.once('ServerList').then((snapshot) {
      serverList.clear();

      (snapshot!.value as Map).forEach((k, v) {
        serverList.add(ServerListItemModel(v['saver'], k, v['timeStamp']));
      });
    });

    super.onInit();
  }

  Future<void> _init() async {
    dataPackage = PkgFireBox(
        boxKeyWithoutVersionNo: ReferenceService.schoolGroupCollectionRef().removeNonEnglishCharacter!,
        collectionPath: ReferenceService.schoolGroupCollectionRef(),
        fetchType: FetchType.LISTEN,
        filterDeletedData: true,
        parsePkg: (key, value) => SchoolGroup.fromJson(value, key),
        sortFunction: (a, b) => (a as SchoolGroup).name!.compareTo((b as SchoolGroup).name!));
    await dataPackage.init();

    _refreshSubscription = dataPackage.refresh.listen((value) {
      itemList = dataPackage.dataList<SchoolGroup>();
      makeFilter(filteredText);
      isPageLoading = false;
      update();

      formKey = GlobalKey<FormState>();
    });
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
    dataPackage.dispose();
    super.onClose();
  }

  void detailBackButtonPressed() {
    selectedItem = null;
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.main;
    update();
  }

  // List<String> _selectedItemExistingServerIdList = [];
  void selectPerson(SchoolGroup item) {
    selectedItem = item;
    //  _selectedItemExistingServerIdList = item.schoolIdList ?? [];
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  void clickNewItem() {
    formKey = GlobalKey<FormState>();
    selectedItem = null;
    visibleScreen = VisibleScreen.detail;
    newItem = SchoolGroup.createNew();
    //  _selectedItemExistingServerIdList = [];
    update();
  }

  void cancelNewEntry() {
    visibleScreen = VisibleScreen.main;
    newItem = null;
    update();
  }

  Future<void> save({bool isDelete = false}) async {
    //todo burda unfocus yapabilir misin
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    if (formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      final _item = newItem ?? selectedItem!;
      if (isDelete) _item.aktif = false;

      Map<String, dynamic> _updates = {};
      _item.schoolIdList!.forEach((element) {
        _updates['/Okullar/$element/SchoolData/Info/gmgl/${_item.forWhat.name}/${_item.key}'] = isDelete ? null : true;
        _updates['/Okullar/$element/SchoolData/Versions/SchoolInfo'] = databaseTime;
      });
      _item.existingIdList!.where((element) => !_item.schoolIdList!.contains(element)).forEach((element) {
        _updates['/Okullar/$element/SchoolData/Info/gmgl/${_item.forWhat.name}/${_item.key}'] = null;
        _updates['/Okullar/$element/SchoolData/Versions/SchoolInfo'] = databaseTime;
      });
      _item.existingIdList ??= [];
      _item.existingIdList = (_item.existingIdList!..addAll(_item.schoolIdList!)).toSet().toList();

      isSaving = true;
      update();
      await Future.wait([dataPackage.sendDatabase('Groups', 'data', _item.key, _item.mapForSave()), AppVar.appBloc.database1.update(_updates)]).then((value) {
        OverAlert.saveSuc();
        newItem = null;
        if (newItem != null) {
          newItem = null;
        }
        if (isDelete) {
          selectedItem = null;
          visibleScreen = VisibleScreen.main;
        }

        update();
      }).catchError((err) {
        OverAlert.saveErr();
      });
      isSaving = false;
      update();
    }
  }

  Future<void> delete() async {
    return save(isDelete: true);
  }
}
