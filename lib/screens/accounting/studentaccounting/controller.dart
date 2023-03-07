import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../models/allmodel.dart';
import '../../../../services/dataservice.dart';

class StudentAccountingController extends BaseController {
  var showErasedStudent = false;
  Student? selectedStudent;

  late Map data;
  StreamSubscription? _studentDataSubscription;
  String? paymentTypeKey;
  bool makeNewPlan = false;
  GlobalKey globalKey = GlobalKey();

  StreamSubscription? _refreshSubscription;
  String filteredText = '';

  VisibleScreen visibleScreen = VisibleScreen.main;

  Future<void> selectItem(Student item) async {
    makeNewPlan = false;
    selectedStudent = item;
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.detail;
    await getStudentAccounting();
    update();
  }

  Future<void> getStudentAccounting() async {
    paymentTypeKey = Fav.preferences.getString('paymentTypeKey', 'paymenttype1');

    if (selectedStudent != null) {
      await _studentDataSubscription?.cancel();
      startLoading();
      _studentDataSubscription = AccountingService.dbStudentAccountingData(selectedStudent!.key!).onValue().listen((event) {
        data = (event?.value ?? {});
        stopLoading();
      });
    }
  }

  String? initialItem;
  StudentAccountingController({this.initialItem});

  var _studentList = <Student>[];
  var _studentListWithDeleted = <Student>[];
  var filteredItemList = <Student>[];

  @override
  void onInit() {
    _refreshSubscription = AppVar.appBloc.studentService!.stream.listen((event) {
      _studentList = AppVar.appBloc.studentService!.dataList;
      _studentListWithDeleted = AppVar.appBloc.studentService!.dataListWithDeleted;
      makeFilter(filteredText);
      isPageLoading = false;
      update();
      if (initialItem != null) {
        final _student = _studentList.singleWhereOrNull((element) => element.key == initialItem);
        if (_student != null) {
          filteredText = initialItem.toSearchCase();
          Future.delayed(200.milliseconds).then((value) async {
            await selectItem(_student);
            initialItem = null;
          });
        }
      }
    });

    super.onInit();
  }

  void makeFilter(String text) {
    final useThisList = showErasedStudent ? _studentListWithDeleted : _studentList;

    filteredText = text.toSearchCase();
    if (filteredText == '') {
      filteredItemList = useThisList;
    } else {
      filteredItemList = useThisList.where((e) => e.getSearchText().contains(filteredText)).toList();
    }
  }

  @override
  void onClose() {
    _refreshSubscription?.cancel();
    super.onClose();
  }

  Future<void> detailBackButtonPressed() async {
    selectedStudent = null;
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.main;
    await _studentDataSubscription?.cancel();
    update();
  }
}
