import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../appbloc/appvar.dart';
import '../helpers/appfunctions.dart';
import '../supermanager/supermanagerbloc.dart';

class TargetListWidget extends StatefulWidget {
  final Function(List<String>?)? onSaved;
  final bool onlyteachers; // true gelmezse yalnizdca ogretmneler ile paylasim yapilmaz
  final bool alluser;
  final List<String>? initialValue;
  TargetListWidget({this.onSaved, this.onlyteachers = true, this.alluser = false, this.initialValue});
  @override
  _TargetListWidgetState createState() => _TargetListWidgetState();
}

class _TargetListWidgetState extends State<TargetListWidget> with AppFunctions {
  String? dropdownValue;
  var uniquekey = UniqueKey();

  List<DropdownItem> getDropdownItems() {
    List<DropdownItem> dropdownItems = [];
    dropdownItems.add(DropdownItem(value: null, disabled: true, name: "anitemchoose".translate));
    if (AppVar.appBloc.hesapBilgileri.gtM || AppVar.appBloc.hesapBilgileri.teacherSeeAllClass == true || widget.alluser) {
      dropdownItems.addAll([
        DropdownItem(value: "alluser", name: "allusers".translate),
      ]);
    }
    dropdownItems.addAll([
      DropdownItem(value: 'classlist', name: "classlist".translate),
      DropdownItem(value: "studentlist", name: "studentlist".translate),
    ]);

    if (widget.onlyteachers) {
      dropdownItems.add(DropdownItem(value: "onlyteachers", name: "onlyteachers".translate));
    }
    return dropdownItems;
  }

  Widget? getMultipleSelectList(BuildContext context, FormFieldState<List<String>> state) {
    late List<String?> teacherClassList;
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      teacherClassList = TeacherFunctions.getTeacherClassList();
    }

    if (dropdownValue == "classlist" || dropdownValue == "studentlist") {
      return Container(
        key: uniquekey,
        child: MyMultiSelect(
          context: context,
          iconData: MdiIcons.fileTree,
          contentPadding: EdgeInsets.symmetric(vertical: isWeb ? 6 : 2, horizontal: 0),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          name: dropdownValue.translate,
          items: dropdownValue == "classlist"
              ? AppVar.appBloc.classService!.dataList
                  .where((sinif) {
                    if (AppVar.appBloc.hesapBilgileri.gtM) return true;
                    if (AppVar.appBloc.hesapBilgileri.gtT && teacherClassList.contains(sinif.key)) return true;
                    return false;
                  })
                  .map((sinif) => MyMultiSelectItem<String>(sinif.key, sinif.name))
                  .toList()
              : AppVar.appBloc.studentService!.dataList
                  .where((ogrenci) {
                    if (AppVar.appBloc.hesapBilgileri.gtM) return true;
                    if (AppVar.appBloc.hesapBilgileri.gtT && (teacherClassList.any((item) => ogrenci.classKeyList.contains(item)))) return true;
                    return false;
                  })
                  .map((sinif) => MyMultiSelectItem<String>(sinif.key, sinif.name))
                  .toList(),
          title: dropdownValue.translate,
          initialValue: state.value ?? [],
          validatorRules: ValidatorRules(req: false),
          onChanged: (value) {
            state.didChange(value);
          },
        ).animate().fadeIn().slideX(begin: 0.2, end: 0),
      );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      if (widget.initialValue!.contains('alluser')) {
        dropdownValue = 'alluser';
      } else if (widget.initialValue!.contains('onlyteachers')) {
        dropdownValue = 'onlyteachers';
      } else {
        if (AppVar.appBloc.classService!.dataListItem(widget.initialValue!.first) != null) {
          dropdownValue = 'classlist';
        } else {
          dropdownValue = 'studentlist';
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      initialValue: widget.initialValue,
      builder: (FormFieldState<List<String>> state) {
        Widget? _multipleSelectWidget = getMultipleSelectList(context, state);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: InputDecorator(
            decoration: InputDecoration(
              errorText: state.hasError ? state.errorText : null,
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(width: 0, color: Colors.transparent)),
            ),
            child: GroupWidget(
              children: <Widget>[
                AdvanceDropdown(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  items: getDropdownItems(),
                  iconData: MdiIcons.accountGroup,
                  name: "choosetarget".translate,
                  initialValue: dropdownValue,
                  onChanged: (dynamic value) {
                    setState(() {
                      dropdownValue = value;
                      uniquekey = UniqueKey();
                      if (value == "alluser" || value == "onlyteachers") {
                        state.didChange([value]);
                      } else {
                        state.didChange([]);
                      }
                    });
                  },
                ),
                if (_multipleSelectWidget != null) _multipleSelectWidget
              ],
            ),
          ),
        );
      },
      validator: ValidatorRules(minLength: 1, req: true),
      // validator: (value) {
      //   if ((value?.length ?? 0) < 1) {
      //     return "errorvalidation7".translate;
      //   }
      // },
      onSaved: widget.onSaved,
    );
  }
}

