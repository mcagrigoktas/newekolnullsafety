import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../helpers/appfunctions.dart';
import '../../../../helpers/apphelpers.dart';
import '../../../../models/allmodel.dart';
import '../../../../services/dataservice.dart';
import '../../../../services/smssender.dart';
import '../../../accounting/route_management.dart';
import '../../../main/menu_list_helper.dart';

class StudentListController extends GetxController {
  StreamSubscription? _refreshSubscription;
  var itemList = <Student>[];
  var filteredItemList = <Student>[];
  String? filteredText = '';
  String? filteredClassKey;

  Student? newItem;
  Student? selectedItem;
  Student? get itemData => newItem ?? selectedItem;
  bool isSaving = false;
  bool isPageLoading = true;

  var formKey = GlobalKey<FormState>();

  final teacherClassList = AppVar.appBloc.hesapBilgileri.gtT ? TeacherFunctions.getTeacherClassList() : null;

  StudentListController({Student? initialItem, Map? preRegistrationData}) {
    if (initialItem != null) {
      filteredText = initialItem.name;
      Future.delayed(200.milliseconds).then((value) async {
        selectPerson(initialItem);
      });
    } else if (preRegistrationData != null) {
      tcController.text = preRegistrationData['tc'];
      newItem = Student.create(_makeKey())
        ..name = preRegistrationData['name']
        ..birthday = preRegistrationData['birthday']
        ..genre = preRegistrationData['gender']
        ..motherName = preRegistrationData['motherName']
        ..motherPhone = preRegistrationData['motherPhone']
        ..fatherName = preRegistrationData['fatherName']
        ..fatherPhone = preRegistrationData['fatherPhone']
        ..explanation = preRegistrationData['explanation'];
      visibleScreen = VisibleScreen.detail;
    }
  }

  TextEditingController tcController = TextEditingController();
  TextEditingController schoolNoController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  List<DropdownMenuItem<String>>? transporterDropDownList;
  List<DropdownMenuItem<String>>? etudClassDropDownList;
  late List<DropdownMenuItem<String>> classDropDownList;

  var parentPassword = ''.obs;

  VisibleScreen visibleScreen = VisibleScreen.main;
  @override
  void onInit() {
    _refreshSubscription = AppVar.appBloc.studentService!.stream.listen((event) {
      itemList = AppVar.appBloc.studentService!.dataList;

      makeFilter(filteredText);
      isPageLoading = false;
      update();
    });

    if (AppVar.appBloc.transporterService != null) {
      transporterDropDownList = AppVar.appBloc.transporterService!.dataList.map((transporter) {
        return DropdownMenuItem(value: transporter.key, child: Text(transporter.profileName ?? '?', style: TextStyle(color: Fav.design.primaryText)));
      }).toList();
      transporterDropDownList!.insert(0, DropdownMenuItem(value: null, child: Text("secimyapilmamis".translate, style: TextStyle(color: Fav.design.textField.hint))));
    }

    if (MenuList.hasTimeTable()) {
      etudClassDropDownList = AppVar.appBloc.classService!.dataList.where((sinif) => sinif.classType == 1).map((sinif) {
        return DropdownMenuItem(value: sinif.key, child: Text(sinif.name, style: TextStyle(color: Fav.design.primaryText)));
      }).toList();
      etudClassDropDownList!.insert(0, DropdownMenuItem(value: null, child: Text("secimyapilmamis".translate, style: TextStyle(color: Fav.design.textField.hint))));
    }

    classDropDownList = AppVar.appBloc.classService!.dataList.where((sinif) => sinif.classType == 0).map((sinif) {
      return DropdownMenuItem(value: sinif.key, child: Text(sinif.name, style: TextStyle(color: Fav.design.primaryText)));
    }).toList();

    // if (AppVar.appBloc.hesapBilgileri.gtT) {
    //   classDropDownList.removeWhere((classDropDown) => !teacherClassList.contains(classDropDown.value));
    // }

    classDropDownList.insert(0, DropdownMenuItem(value: null, child: Text("secimyapilmamis".translate, style: TextStyle(color: Fav.design.textField.hint))));

    passwordController.addListener(() {
      parentPassword.value = AppHelpers.passwordToParentPassword(passwordController.text);
    });
    super.onInit();
  }

