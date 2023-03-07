import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myfileuploadwidget.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../localization/usefully_words.dart';
import '../../../../../supermanager/supermanagerbloc.dart';
import '../../helper.dart';
import 'controller.dart';
import 'model.dart';

class OnlineFormDefine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnlineFormController>(builder: (controller) {
      return AppScaffold(
        topBar: TopBar(leadingTitle: controller.exam!.name),
        topActions: TopActionsTitle(title: 'bookletsettings'.translate),
        body: Body.singleChildScrollView(
            child: MyForm(
                formKey: controller.formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AnimatedGroupWidget(
                        children: [
                          //! Bunu silme ileride pdf disinda  sinav tipi gerekierse ekle ve ac simdilik otomatik pdf secili
                          // MyDropDownField(
                          //   name: 'exambookletlocation'.translate,
                          //   initialValue: controller.model.exambookletlocation,
                          //   iconData: Icons.pending_rounded,
                          //   color: Colors.pink,
                          //   items: [
                          //     DropdownMenuItem(
                          //       value: Exambookletlocation.pdf,
                          //       child: 'examwithpdf'.translate.text.color(Fav.design.dropdown.text).make(),
                          //     ),
                          //   ],
                          //   onSaved: (value) {
                          //     controller.model.exambookletlocation = value;
                          //   },
                          //   onChanged: (value) {
                          //     controller.model.exambookletlocation = value;
                          //     controller.update();
                          //   },
                          // ),
                          if (controller.model!.exambookletlocation == Exambookletlocation.pdf)
                            MyDropDownField(
                              initialValue: controller.model!.isOnlyMainBooklet,
                              iconData: Icons.pending_rounded,
                              color: Colors.pink,
                              items: [
                                DropdownMenuItem(value: true, child: 'pdfonlymainbooklet1'.translate.text.color(Fav.design.dropdown.text).make()),
                                DropdownMenuItem(value: false, child: 'pdfonlymainbooklet2'.translate.text.color(Fav.design.dropdown.text).make()),
                              ],
                              onSaved: (value) {
                                controller.model!.isOnlyMainBooklet = value;
                              },
                              onChanged: (value) {
                                controller.model!.isOnlyMainBooklet = value;
                                controller.update();
                              },
                            ),
                          if (controller.model!.exambookletlocation == Exambookletlocation.pdf)
                            MySwitch(
                              iconData: Icons.download_rounded,
                              color: Colors.amber,
                              name: 'bookletisdownloadable'.translate,
                              initialValue: controller.model!.bookletIsDownladable ?? false,
                              onSaved: (value) {
                                controller.model!.bookletIsDownladable = value;
                              },
                            ),
                          // MySwitch(
                          //   iconData: Icons.multitrack_audio_sharp,
                          //   color: Colors.red,
                          //   name: 'showinannouncement'.translate,
                          //   initialValue: controller.model.mustAddedInNotification ?? false,
                          //   onSaved: (value) {
                          //     controller.model.mustAddedInNotification = value;
                          //   },
                          // ),
                          MyDateTimePicker(
                            initialValue: controller.model!.examBookLetVisibleTime ?? DateTime.now().millisecondsSinceEpoch,
                            onSaved: (value) {
                              controller.model!.examBookLetVisibleTime = value;
                            },
                            title: 'examstarttime'.translate,
                            firstYear: DateTime.now().year,
                            lastYear: DateTime.now().year + 2,
                          ),
                          MyDateTimePicker(
                            initialValue: controller.model!.examFormClosedTime ?? DateTime.now().millisecondsSinceEpoch,
                            onSaved: (value) {
                              controller.model!.examFormClosedTime = value;
                            },
                            title: 'examfinishtime'.translate,
                            firstYear: DateTime.now().year,
                            lastYear: DateTime.now().year + 2,
                          ),
                          MyTextFormField(
                            initialValue: (controller.model!.examFormEkstraTime ?? 0).toString(),
                            onSaved: (value) {
                              controller.model!.examFormEkstraTime = int.tryParse(value!);
                            },
                            iconData: Icons.alt_route,
                            validatorRules: ValidatorRules(mustNumber: true, minValue: 0, req: true),
                            labelText: 'examextratime'.translate,
                            keyboardType: TextInputType.number,
                          ),
                          if (controller.model!.isOnlyMainBooklet!)
                            Column(
                              children: [
                                'exambooklet'.translate.text.make(),
                                MultiFileUploadWidget(
                                    mustCrypt: true,
                                    saveLocation: controller.userType == EvaulationUserType.school
                                        ? '${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/ExamFiles/${controller.exam!.key}'
                                        : '${Get.find<SuperManagerController>().hesapBilgileri.kurumID}/ExamFiles/${controller.exam!.key}',
                                    onSaved: (value) {
                                      if (value == null) return;
                                      controller.model!.mainBookLetFile ??= BookLetFile();
                                      controller.model!.mainBookLetFile!.fileName = value.name;
                                      controller.model!.mainBookLetFile!.pdfUrlList = value.urlList;
                                    },
                                    validatorRules: ValidatorRules(req: true),
                                    initialValue: controller.model!.mainBookLetFile == null ? null : MultiFileResult(urlList: controller.model!.mainBookLetFile!.pdfUrlList!, name: controller.model!.mainBookLetFile!.fileName!)),
                              ],
                            ),
                          if (controller.model!.isOnlyMainBooklet!)
                            MyTextFormField(
                              initialValue: (controller.model!.examBookLetExtraPage ?? 0).toString(),
                              onSaved: (value) {
                                controller.model!.examBookLetExtraPage = int.tryParse(value!);
                              },
                              iconData: Icons.alt_route,
                              validatorRules: ValidatorRules(mustNumber: true, minValue: 0, req: true),
                              labelText: 'extrapagenumber'.translate,
                              keyboardType: TextInputType.number,
                            ),
                          for (var l = 0; l < controller.examType!.lessons!.length; l++)
                            if (controller.examType!.lessons![l].seisonNo == controller.seisonNo)
                              Column(
                                children: [
                                  controller.examType!.lessons![l].name.text.make(),
                                  if (!controller.model!.isOnlyMainBooklet!)
                                    MultiFileUploadWidget(
                                        mustCrypt: true,
                                        saveLocation: controller.userType == EvaulationUserType.school
                                            ? '${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/ExamFiles/${controller.exam!.key}'
                                            : '${Get.find<SuperManagerController>().hesapBilgileri.kurumID}/ExamFiles/${controller.exam!.key}',
                                        onSaved: (value) {
                                          if (value == null) return;
                                          controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key] ??= BookLetFile();
                                          controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key]!.fileName = value.name;
                                          controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key]!.pdfUrlList = value.urlList;
                                        },
                                        validatorRules: ValidatorRules(req: true),
                                        initialValue: controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key] == null
                                            ? null
                                            : MultiFileResult(name: controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key]!.fileName!, urlList: controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key]!.pdfUrlList!)),
                                  if (controller.model!.isOnlyMainBooklet!)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MyTextFormField(
                                            initialValue: controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key] == null ? null : controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key]!.startPageNo.toString(),
                                            onSaved: (value) {
                                              controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key] ??= BookLetFile();
                                              controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key]!.startPageNo = int.tryParse(value!);
                                            },
                                            iconData: Icons.alt_route,
                                            validatorRules: ValidatorRules(mustNumber: true, minValue: 0, req: true),
                                            labelText: 'pageinbooklet'.translate,
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        Expanded(
                                          child: MyTextFormField(
                                            initialValue: controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key] == null ? null : controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key]!.endPageNo.toString(),
                                            onSaved: (value) {
                                              controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key] ??= BookLetFile();
                                              controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key]!.endPageNo = int.tryParse(value!);
                                            },
                                            iconData: Icons.alt_route,
                                            validatorRules: ValidatorRules(mustNumber: true, minValue: 0, req: true),
                                            labelText: 'pageinbookletend'.translate,
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        Expanded(
                                          child: MyTextFormField(
                                            initialValue: controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key] == null ? '1' : controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key]!.firstQuestionNo.toString(),
                                            onSaved: (value) {
                                              controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key] ??= BookLetFile();
                                              controller.model!.lessonBookLetFiles![controller.examType!.lessons![l].key]!.firstQuestionNo = int.tryParse(value!);
                                            },
                                            iconData: Icons.alt_route,
                                            validatorRules: ValidatorRules(mustNumber: true, minValue: 0, req: true),
                                            labelText: 'bookletlessonfirstQno'.translate,
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              MyProgressButton(onPressed: controller.saveItem, label: Words.save).pr12,
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ))),
      );
    });
  }
}
