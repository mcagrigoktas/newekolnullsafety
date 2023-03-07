import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import '../helper.dart';
import 'controller.dart';
import 'graphics/classcompressiongraphics.dart';
import 'graphics/classcompressionnetgraphics.dart';
import 'graphics/earningstatistics.dart';
import 'graphics/instutioncompressiongraphics.dart';
import 'graphics/studentresultgraphic1.dart';
import 'helper.dart';

class ExamResultReview extends StatelessWidget {
  ExamResultReview();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamResultViewController>(builder: (controller) {
      if (controller.errorText != null) {
        return AppScaffold(
          topBar: TopBar(leadingTitle: controller.exam!.name),
          topActions: TopActionsTitle(title: 'viewexamresult'.translate),
          body: Body.child(child: EmptyState(text: controller.errorText.toString())),
        );
      }

      return AppScaffold(
        topBar: TopBar(leadingTitle: controller.exam!.name, middle: 'viewexamresult'.translate.text.color(Fav.design.primary).bold.make(), trailingActions: [
          QudsPopupButton(
            backgroundColor: Fav.design.scaffold.background,
            child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(Icons.more_vert, color: Fav.design.primaryText)),
            items: [
              QudsPopupMenuSection(titleText: Words.print, leading: Icons.print.icon.color(Fav.design.primaryText).make(), subItems: [
                QudsPopupMenuWidget(builder: (ctx) {
                  return MyTextField(
                    labelText: 'margins'.translate,
                    iconData: Icons.margin,
                    onChanged: (text) {
                      Fav.preferences.setInt('printfullprogrammargin', int.tryParse(text) ?? 8);
                    },
                    initialValue: Fav.preferences.getInt('printfullprogrammargin', 8).toString(),
                  );
                }),
                QudsPopupMenuWidget(builder: (ctx) {
                  return 'printexamfulllisthint'.translate.text.center.color(Fav.design.primaryText).make().p8;
                }),
                QudsPopupMenuWidget(builder: (_) {
                  return MyMiniRaisedButton(
                          onPressed: () {
                            Get.back();
                            ExamResultReviewHelper.print();
                          },
                          text: Words.print)
                      .p8;
                }),
              ]),
              QudsPopupMenuSection(titleText: 'printreportcards'.translate, leading: Icons.card_membership_outlined.icon.color(Fav.design.primaryText).make(), subItems: [
                if (controller.examResultBigData!.earningIsActive!)
                  QudsPopupMenuWidget(builder: (ctx) {
                    return MyTextField(
                      labelText: 'eIFontSize'.translate,
                      iconData: Icons.margin,
                      onChanged: (text) {
                        Fav.preferences.setInt('eIFontSize', int.tryParse(text) ?? 12);
                      },
                      initialValue: Fav.preferences.getInt('eIFontSize', 12).toString(),
                    );
                  }),
                QudsPopupMenuWidget(builder: (_) {
                  return MyMiniRaisedButton(
                          onPressed: () {
                            ExamResultReviewHelper.printReportCards(controller.filteredClassList, earnintItemFontSize: Fav.preferences.getInt('eIFontSize', 12)!.toDouble());
                          },
                          text: Words.print)
                      .p8;
                }),
              ]),
              QudsPopupMenuItem(title: Text('exportexcell'.translate, style: TextStyle(color: Fav.design.primaryText)), leading: Icons.table_chart_sharp.icon.color(Fav.design.primaryText).make(), onPressed: ExamResultReviewHelper.exportExcel),
              if (controller.girisTuru == EvaulationUserType.school && AppVar.appBloc.schoolInfoService!.singleData!.smsConfig.isSturdy)
                QudsPopupMenuItem(title: Text('sendwithsms'.translate, style: TextStyle(color: Fav.design.primaryText)), leading: Icons.sms.icon.color(Fav.design.primaryText).make(), onPressed: ExamResultReviewHelper.sendSms),
            ],
          ),
          Icons.pie_chart.icon.color(Fav.design.appBar.text).onPressed(() {
            Fav.to(ExamStatisticsPage());
          }).make()
        ]),
        topActions: TopActions(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1250, maxHeight: 95),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.girisTuru != EvaulationUserType.school)
                      SizedBox(
                        width: 200,
                        child: AdvanceDropdown(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          items: controller.allKurumAllStudentResults!.keys.map((e) => DropdownItem(name: e, value: e)).toList(),
                          initialValue: controller.kurumId,
                          onChanged: (dynamic value) {
                            controller.kurumId = value;
                            controller.update();
                          },
                          name: 'schoollist'.translate,
                        ),
                      )
                    else
                      SizedBox(
                        width: 200,
                        child: AdvanceMultiSelectDropdown(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          items: controller.allClassList.map((e) => DropdownItem(name: e, value: e)).toList()..insert(0, DropdownItem(name: 'all'.translate, value: 'all')),
                          initialValue: controller.filteredClassList,
                          onChanged: (value) {
                            controller.filteredClassList = value as List<String>;
                            controller.update();
                          },
                          name: 'classlist'.translate,
                        ),
                      ),
                    Expanded(
                      child: MyMultiSelect(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        iconData: Icons.search,
                        context: context,
                        miniChip: true,
                        items: controller.examType!.lessons!.map((e) => MyMultiSelectItem<String>(e.key!, e.name!)).toList(),
                        initialValue: controller.filtrLessonList,
                        title: 'lesson'.translate,
                        name: 'lesson'.translate,
                        onChanged: (value) {
                          controller.filtrLessonList = value!;
                          controller.update();
                        },
                      ),
                    ),
                    Expanded(
                      child: MyMultiSelect(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        iconData: Icons.search,
                        context: context,
                        miniChip: true,
                        items: controller.lessonSettingsList.map((e) => MyMultiSelectItem(e, e.translate)).toList(),
                        initialValue: controller.filterSettings!,
                        title: 'testfilersettings'.translate,
                        name: 'testfilersettings'.translate,
                        onChanged: (value) {
                          controller.filterSettings = value;
                          controller.update();
                        },
                      ),
                    ),
                    Expanded(
                      child: MyMultiSelect(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        iconData: Icons.search,
                        context: context,
                        miniChip: true,
                        items: controller.scoreSettingsList.map((e) => MyMultiSelectItem(e, e.translate)).toList(),
                        initialValue: controller.scoreSettings!,
                        title: 'scorefilersettings'.translate,
                        name: 'scorefilersettings'.translate,
                        onChanged: (value) {
                          controller.scoreSettings = value;
                          controller.update();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Body.child(
            child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              controller.headerWidget,
              Expanded(child: controller.bodyWidget),
            ],
          ),
        )),
      );
    });
  }
}

