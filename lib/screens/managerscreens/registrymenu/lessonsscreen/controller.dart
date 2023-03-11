import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../models/allmodel.dart';
import '../../../../services/dataservice.dart';

class LessonListController extends GetxController {
  StreamSubscription? _refreshSubscription;
  var itemList = <Lesson>[];
  var filteredItemList = <Lesson>[];

  Map filteredClassKey = {'filteredClassKey': null}; //String yapmamamin nedeni var. Klon

  Lesson? newItem;
  Lesson? selectedItem;
  Lesson? get itemData => newItem ?? selectedItem;
  bool isSaving = false;
  bool isPageLoading = true;

  var formKey = GlobalKey<FormState>();

  final classListDropdown = AppVar.appBloc.classService!.dataList.map((sinif) => DropdownItem(name: sinif.name, value: sinif.key)).toList();
  final classListDropdown2 = AppVar.appBloc.classService!.dataList.map((sinif) => DropdownItem(name: sinif.name, value: sinif.key)).toList();
  final teacherListDropdown = AppVar.appBloc.teacherService!.dataList.map((teacher) => DropdownItem<String?>(value: teacher.key, name: teacher.name)).toList()..insert(0, DropdownItem(value: null, name: "secimyapilmamis".translate));

  LessonListController();

  VisibleScreen visibleScreen = VisibleScreen.main;
  @override
  void onInit() {
    if (AppVar.appBloc.lessonService!.dataList.isNotEmpty && filteredClassKey['filteredClassKey'] == null) {
      filteredClassKey['filteredClassKey'] = AppVar.appBloc.classService!.dataList.first.key;
    }

    _refreshSubscription = AppVar.appBloc.lessonService!.stream.listen((event) {
      itemList = AppVar.appBloc.lessonService!.dataList;
      makeFilter();
      isPageLoading = false;
      update();
    });

    super.onInit();
  }

  void makeFilter() {
    filteredItemList = AppVar.appBloc.lessonService!.dataList.where((lesson) {
      return lesson.classKey == filteredClassKey['filteredClassKey'];
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

  void selectPerson(Lesson item) {
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
      newDataKey = 3.makeKey;
    } while (AppVar.appBloc.lessonService!.dataList.any((lesson) => lesson.key == newDataKey));

    newItem = Lesson.create(newDataKey);
    newItem!.classKey = filteredClassKey['filteredClassKey'];
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

      await LessonService.saveLesson(_item, _item.key).then((value) {
        OverAlert.saveSuc();
        newItem = null;
        filteredClassKey['filteredClassKey'] = _item.classKey;
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
      await LessonService.deleteLesson(selectedItem!.key).then((a) {
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
}
