import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../models/allmodel.dart';
import '../../../../services/dataservice.dart';

class ClassListController extends GetxController {
  StreamSubscription? _refreshSubscription;
  var itemList = <Class>[];
  var filteredItemList = <Class>[];
  String filteredText = '';
  int filteredClassType = -1;

  Class? newItem;
  Class? selectedItem;
  Class? get itemData => newItem ?? selectedItem;
  bool isSaving = false;
  bool isPageLoading = true;
  bool isCourseClass = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var formKey = GlobalKey<FormState>();

  ClassListController({Class? initialItem}) {
    if (initialItem != null) {
      filteredText = initialItem.name.toSearchCase();
      Future.delayed(200.milliseconds).then((value) {
        selectPerson(initialItem);
      });
    }
  }

  VisibleScreen visibleScreen = VisibleScreen.main;

  late List<DropdownMenuItem<String>> teacherDropDownList;
  @override
  void onInit() {
    _refreshSubscription = AppVar.appBloc.classService!.stream.listen((event) {
      itemList = AppVar.appBloc.classService!.dataList;
      makeFilter(filteredText);
      isPageLoading = false;
      update();
    });

    teacherDropDownList = AppVar.appBloc.teacherService!.dataList.map((teacher) {
      return DropdownMenuItem(
          value: teacher.key,
          child: Text(
            teacher.name,
            style: TextStyle(color: Fav.design.primaryText),
          ));
    }).toList();
    teacherDropDownList.insert(0, DropdownMenuItem(value: null, child: Text("secimyapilmamis".translate, style: TextStyle(color: Fav.design.textField.hint))));

    super.onInit();
  }

  void makeFilter(String text) {
    filteredText = text.toSearchCase();
    if (filteredText == '' && filteredClassType == -1) {
      filteredItemList = itemList;
    } else {
      filteredItemList = itemList.where((e) => e.getSearchText.contains(filteredText)).where((item) => filteredClassType == -1 || filteredClassType == item.classType).toList();
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

  void selectPerson(Class item) {
    selectedItem = item;
    isCourseClass = item.classType == 0;
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
      newDataKey = 3.makeKey;
    } while (AppVar.appBloc.classService!.dataList.any((sinif) => sinif.key == newDataKey));
    newItem = Class.create(newDataKey)..classType = 0;
    isCourseClass = newItem!.classType == 0;
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
      final _item = newItem ?? selectedItem;
      if (benzerOgretmenKontrol(_item)) {
        OverAlert.show(message: "sameclassteacher".translate, type: AlertType.danger);
        return;
      }
      if (AppVar.appBloc.hesapBilgileri.isEkid && _item!.classTeacher == _item.classTeacher2 && _item.classTeacher != null) {
        OverAlert.show(message: "samechooseteacher".translate, type: AlertType.danger);
        return;
      }
      if (_item!.classType == null && AppVar.appBloc.hesapBilgileri.isEkid) {
        _item.classType = 0;
      }
      isSaving = true;
      update();

      await ClassService.saveClass(_item, _item.key).then((a) {
        OverAlert.saveSuc();
        newItem = null;
        update();
      }).catchError((error) {
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
      await ClassService.deleteClass(selectedItem!.key).then((a) {
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

  bool benzerOgretmenKontrol(Class? item) {
    if (AppVar.appBloc.hesapBilgileri.isEkid) {
      return AppVar.appBloc.classService!.dataList.any((sinif) {
        if (sinif.key == item!.key) {
          return false;
        }
        if (sinif.classTeacher == item.classTeacher && item.classTeacher != null) {
          return true;
        }
        if (sinif.classTeacher2 == item.classTeacher && item.classTeacher != null) {
          return true;
        }
        if (sinif.classTeacher == item.classTeacher2 && item.classTeacher2 != null) {
          return true;
        }
        if (sinif.classTeacher2 == item.classTeacher2 && item.classTeacher2 != null) {
          return true;
        }
        return false;
      });
    } else {
      return AppVar.appBloc.classService!.dataList.any((sinif) {
        if (sinif.key == item!.key) {
          return false;
        }
        if (sinif.classTeacher == item.classTeacher && item.classTeacher != null) {
          return true;
        }
        return false;
      });
    }
  }
}
