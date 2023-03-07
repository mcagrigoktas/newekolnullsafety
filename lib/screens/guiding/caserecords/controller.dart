import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myfileuploadwidget.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/appfunctions.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/accountdata.dart';
import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';
import 'model.dart';

class CaseRecordsController extends ResponsivePageController<CaseRecordModel> {
  CaseRecordsController()
      : super(
            menuName: 'caserecord',
            listViewPageStorageKey: 'caserecorddefine',
            saveFunction: (item) async {
              item.isClosed = item.closeReason.safeLength > 6;

              await CaseRecordService.saveCaseRecord(item);
            },
            deleteFunction: (item) async {
              item.aktif = false;
              await CaseRecordService.saveCaseRecord(item);
            },
            createNewClassFunction: () => CaseRecordModel.create(AppVar.appBloc.hesapBilgileri.uid),
            extraFilterWhereFunction: (e) {
              final _controller = Get.find<CaseRecordsController>();
              if (e.isClosed != true && _controller.caseRecordStatusDropdownValue == 0) return true;
              if (e.isClosed == true && _controller.caseRecordStatusDropdownValue == 1) return true;

              return false;
            });

  List<Student>? studentList;
  late List<Class?> classList;

  late MiniFetcher<CaseRecordModel> allRecordsFetcher;

  bool isPasswordChanged = false;

  int caseRecordStatusDropdownValue = 0;

  @override
  void onInit() {
    super.onInit();

    isPasswordChanged = AppVar.appBloc.hesapBilgileri.isUserChangedPassword;
    if (isPasswordChanged == false) return;

    studentList = AppFunctions2.getStudentListForTeacherAndManager();
    classList = AppVar.appBloc.hesapBilgileri.gtM ? AppVar.appBloc.classService!.dataList : TeacherFunctions.getTeacherClassList2();

    allRecordsFetcher = MiniFetcher<CaseRecordModel>(
      '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}caseRecords5',
      FetchType.LISTEN,
      multipleData: true,
      jsonParse: (key, value) => CaseRecordModel.fromJson(value, key),
      lastUpdateKey: 'lastUpdate',
      sortFunction: (CaseRecordModel i1, CaseRecordModel i2) => (i2.lastUpdate as int) - (i1.lastUpdate as int),
      removeFunction: (a) => a.name == null,
      queryRef: CaseRecordService.dbGetAllCaseRecords(),
      filterDeletedData: true,
    );

    refreshSubscription = allRecordsFetcher.stream.listen((event) {
      itemList = allRecordsFetcher.dataList.where((element) {
        if (element.teacherList!.contains(AppVar.appBloc.hesapBilgileri.uid)) return true;
        if (AppVar.appBloc.hesapBilgileri.gtM && element.hasSensitiveData == false) return true;
        return false;
      }).toList();

      makeFilter(filteredText);
      isPageLoading = false;
      update();
    });
  }

  @override
  void selectItem(CaseRecordModel item) {
    //? Eger daha onceden olay kaydi eklenen ogrenci daha sonra ogrencilikten cikmissa ogrenci listesine eklenmesi icin kondu
    item.targetList!.forEach((targetKey) {
      if (studentList!.every((element) => element.key != targetKey) && classList.every((element) => element!.key != targetKey)) {
        log("burdaaa");
        final _student = AppVar.appBloc.studentService!.dataListWithDeleted.firstWhereOrNull((element) => element.key == targetKey);
        if (_student != null) {
          studentList!.add(_student);
        } else {
          final _sinif = AppVar.appBloc.classService!.dataListWithDeleted.firstWhereOrNull((element) => element.key == targetKey);
          if (_sinif != null) {
            classList.add(_sinif);
          }
        }
      }
    });

    super.selectItem(item);
  }

  @override
  void onClose() {
    allRecordsFetcher.dispose();
    super.onClose();
  }

