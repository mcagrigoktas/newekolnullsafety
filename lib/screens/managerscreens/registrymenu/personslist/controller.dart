import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/minifetchers.dart';
import '../../../../services/dataservice.dart';
import 'model.dart';

class PersonsListController extends GetxController {
  MiniFetcher<Person>? _personFetcher;
  Person? newPerson;
  Person? selectedPerson;
  Person? get personData => newPerson ?? selectedPerson;
  bool isSaving = false;
  bool isPageLoading = true;

  var formKey = GlobalKey<FormState>();

  var itemList = <Person>[];
  var filteredItemList = <Person>[];
  String filteredText = '';

  VisibleScreen visibleScreen = VisibleScreen.main;
  @override
  void onInit() {
    _personFetcher = MiniFetchers.getFetcher(MiniFetcherKeys.schoolPersons) as MiniFetcher<Person>?;

    _personFetcher!.stream.listen((event) {
      itemList = _personFetcher!.dataList;
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

  void detailBackButtonPressed() {
    selectedPerson = null;
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.main;
    update();
  }

  void selectPerson(Person person) {
    selectedPerson = person;
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  void clickNewPerson() {
    formKey = GlobalKey<FormState>();
    selectedPerson = null;
    visibleScreen = VisibleScreen.detail;
    newPerson = Person(
      lastUpdate: databaseTime,
      name: '',
      categories: [],
      key: 6.makeKey,
    );
    update();
  }

  void cancelNewEntry() {
    visibleScreen = VisibleScreen.main;
    newPerson = null;
    update();
  }

  Future<void> save({bool delete = false}) async {
    if (formKey.currentState!.checkAndSave()) {
      isSaving = true;
      update();
      final _person = newPerson ?? selectedPerson!;
      if (delete) _person.aktif = false;
      await PersonService.savePerson(_person).then((value) {
        OverAlert.saveSuc();
        newPerson = null;
        if (delete) visibleScreen = VisibleScreen.main;
        update();
      }).catchError((err) {
        OverAlert.saveErr();
      });
      isSaving = false;
      update();
    }
  }
}
