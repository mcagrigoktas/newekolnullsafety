import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import '../../../../services/dataservice.dart';
import '../programlistmodels.dart';

class SchoolTimes extends StatefulWidget {
  @override
  _SchoolTimesState createState() => _SchoolTimesState();
}

class _SchoolTimesState extends State<SchoolTimes> {
  bool _isLoading = false;
  late TimesModel _timesModel;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (AppVar.appBloc.schoolTimesService?.dataList.length != null && AppVar.appBloc.schoolTimesService!.dataList.isNotEmpty) {
      _timesModel = AppVar.appBloc.schoolTimesService!.dataList.last;
    } else {
      _timesModel = TimesModel();
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.checkAndSave()) {
      _timesModel.timeStamp = databaseTime;

      if (_timesModel.validate() == true) {
        _submit2();
      }
    }
  }

  void _submit2() {
    if (Fav.noConnection()) return;

    setState(() {
      _isLoading = true;
    });
    ProgramService.saveTimes(_timesModel.mapForSave()).then((a) async {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context, true);
      OverAlert.saveSuc();
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      OverAlert.saveErr();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _body = _isLoading
        ? Body.child(child: MyProgressIndicator(isCentered: true))
        : Body.singleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  MyMultiSelect(
                    initialValue: List<String>.from(_timesModel.activeDays!),
                    context: context,
                    items: [1, 2, 3, 4, 5, 6, 7].map((day) => MyMultiSelectItem(day.toString(), McgFunctions.getDayNameFromDayOfWeek(day))).toList(),
                    title: 'activedays'.translate,
                    iconData: MdiIcons.angular,
                    onChanged: (value) {
                      _timesModel.activeDays = Set.from(value!);
                    },
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    validatorRules: ValidatorRules(minLength: 1, req: true),
                  ),
                  Row(
                    children: <Widget>[
                      16.widthBox,
                      Expanded(
                        flex: 2,
                        child: Text(
                          'schoolstartEndtime'.translate,
                          style: TextStyle(color: Fav.design.primaryText),
                        ),
                      ),
                      Expanded(
                          flex: 3,
                          child: MyTimePicker(
                            onSaved: (value) {
                              _timesModel.schoolStartTime = value;
                            },
                            hasIcon: false,
                            initialValue: _timesModel.schoolStartTime,
                          )),
                      const Text('-'),
                      Expanded(
                          flex: 3,
                          child: MyTimePicker(
                              onSaved: (value) {
                                _timesModel.schoolEndTime = value;
                              },
                              hasIcon: false,
                              initialValue: _timesModel.schoolEndTime)),
                    ],
                  ),
                  AdvanceDropdown<int>(
                    items: [0, 1].map((e) => DropdownItem<int>(value: e, name: 'programtimetype$e'.translate)).toList(),
                    onChanged: (value) {
                      setState(() {
                        _timesModel.programTypes = value;
                      });
                    },
                    initialValue: _timesModel.programTypes,
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  ),
                  if (_timesModel.programTypes == 0)
                    Group2Widget(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: <Widget>[
                        Card(
                          color: Fav.design.card.background,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AdvanceDropdown(
                                initialValue: _timesModel.getWeekDaysLessonCountForSetup(),
                                name: 'weekdayslessoncount'.translate,
                                iconData: MdiIcons.tablet,
                                searchbarEnableLength: 1000,
                                items: Iterable.generate(/*15*/ 30)
                                    .map((no) => DropdownItem(
                                          name: '${no + 1}',
                                          value: no + 1,
                                        ))
                                    .toList(),
                                onChanged: (dynamic value) {
                                  setState(() {
                                    _timesModel.setWeekDaysLessonCount(value);
                                  });
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, top: 16),
                                child: Text(
                                  'weekdayslessontimes'.translate,
                                  style: TextStyle(color: Fav.design.disablePrimary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Column(
                                children: Iterable.generate(_timesModel.getWeekDaysLessonCountForSetup()!)
                                    .map((no) => Row(
                                          children: <Widget>[
                                            16.widthBox,
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'lesson'.translate + ' ${no + 1}',
                                                style: TextStyle(color: Fav.design.primaryText),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 3,
                                                child: MyTimePicker(
                                                  onSaved: (value) {
                                                    _timesModel.setWeekDaysLessonNoTimes(no, 0, value);
                                                  },
                                                  hasIcon: false,
                                                  initialValue: _timesModel.getDayLessonNoTimes('1', no).first,
                                                )),
                                            const Text('-'),
                                            Expanded(
                                                flex: 3,
                                                child: MyTimePicker(
                                                    onSaved: (value) {
                                                      _timesModel.setWeekDaysLessonNoTimes(no, 1, value);
                                                    },
                                                    hasIcon: false,
                                                    initialValue: _timesModel.getDayLessonNoTimes('1', no).last)),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: Fav.design.card.background,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AdvanceDropdown(
                                initialValue: _timesModel.getWeekEndLessonCountForSetup(),
                                name: 'weekendlessoncount'.translate,
                                iconData: MdiIcons.tablet,
                                searchbarEnableLength: 1000,
                                items: Iterable.generate(30 /*15*/)
                                    .map((no) => DropdownItem(
                                          name: '${no + 1}',
                                          value: no + 1,
                                        ))
                                    .toList(),
                                onChanged: (dynamic value) {
                                  setState(() {
                                    _timesModel.setWeekEndLessonCount(value);
                                  });
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0, top: 16),
                                child: Text(
                                  'weekendslessontimes'.translate,
                                  style: TextStyle(color: Fav.design.disablePrimary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Column(
                                children: Iterable.generate(_timesModel.getWeekEndLessonCountForSetup()!)
                                    .map((no) => Row(
                                          children: <Widget>[
                                            16.widthBox,
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                'lesson'.translate + ' ${no + 1}',
                                                style: TextStyle(color: Fav.design.primaryText),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 3,
                                                child: MyTimePicker(
                                                  onSaved: (value) {
                                                    _timesModel.setWeekEndLessonNoTimes(no, 0, value);
                                                  },
                                                  hasIcon: false,
                                                  initialValue: _timesModel.getDayLessonNoTimes('6', no).first,
                                                )),
                                            const Text('-'),
                                            Expanded(
                                                flex: 3,
                                                child: MyTimePicker(
                                                    onSaved: (value) {
                                                      _timesModel.setWeekEndLessonNoTimes(no, 1, value);
                                                    },
                                                    hasIcon: false,
                                                    initialValue: _timesModel.getDayLessonNoTimes('6', no).last)),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (_timesModel.programTypes == 1)
                    Group2Widget(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: <Widget>[
                        ..._timesModel.activeDays!
                            .map((day) => Card(
                                  color: Fav.design.card.background,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      AdvanceDropdown(
                                        initialValue: _timesModel.getDayLessonCount(day) ?? 1,
                                        name: McgFunctions.getDayNameFromDayOfWeek(int.tryParse(day)!),
                                        iconData: MdiIcons.tablet,
                                        items: Iterable.generate(30)
                                            .map((no) => DropdownItem(
                                                  name: '${no + 1}',
                                                  value: no + 1,
                                                ))
                                            .toList(),
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            _timesModel.setDayLessonCount(day, value);
                                          });
                                        },
                                        searchbarEnableLength: 1000,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16.0, top: 16),
                                        child: Text(
                                          'times'.translate,
                                          style: TextStyle(color: Fav.design.disablePrimary, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Column(
                                        children: Iterable.generate(_timesModel.getDayLessonCount(day)!)
                                            .map((no) => Row(
                                                  children: <Widget>[
                                                    16.widthBox,
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        'lesson'.translate + ' ${no + 1}',
                                                        style: TextStyle(color: Fav.design.primaryText),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 3,
                                                        child: MyTimePicker(
                                                          onSaved: (value) {
                                                            _timesModel.setDayLessonNoTimes(day, no, 0, value);
                                                          },
                                                          hasIcon: false,
                                                          initialValue: _timesModel.getDayLessonNoTimes(day, no).first ?? 0,
                                                        )),
                                                    const Text('-'),
                                                    Expanded(
                                                        flex: 3,
                                                        child: MyTimePicker(
                                                            onSaved: (value) {
                                                              _timesModel.setDayLessonNoTimes(day, no, 1, value);
                                                            },
                                                            hasIcon: false,
                                                            initialValue: _timesModel.getDayLessonNoTimes(day, no).last ?? 0)),
                                                  ],
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                ],
              ),
            ),
          );

    return AppScaffold(
      topBar: TopBar(leadingTitle: 'menu1'.translate),
      topActions: TopActionsTitle(title: 'schooltimes'.translate),
      body: _body,
      bottomBar: _isLoading
          ? null
          : BottomBar(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyProgressButton(
                  label: Words.save,
                  onPressed: _submit,
                  isLoading: _isLoading,
                ).pr16,
              ],
            )),
    );
  }
}