class ExamStatisticsPage extends StatelessWidget {
  ExamStatisticsPage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExamResultViewController>();

    return AppScaffold(
      topBar: TopBar(
        leadingTitle: controller.exam!.name,
      ),
      topActions: TopActionsTitle(
        title: 'statistics'.translate,
      ),
      body: controller.allKurumAllStudentResults![controller.kurumId] == null || controller.allKurumAllStudentResults![controller.kurumId]!.isEmpty
          ? Body.child(child: const SizedBox())
          : Body.singleChildScrollView(
              child: Column(
              children: [
                ///Ogrenci datadan geldigini false yaparsan okulu kendi icinde kiyasllayan grafik cikar
                StudentLessonPerformanceGraphics(
                  resultModel: controller.allKurumAllStudentResults![controller.kurumId]!.entries.first.value,
                  examType: controller.examType,
                  comingFromStudentsChart: false,
                ),
                16.heightBox,
                InstutionScoreGraphics(
                  kurumAllStudentResults: controller.allKurumAllStudentResults![controller.kurumId],
                  examType: controller.examType,
                ),
                16.heightBox,
                ClassScoreGraphics(
                  kurumAllStudentResults: controller.allKurumAllStudentResults![controller.kurumId],
                  examType: controller.examType,
                ),
                16.heightBox,
                ClassNetGraphics(
                  kurumAllStudentResults: controller.allKurumAllStudentResults![controller.kurumId],
                  examType: controller.examType,
                ),
                16.heightBox,
                if (controller.examResultBigData!.earningIsActive!) EarningStatistics(),
              ],
            )),
    );
  }
}
