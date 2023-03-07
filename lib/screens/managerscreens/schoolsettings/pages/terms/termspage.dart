import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../flavors/appentry/reviewtermscaffold.dart';
import '../../../../../localization/usefully_words.dart';
import '../../../../../models/allmodel.dart';
import '../../../../../services/dataservice.dart';

class Terms extends StatefulWidget {
  @override
  _TermsState createState() => _TermsState();
}

class _TermsState extends State<Terms> {
  late StreamSubscription _streamSubsccription;
  final List<Widget> _termWidgetList = [];
  final _newTermController = TextEditingController();

  bool _addNewTerm() {
    FocusScope.of(context).requestFocus(FocusNode());

    var _termName = _newTermController.text.trim();

    if (_termName.contains(' ')) {
      OverAlert.show(type: AlertType.danger, message: 'hasSpace'.translate);
      return false;
    }

    if (_termName.safeLength > 5) {
      if (_termName.hasFirebaseForbiddenCharacter || !_termName.everyCharacterIsAscii) {
        OverAlert.show(type: AlertType.danger, message: 'firebaseSafe'.translate);
        return false;
      } else {
        SchoolDataService.dbAddTerm({"name": _termName, "aktif": true}).then((_) {
          OverAlert.saveSuc();
          _newTermController.value = const TextEditingValue(text: '');
        }).catchError((_) {
          OverAlert.saveErr();
        });
        return true;
      }
    } else {
      OverAlert.show(type: AlertType.danger, message: 'minLength'.argTranslate('6'));
      return false;
    }
  }

  final _termList = Iterable.generate(15).map((i) => i + 2019).map((year) => '$year-${year + 1}');