class SuperManagerTargetListWidget extends StatefulWidget {
  final Function(List<String>?)? onSaved;
  SuperManagerTargetListWidget({
    this.onSaved,
  });
  @override
  _SuperManagerTargetListWidgetState createState() => _SuperManagerTargetListWidgetState();
}

class _SuperManagerTargetListWidgetState extends State<SuperManagerTargetListWidget> with AppFunctions {
  String? dropdownValue;
  var uniquekey = UniqueKey();

  List<DropdownItem> getDropdownItems(BuildContext context) {
    return [
      DropdownItem(value: null, name: "anitemchoose".translate),
      DropdownItem(value: "allschool", name: "allschool".translate),
      DropdownItem(value: 'schoollist', name: "schoollist".translate),
    ];
  }

  Widget getMultipleSelectList(BuildContext context, FormFieldState<List<String>> state) {
    if (dropdownValue == "schoollist") {
      return Container(
        key: uniquekey,
        child: MyMultiSelect(
          context: context,
          contentPadding: EdgeInsets.symmetric(vertical: isWeb ? 6 : 2, horizontal: 0),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          iconData: MdiIcons.fileTree,
          name: dropdownValue.translate,
          items: Get.find<SuperManagerController>().serverList!.map((sinif) => MyMultiSelectItem(sinif.serverId, sinif.schoolName!)).toList() as List<MyMultiSelectItem<String>>,
          title: dropdownValue.translate,
          initialValue: [],
          validatorRules: ValidatorRules(req: false),
          onChanged: (value) {
            state.didChange(value);
          },
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      initialValue: null,
      builder: (FormFieldState<List<String>> state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: InputDecorator(
            decoration: InputDecoration(
              errorText: state.hasError ? state.errorText : null,
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(width: 0, color: Colors.transparent)),
            ),
            child: GroupWidget(
              children: <Widget>[
                AdvanceDropdown(
                  padding: const EdgeInsets.all(0.0),
                  items: getDropdownItems(context),
                  iconData: MdiIcons.accountGroup,
                  name: "choosetarget".translate,
                  initialValue: null,
                  onChanged: (dynamic value) {
                    setState(() {
                      dropdownValue = value;
                      uniquekey = UniqueKey();
                      if (value == "allschool") {
                        state.didChange([value]);
                      } else {
                        state.didChange([]);
                      }
                    });
                  },
                ),
                // MyDropDownField(
                //   padding: const EdgeInsets.all(0.0),
                //   color: Colors.amber,
                //   items: getDropdownItems(context),
                //   iconData: MdiIcons.accountGroup,
                //   name: "choosetarget".translate,
                //   initialValue: null,
                //   canvasColor: Fav.design.dropdown.canvas,
                //   onChanged: (value) {
                //     setState(() {
                //       dropdownValue = value;
                //       uniquekey = UniqueKey();
                //       if (value == "allschool") {
                //         state.didChange([value]);
                //       } else {
                //         state.didChange([]);
                //       }
                //     });
                //   },
                // ),
                getMultipleSelectList(context, state)
              ],
            ),
          ),
        );
      },
      validator: ValidatorRules(minLength: 1, req: true),
      // validator: (value) {
      //   if ((value?.length ?? 0) < 1) {
      //     return "errorvalidation7".translate;
      //   }
      // },
      onSaved: widget.onSaved,
    );
  }
}
