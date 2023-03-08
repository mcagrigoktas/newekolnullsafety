import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../appbloc/appvar.dart';
import '../../../services/dataservice.dart';
import '../../../services/pushnotificationservice.dart';
import '../homework_helper.dart';
import '../modelshw.dart';

class CheckHomeWork extends StatefulWidget {
  final HomeWork? homeWork;
  CheckHomeWork({this.homeWork});

  @override
  _CheckHomeWorkState createState() => _CheckHomeWorkState();
}

class _CheckHomeWorkState extends State<CheckHomeWork> {
  GlobalKey<FormState> formKey = GlobalKey();
  int? checktype = 0;

  Map? _studentData = {};
  bool isLoading = false;
  bool isLoading2 = true;

  void submit() {
    if (formKey.currentState!.validate()) {
      if (Fav.noConnection()) return;

      Map _data = {};
      _data['checktype'] = checktype;
      _studentData!.clear();
      formKey.currentState!.save();

      bool err = false;
      if (checktype != 0) {
        _studentData!.entries.forEach((item) {
          var value = item.value;
          var note = int.tryParse(value);
          int maxDeger = checktype == 1 ? 100 : (checktype == 2 ? 10 : 5);
          if (note == null) {
            _studentData![item.key] = -1;
          } else if (note < -1 || note > maxDeger) {
            err = true;
          } else {
            _studentData![item.key] = note;
          }
        });
      }
      if (err) {
        OverAlert.show(type: AlertType.danger, message: 'errhwnote'.translate);
        return;
      }
      if (_studentData!.isEmpty) {
        OverAlert.show(type: AlertType.danger, message: 'nostudent'.translate);
        return;
      }
      _data['studentData'] = _studentData;

      setState(() {
        isLoading = true;
      });
      HomeWorkService.addCheckHomeWorkData(widget.homeWork!, _data).then((a) async {
        _studentData!.entries.forEach((item) {
          EkolPushNotificationService.sendSingleNotification(HomeWorkHelper.getNotificationHeader(widget.homeWork!.tur) + ': ' + widget.homeWork!.title!, 'notecheck'.translate + ': ' + item.key.toString(), item.value.toString(), NotificationArgs(tag: 'homework'));
        });

        setState(() {
          isLoading = false;
        });
        Navigator.pop(context, true);
        OverAlert.saveSuc();
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        OverAlert.saveErr();
      });
    } else {
      setState(() {
        isLoading = false;
      });
      OverAlert.fillRequired();
    }
  }

  @override
  void initState() {
    super.initState();

    HomeWorkService.dbHomeWorkCheckData(widget.homeWork!.key!).once().then((snap) {
      if (snap?.value != null) {
        checktype = snap!.value['checktype'];
        _studentData = snap.value['studentData'];
      }
      setState(() {
        isLoading2 = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: widget.homeWork!.lessonName ?? ''),
      topActions: TopActionsTitleWithChild(title: TopActionsTitle(title: 'checkhomework'.translate), child: widget.homeWork!.content.text.maxLines(2).color(Fav.design.primaryText).bold.make()),
      body: isLoading2
          ? Body.circularProgressIndicator()
          : Body.singleChildScrollView(
              maxWidth: 960,
              child: MyForm(
                formKey: formKey,
                child: Column(
                  children: <Widget>[
                    AdvanceDropdown(
                        initialValue: checktype,
                        name: 'checktype'.translate,
                        onChanged: (dynamic value) {
                          setState(() {
                            checktype = value;
                            formKey = GlobalKey();
                            _studentData!.clear();
                          });
                        },
                        items: <List<dynamic>>[
                          [0, '${'hwdone2'.translate} - ${'hwdone1'.translate} - ${'hwdone0'.translate}'],
                          [1, 'hwpercent100'],
                          [2, 'hwpercent10'],
                          [3, 'hwpercent5']
                        ].map((e) => DropdownItem(value: e.first, name: (e.last as String).translate)).toList()),
                    ...AppVar.appBloc.studentService!.dataList
                        .where((student) => student.classKeyList.contains(widget.homeWork!.classKey))
                        .map((student) => Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0, top: 4.0),
                              padding: const EdgeInsets.only(left: 16.0, top: 4, bottom: 4, right: 4),
                              decoration: BoxDecoration(
                                color: Fav.design.primaryText.withAlpha(5),
                                boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 2.0)],
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Row(
                                children: <Widget>[
                                  if (student.imgUrl?.startsWithHttp ?? false)
                                    Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: CircularProfileAvatar(
                                          imageUrl: student.imgUrl,
                                          backgroundColor: Fav.design.scaffold.background,
                                          radius: 12.0,
                                        )),
                                  Expanded(
                                    child: Text(student.name, style: TextStyle(color: Fav.design.primaryText)),
                                  ),
                                  8.widthBox,
                                  if (checktype == 0)
                                    MyDropDownFieldOld(
                                        initialValue: _studentData![student.key] ?? 2,
                                        padding: const EdgeInsets.only(right: 8),
                                        isExpanded: false,
                                        onSaved: (value) {
                                          _studentData![student.key] = value;
                                        },
                                        items: <List<dynamic>>[
                                          [2, 'hwdone2'],
                                          [1, 'hwdone1'],
                                          [0, 'hwdone0'],
                                          [-1, 'notcheck']
                                        ].map((e) => DropdownMenuItem(value: e.first, child: Text((e.last as String).translate, style: TextStyle(color: Fav.design.primaryText, fontSize: 13)))).toList()),
                                  if (checktype! > 0)
                                    SizedBox(
                                        width: 75,
                                        height: 35,
                                        child: MyTextFormField(
                                          initialValue: _studentData![student.key] == -1 ? '' : (_studentData![student.key] ?? '').toString(),
                                          padding: const EdgeInsets.only(right: 8),
                                          keyboardType: TextInputType.number,
                                          onSaved: (value) {
                                            _studentData![student.key] = value;
                                          },
                                          validatorRules: ValidatorRules(
                                              mustNumber: true,
                                              maxValue: checktype == 1
                                                  ? 100
                                                  : checktype == 2
                                                      ? 10
                                                      : 5,
                                              minValue: 0),
                                          hintText: '...',
                                        ))
                                ],
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),
            ),
      bottomBar: isLoading2 ? null : BottomBar.saveButton(onPressed: submit, isLoading: isLoading),
    );
  }
}
