import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../appbloc/appvar.dart';
import '../../../services/dataservice.dart';
import '../hwwidget.dart';
import '../modelshw.dart';

class HomeWorkPublish extends StatefulWidget {
  @override
  _HomeWorkPublishState createState() => _HomeWorkPublishState();
}

class _HomeWorkPublishState extends State<HomeWorkPublish> {
  StreamSubscription? subscription;
  List<HomeWork>? hwList;
  int classType = 0;
  String? classKey;

  bool loading = false;

  void onChangeClass(sinifKey) {
    setState(() {
      hwList = null;
      classKey = sinifKey;
      getData();
    });
  }

  void getData() {
    if (classKey == null) return;

    subscription?.cancel();
    subscription = null;
    setState(() {
      loading = true;
    });
    subscription = HomeWorkService.dbIsNotPublishedHomeWork(classKey!).onValue(orderByChild: 'isPublish', equalTo: false).listen((event) {
      hwList = [];

      if (event?.value == null) {
      } else {
        (event!.value as Map).forEach((key, value) {
          hwList!.add(HomeWork.fromJson(value, key));
        });
        hwList!.removeWhere((item) => item.aktif == false);
      }
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownItem<String>> classDropDownList = AppVar.appBloc.classService!.dataList.where((sinif) => sinif.classType == classType).map((sinif) {
      return DropdownItem<String>(value: sinif.key, name: sinif.name);
    }).toList();
    classDropDownList.insert(
        0,
        DropdownItem<String>(
          value: null,
          name: "chooseclass".translate,
        ));

    return AppScaffold(
      topBar: TopBar(leadingTitle: 'menu1'.translate),
      topActions: TopActionsTitleWithChild(
        title: TopActionsTitle(title: 'hwwaitpublish'.translate),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: AdvanceDropdown<int>(
                padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4, right: 4),
                initialValue: classType,
                iconData: MdiIcons.humanMaleBoard,
                items: [
                  DropdownItem(value: 0, name: 'classtype0'.translate),
                  DropdownItem(value: 1, name: 'classtype1'.translate),
                  ...AppVar.appBloc.schoolInfoService!.singleData!.filteredClassType!.entries
                      .map((item) => DropdownItem(
                            name: item.value,
                            value: int.parse(item.key.toString().replaceAll('t', '')),
                          ))
                      .toList()
                ],
                onChanged: (value) {
                  setState(() {
                    classType = value;
                    classKey = null;
                    hwList = null;
                  });
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: AdvanceDropdown(
                padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4, right: 12),
                onChanged: onChangeClass,
                initialValue: classKey,
                iconData: MdiIcons.humanMaleBoard,
                items: classDropDownList,
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? Body.circularProgressIndicator()
          : (hwList == null || hwList!.isEmpty)
              ? Body.child(
                  child: EmptyState(
                  text: 'nopublishedhomework'.translate,
                ))
              : Body.listviewBuilder(
                  itemCount: hwList!.length,
                  itemBuilder: (context, index) => HomeWorkWidget(
                        showLessonName: true,
                        publishButton: true,
                        checkButton: false,
                        homeWork: hwList![index],
                        dividerStyle: hwList!.length == 1 ? 3 : (index == 0 ? 0 : (index == hwList!.length - 1 ? 2 : 1)),
                      )),
    );
  }
}
