import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../localization/usefully_words.dart';
import '../../../../screens/managerscreens/registrymenu/copy_another_term_helper.dart';
import '../helper.dart';
import 'controller.dart';
import 'model.dart';

class ExamTypeDefine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var islargeScreen = context.screenWidth > 600;

    final Widget copyAnotherTermWidget = MyPopupMenuButton(
      itemBuilder: (context) {
        return <PopupMenuEntry>[
          PopupMenuItem(value: 3, child: Text('copyanotherterm'.translate)),
        ];
      },
      child: Icon(Icons.more_vert, color: Fav.design.appBar.text).paddingOnly(top: 0, right: 8, bottom: 0, left: 0),
      onSelected: (value) {
        if (value == 3) {
          CopyFromAnotherTermHelper.copyExamType();
        }
      },
    );

    return GetBuilder<ExamTypeController>(
      builder: (controller) {
        return MyResponsiveScaffold(
          appBar: MyAppBar(
            visibleBackButton: true,
            title: 'Exam Type List',
            backButtonPressed: () {
              if (islargeScreen || controller.visibleScreen == VisibleScreen.main) {
                Get.back();
              } else {
                controller.deSelectItem();
              }
            },
            trailingWidgets: [Icons.add.icon.color(Fav.design.appBar.text).onPressed(controller.addItem).make(), if (controller.girisTuru == EvaulationUserType.school) copyAnotherTermWidget],
          ),
          mainScreen: ExamTypeList(),
          detailScreen: ExamTypeDetail(),
          visibleScreen: controller.visibleScreen,
        );
      },
    );
  }
}

class ExamTypeList extends StatelessWidget {
  ExamTypeList();

  @override
  Widget build(BuildContext context) {
    final ExamTypeController controller = Get.find();
    var islargeScreen = context.screenWidth > 600;

    final filteredList = controller.allExamType.where(controller.elementCanBeChange).toList();
    if (filteredList.isEmpty) {
      return EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS);
    }
    return ListView.builder(
      key: const PageStorageKey('adminexamtypedefinelist'),
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: islargeScreen ? 8.0 : 16.0),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        var item = filteredList[index];
        return MyCupertinoListTile(
          onTap: () {
            controller.selectItem(item);
          },
          title: item.name,
          isSelected: controller.selectedItem?.key == item.key,
        );
      },
    );
  }
}

class ExamTypeDetail extends StatelessWidget {
  ExamTypeDetail();

