import 'dart:async';

import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../adminpages/screens/makeschoolgroup/school_group.dart';
import '../../../appbloc/appvar.dart';
import '../../../helpers/stringhelper.dart';
import '../../../models/enums.dart';
import '../../../services/dataservice.dart';
import '../../../services/reference_service.dart';
import '../../../supermanager/supermanagerbloc.dart';
import '../education_content/layout.dart';
import '../model.dart';
import 'model.dart';

class EducationListController extends GetxController {
  StreamSubscription? _refreshSubscription;
  var itemList = <Education>[];
  var filteredItemList = <Education>[];
  String filteredText = '';

  Education? newItem;
  Education? selectedItem;
  Education? get itemData => newItem ?? selectedItem;
  bool isSaving = false;
  bool isPageLoading = true;
  PkgFireBox? dataPackage;

  var formKey = GlobalKey<FormState>();

  EducationListController();
  SuperManagerController get superManagerController => Get.find<SuperManagerController>();

  VisibleScreen visibleScreen = VisibleScreen.main;

  List<SchoolPackage> schoolPackageList = [];

  @override
  void onInit() {
    _init();

    super.onInit();
  }

  Future<void> _init() async {
    superManagerController.serverList!.forEach((element) {
      schoolPackageList.add(SchoolPackage(name: element.schoolName, key: element.serverId, kurumIdlist: [element.serverId]));
    });

    schoolPackageList.insert(0, SchoolPackage(name: superManagerController.hesapBilgileri.kurumID, key: superManagerController.hesapBilgileri.kurumID, kurumIdlist: superManagerController.serverList!.map((e) => e.serverId).toList()));

    final schoolGroupPackage = PkgFireBox(
        boxKeyWithoutVersionNo: ReferenceService.schoolGroupCollectionRef().removeNonEnglishCharacter!,
        collectionPath: ReferenceService.schoolGroupCollectionRef(),
        fetchType: FetchType.ONCE,
        filterDeletedData: true,
        parsePkg: (key, value) => SchoolGroup.fromJson(value, key),
        sortFunction: (a, b) => (a as SchoolGroup).name!.compareTo((b as SchoolGroup).name!));
    await schoolGroupPackage.init();
    final _schoolGroupList = schoolGroupPackage.dataList<SchoolGroup>().where((element) => element.forWhat == SchoolGroupForWhat.education && element.generalManagersWhoCanSee != null && element.generalManagersWhoCanSee!.contains(superManagerController.hesapBilgileri.kurumID)).toList();
    _schoolGroupList.forEach((element) {
      schoolPackageList.insert(1, SchoolPackage(name: element.name, kurumIdlist: element.schoolIdList, key: element.key));
    });

    dataPackage = PkgFireBox(
        boxKeyWithoutVersionNo: ReferenceService.privateEducationListRef().removeNonEnglishCharacter!,
        collectionPath: ReferenceService.privateEducationListRef(),
        fetchType: FetchType.LISTEN,
        filterDeletedData: true,
        parsePkg: (key, value) => Education.fromJson(value, key),
        removeIfHasntThis: ['name'],
        sortFunction: (a, b) => (a as Education).name!.compareTo((b as Education).name!));
    await dataPackage!.init();

    _refreshSubscription = dataPackage!.refresh.listen((event) {
      itemList = dataPackage!.dataList<Education>();
      makeFilter(filteredText);
      isPageLoading = false;

      update();
    });
  }

  void makeFilter(String text) {
    filteredText = text.toSearchCase();

    filteredItemList = itemList.where((e) {
      if (e.saver != superManagerController.hesapBilgileri.kurumID) return false;
      return e.searchText.contains(filteredText);
    }).toList();
  }

  @override
  void onClose() {
    _refreshSubscription?.cancel();
    dataPackage?.dispose();
    super.onClose();
  }

  void detailBackButtonPressed() {
    selectedItem = null;
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.main;
    update();
  }

  IndexedTreeViewController? treeViewController;
  EducationNode? initialRoot;

  // List<String> _selectedItemExistingServerIdList = [];
  void selectItem(Education item) {
    selectedItem = item;
    // _selectedItemExistingServerIdList = item.serverIdList ?? [];
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.detail;

    treeViewController = IndexedTreeViewController<EducationNode>();
    initialRoot = EducationNode.fromJson({'t': 'Root', 'key': 'root', 'i': item.data});
    log(initialRoot);

    update();
  }

