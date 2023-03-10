import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../flavors/mainhelper.dart';
import '../../../../localization/usefully_words.dart';
import '../../account_settings/case_names.dart';
import '../../accountingstatistics/paststatistics.dart';
import '../../accountingstatistics/student_financal_analysis.dart';
import '../controller.dart';

class FilterMenu extends StatelessWidget {
  FilterMenu();
  final _controller = Get.find<FinancialAnalysisController>();
  void _makeFilterButtonPressed() {
    _controller.filterMenuIsOpen = false;
    _controller.makeFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scroller(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Card(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                'favfilters'.translate.text.color(Fav.design.primary).bold.make(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InkWell(
                      onTap: () {
                        Fav.guardTo(PastStatistics());
                      },
                      child: Container(color: Fav.design.primaryText.withAlpha(5), padding: Inset(8), child: "accountingstatitictype0".translate.text.make()),
                    ),
                    InkWell(
                      onTap: () {
                        Fav.guardTo(StudentFinancalAnalysis());
                      },
                      child: Container(color: Fav.design.primaryText.withAlpha(5), padding: Inset(8), child: "accountingstatitictype2".translate.text.make()),
                    ),
                    InkWell(
                      onTap: () {
                        _controller.filterOption!.addAll({
                          'caseList': ['all'],
                          'contractsEnable': false,
                          'salesContractsEnable': false,
                          'expenseEnable': false,
                          'virmanEnable': false,
                          'studentAccountingEnable': true,
                          'studentsTahsilEdildi': true,
                          'studentsTahsilEdilecek': false,
                          'studentsAccountingLabelList': ['all'],
                        });
                        _makeFilterButtonPressed();
                      },
                      child: Container(color: Fav.design.primaryText.withAlpha(5), padding: Inset(8), child: "showstudentspayments".translate.text.make()),
                    ),
                    ...Fav.securePreferences
                        .getMap('finanacialAnalysisFav')
                        .entries
                        .map((e) => InkWell(
                              onTap: () {
                                _controller.filterOption = e.value;
                                _makeFilterButtonPressed();
                              },
                              child: Container(
                                padding: Inset(8),
                                color: Fav.design.primaryText.withAlpha(5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    e.key.text.make(),
                                    Icons.clear.icon
                                        .size(20)
                                        .padding(0)
                                        .onPressed(() async {
                                          final _result = await Over.sure();
                                          if (_result) {
                                            await Fav.securePreferences.deleteItemMap('finanacialAnalysisFav', e.key);
                                            _controller.update();
                                          }
                                        })
                                        .color(Colors.red)
                                        .make()
                                        .pl2,
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ],
            ).p8),
          ),
          Divider(),
          MySearchBar(
            onChanged: (value) {
              _controller.filterOption!['searchText'] = value.toLowerCase();
            },
            initialText: _controller.filterOption!['searchText'],
          ),
          Divider(),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 48,
                      child: MyDateFilterPicker(
                          padding: EdgeInsets.zero,
                          firstDate: DateTime.now().subtract(Duration(days: 730)),
                          lastDate: DateTime.now().add(Duration(days: 730)),
                          name: 'date'.translate,
                          onChanged: (value) {
                            if (value != null) {
                              _controller.filterOption!['startDate'] = value.startDate;
                              _controller.filterOption!['endDate'] = value.endDate;
                            } else {
                              _controller.filterOption!['startDate'] = null;
                              _controller.filterOption!['endDate'] = null;
                            }
                          },
                          value: _controller.filterOption!['startDate'] == null && _controller.filterOption!['endDate'] == null
                              ? null
                              : _controller.filterOption!['startDate'] == null
                                  ? DateFilterPickerValue(
                                      dateFilterPickerType: DateFilterPickerType.mustEnd,
                                      startDate: null,
                                      endDate: _controller.filterOption!['endDate'],
                                    )
                                  : DateFilterPickerValue(
                                      dateFilterPickerType: DateFilterPickerType.mustStart,
                                      startDate: _controller.filterOption!['startDate'],
                                      endDate: null,
                                    )),
                    ),
                    MyTextField(
                      padding: EdgeInsets.zero,
                      labelText: 'amountrange'.translate,
                      hintText: 'short_example'.argTranslate(['0-15000', '1000-12000'].randomOne()!),
                      iconData: Icons.attach_money_outlined,
                      initialValue: _controller.filterOption!['amountRange'],
                      onChanged: (value) {
                        _controller.filterOption!['amountRange'] = value;
                      },
                    )
                  ],
                ),
              )
            ],
          ),
          Divider(),
          ExpansionPanelList(
            elevation: 1,
            expandedHeaderPadding: Inset.hv(16, 4),
            expansionCallback: (index, isOpen) {
              Fav.writeSeasonCache('AccountingStatisticsExpansionPanelListState$index', !isOpen);
              _controller.update();
            },
            children: [
              ExpansionPanel(
                isExpanded: Fav.readSeasonCache('AccountingStatisticsExpansionPanelListState0', false)!,
                headerBuilder: (context, isExpand) {
                  return MySwitch(
                    padding: Inset.h(8),
                    initialValue: _controller.filterOption!['studentAccountingEnable'],
                    name: "studentaccounting".translate,
                    iconData: MdiIcons.accountCashOutline,
                    color: Colors.deepPurple,
                    onChanged: (value) {
                      _controller.filterOption!['studentAccountingEnable'] = value;
                    },
                  );
                },
                body: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: MySwitch(
                          padding: Inset.h(2),
                          name: 'showcollecting'.translate,
                          initialValue: _controller.filterOption!['studentsTahsilEdildi'],
                          onChanged: (value) {
                            _controller.filterOption!['studentsTahsilEdildi'] = value;
                          },
                        )),
                        Expanded(
                            child: MySwitch(
                          padding: Inset.h(2),
                          name: 'showcollectibles'.translate,
                          initialValue: _controller.filterOption!['studentsTahsilEdilecek'],
                          onChanged: (value) {
                            _controller.filterOption!['studentsTahsilEdilecek'] = value;
                          },
                        )),
                      ],
                    ),
                    MyMultiSelect(
                      context: context,
                      items: [
                        MyMultiSelectItem('all', 'all'.translate),
                        ...AppConst.accountingType.map((paymentType) {
                          final _realPaymentName = AppVar.appBloc.schoolInfoService!.singleData!.paymentName(paymentType);
                          return MyMultiSelectItem(paymentType, _realPaymentName);
                        }).toList()
                      ],
                      name: 'paymenttype'.translate,
                      title: 'paymenttype'.translate,
                      iconData: Icons.label,
                      initialValue: List<String>.from(_controller.filterOption!['studentsAccountingLabelList']),
                      onChanged: (value) {
                        _controller.filterOption!['studentsAccountingLabelList'] = value;
                      },
                    ).pb8,
                  ],
                ),
              ),
              ExpansionPanel(
                isExpanded: Fav.readSeasonCache('AccountingStatisticsExpansionPanelListState1', false)!,
                headerBuilder: (context, isExpand) {
                  return MySwitch(
                    padding: Inset.h(8),
                    initialValue: _controller.filterOption!['contractsEnable'],
                    name: "contracts".translate,
                    iconData: MdiIcons.fileSign,
                    color: Colors.deepPurple,
                    onChanged: (value) {
                      _controller.filterOption!['contractsEnable'] = value;
                    },
                  );
                },
                body: Column(children: [
                  Row(
                    children: [
                      Expanded(
                          child: MySwitch(
                        padding: Inset.h(2),
                        name: 'showcollecting'.translate,
                        initialValue: _controller.filterOption!['contractsTahsilEdildi'],
                        onChanged: (value) {
                          _controller.filterOption!['contractsTahsilEdildi'] = value;
                        },
                      )),
                      Expanded(
                          child: MySwitch(
                        padding: Inset.h(2),
                        name: 'showcollectibles'.translate,
                        initialValue: _controller.filterOption!['contractsTahsilEdilecek'],
                        onChanged: (value) {
                          _controller.filterOption!['contractsTahsilEdilecek'] = value;
                        },
                      )),
                    ],
                  ),
                  MyMultiSelect(
                    context: context,
                    items: [
                      MyMultiSelectItem('all', 'all'.translate),
                      ...AppVar.appBloc.schoolInfoForManagerService!.singleData!
                          .contractLabelInfoList()
                          .map((e) => MyMultiSelectItem<String>(e.key, e.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 14,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MyPalette.getBaseColor(int.tryParse(e.key.replaceAll('c', ''))!)),
                                  ),
                                  8.widthBox,
                                  e.value.text.make()
                                ],
                              )))
                          .toList()
                    ],
                    name: 'label'.translate,
                    title: 'label'.translate,
                    iconData: Icons.label,
                    initialValue: List<String>.from(_controller.filterOption!['contractsLabelList']),
                    onChanged: (value) {
                      _controller.filterOption!['contractsLabelList'] = value;
                    },
                  ).pb8,
                ]),
              ),
              ExpansionPanel(
                isExpanded: Fav.readSeasonCache('AccountingStatisticsExpansionPanelListState2', false)!,
                headerBuilder: (context, isExpand) {
                  return MySwitch(
                    padding: Inset.h(8),
                    initialValue: _controller.filterOption!['salesContractsEnable'],
                    name: "salescontracts".translate,
                    iconData: MdiIcons.fileDocumentEditOutline,
                    color: Colors.deepPurple,
                    onChanged: (value) {
                      _controller.filterOption!['salesContractsEnable'] = value;
                    },
                  );
                },
                body: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: MySwitch(
                          padding: Inset.h(2),
                          name: 'showcollecting'.translate,
                          initialValue: _controller.filterOption!['salesContractsTahsilEdildi'],
                          onChanged: (value) {
                            _controller.filterOption!['salesContractsTahsilEdildi'] = value;
                          },
                        )),
                        Expanded(
                            child: MySwitch(
                          padding: Inset.h(2),
                          name: 'showcollectibles'.translate,
                          initialValue: _controller.filterOption!['salesContractsTahsilEdilecek'],
                          onChanged: (value) {
                            _controller.filterOption!['salesContractsTahsilEdilecek'] = value;
                          },
                        )),
                      ],
                    ),
                    MyMultiSelect(
                      context: context,
                      items: [
                        MyMultiSelectItem('all', 'all'.translate),
                        ...AppVar.appBloc.schoolInfoForManagerService!.singleData!
                            .salesContractLabelInfoList()
                            .map((e) => MyMultiSelectItem<String>(e.key, e.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 14,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MyPalette.getBaseColor(int.tryParse(e.key.replaceAll('c', ''))!)),
                                    ),
                                    8.widthBox,
                                    e.value.text.make()
                                  ],
                                )))
                            .toList()
                      ],
                      name: 'label'.translate,
                      title: 'label'.translate,
                      iconData: Icons.label,
                      initialValue: List<String>.from(_controller.filterOption!['salesContractsLabelList']),
                      onChanged: (value) {
                        _controller.filterOption!['salesContractsLabelList'] = value;
                      },
                    ).pb8
                  ],
                ),
              ),
              ExpansionPanel(
                isExpanded: Fav.readSeasonCache('AccountingStatisticsExpansionPanelListState3', false)!,
                headerBuilder: (context, isExpand) {
                  return MySwitch(
                    padding: Inset.h(8),
                    initialValue: _controller.filterOption!['expenseEnable'],
                    name: "expenses".translate,
                    iconData: MdiIcons.storeEditOutline,
                    color: Colors.deepPurple,
                    onChanged: (value) {
                      _controller.filterOption!['expenseEnable'] = value;
                    },
                  );
                },
                body: Column(
                  children: [
                    MyMultiSelect(
                      context: context,
                      items: [
                        MyMultiSelectItem('all', 'all'.translate),
                        ..._controller.allExpensesLabelNodes
                            .map((e) => MyMultiSelectItem<String>(e.path, e.name!,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 14,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MyPalette.getColorFromCount(e.colorNo!)),
                                    ),
                                    8.widthBox,
                                    e.name.text.make()
                                  ],
                                )))
                            .toList()
                      ],
                      name: 'label'.translate,
                      title: 'label'.translate,
                      iconData: Icons.label,
                      initialValue: List<String>.from(_controller.filterOption!['expensesLabelList']),
                      onChanged: (value) {
                        log(value);
                        _controller.filterOption!['expensesLabelList'] = value;
                      },
                    ).pb8
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: [
              MySwitch(
                padding: EdgeInsets.zero,
                initialValue: _controller.filterOption!['virmanEnable'],
                name: "vmenuhint".translate,
                iconData: MdiIcons.eyeCheck,
                color: Colors.deepPurple,
                onChanged: (value) {
                  _controller.filterOption!['virmanEnable'] = value;
                },
              ),
              MyMultiSelect(
                context: context,
                items: [MyMultiSelectItem('all', 'all'.translate), ...Iterable.generate(maxCaseNumber).map((i) => MyMultiSelectItem((i + 1).toString(), AppVar.appBloc.schoolInfoService!.singleData!.caseName(i + 1)!)).toList()],
                name: 'casenumber'.translate,
                title: 'casenumber'.translate,
                iconData: Icons.label,
                initialValue: List<String>.from(_controller.filterOption!['caseList']),
                onChanged: (value) {
                  _controller.filterOption!['caseList'] = value;
                },
              ).pb8
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconTextfield(
                toolTip: 'addfavorites'.translate,
                saveText: Words.save,
                textfieldHint: 'name'.translate,
                afterSave: (text) {
                  Fav.securePreferences.addItemToMap('finanacialAnalysisFav', text, _controller.filterOption);
                  _controller.update();
                },
                validatorRules: ValidatorRules(minLength: 5),
                icon: MdiIcons.starPlus.icon.color(Fav.design.primaryText).make(),
              ),
              MyRaisedButton(
                text: 'showrecords'.translate,
                onPressed: _makeFilterButtonPressed,
              ),
            ],
          )
        ],
      ).p16,
    );
  }
}