  void makeFilter(String? text) {
    filteredText = text.toSearchCase();
    if (filteredText == '' && filteredClassKey == null && AppVar.appBloc.hesapBilgileri.gtM) {
      filteredItemList = itemList;
    } else {
      var _filteredItemList = itemList.where((item) => (item.getSearchText().contains(filteredText ?? ''))).where((student) {
        if (filteredClassKey == null) return true;

        if (filteredClassKey == 'noclass') {
          if (student.class0 == null) return true;
          if (student.class0 == '') return true;
          if (AppVar.appBloc.classService!.dataList.singleWhereOrNull((sinif) => sinif.key == student.class0) == null) return true;
          return false;
        }

        return student.classKeyList.contains(filteredClassKey);
      }).toList();
      if (AppVar.appBloc.hesapBilgileri.gtT) {
        _filteredItemList.removeWhere((student) => !(teacherClassList!.any((item) => student.classKeyList.contains(item))));
      }
      filteredItemList = _filteredItemList;
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

  void selectPerson(Student item) {
    selectedItem = item;
    usernameController.text = item.username ?? "";
    passwordController.text = item.password ?? "";
    tcController.text = item.tc ?? "";
    schoolNoController.text = item.no ?? "";
    classKeyForAutoScoolNo = item.class0;
    formKey = GlobalKey<FormState>();
    visibleScreen = VisibleScreen.detail;
    update();
  }

  String _makeKey() {
    String newDataKey;
    do {
      newDataKey = 4.makeKey;
    } while (AppVar.appBloc.studentService!.dataList.any((student) => student.key == newDataKey));
    return newDataKey;
  }

  void clickNewItem() {
    formKey = GlobalKey<FormState>();
    selectedItem = null;
    visibleScreen = VisibleScreen.detail;

    newItem = Student.create(_makeKey());
    usernameController.text = "";
    passwordController.text = "";
    tcController.text = "";
    schoolNoController.text = "";
    classKeyForAutoScoolNo = null;
    update();
  }

  void cancelNewEntry() {
    visibleScreen = VisibleScreen.main;
    newItem = null;
    update();
  }

  bool _passwordEditThenCheckAnyError(Student item) {
    item.parentPassword1 = item.parentPassword1?.removeFirebaseForbiddenCharacters?.trim();
    item.parentPassword2 = item.parentPassword2?.removeFirebaseForbiddenCharacters?.trim();
    if (item.parentPassword1.safeLength < 6) item.parentPassword1 = null;
    if (item.parentPassword2.safeLength < 6) item.parentPassword2 = null;

    bool _err = false;
    if (item.parentPassword1.safeLength > 5 && item.password == item.parentPassword1) _err = true;
    if (item.parentPassword2.safeLength > 5 && item.password == item.parentPassword2) _err = true;
    if (item.parentPassword2.safeLength > 5 && item.parentPassword1.safeLength > 5 && item.parentPassword2 == item.parentPassword1) _err = true;
    if (_err) 'samepassword'.translate.showAlert(AlertType.danger);
    return _err;
  }

  Future<void> save({bool goAccounting = false}) async {
    //todo burda unfocus yapabilir misin
    FocusScope.of(Get.context!).requestFocus(FocusNode());

    if (AppVar.appBloc.studentService!.dataList.length >= AppVar.appBloc.schoolInfoForManagerService!.singleData!.maxStudentCount) {
      OverAlert.show(type: AlertType.danger, message: "studentCountMaxSize".translate);
      return;
    }

    if (Fav.noConnection()) return;
    if (formKey.currentState!.validate()) {
      final _item = newItem ?? selectedItem!;
      _item.groupList.clear();
      // _item.groupList = {};

      formKey.currentState!.save();

      if (_passwordEditThenCheckAnyError(_item)) return;

      if (_item.no.safeLength > 0) {
        if (AppVar.appBloc.studentService!.dataList.where((student) {
          if (student.no != _item.no) return false;
          return student.key != _item.key;
        }).isNotEmpty) {
          OverAlert.show(type: AlertType.danger, message: "samestudentnumber");
          return;
        }
      }

      isSaving = true;
      update();

      if (_item.parentPassword1.safeLength < 6) {
        _item.parentPassword1 = _item.password! + '-' + (3.makeKey).toUpperCase();
      }

      await StudentService.saveStudent(_item, _item.key, addBundle: true).then((value) {
        String? _studentKey = _item.key;
        mailListesineEkle(_item);
        OverAlert.saveSuc();
        newItem = null;
        update();
        if (goAccounting) {
          AccountingMainRoutes.goStudentAccounting(selectedKey: _studentKey);
        }
      }).catchError((err) {
        OverAlert.show(message: "saveerruser".translate, type: AlertType.danger);
      });
      isSaving = false;
      update();
    } else {
      OverAlert.fillRequired();
    }
  }

//! Hedef donemde zaten kopyalama secenegi oldugundan gerek olmayabilir
  // Future<void> copy() async {
  //   FocusScope.of(Get.context).requestFocus(FocusNode());
  //   if (Fav.noConnection()) return;

  //   var snapshot = await GetDataService.dbTermsRef().once(orderByChild: "aktif", equalTo: true);
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
  //   SetDataService.saveStudent(selectedItem, selectedItem.key, _result).then((a) {
  //     Fav.removeLoading();
  //     OverAlert.saveSuc();
  //   }).catchError((error) {
  //     Fav.removeLoading();
  //     OverAlert.saveErr();
  //   }).unawaited;
  // }

  Future<void> delete() async {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
    if (Fav.noConnection()) return;

    if (selectedItem != null) {
      isSaving = true;
      update();
      await StudentService.deleteStudent(selectedItem!.key).then((a) {
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

  void sendSMS() {
    SmsSender.sendUserAccountWithSms(StudentSmsPrepare.prepare(selectedItem));
  }

  void mailListesineEkle(Student data) {
    [data.motherMail ?? '', data.fatherMail ?? ''].forEach((mail) {
      if (mail.contains('gmail.com')) {
        SignInOutService.dbAddMailList(mail.replaceAll('.', ':'), {
          'username': data.username,
          'password': data.password,
          'kurumID': AppVar.appBloc.hesapBilgileri.kurumID,
          'girisTuru': 30,
        });
      }
    });
  }

  void autoPasswords() {
    if (tcController.text.length > 6) {
      usernameController.text = tcController.text.substring(tcController.text.length - 6);
      passwordController.text = tcController.text.substring(tcController.text.length - 6);
    }
  }

  String? classKeyForAutoScoolNo;
  void autoSchoolNo() {
    int? minSchoolNo;
    log(classKeyForAutoScoolNo);
    AppVar.appBloc.studentService!.dataList.where((element) {
      if (classKeyForAutoScoolNo == null) return true;
      return element.class0 == classKeyForAutoScoolNo;
    }).forEach((element) {
      int? _itemNo = int.tryParse(element.no!);
      if (_itemNo != null) {
        if (minSchoolNo == null || _itemNo < minSchoolNo!) {
          minSchoolNo = _itemNo;
        }
      }
    });
    minSchoolNo ??= 0;

    do {
      minSchoolNo = minSchoolNo! + 1;
    } while (AppVar.appBloc.studentService!.dataList.any((element) => int.tryParse(element.no!) == minSchoolNo));

    schoolNoController.text = minSchoolNo.toString();
  }

  bool get isPasswordMustHide => newItem == null && selectedItem!.passwordChangedByUser == true && selectedItem!.password.safeLength >= 6;
  bool get isParent1PasswordMustHide => newItem == null && selectedItem!.parent1PasswordChangedByUser == true && selectedItem!.parentPassword1.safeLength >= 6;
  bool get isParent2PasswordMustHide => newItem == null && selectedItem!.parent2PasswordChangedByUser == true && selectedItem!.parentPassword2.safeLength >= 6;
}

class StudentSmsPrepare {
  StudentSmsPrepare._();

  static List<UserAccountSmsModel> prepare(Student? student) {
    return prepareNew(student);
  }

  static List<UserAccountSmsModel> prepareNew(Student? student) {
    List<UserAccountSmsModel> _smsModelList = [];

    if (AppVar.appBloc.hesapBilgileri.isEkid) {
      if (student!.parentState == 2) {
        final _smsModelParent1 = UserAccountSmsModel(username: student.username, password: student.password, kurumId: AppVar.appBloc.hesapBilgileri.kurumID, numbers: []);
        final _smsModelParent2 = UserAccountSmsModel(username: student.username, password: student.parentPassword2, kurumId: AppVar.appBloc.hesapBilgileri.kurumID, numbers: []);

        if (student.studentPhone.safeLength > 5) {
          _smsModelParent1.numbers!.add(student.studentPhone);
        }
        if (student.motherPhone.safeLength > 5) {
          _smsModelParent1.numbers!.add(student.motherPhone);
        }
        if (student.fatherPhone.safeLength > 5) {
          _smsModelParent2.numbers!.add(student.fatherPhone);
        }

        if (_smsModelParent1.password.safeLength > 5) _smsModelList.add(_smsModelParent1);
        if (_smsModelParent2.password.safeLength > 5) _smsModelList.add(_smsModelParent2);
      } else {
        final _smsModel = UserAccountSmsModel(username: student.username, password: student.password, kurumId: AppVar.appBloc.hesapBilgileri.kurumID, numbers: []);

        if (student.motherPhone.safeLength > 5) {
          _smsModel.numbers!.add(student.motherPhone);
        }
        if (student.fatherPhone.safeLength > 5) {
          _smsModel.numbers!.add(student.fatherPhone);
        }
        if (student.studentPhone.safeLength > 5) {
          _smsModel.numbers!.add(student.studentPhone);
        }
        _smsModelList.add(_smsModel);
      }
    } else {
      if (student!.parentState == 2) {
        final _smsModelParent = UserAccountSmsModel(username: student.username, password: student.parentPassword1, kurumId: AppVar.appBloc.hesapBilgileri.kurumID, numbers: []);
        final _smsModelParent2 = UserAccountSmsModel(username: student.username, password: student.parentPassword2, kurumId: AppVar.appBloc.hesapBilgileri.kurumID, numbers: []);
        final _smsModelStudent = UserAccountSmsModel(username: student.username, password: student.password, kurumId: AppVar.appBloc.hesapBilgileri.kurumID, numbers: []);

        if (student.studentPhone.safeLength > 5) {
          _smsModelStudent.numbers!.add(student.studentPhone);
        }
        if (student.motherPhone.safeLength > 5) {
          _smsModelParent.numbers!.add(student.motherPhone);
        }
        if (student.fatherPhone.safeLength > 5) {
          _smsModelParent2.numbers!.add(student.fatherPhone);
        }

        if (_smsModelParent.password.safeLength > 5) _smsModelList.add(_smsModelParent);
        if (_smsModelParent2.password.safeLength > 5) _smsModelList.add(_smsModelParent2);
        if (_smsModelStudent.password.safeLength > 5) _smsModelList.add(_smsModelStudent);
      } else {
        final _smsModelParent = UserAccountSmsModel(username: student.username, password: student.parentPassword1, kurumId: AppVar.appBloc.hesapBilgileri.kurumID, numbers: []);
        final _smsModelStudent = UserAccountSmsModel(username: student.username, password: student.password, kurumId: AppVar.appBloc.hesapBilgileri.kurumID, numbers: []);

        if (student.motherPhone.safeLength > 5) {
          _smsModelParent.numbers!.add(student.motherPhone);
        }
        if (student.fatherPhone.safeLength > 5) {
          _smsModelParent.numbers!.add(student.fatherPhone);
        }
        if (student.studentPhone.safeLength > 5) {
          _smsModelStudent.numbers!.add(student.studentPhone);
        }

        if (_smsModelParent.password.safeLength > 5) _smsModelList.add(_smsModelParent);
        if (_smsModelStudent.password.safeLength > 5) _smsModelList.add(_smsModelStudent);
      }
    }

    return _smsModelList;
  }

  static List<UserAccountSmsModel> prepareOld(Student student) {
    List<UserAccountSmsModel> _smsModelList = [];

    if (AppVar.appBloc.hesapBilgileri.isEkid) {
      final _smsModel = UserAccountSmsModel(username: student.username, password: student.password, kurumId: AppVar.appBloc.hesapBilgileri.kurumID, numbers: []);

      if (student.motherPhone.safeLength > 5) {
        _smsModel.numbers!.add(student.motherPhone);
      }
      if (student.fatherPhone.safeLength > 5) {
        _smsModel.numbers!.add(student.fatherPhone);
      }
      if (student.studentPhone.safeLength > 5) {
        _smsModel.numbers!.add(student.studentPhone);
      }
      _smsModelList.add(_smsModel);
    } else {
      final _smsModelParent = UserAccountSmsModel(username: student.username, password: AppHelpers.passwordToParentPassword(student.password!), kurumId: AppVar.appBloc.hesapBilgileri.kurumID, numbers: []);
      final _smsModelStudent = UserAccountSmsModel(username: student.username, password: student.password, kurumId: AppVar.appBloc.hesapBilgileri.kurumID, numbers: []);

      if (student.motherPhone.safeLength > 5) {
        _smsModelParent.numbers!.add(student.motherPhone);
      }
      if (student.fatherPhone.safeLength > 5) {
        _smsModelParent.numbers!.add(student.fatherPhone);
      }
      if (student.studentPhone.safeLength > 5) {
        _smsModelStudent.numbers!.add(student.studentPhone);
      }

      _smsModelList.add(_smsModelParent);
      _smsModelList.add(_smsModelStudent);
    }

    return _smsModelList;
  }
}