  Future<void> _clickTerm(String itemKey, String? name) async {
    final _value = await OverBottomSheet.show(BottomSheetPanel.simpleGroup(title: name, subTitle: itemKey == AppVar.appBloc.schoolInfoService!.singleData?.activeTerm ? "activeterm".translate : null, groups: [
      if (itemKey != AppVar.appBloc.schoolInfoService!.singleData?.activeTerm)
        BottomSheetGroup(items: [
          BottomSheetItem(
            name: "makeactiveterm".translate,
            value: "makeactiveterm",
            bold: true,
          )
        ]),
      if (isWeb && itemKey != AppVar.appBloc.schoolInfoService!.singleData?.activeTerm)
        BottomSheetGroup(items: [
          BottomSheetItem(
            name: "reviewterm".translate,
            value: "reviewterm",
          )
        ]),
      BottomSheetGroup(items: [
        BottomSheetItem(
          itemColor: Colors.red,
          name: _termList.contains(itemKey) ? "cantdelete".translate : Words.delete,
          value: _termList.contains(itemKey) ? null : "delete",
        )
      ]),
      BottomSheetGroup(items: [BottomSheetItem.cancel()]),
    ]));

    if (_value != null) {
      if (_value == "makeactiveterm") {
        final _sure = await Over.sure(message: 'termchangewarning'.argsTranslate({'name': itemKey}));
        if (_sure) {
          await SchoolDataService.dbChangeActiveTerm(itemKey);
        }
      } else if (_value == "delete") {
        final _sure = await Over.sure();
        if (_sure) {
          await SchoolDataService.dbDeleteTerm(itemKey).then((value) {
            OverAlert.deleteSuc();
          }).catchError((err) {
            OverAlert.deleteErr();
          });
        }
      } else if (_value == "reviewterm") {
        AppVar.appBloc.appConfig.ekolRestartApp!(true, {'reviewterm': itemKey});
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _streamSubsccription = SchoolDataService.dbTermsRef().onValue(orderByChild: "aktif", equalTo: true).listen((event) {
      final Map terms = event!.value;
      _termWidgetList.clear();

      (terms.entries.toList()..sort((a, b) => a.value["name"].compareTo(b.value["name"]))).forEach((item) {
        _termWidgetList.add(Container(
          margin: EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(color: Fav.design.primaryText.withOpacity(0.05), borderRadius: BorderRadius.circular(9)),
          child: ListTile(
            onTap: () {
              _clickTerm(item.key, item.value["name"]);
            },
            title: (item.value["name"] as String?).text.bold.make(),
            trailing: item.key == AppVar.appBloc.schoolInfoService!.singleData?.activeTerm ? Icons.check_box.icon.color(Fav.design.primary).make() : null,
          ),
        ));
      });

      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubsccription.cancel();
  }

  void stateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (AppVar.appBloc.reviewTerm == true) {
      return Center(
        child: ReviewTermScaffold(),
      );
    }

    return Column(
      children: <Widget>[
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Fav.design.primary)),
          color: Fav.design.card.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              'subtermsettings'.translate.text.color(Fav.design.primary).bold.make(),
              "termpagewarning2".argsTranslate({'term': (AppVar.appBloc.schoolInfoService!.singleData?.activeTerm ?? "")}).text.color(Fav.design.primaryText).make(),
              8.heightBox,
              Row(
                children: [
                  'subtermlist'.translate.toUpperCase().text.color(Fav.design.primaryText).fontSize(16).make(),
                  Spacer(),
                  MyMiniRaisedButton(
                    text: "addnewsubterm".translate,
                    onPressed: () {
                      openAddNewSubTermDialog(stateChanged);
                    },
                  ),
                ],
              ),
              8.heightBox,
              AppVar.appBloc.schoolInfoService!.singleData!.subTermList() == null
                  ? Align(alignment: Alignment.topLeft, child: 'subtermnotfound'.argsTranslate({'term': (AppVar.appBloc.schoolInfoService!.singleData?.activeTerm ?? "")}).text.color(Fav.design.primaryText).make()).rounded(background: Fav.design.primaryText.withOpacity(0.05))
                  : Column(
                      children: AppVar.appBloc.schoolInfoService!.singleData!
                          .subTermList()!
                          .map((e) => Row(
                                children: [
                                  e.name.text.make(),
                                  Spacer(),
                                  (e.startDate!.dateFormat('d-MMM-yyyy') + ' / ' + e.endDate!.dateFormat('d-MMM-yyyy')).text.make(),
                                ],
                              ))
                          .toList(),
                    )
            ],
          ).p8,
        ),
        12.heightBox,
        Divider(),
        12.heightBox,
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Fav.design.primary)),
          color: Fav.design.card.background,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ("activeterm".translate + ":").text.color(Colors.white).bold.fontSize(17).make(),
                  12.widthBox,
                  (AppVar.appBloc.schoolInfoService!.singleData?.activeTerm ?? "").text.color(Colors.white).bold.fontSize(27).make(),
                ],
              ).rounded(borderRadius: 16, background: Fav.design.primary, padding: EdgeInsets.all(16)),
              8.heightBox,
              "termpagewarning".translate.text.color(Fav.design.primaryText).make(),
              8.heightBox,
              Row(
                children: [
                  'termlist'.translate.toUpperCase().text.color(Fav.design.primaryText).fontSize(16).make(),
                  Spacer(),
                  MyMiniRaisedButton(
                    text: "addnewterm".translate,
                    onPressed: openAddNewTermDialog,
                  ),
                ],
              ),
              8.heightBox,
              Column(children: _termWidgetList),
            ],
          ).p8,
        ),
      ],
    );
  }

  Future<void> openAddNewTermDialog() async {
    await OverBottomSheet.show(BottomSheetPanel.child(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyTextFormField(
          enableInteractiveSelection: false,
          labelText: 'name'.translate,
          controller: _newTermController,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            16.widthBox,
            MyRaisedButton(
              text: 'cancel'.translate,
              onPressed: () {
                OverBottomSheet.closeBottomSheet();
              },
            ),
            Spacer(),
            MyRaisedButton(
              text: 'add'.translate,
              onPressed: () {
                final _result = _addNewTerm();
                if (_result == true) OverBottomSheet.closeBottomSheet();
              },
            ),
            16.widthBox,
          ],
        ),
      ],
    )));
  }

  Future<void> openAddNewSubTermDialog(Function() afterSaved) async {
    await OverBottomSheet.show(BottomSheetPanel.child(child: _SubTermAddWidget(afterSaved)));
  }
}

