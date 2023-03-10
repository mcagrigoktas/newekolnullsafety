import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myfileuploadwidget.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import '../../../../supermanager/supermanagerbloc.dart';
import '../answerkeyspage/answerkeydefine.dart';
import '../answerkeyspage/controller.dart';
import '../helper.dart';
import '../onlineexam/controller.dart';
import '../onlineexam/layout.dart';
import 'bookletdefine/controller.dart';
import 'bookletdefine/layout.dart';
import 'controller.dart';
import 'model.dart';

class ExamDefine extends StatelessWidget {
  final EvaulationUserType userType;
  ExamDefine(this.userType);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamController>(
        init: ExamController(userType),
        builder: (controller) {
          final Widget _newButton = AddIcon(onPressed: controller.addItem);

          final Widget _middle = (controller.dataIsNew
                  ? 'new'.translate
                  : controller.selectedItem != null
                      ? controller.selectedItem!.name
                      : 'evaulationexams'.translate)
              .text
              .bold
              .color(Fav.design.primary)
              .maxLines(1)
              .fontSize(18)
              .autoSize
              .make();

          final _topBar = controller.dataIsNew
              ? RTopBar.sameAll(leadingIcon: Icons.clear_rounded, leadingTitle: 'cancelnewentry'.translate, backButtonPressed: controller.deSelectItem, middle: _middle)
              : RTopBar(
                  mainLeadingTitle: 'back'.translate,
                  leadingTitleMainEqualBoth: true,
                  detailBackButtonPressed: controller.deSelectItem,
                  detailLeadingTitle: 'evaulationexams'.translate,
                  bothMiddle: _middle,
                  mainMiddle: _middle,
                  detailMiddle: _middle,
                  detailTrailingActions: [_newButton],
                  mainTrailingActions: [_newButton],
                  bothTrailingActions: [_newButton],
                );
          Body? _leftBody;
          Body? _rightBody;
          if (controller.isPageLoading) {
            _leftBody = Body.child(child: MyProgressIndicator(isCentered: true));
          } else {
            final _finalExamList = controller.getFinalList();

            _leftBody = controller.dataIsNew == true
                ? null
                : Body.listviewBuilder(
                    pageStorageKey: 'userexamdefinelist',
                    listviewFirstWidget: Row(
                      children: [
                        Expanded(
                          child: MySearchBar(
                            onChanged: (text) {
                              controller.filteredText = text.toSearchCase();
                              controller.update();
                            },
                            resultCount: _finalExamList.length,
                            initialText: controller.filteredText,
                          ),
                        ),
                        QudsPopupButton(
                          child: Icons.filter_alt.icon.color(Fav.design.primaryText).make(),
                          backgroundColor: Fav.design.scaffold.background,
                          items: [
                            QudsPopupMenuWidget(builder: (ctx) {
                              return MyDateRangePicker(
                                value: controller.dateFilter,
                                firstDate: DateTime.now().subtract(Duration(days: 1500)),
                                lastDate: DateTime.now().add(Duration(days: 30)),
                                onChanged: (date) {
                                  controller.dateFilter = date;
                                  controller.update();
                                },
                                showResetButton: true,
                              );
                            }),
                            QudsPopupMenuWidget(builder: (ctx) {
                              return AdvanceDropdown<String?>(
                                name: 'examtype'.translate,
                                nullValueText: 'examtype'.translate,
                                initialValue: controller.filteredExamTypeKey,
                                searchbarEnableLength: 1000,
                                items: controller.allExamType.map((e) => DropdownItem(value: e.key, name: e.name)).toList()..insert(0, DropdownItem(value: null, name: 'all'.translate)),
                                onChanged: (value) {
                                  controller.filteredExamTypeKey = value;
                                  controller.update();
                                },
                              );
                            }),
                            QudsPopupMenuWidget(builder: (ctx) {
                              return MyMiniRaisedButton(
                                onPressed: Get.back,
                                text: 'back'.translate,
                              ).py4;
                            }),
                          ],
                        ),
                      ],
                    ).p4,
                    itemCount: _finalExamList.length,
                    itemBuilder: (context, index) {
                      var item = _finalExamList[index];
                      return MyCupertinoListTile(
                        onTap: () {
                          controller.selectItem(item);
                        },
                        maxLines: 2,
                        title: (controller.girisTuru != EvaulationUserType.school
                                ? ''
                                : item.userType == EvaulationUserType.school
                                    ? ''
                                    : '(*) ') +
                            item.name!,
                        isSelected: controller.selectedItem?.key == item.key,
                      );
                    },
                  );

            _rightBody = controller.dataIsNew == false && controller.selectedItem == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : Body.singleChildScrollView(
                    maxWidth: 720,
                    withKeyboardCloserGesture: true,
                    child: Column(
                      children: [
                        if (controller.girisTuru == EvaulationUserType.school && controller.selectedItem?.userType != EvaulationUserType.school)
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                alignment: Alignment.center,
                                decoration: ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)), color: Fav.design.primary),
                                child: ('(*) ' + "examdefineradmin".translate).text.color(Colors.white).center.make(),
                              ),
                              8.heightBox,
                              MyProgressButton(
                                onPressed: controller.copyExamGlobalToSchool,
                                label: 'copyexamtoschool'.translate,
                                isLoading: controller.isLoading,
                                mini: true,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        MyForm(
                          formKey: controller.formKey,
                          child: Column(
                            children: [
                              AbsorbPointer(
                                absorbing: controller.selectedItem != null && !controller.dataIsNew && !controller.elementCanBeChange(controller.selectedItem),
                                child: Card(
                                  color: Fav.design.card.background,
                                  child: Column(
                                    children: [
                                      'examinfos'.translate.text.bold.color(Fav.design.primaryText).make().py4,
                                      if (controller.girisTuru == EvaulationUserType.supermanager)
                                        MyMultiSelect(
                                          context: context,
                                          items: Get.find<SuperManagerController>().serverList!.map((e) => MyMultiSelectItem<String>(e.serverId!, e.schoolName!)).toList(),
                                          title: 'choosetarget'.translate,
                                          name: 'choosetarget'.translate,
                                          initialValue: controller.selectedItem?.kurumIdList ?? [],
                                          onSaved: (value) {
                                            controller.selectedItem!.kurumIdList = value;
                                          },
                                          validatorRules: ValidatorRules(minLength: 1),
                                          iconData: Icons.source,
                                        ),
                                      AnimatedGroupWidget(
                                        children: [
                                          //* Genel mudurlukten okula kopyalanan sinavlarin ismini degistirtmememk icin opacity be absorb yapildi
                                          Opacity(
                                            opacity: (controller.selectedItem?.key ?? '').startsWith('copy') ? 0.5 : 1.0,
                                            child: AbsorbPointer(
                                              absorbing: (controller.selectedItem?.key ?? '').startsWith('copy'),
                                              child: MyTextFormField(
                                                labelText: 'name'.translate,
                                                hintText: 'rememberthanhint'.translate,
                                                validatorRules: ValidatorRules(req: true, minLength: 4),
                                                iconData: Icons.nat,
                                                initialValue: controller.selectedItem?.name,
                                                onSaved: (value) => controller.selectedItem!.name = value,
                                              ),
                                            ),
                                          ),
                                          MyTextFormField(
                                            labelText: 'aciklama'.translate,
                                            hintText: 'rememberthanhint'.translate,
                                            validatorRules: ValidatorRules(),
                                            iconData: Icons.devices,
                                            initialValue: controller.selectedItem?.explanation,
                                            onSaved: (value) => controller.selectedItem!.explanation = value,
                                          ),
                                          MyDateTimePicker(
                                            title: 'date'.translate,
                                            firstYear: 2020,
                                            lastYear: 2030,
                                            initialValue: controller.selectedItem?.date ?? DateTime.now().millisecondsSinceEpoch,
                                            onSaved: (value) => controller.selectedItem?.date = value,
                                          ),
                                          controller.dataIsNew
                                              ? AdvanceDropdown<String?>(
                                                  searchbarEnableLength: 10,
                                                  name: 'examtype'.translate,
                                                  nullValueText: 'examtype'.translate,
                                                  initialValue: controller.selectedItem?.examType?.key,
                                                  items: controller.allExamType.map((e) => DropdownItem(value: e.key, name: e.name)).toList(),
                                                  validatorRules: ValidatorRules(req: true),
                                                  onSaved: (value) {
                                                    controller.selectedItem!.examTypeKey = value;
                                                    controller.selectedItem!.examTypeData = controller.allExamType.singleWhere((element) => element.key == value).mapForSave();
                                                  },
                                                )
                                              : Row(
                                                  children: [('examtype'.translate + ': ').text.bold.make(), Flexible(child: controller.selectedItem?.examType?.name?.text.color(Fav.design.primaryText).make() ?? SizedBox())],
                                                ).p16,
                                          controller.dataIsNew
                                              ? AdvanceDropdown<int>(
                                                  name: 'formtype'.translate,
                                                  initialValue: controller.selectedItem!.formTypeValue ?? 0,
                                                  items: [0, 1, 2]
                                                      .map((e) => DropdownItem(
                                                            value: e,
                                                            name: 'formtype$e'.translate,
                                                          ))
                                                      .toList(),
                                                  onSaved: (value) {
                                                    controller.selectedItem!.formTypeValue = value;
                                                  },
                                                )
                                              : Row(
                                                  children: [('formtype'.translate + ': ').text.bold.make(), Flexible(child: 'formtype${controller.selectedItem!.formTypeValue}'.translate.text.make())],
                                                ).px16.pb8,
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!controller.dataIsNew && controller.elementCanBeChange(controller.selectedItem))
                                Card(
                                  color: Fav.design.card.background,
                                  child: Column(
                                    children: [
                                      'settings'.translate.text.bold.color(Fav.design.primaryText).make().pb12,
                                      AnimatedGroupWidget(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Fav.to(AnswerKeyDefine(), binding: BindingsBuilder(() => Get.put<AnswerKeyController>(AnswerKeyController(controller.selectedItem, controller.girisTuru))));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(color: Colors.purple.withAlpha(20), borderRadius: BorderRadius.circular(16)),
                                              child: Column(
                                                children: [
                                                  8.heightBox,
                                                  'answerearningmenu'.translate.text.bold.make(),
                                                  Row(
                                                    children: [
                                                      (controller.selectedItem!.answerEarningData == null ? Icons.clear : Icons.done).icon.color(controller.selectedItem!.answerEarningData == null ? Colors.red : Colors.green).size(16).make(),
                                                      Expanded(child: (controller.selectedItem!.answerEarningData == null ? 'hasanswerdata1' : 'hasanswerdata2').translate.text.fontSize(12).make()),
                                                    ],
                                                  ),
                                                ],
                                              ).p8,
                                            ),
                                          ).p4,
                                          if (controller.selectedItem!.formType.isOpticFormActive)
                                            Column(
                                              children: [
                                                for (var s = 1; s < controller.selectedItem!.examType!.numberOfSeison! + 1; s++)
                                                  GestureDetector(
                                                    onTap: () async {
                                                      String? opticformKey = await controller.allOpticFormType.where((form) => form.examTypeKey == controller.selectedItem!.examTypeKey).fold<Map>({}, (p, e) => p..[e.key] = e.name! + '\n' + e.explanation!).selectOne(title: 'opticalforms'.translate);
                                                      if (opticformKey != null) {
                                                        controller.selectedItem!.opticFormKeyMap ??= {};
                                                        controller.selectedItem!.opticFormData ??= {};
                                                        controller.selectedItem!.opticFormKeyMap!['seison$s'] = opticformKey;
                                                        controller.selectedItem!.opticFormData!['seison$s'] = controller.allOpticFormType.singleWhere((element) => element.key == opticformKey).mapForSave();
                                                      }
                                                      controller.update();
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(color: Colors.purple.withAlpha(20), borderRadius: BorderRadius.circular(16)),
                                                      child: Column(
                                                        children: [
                                                          8.heightBox,
                                                          ('opticformtype'.translate + ' (${'seison'.translate}:$s)').text.bold.make(),
                                                          Row(
                                                            children: [
                                                              (controller.selectedItem!.opticForm(s) == null ? Icons.clear : Icons.done).icon.color(controller.selectedItem!.opticForm(s) == null ? Colors.red : Colors.green).size(16).make(),
                                                              Expanded(child: (controller.selectedItem!.opticForm(s) == null ? '----' : controller.selectedItem!.opticForm(s)!.name).text.fontSize(12).make()),
                                                            ],
                                                          ),
                                                        ],
                                                      ).p8,
                                                    ),
                                                  ).p4,
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ).p12,
                                ),
                              if (!controller.dataIsNew && controller.selectedItem!.formType.isOpticFormActive)
                                Card(
                                  color: Fav.design.card.background,
                                  child: Column(
                                    children: [
                                      'datfiles'.translate.text.bold.color(Fav.design.primaryText).make().pb12,
                                      for (var kN = 0; kN < controller.selectedItem!.kurumIdList!.length; kN++)
                                        if (controller.elementCanBeChange(controller.selectedItem) || (controller.girisTuru == EvaulationUserType.school && controller.selectedItem!.kurumIdList![kN] == AppVar.appBloc.hesapBilgileri.kurumID))
                                          Column(
                                            children: [
                                              if (controller.girisTuru != EvaulationUserType.school) controller.selectedItem!.kurumIdList![kN].text.bold.color(Fav.design.primaryText).make().p8,
                                              AnimatedGroupWidget(
                                                children: [
                                                  for (var sN = 1; sN < controller.selectedItem!.examType!.numberOfSeison! + 1; sN++)
                                                    Container(
                                                      decoration: BoxDecoration(color: Colors.blue.withAlpha(20), borderRadius: BorderRadius.circular(16)),
                                                      child: Column(
                                                        children: [
                                                          8.heightBox,
                                                          ('seison'.translate + ' $sN').text.bold.make(),
                                                          FileUploadWidget(
                                                            readAsString: true,
                                                            saveLocation: controller.girisTuru == EvaulationUserType.school
                                                                ? '${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/ExamFiles/${controller.selectedItem!.key}'
                                                                : '${Get.find<SuperManagerController>().hesapBilgileri.kurumID}/ExamFiles/${controller.selectedItem!.key}',
                                                            initialValue: controller.selectedItem != null &&
                                                                    // controller.selectedItem!.seisonDatFiles != null &&
                                                                    // controller.selectedItem!.kurumIdList![kN] != null &&
                                                                    controller.selectedItem!.seisonDatFiles[controller.selectedItem!.kurumIdList![kN]] != null &&
                                                                    controller.selectedItem!.seisonDatFiles[controller.selectedItem!.kurumIdList![kN]]!['seison$sN'] != null &&
                                                                    controller.selectedItem!.seisonDatFiles[controller.selectedItem!.kurumIdList![kN]]!['seison$sN']!.url.safeLength > 6
                                                                ? FileResult(name: controller.selectedItem!.seisonDatFiles[controller.selectedItem!.kurumIdList![kN]]!['seison$sN']!.name!, url: controller.selectedItem!.seisonDatFiles[controller.selectedItem!.kurumIdList![kN]]!['seison$sN']!.url!)
                                                                : null,
                                                            onSaved: (value) {
                                                              if (value == null) {
                                                                controller.selectedItem?.seisonDatFiles[controller.selectedItem!.kurumIdList![kN]] ??= {};
                                                                controller.selectedItem?.seisonDatFiles[controller.selectedItem!.kurumIdList![kN]]!['seison$sN'] = null;
                                                              } else {
                                                                controller.selectedItem?.seisonDatFiles[controller.selectedItem!.kurumIdList![kN]] ??= {};
                                                                controller.selectedItem?.seisonDatFiles[controller.selectedItem!.kurumIdList![kN]]!['seison$sN'] ??= ExamFile(seisonNo: sN);
                                                                controller.selectedItem?.seisonDatFiles[controller.selectedItem!.kurumIdList![kN]]!['seison$sN']?.url = value.url;
                                                                controller.selectedItem?.seisonDatFiles[controller.selectedItem!.kurumIdList![kN]]!['seison$sN']?.name = value.name;
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ).p4
                                                ],
                                              ),
                                            ],
                                          ),
                                    ],
                                  ).p12,
                                ),
                              if (!controller.dataIsNew && controller.elementCanBeChange(controller.selectedItem) && controller.selectedItem!.formType.isOnlineFormActive)
                                Card(
                                  color: Fav.design.card.background,
                                  child: Column(
                                    children: [
                                      for (var s = 1; s < controller.selectedItem!.examType!.numberOfSeison! + 1; s++)
                                        GestureDetector(
                                          onTap: () async {
                                            controller.selectedItem!.bookLetsData ??= {};
                                            var result = await Fav.guardTo(OnlineFormDefine(),
                                                binding: BindingsBuilder(() => Get.put<OnlineFormController>(OnlineFormController(controller.selectedItem!.bookLetsData!['seison$s'], controller.selectedItem!.examType, controller.girisTuru, controller.selectedItem, s))));
                                            if (result == true) {
                                              await controller.saveItem();
                                            }
                                            controller.update();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(color: Colors.purple.withAlpha(20), borderRadius: BorderRadius.circular(16)),
                                            child: Column(
                                              children: [
                                                8.heightBox,
                                                ('bookletsettings'.translate + ' (${'seison'.translate}:$s)').text.bold.make(),
                                                Row(
                                                  children: [
                                                    (controller.selectedItem!.onlineForm(s) == null ? Icons.clear : Icons.done).icon.color(controller.selectedItem!.onlineForm(s) == null ? Colors.red : Colors.green).size(16).make(),
                                                    Expanded(child: (controller.selectedItem!.onlineForm(s) == null ? 'bookletsettings1'.translate : 'bookletsettings2'.translate).text.fontSize(12).make()),
                                                  ],
                                                ),
                                                if (controller.selectedItem!.onlineForm(s) != null)
                                                  MyFlatButton(
                                                      onPressed: () {
                                                        Map data = {};
                                                        data['examType'] = controller.selectedItem!.examType!.mapForStudent();
                                                        data['onlineForms'] ??= {};
                                                        data['onlineForms']['seison$s'] = controller.selectedItem!.onlineForm(s)!.mapForStudent();
                                                        Fav.guardTo(OlineExamMain(), binding: BindingsBuilder(() => Get.put<OnlineExamController>(OnlineExamController(data, controller.selectedItem!.key!, s, isBookletReviewing: true))));
                                                      },
                                                      text: 'checkbooklet'.translate)
                                              ],
                                            ).p8,
                                          ),
                                        ).p4,
                                    ],
                                  ).p12,
                                ),
                              if (!controller.dataIsNew)
                                AbsorbPointer(
                                  absorbing: !controller.elementCanBeChange(controller.selectedItem),
                                  child: Card(
                                    color: Fav.design.card.background,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            'examfiles'.translate.text.bold.color(Fav.design.primaryText).make(),
                                            AddIcon(onPressed: controller.addexambookletfile),
                                          ],
                                        ).pb12,
                                        AnimatedGroupWidget(
                                          children: [
                                            for (var i = 0; i < controller.selectedItem!.examBookLetFiles.length; i++)
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withAlpha(20),
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: MyTextFormField(
                                                            labelText: 'name'.translate,
                                                            initialValue: controller.selectedItem!.examBookLetFiles[i].name,
                                                            validatorRules: ValidatorRules(req: true, minLength: 4),
                                                            onSaved: (value) {
                                                              controller.selectedItem!.examBookLetFiles[i].name = value;
                                                            },
                                                            iconData: Icons.account_balance_sharp,
                                                          ),
                                                        ),
                                                        Icons.delete.icon
                                                            .onPressed(() async {
                                                              var sure = await Over.sure();
                                                              if (sure) {
                                                                controller.selectedItem!.examBookLetFiles.removeAt(i);
                                                                controller.update();
                                                              }
                                                            })
                                                            .color(Colors.red)
                                                            .make()
                                                      ],
                                                    ),
                                                    if (controller.selectedItem!.examBookLetFiles[i].examFileType == ExamFileType.file)
                                                      FileUploadWidget(
                                                        saveLocation: controller.girisTuru == EvaulationUserType.school
                                                            ? '${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/ExamFiles/${controller.selectedItem!.key}'
                                                            : '${Get.find<SuperManagerController>().hesapBilgileri.kurumID}/ExamFiles/${controller.selectedItem!.key}',
                                                        initialValue: (controller.selectedItem!.examBookLetFiles[i].url).safeLength > 6 ? FileResult(url: controller.selectedItem!.examBookLetFiles[i].url!, name: controller.selectedItem!.examBookLetFiles[i].name!) : null,
                                                        onSaved: (value) {
                                                          controller.selectedItem!.examBookLetFiles[i].url = value!.url;
                                                          //   controller.selectedItem.examBookLetFiles[i].name = value[1];
                                                        },
                                                      ),
                                                    if (controller.selectedItem!.examBookLetFiles[i].examFileType == ExamFileType.url)
                                                      MyTextFormField(
                                                        labelText: 'link'.translate,
                                                        initialValue: controller.selectedItem!.examBookLetFiles[i].url,
                                                        validatorRules: ValidatorRules(req: true, minLength: 4),
                                                        onSaved: (value) {
                                                          controller.selectedItem!.examBookLetFiles[i].url = value;
                                                        },
                                                        iconData: Icons.web,
                                                      ),
                                                    if (controller.selectedItem!.examBookLetFiles[i].examFileType == ExamFileType.youtubeVideo)
                                                      MyTextFormField(
                                                        labelText: 'youtubelink'.translate,
                                                        initialValue: controller.selectedItem!.examBookLetFiles[i].url,
                                                        validatorRules: ValidatorRules(req: true, minLength: 4),
                                                        onSaved: (value) {
                                                          controller.selectedItem!.examBookLetFiles[i].url = value;
                                                        },
                                                        iconData: Icons.web,
                                                      ),
                                                  ],
                                                ),
                                              ).p4
                                          ],
                                        ),
                                      ],
                                    ).p12,
                                  ),
                                ),
                              if (!controller.dataIsNew)
                                Card(
                                  color: Fav.design.card.background,
                                  child: Column(
                                    children: [
                                      'actions'.translate.text.bold.color(Fav.design.primaryText).make().pb12,
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withAlpha(20),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          runSpacing: 16,
                                          spacing: 16,
                                          children: [
                                            if (controller.girisTuru == EvaulationUserType.school) MyRaisedButton(onPressed: controller.makeannouncement, text: 'makeannouncement'.translate),
                                            MyRaisedButton(onPressed: controller.elementCanBeChange(controller.selectedItem) ? controller.calcResult : null, text: 'calcresult'.translate),
                                            MyRaisedButton(onPressed: controller.viewResult, text: 'viewexamresult'.translate),
                                            MyRaisedButton(onPressed: controller.sendResult, text: 'sendexamresult'.translate),
                                          ],
                                        ).p8,
                                      ).pb4
                                    ],
                                  ).p12,
                                ),
                              16.heightBox
                            ],
                          ),
                        ),
                      ],
                    ));
          }

          RBottomBar? _bottomBar;
          if (controller.selectedItem != null) {
            Widget _bottomChild = Row(
              children: [
                if (controller.selectedItem != null && !controller.dataIsNew)
                  MyPopupMenuButton(
                    itemBuilder: (context) {
                      return <PopupMenuEntry>[
                        if (controller.elementCanBeChange(controller.selectedItem)) PopupMenuItem(value: 0, child: Text(Words.delete)),
                      ];
                    },
                    child: Container(margin: const EdgeInsets.only(left: 16), padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, color: Fav.design.customDesign4.primary), child: const Icon(Icons.more_vert, color: Colors.white)),
                    onSelected: (value) async {
                      if (value == 0) {
                        var sure = await Over.sure(message: controller.selectedItem!.name! + '\n' + 'deleterecorderr'.translate);
                        if (sure == true) await controller.deleteItem();
                      }
                    },
                  ),
                const Spacer(),
                MyProgressButton(onPressed: controller.saveItem, label: Words.save, isLoading: controller.isLoading).pr12,
              ],
            );
            _bottomBar = RBottomBar(
              bothChild: _bottomChild,
              detailChild: _bottomChild,
            );
          }
          return AppResponsiveScaffold(
            topBar: _topBar,
            leftBody: _leftBody,
            rightBody: _rightBody,
            visibleScreen: controller.visibleScreen,
            bottomBar: _bottomBar,
          );
        });
  }
}