  Future<void> addItem() async {
    final _formKey = GlobalKey<FormState>();
    CaseRecordItem? newItem;
    CaseRecordItemType _itemType = CaseRecordItemType.meeting;
    final _child = MyForm(
      formKey: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MyDateTimePicker(
            title: 'date'.translate,
            initialValue: DateTime.now().millisecondsSinceEpoch,
            onSaved: (value) {
              newItem!.date = value;
            },
          ),
          Flexible(
            child: CupertinoTabWidget(
              initialPageValue: 0,
              tabs: [
                TabMenu(
                    name: 'meeting'.translate,
                    widget: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: MyTextFormField(
                                    labelText: 'duration'.translate + ' (' + 'minute'.translate + ')',
                                    enableInteractiveSelection: false,
                                    iconData: Icons.hourglass_bottom_rounded,
                                    validatorRules: ValidatorRules(req: false, mustInt: true),
                                    maxLines: 1,
                                    onSaved: (value) {
                                      newItem!.duration = int.tryParse(value!);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: AdvanceDropdown<MeetingType>(
                                    initialValue: MeetingType.p2p,
                                    name: 'meetingtype'.translate,
                                    items: [
                                      DropdownItem(value: MeetingType.p2p, name: 'p2p_m'.translate),
                                      DropdownItem(value: MeetingType.online, name: 'online_m'.translate),
                                      DropdownItem(value: MeetingType.phone, name: 'phone_m'.translate),
                                      DropdownItem(value: MeetingType.other, name: 'other'.translate),
                                    ],
                                    onSaved: (value) {
                                      newItem!.meetingType = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            MyTextFormField(
                              labelText: 'content'.translate,
                              iconData: Icons.comment,
                              validatorRules: ValidatorRules(req: true, minLength: 10),
                              enableInteractiveSelection: false,
                              maxLines: null,
                              onSaved: (value) {
                                newItem!.content = value;
                              },
                            ),
                            if (selectedItem!.targetList!.length > 2)
                              AdvanceMultiSelectDropdown(
                                name: 'participants'.translate,
                                initialValue: selectedItem!.targetList,
                                onSaved: (value) {
                                  newItem!.targetList = value as List<String>?;
                                },
                                validatorRules: ValidatorRules(minLength: 1),
                                items: selectedItem!.targetListIsClassList == true
                                    ? classList.where((element) => selectedItem!.targetList!.contains(element!.key)).map((e) {
                                        return DropdownItem(name: e!.name, value: e.key);
                                      }).toList()
                                    : studentList!.where((element) => selectedItem!.targetList!.contains(element.key)).map((e) {
                                        return DropdownItem(name: e.name, value: e.key);
                                      }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                    value: 0),
                TabMenu(
                    name: 'document'.translate,
                    widget: Column(
                      children: [
                        FileUploadWidget(
                          maxSizeMB: 20,
                          saveLocation: "${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/CRFiles",
                          onSaved: (value) {
                            newItem!.content = value!.name;
                            newItem!.documentUrl = value.url;
                          },
                        ),
                      ],
                    ),
                    value: 1),
                TabMenu(
                    name: 'note'.translate,
                    widget: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            MyTextFormField(
                              labelText: 'note'.translate,
                              validatorRules: ValidatorRules(req: true, minLength: 10),
                              enableInteractiveSelection: false,
                              maxLines: null,
                              iconData: Icons.note,
                              onSaved: (value) {
                                newItem!.content = value;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    value: 2),
              ],
              onChanged: (value) {
                value == 0
                    ? _itemType = CaseRecordItemType.meeting
                    : value == 1
                        ? _itemType = CaseRecordItemType.documents
                        : value == 2
                            ? _itemType = CaseRecordItemType.note
                            : _itemType = CaseRecordItemType.note;
              },
            ),
          ),
          MyRaisedButton(
                  onPressed: () {
                    if (_formKey.currentState!.check()) {
                      newItem = CaseRecordItem.create(_itemType);
                      newItem!.teacherList = [AppVar.appBloc.hesapBilgileri.uid];
                      _formKey.currentState!.save();
                      OverBottomSheet.selectBottomSheetItem(newItem);
                    }
                  },
                  text: Words.save)
              .p8
        ],
      ),
    );

    CaseRecordItem? item = await (OverBottomSheet.show(BottomSheetPanel.child(child: _child)));
    if (item == null) return;
    selectedItem!.items!.add(item);
    await save();
  }
}
