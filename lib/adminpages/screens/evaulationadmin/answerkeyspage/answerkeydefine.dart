import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../../localization/usefully_words.dart';
import '../../../../supermanager/supermanagerbloc.dart';
import '../helper.dart';
import 'controller.dart';
import 'earning_list_define/layout.dart';
import 'model.dart';

class AnswerKeyDefine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AnswerKeyController>(
      builder: (controller) {
        return AppScaffold(
          topBar: TopBar(leadingTitle: controller.exam!.name, trailingActions: [
            MyPopupMenuButton(
              itemBuilder: (context) {
                return <PopupMenuEntry>[
                  PopupMenuItem(value: 0, child: Text('sampleexcel'.translate)),
                  PopupMenuItem(value: 1, child: Text('fromexcell'.translate)),
                ];
              },
              child: Icon(Icons.more_vert, color: Fav.design.appBar.text).paddingOnly(right: 8),
              onSelected: (value) {
                if (value == 0) {
                  controller.downloadExcelFile();
                } else if (value == 1) {
                  controller.uploadExcelFile();
                }
              },
            )
          ]),
          topActions: TopActionsTitleWithChild(
              title: TopActionsTitle(title: 'answerearningmenu'.translate),
              child: Group2Widget(
                leftItemPercent: 33,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AdvanceDropdown(
                          padding: EdgeInsets.zero,
                          name: 'bookletcount'.translate,
                          initialValue: controller.bookLetCounnt,
                          onChanged: controller.changeBookLetCount,
                          items: [1, 2, 3, 4].map((e) => DropdownItem(value: e, name: e.toString())).toList(),
                        ),
                      ),
                      16.widthBox,
                      Expanded(
                        child: Column(
                          children: [
                            'earningsIsActive'.translate.text.fontSize(10).make(),
                            CupertinoSlidingSegmentedControl<bool>(
                              children: {
                                false: 'no'.translate.text.make(),
                                true: 'yes'.translate.text.make(),
                              },
                              groupValue: controller.earningsIsActive,
                              onValueChanged: controller.changeEarningIsActive,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AdvanceDropdown(
                    padding: Inset.v(8),
                    name: 'answerkeyq1'.translate,
                    initialValue: controller.answerKeyLocation,
                    items: {
                      AnswerKeyLocation.menu: 'answerkeyq10'.translate,
                      AnswerKeyLocation.opticForm: 'answerkeyq11'.translate,
                    }
                        .entries
                        .map((e) => DropdownItem(
                              name: e.value,
                              value: e.key,
                            ))
                        .toList(),
                    onChanged: controller.changeAnswerKeyLocation,
                  ),
                ],
              )),
          body: Body.singleChildScrollView(child: AnswerKeyDetail()),
          bottomBar: BottomBar.saveButton(onPressed: controller.save, isLoading: controller.isLoading),
        );
      },
    );
  }
}

class AnswerKeyDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AnswerKeyController controller = Get.find();

    return MyForm(
        formKey: controller.formKey,
        child: Column(
          children: [
            for (var i = 1; i < controller.bookLetCounnt! + 1; i++)
              Card(
                color: Fav.design.card.background,
                margin: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    MyTextFormField(
                      labelText: 'name'.translate,
                      validatorRules: ValidatorRules(req: true, minLength: 1),
                      initialValue: controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + 'name'] ?? controller.noToBooklet(i),
                      onSaved: (value) {
                        controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + 'name'] = value.toString().trim();
                      },
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var j = 0; j < controller.examType!.lessons!.length; j++)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              controller.examType!.lessons![j].name.firstXcharacter(8).text.color(Colors.white).make().stadium(),
                              if (controller.answerKeyLocation == AnswerKeyLocation.menu)
                                MyTextFormFieldWithCounter(
                                  labelText: 'answerkey'.translate,
                                  hintText: 'ABCDDCBABBA',
                                  validatorRules: ValidatorRules(req: true, minLength: 1),
                                  initialValue: controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + controller.examType!.lessons![j].key! + 'answers'],
                                  onSaved: (value) {
                                    controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + controller.examType!.lessons![j].key! + 'answers'] = value;
                                  },
                                ),
                              if (controller.answerKeyLocation == AnswerKeyLocation.menu)
                                for (var t = 0; t < controller.examType!.lessons![j].wQuestionCount!; t++)
                                  MyTextFormField(
                                    labelText: 'W${t + 1}',
                                    hintText: '....',
                                    validatorRules: ValidatorRules(req: true, minLength: 1),
                                    initialValue: controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + controller.examType!.lessons![j].key! + '-w${t + 1}' + 'answers'],
                                    onSaved: (value) {
                                      controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + controller.examType!.lessons![j].key! + '-w${t + 1}' + 'answers'] = value;
                                    },
                                  ),
                              if (controller.earningsIsActive!)
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 300),
                                  child: Builder(builder: (context) {
                                    var earningList = (controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + controller.examType!.lessons![j].key! + 'earnings'] as String? ?? '').split('\n');
                                    earningList.removeWhere((element) => element.safeLength < 1);
                                    final _examTypeLesson = controller.examType!.lessons![j];
                                    var fullEarningList = (controller.earningListContent[j] ?? _examTypeLesson.earninglist)!.split('\n');
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            'earninglist'.translate.text.bold.make(),
                                            16.widthBox,
                                            Expanded(
                                              key: ValueKey(controller.drowdownValueKeyPrefix + '$j'),
                                              child: AdvanceDropdown(
                                                name: 'chooselist'.translate,
                                                items: [
                                                  DropdownItem(name: 'recommendedlist'.translate, value: 'original'),
                                                  ...controller.allEarningItems!.dataList.map((e) {
                                                    return DropdownItem(name: e.name, value: e.key);
                                                  }).toList()
                                                ],
                                                // initialValue: 'original',
                                                onChanged: (value) {
                                                  controller.earningListContent[j] = controller.allEarningItems!.dataList.singleWhereOrNull((element) => element.key == value)?.content ?? _examTypeLesson.earninglist;
                                                  controller.update();
                                                },
                                                extraWidget: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    MyMiniRaisedButton(
                                                      text: 'earninglistdefine'.translate,
                                                      onPressed: () async {
                                                        await Fav.to(EarningList(
                                                          controller.allEarningItems,
                                                          controller.girisTuru,
                                                          controller.girisTuru == EvaulationUserType.supermanager ? Get.find<SuperManagerController>().hesapBilgileri.kurumID : null,
                                                        ));
                                                        controller.drowdownValueKeyPrefix = 6.makeKey;
                                                        controller.update();
                                                      },
                                                    ).p8,
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Flexible(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Card(
                                                color: Fav.design.card.background,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      for (var k = 0; k < fullEarningList.length; k++)
                                                        InkWell(
                                                            onTap: () {
                                                              controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + controller.examType!.lessons![j].key! + 'earnings'] ??= '';
                                                              controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + controller.examType!.lessons![j].key! + 'earnings'] += fullEarningList[k] + '\n';
                                                              controller.update();
                                                            },
                                                            child: fullEarningList[k].text.make())
                                                    ],
                                                  ).p4,
                                                ),
                                              )),
                                              '->'.text.bold.make(),
                                              Expanded(
                                                child: Card(
                                                  color: Fav.design.card.background,
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        for (var k = 0; k < earningList.length; k++)
                                                          Row(
                                                            children: [
                                                              ((k + 1).toString() + ': ').text.bold.color(Fav.design.primaryText).make(),
                                                              earningList[k].text.make(),
                                                            ],
                                                          ),
                                                        8.heightBox,
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            MyMiniRaisedButton(
                                                                onPressed: () {
                                                                  String? earningText = controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + controller.examType!.lessons![j].key! + 'earnings'];
                                                                  if (earningText.safeLength > 1) {
                                                                    final splittedtList = earningText!.split('\n');
                                                                    final text = splittedtList.length < 2 ? '' : splittedtList.take(splittedtList.length - 2).join('\n') + '\n';
                                                                    controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + controller.examType!.lessons![j].key! + 'earnings'] = text;
                                                                    controller.update();
                                                                  }
                                                                },
                                                                text: Words.delete),
                                                            MyMiniRaisedButton(
                                                                onPressed: () {
                                                                  controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + controller.examType!.lessons![j].key! + 'earnings'] = '';
                                                                  controller.update();
                                                                },
                                                                text: 'clear'.translate),
                                                          ],
                                                        ),
                                                      ],
                                                    ).p4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              if (controller.earningsIsActive!)
                                for (var t = 0; t < controller.examType!.lessons![j].wQuestionCount!; t++)
                                  Padding(
                                    key: ValueKey(controller.drowdownValueKeyPrefix + 'w$j$t'),
                                    padding: EdgeInsets.zero,
                                    child: AdvanceDropdown(
                                      name: 'W${t + 1}',
                                      validatorRules: ValidatorRules(req: true, minLength: 1),
                                      items: (controller.earningListContent[j] ?? controller.examType!.lessons![j].earninglist)!
                                          //controller.examType.lessons[j].earninglist
                                          .split('\n')
                                          .map((e) => DropdownItem(
                                                name: e,
                                                value: e,
                                              ))
                                          .toList(),
                                      initialValue: controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + controller.examType!.lessons![j].key! + '-w${t + 1}' + 'earnings'],
                                      onSaved: (value) {
                                        controller.answerEarningMap!.datas['bookLet${controller.noToBooklet(i)}' + controller.examType!.lessons![j].key! + '-w${t + 1}' + 'earnings'] = value;
                                      },
                                    ),
                                  ),
                            ],
                          )
                      ],
                    )
                  ],
                ).p8,
              ),
            'wrongquestionhint'.translate.text.color(Fav.design.primaryText.withAlpha(200)).center.make()
          ],
        )).py8;
  }
}