  void clickNewItem() {
    formKey = GlobalKey<FormState>();
    selectedItem = null;
    visibleScreen = VisibleScreen.detail;
    newItem = Education.create();
    // _selectedItemExistingServerIdList = [];
    treeViewController = IndexedTreeViewController<EducationNode>();
    initialRoot = EducationNode.fromJson({'t': 'Root', 'key': 'root', 'i': null});
    log(initialRoot);
    update();
  }

  void cancelNewEntry() {
    visibleScreen = VisibleScreen.main;
    newItem = null;
    update();
  }

  String get fileSaveLocation {
    return "${superManagerController.hesapBilgileri.kurumID}/EducationListFiles";
  }

  // List<String> superManagerIdToKurumIdList(List<String> superManagerIdList) {
  //   return superManagerList.fold<List<String>>(<String>[], (p, e) => superManagerIdList.contains(e.superManagerServerId) ? (p..addAll(e.schoolDataList.map((e) => e.serverId).toList())) : p);
  // }

  Future<void> save({bool isPublish = false, bool isDelete = false}) async {
    Map _newData = initialRoot!.value.toJson();
    List? _removedRootData = _newData['i'];
    if (_removedRootData == null || _removedRootData.isEmpty) {
      return OverAlert.nothingFoundToSave();
    }
    //todo burda unfocus yapabilir misin
    FocusScope.of(Get.context!).requestFocus(FocusNode());

    if (formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      final _item = newItem ?? selectedItem!;
      _item.data = _removedRootData;
      _item.serverIdList ??= [];
      _item.fullServerIdList ??= [];
      _item.fullServerIdList!.addAll(_item.serverIdList!);
      _item.fullServerIdList = _item.fullServerIdList!.toSet().toList();
      _item.saver ??= superManagerController.hesapBilgileri.kurumID;
      if (_item.serverIdList == null || _item.serverIdList!.isEmpty) {
        _item.serverIdList = [superManagerController.hesapBilgileri.kurumID];
      }

      if (isDelete) {
        _item.aktif = false;
        isPublish = true;
      }

      Map<String, dynamic> updates = {};
      if (isPublish) {
        //? Yayinlanan kurumlarin versiyonunu degistriri
        final _allKururms = _item.fullServerIdList!.fold<List<String?>>([], (p, e) {
          final _schoolGroup = schoolPackageList.firstWhereOrNull((element) => element.key == e);
          if (_schoolGroup == null) {
            if (e!.startsWith('739') || e.startsWith('SchoolGroup')) {
              return p;
            } else {
              return p..add(e);
            }
          }
          return p..addAll(_schoolGroup.kurumIdlist!);
        });
        _allKururms.forEach((element) {
          updates['/${StringHelper.schools}/$element/SchoolData/Versions/${VersionListEnum.educationService}'] = databaseTime;
        });
      }
      //? Yayinlanmamisken bazen kurum listesinden kaldirip kaydettiginde silinmis kurumlarin versiyonunu degistriri
      // if (newItem == null && _selectedItemExistingServerIdList != null) {
      //   final _changedKururms = (_selectedItemExistingServerIdList.where((element) => !_item.serverIdList.contains(element)).toList()).fold<List<String>>([], (p, e) => p..addAll(schoolPackageList.firstWhere((element) => element.key == e).kurumIdlist));
      //   _changedKururms.forEach((element) {
      //     updates['/${StringHelper.schools}/$element/SchoolData/Versions/${VersionListEnum.educationService}'] = databaseTime;
      //   });
      //   log('Degisen Kurumlar $_changedKururms');
      // }

      isSaving = true;
      update();
      await Future.wait(<Future>[
        dataPackage!.sendDatabase(_item.key!, 'data', _item.key!, _item.toJson()),
        if (isPublish) AppVar.appBloc.firestore.setItemInPkg('${ReferenceService.publicEducationListRef()}/${_item.key}', 'data', _item.key!, _item.toJson(), targetList: _item.fullServerIdList as List<String>?),
      ]).then((value) {
        if (updates.isNotEmpty) AppVar.appBloc.database1.update(updates);
        OverAlert.saveSuc();
        newItem = null;
        update();
      }).catchError((err) {
        log(err);
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
      await TeacherService.deleteTeacher(selectedItem!.key!).then((a) {
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

  void preview() {
    Fav.to(EducationContent(education: selectedItem));
  }
}