  @override
  Widget build(BuildContext context) {
    final ExamTypeController controller = Get.find();

    if (controller.pageLoading) return MyProgressIndicator(isCentered: true);

    if (!controller.dataIsNew && controller.selectedItem == null) {
      return EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST);
    }
    return Column(
      children: [
        if (controller.dataIsNew)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            alignment: Alignment.center,
            decoration: ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)), color: Fav.design.primary),
            child: "new".translate.text.color(Colors.white).make(),
          ),
        Expanded(
          child: MyForm(
            formKey: controller.formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  AnimatedGroupWidget(
                    children: [
                      MyTextFormField(
                        labelText: 'Exam name',
                        validatorRules: ValidatorRules(req: true, minLength: 3),
                        iconData: Icons.nat,
                        initialValue: controller.selectedItem?.name,
                        onSaved: (value) => controller.selectedItem!.name = value,
                      ),
                      MyTextFormField(
                        labelText: 'Explanation',
                        validatorRules: ValidatorRules(req: true, minLength: 20),
                        iconData: Icons.devices,
                        initialValue: controller.selectedItem?.explanation,
                        onSaved: (value) => controller.selectedItem!.explanation = value,
                      ),
                      if (controller.advanceMenu)
                        Opacity(
                          opacity: controller.dataIsNew ? 1.0 : 0.5,
                          child: AbsorbPointer(
                            absorbing: !controller.dataIsNew,
                            child: MyTextFormField(
                              labelText: 'Country',
                              hintText: 'Turkey=tr,',
                              validatorRules: ValidatorRules(req: true, minLength: 2),
                              iconData: Icons.accessible_forward_sharp,
                              initialValue: controller.selectedItem?.countryCode,
                              onSaved: (value) => controller.selectedItem!.countryCode = value,
                            ),
                          ),
                        ),
                      if (controller.advanceMenu)
                        Opacity(
                          opacity: controller.dataIsNew ? 1.0 : 0.5,
                          child: AbsorbPointer(
                            absorbing: !controller.dataIsNew,
                            child: MyDropDownField(
                              name: 'seisoncount'.translate,
                              validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: 1),
                              iconData: Icons.alt_route_outlined,
                              initialValue: controller.selectedItem?.numberOfSeison ?? 1,
                              onSaved: (value) => controller.selectedItem!.numberOfSeison = value,
                              canvasColor: Fav.design.dropdown.canvas,
                              items: [1, 2, 3, 4, 5].map((e) => DropdownMenuItem(value: e, child: e.toString().text.color(Fav.design.dropdown.text).make())).toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                  AbsorbPointer(
                    absorbing: !controller.dataIsNew,
                    child: Row(
                      children: ['Lessons'.text.bold.make(), 8.widthBox, Icons.add_box_rounded.icon.color(Fav.design.primaryText).onPressed(controller.addNewLesson).make()],
                    ).px12,
                  ),
                  ...(controller.selectedItem!.lessons ?? <ExamTypeLesson>[])
                      .map<Widget>((e) => Container(
                            padding: const EdgeInsets.all(4),
                            color: Fav.design.primaryText.withAlpha(10),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Opacity(
                                        opacity: controller.dataIsNew ? 1.0 : 0.5,
                                        child: AbsorbPointer(
                                          absorbing: !controller.dataIsNew,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: MyTextFormField(
                                                  padding: EdgeInsets.zero,
                                                  labelText: 'Lesson name',
                                                  validatorRules: ValidatorRules(req: true, minLength: 4),
                                                  initialValue: e.name,
                                                  onSaved: (value) => e.name = value,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: MyDropDownField(
                                                  name: 'Number of Options',
                                                  validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: 2),
                                                  initialValue: e.numberOfOptions ?? 5,
                                                  onSaved: (value) => e.numberOfOptions = value,
                                                  canvasColor: Fav.design.dropdown.canvas,
                                                  items: [3, 4, 5].map((e) => DropdownMenuItem(value: e, child: e.toString().text.color(Fav.design.dropdown.text).make())).toList(),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: MyDropDownField(
                                                  name: 'Right Wrong Rate',
                                                  validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: 0),
                                                  initialValue: e.rightWrongRate ?? 4,
                                                  onSaved: (value) => e.rightWrongRate = value,
                                                  canvasColor: Fav.design.dropdown.canvas,
                                                  items: [0, 1, 2, 3, 4, 5].map((e) => DropdownMenuItem(value: e, child: e.toString().text.color(Fav.design.dropdown.text).make())).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      4.heightBox,
                                      Opacity(
                                        opacity: controller.dataIsNew ? 1.0 : 0.5,
                                        child: AbsorbPointer(
                                          absorbing: !controller.dataIsNew,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  children: [
                                                    MyTextFormField(
                                                      padding: EdgeInsets.zero,
                                                      labelText: 'Question count',
                                                      validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: 1),
                                                      initialValue: e.questionCount.toString(),
                                                      onSaved: (value) => e.questionCount = int.parse(value!),
                                                    ),
                                                    12.heightBox,
                                                    if (controller.advanceMenu)
                                                      MyTextFormField(
                                                        padding: EdgeInsets.zero,
                                                        labelText: 'Formule Key',
                                                        initialValue: e.formuleKey,
                                                        onSaved: (value) => e.formuleKey = value,
                                                        validatorRules: ValidatorRules(req: true, minLength: 1, maxLength: 1),
                                                      )
                                                  ],
                                                ),
                                              ),
                                              8.widthBox,
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  children: [
                                                    MyTextFormField(
                                                      padding: EdgeInsets.zero,
                                                      labelText: 'WQ count',
                                                      validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: 0),
                                                      initialValue: e.wQuestionCount.toString(),
                                                      onSaved: (value) => e.wQuestionCount = int.parse(value!),
                                                    ),
                                                    12.heightBox,
                                                    if (controller.advanceMenu)
                                                      MyTextFormField(
                                                        padding: EdgeInsets.zero,
                                                        labelText: 'W Formule Key',
                                                        initialValue: e.wFormuleKey,
                                                        onSaved: (value) => e.wFormuleKey = value,
                                                        validatorRules: ValidatorRules(req: true, minLength: 1, maxLength: 1),
                                                      )
                                                  ],
                                                ),
                                              ),
                                              8.widthBox,
                                              if (controller.advanceMenu)
                                                Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    children: [
                                                      MyTextFormField(
                                                        padding: EdgeInsets.zero,
                                                        labelText: 'Group Key',
                                                        initialValue: e.groupKey,
                                                        onSaved: (value) => e.groupKey = value,
                                                        validatorRules: ValidatorRules(req: true, minLength: 1, maxLength: 1),
                                                      ),
                                                      12.heightBox,
                                                      MyDropDownField(
                                                        padding: EdgeInsets.zero,
                                                        name: 'Seison No',
                                                        validatorRules: ValidatorRules(req: true, mustNumber: true, minValue: 1),
                                                        initialValue: e.seisonNo,
                                                        onSaved: (value) => e.seisonNo = value,
                                                        canvasColor: Fav.design.dropdown.canvas,
                                                        items: [1, 2, 3, 4, 5].map((e) => DropdownMenuItem(value: e, child: e.toString().text.color(Fav.design.dropdown.text).make())).toList(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                8.widthBox,
                                Expanded(
                                  flex: 2,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 220),
                                    child: MyTextFormField(
                                      padding: EdgeInsets.zero,
                                      maxLines: null,
                                      labelText: 'Earning List',
                                      initialValue: e.earninglist,
                                      onSaved: (value) => e.earninglist = value,
                                      validatorRules: ValidatorRules(req: false),
                                    ).px4,
                                  ),
                                )
                              ],
                            ),
                          ).py8)
                      .toList(),
                  if (controller.advanceMenu)
                    Row(
                      children: ['Scoring'.text.bold.make(), 8.widthBox, Icons.add_box_rounded.icon.color(Fav.design.primaryText).onPressed(controller.addNewScoring).make()],
                    ).px12,
                  if (controller.advanceMenu)
                    ...(controller.selectedItem!.scoring ?? <Scoring>[])
                        .map<Widget>((e) => Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: MyTextFormField(
                                    padding: EdgeInsets.zero,
                                    labelText: 'Scoring name',
                                    validatorRules: ValidatorRules(req: true, minLength: 4),
                                    initialValue: e.name,
                                    onSaved: (value) => e.name = value,
                                  ).px4,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: MyTextFormField(
                                    padding: EdgeInsets.zero,
                                    labelText: 'Formule',
                                    validatorRules: ValidatorRules(req: true, minLength: 4),
                                    initialValue: e.formule,
                                    onSaved: (value) => e.formule = value,
                                  ).px4,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: MyTextFormField(
                                    padding: EdgeInsets.zero,
                                    labelText: 'Group Key',
                                    initialValue: e.groupKey,
                                    onSaved: (value) => e.groupKey = value,
                                    validatorRules: ValidatorRules(req: true, minLength: 1, maxLength: 1),
                                  ).px4,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: MyTextFormField(
                                    padding: EdgeInsets.zero,
                                    labelText: 'Max Value',
                                    initialValue: e.maxValue.toString(),
                                    onSaved: (value) => e.maxValue = double.tryParse(value!),
                                    validatorRules: ValidatorRules(req: true, minLength: 1, mustNumber: true),
                                  ).px4,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: MyTextFormField(
                                    padding: EdgeInsets.zero,
                                    labelText: 'Min Value',
                                    initialValue: e.minValue.toString(),
                                    onSaved: (value) => e.minValue = double.tryParse(value!),
                                    validatorRules: ValidatorRules(req: true, minLength: 1, mustNumber: true),
                                  ).px4,
                                ),
                              ],
                            ).py4)
                        .toList(),
                  8.heightBox,
                  if (controller.advanceMenu)
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: MyTextFormField(
                            padding: EdgeInsets.zero,
                            labelText: 'Lesson layout code',
                            initialValue: controller.selectedItem?.lessonLayoutCode,
                            onSaved: (value) => controller.selectedItem?.lessonLayoutCode = value,
                            validatorRules: ValidatorRules(req: true, minLength: 1, maxLength: 20),
                          ).px4,
                        ),
                        Expanded(
                          flex: 1,
                          child: MyTextFormField(
                            padding: EdgeInsets.zero,
                            labelText: 'Score layout code',
                            initialValue: controller.selectedItem?.scoreLayoutCode,
                            onSaved: (value) => controller.selectedItem?.scoreLayoutCode = value,
                            validatorRules: ValidatorRules(req: true, minLength: 1, maxLength: 20),
                          ).px4,
                        ),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (controller.selectedItem != null && !controller.dataIsNew)
                        MyPopupMenuButton(
                          itemBuilder: (context) {
                            return <PopupMenuEntry>[
                              PopupMenuItem(value: 0, child: Text(Words.delete)),
                            ];
                          },
                          child: Container(margin: const EdgeInsets.only(left: 16), padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, color: Fav.design.customDesign4.primary), child: const Icon(Icons.more_vert, color: Colors.white)),
                          onSelected: (value) async {
                            if (value == 0) {
                              var sure = await Over.sure();
                              if (sure == true) await controller.deleteItem();
                            }
                          },
                        ).pl12,
                      if (controller.advanceMenu)
                        SizedBox(
                          width: 200,
                          child: MySwitch(
                            name: 'publish'.translate,
                            initialValue: controller.selectedItem!.isPublished,
                            onSaved: (value) => controller.selectedItem!.isPublished = value,
                          ),
                        ),
                      MyProgressButton(onPressed: controller.saveItem, label: Words.save, isLoading: controller.isLoading).pr12,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).py8;
  }
}