class _SubTermAddWidget extends StatefulWidget {
  final Function() afterSaved;
  _SubTermAddWidget(this.afterSaved);
  @override
  _SubTermAddWidgetState createState() => _SubTermAddWidgetState();
}

class _SubTermAddWidgetState extends State<_SubTermAddWidget> {
  final _formKey = GlobalKey<FormState>();
  String? term;
  @override
  void initState() {
    term = AppVar.appBloc.schoolInfoService!.singleData!.activeTerm;
    _itemList = AppVar.appBloc.schoolInfoService!.singleData!.subTermList() ?? [];
    if (_itemList.isEmpty) _addNewItem(0);

    super.initState();
  }

  var _itemList = <SubTermModel>[];

  void _addNewItem(int index) {
    _itemList.add(SubTermModel(name: 'term'.translate + ' ${index + 1}', startDate: DateTime.now().millisecondsSinceEpoch, endDate: DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch));
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.checkAndSave()) {
      for (var i = 1; i < _itemList.length; i++) {
        final _item = _itemList[i];
        final _beforeItem = _itemList[i - 1];
        if (_item.startDate! < _beforeItem.endDate!) {
          OverAlert.showWarning(message: 'termtimeerr');
          return;
        }
      }
      OverLoading.show();
      SchoolDataService.saveSchoolSubTerm(term, _itemList).then((value) async {
        OverAlert.saveSuc();
        await OverLoading.close();
        OverBottomSheet.closeBottomSheet();
        widget.afterSaved();
      }).catchError((err) {
        OverAlert.saveErr();
        OverLoading.close();
      }).unawaited;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyForm(
      formKey: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ('subtermlist'.translate + ' ($term)').text.bold.fontSize(20).make(),
          8.heightBox,
          ..._itemList.map((e) {
            return Row(
              key: ObjectKey(e),
              children: [
                (_itemList.indexOf(e) + 1).toString().text.color(Fav.design.primaryText).bold.make().pl8,
                8.widthBox,
                Expanded(
                    child: MyTextFormField(
                  labelText: 'name'.translate,
                  padding: EdgeInsets.zero,
                  validatorRules: ValidatorRules(req: true, minLength: 6),
                  initialValue: e.name,
                  onSaved: (value) {
                    e.name = value;
                  },
                )),
                Expanded(
                    child: MyDateRangePicker(
                  name: 'date'.translate,
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2028),
                  entryMode: DatePickerEntryMode.input,
                  value: [e.startDate!, e.endDate!],
                  onSaved: (value) {
                    if (value != null) {
                      e.startDate = value[0];
                      e.endDate = value[1];
                    }
                  },
                )),
                Icons.clear.icon.color(Colors.red).onPressed(() {
                  setState(() {
                    _itemList.remove(e);
                  });
                }).make()
              ],
            );
          }).toList(),
          8.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              16.widthBox,
              MyRaisedButton(
                text: 'add'.translate,
                onPressed: () async {
                  if (_itemList.length < 10)
                    setState(() {
                      _addNewItem(_itemList.length);
                    });
                },
              ),
              Spacer(),
              MyRaisedButton(
                color: Fav.design.scaffold.background,
                textColor: Fav.design.primary,
                text: 'cancel'.translate,
                onPressed: () {
                  OverBottomSheet.closeBottomSheet();
                },
              ),
              16.widthBox,
              MyRaisedButton(
                text: Words.save,
                onPressed: _submit,
              ),
              16.widthBox,
            ],
          ),
        ],
      ),
    );
  }
}
