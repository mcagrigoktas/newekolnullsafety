import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../flavors/mainhelper.dart';
import '../../localization/usefully_words.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import '../../widgets/mycard.dart';
import '../../widgets/sticker_picker.dart';
import 'helper.dart';

class EditDailyReport extends StatefulWidget {
  final String? classKey;

  EditDailyReport({this.classKey});

  @override
  _EditDailyReportState createState() => _EditDailyReportState();
}

class _EditDailyReportState extends State<EditDailyReport> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Class _sinif;
  bool isLoading = false;
  final _dailyReportList = <DailyReport>[];
  final _scrollController = ScrollController();
  bool _isLoadingAdd = false;

  @override
  void initState() {
    super.initState();
    _sinif = AppVar.appBloc.classService!.dataList.singleWhere((sinif) => sinif.key == widget.classKey);

    Future.delayed(Duration.zero, () {
      if (AppVar.appBloc.dailyReportProfileService!.state != FetchDataState.Null && AppVar.appBloc.dailyReportProfileService!.data[widget.classKey] == null) {
        _defaultDatalariYaz();
      }
      (AppVar.appBloc.dailyReportProfileService!.data[widget.classKey] ?? DailyReportHelper.defaultData()).forEach((daily) {
        _dailyReportList.add(DailyReport.fromJson(daily));
      });
      setState(() {});
    });
  }

  void _save() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (Fav.noConnection()) return;

    if (_formKey.currentState!.validate() && _dailyReportList.isNotEmpty) {
      _formKey.currentState!.save();

      DailyReportService.dbSetDailyReport(widget.classKey, _dailyReportList.map((daily) => daily.mapForSave()).toList()).then((_) {
        OverAlert.saveSuc();
      }).catchError((_) {
        OverAlert.saveErr();
      });
    } else {
      OverAlert.show(type: AlertType.danger, message: "errvalidation".translate);
    }
  }

  void _defaultDatalariYaz() {
    DailyReportService.dbDailyReportProfilesRef().once().then((snapshot) {
      if (snapshot?.value == null || snapshot!.value[widget.classKey] == null) {
        DailyReportService.dbSetDailyReport(widget.classKey, DailyReportHelper.defaultData());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dailyReportWidgetList = [];

    for (int i = 0; i < _dailyReportList.length; i++) {
      var daily = _dailyReportList[i];
      Widget current = MyListedCard(
          number: i + 1,
          closePressed: i < 3
              ? null
              : () {
                  setState(() {
                    _formKey = GlobalKey<FormState>();
                    _dailyReportList.removeAt(i);
                  });
                },
          tapPressed: i < 4
              ? null
              : () {
                  setState(() {
                    _formKey = GlobalKey<FormState>();
                    var item = _dailyReportList[i];
                    _dailyReportList.removeAt(i);
                    _dailyReportList.insert(i - 1, item);
                  });
                },
          downPressed: i + 1 == _dailyReportList.length || i < 3
              ? null
              : () {
                  setState(() {
                    _formKey = GlobalKey<FormState>();
                    var item = _dailyReportList[i];
                    _dailyReportList.removeAt(i);
                    _dailyReportList.insert(i + 1, item);
                  });
                },
          child: FormField(
            initialValue: daily,
            builder: (FormFieldState<DailyReport> state) => Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: MySegmentedControl(
                        padding: const EdgeInsets.only(top: 8.0),
                        initialValue: daily.tur,
                        name: "",
                        children: {0: Text('daily'.translate), 1: Text('education'.translate)},
                        onSaved: (value) {
                          _dailyReportList[i].tur = value;
                        },
                      ),
                    ),
                    Expanded(
                      child: MySegmentedControl(
                        padding: const EdgeInsets.only(top: 8.0),
                        initialValue: state.value!.hasOption,
                        name: "",
                        children: {true: Text('choosable'.translate), false: Text('writable'.translate)},
                        onSaved: (value) {
                          _dailyReportList[i].hasOption = value;
                        },
                        onChanged: (value) {
                          var daily = state.value!;
                          daily.hasOption = value;
                          state.didChange(daily);
                        },
                      ),
                    ),
                  ],
                ),
                6.heightBox,
                GroupWidget(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 80,
                          height: 48,
                          child: LogoPicker(
                            initialValue: daily.iconName,
                            onSaved: (value) {
                              _dailyReportList[i].iconName = value;
                            },
                            itemNames: Iterable.generate(AppConst.stickerCount).map((sayi) {
                              return "et${sayi + 1}" + "c.png";
                            }).toList(),
                          ),
                        ),
                        Expanded(
                          child: MyTextFormField(
                            labelText: "header".translate,
                            validatorRules: ValidatorRules(req: true, minLength: 4, firebaseSafe: true),
                            initialValue: daily.header,
                            onSaved: (value) {
                              _dailyReportList[i].header = value;
                            },
                          ),
                        )
                      ],
                    ),
                    state.value!.hasOption!
                        ? MyMakeChipList(
                            validatorRules: ValidatorRules(req: true, minLength: 2),
                            initialValue: daily.options ?? [],
                            iconData: MdiIcons.accountMultiple,
                            color: Colors.lightBlueAccent,
                            labelText: "option".translate,
                            onSaved: (value) {
                              _dailyReportList[i].options = value;
                            },
                          )
                        : const SizedBox(),
                  ],
                ),
              ],
            ),
          ));
      dailyReportWidgetList.add(
//          daily.key == "data1" || daily.key == "data2" || daily.key == "data3"
//              ? GestureDetector(
//                  onTap: () {
//                    Alert.alert(
//                        context: context,
//                        type: AlertType.danger,
//                        text:   "morningbreakfast") +
//                            ", " +
//                              "lunch") +
//                            ", " +
//                              "afternoonbreakfast") +
//                            " " +
//                              "cantchangeeat"));
//                  },
//                  child: AbsorbPointer(
//                    absorbing: true,
//                    child: current,
//                  ))
//              :
          current);
    }

    return AppScaffold(
      topBar: TopBar(
        leadingTitle: "dailyreport".translate,
      ),
      topActions: TopActionsTitleWithChild(
        title: TopActionsTitle(title: "dailyreportedit".translate),
        child: ("editdailyimporthintprefix".translate + " " + _sinif.name! + " " + "editdailyimporthintsufix".translate).text.center.make(),
      ),
      body: Body(
          singleChildScroll: MyForm(
            formKey: _formKey,
            child: Column(
              children: dailyReportWidgetList,
            ),
          ),
          scrollController: _scrollController),
      bottomBar: BottomBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            MyProgressButton(
              isLoading: _isLoadingAdd,
              label: 'add'.translate,
              onPressed: () {
                //FocusScope.of(context).requestFocus(new FocusNode());
                _formKey.currentState!.save();
                setState(() {
                  _isLoadingAdd = true;
                  _formKey = GlobalKey<FormState>();
                  _dailyReportList.add(DailyReport(tur: 0, key: 10.makeKey, options: [], hasOption: true, header: ""));
                });
                Future.delayed(const Duration(milliseconds: 100)).then((_) {
                  _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.linear);
                });
                Future.delayed(const Duration(milliseconds: 400)).then((_) {
                  setState(() {
                    _isLoadingAdd = false;
                  });
                });
              },
            ),
            MyProgressButton(
              isLoading: isLoading,
              label: Words.save,
              onPressed: _save,
            ),
          ],
        ).px16,
      ),
    );
  }
}
