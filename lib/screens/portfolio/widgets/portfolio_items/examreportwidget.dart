import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:random_color/random_color.dart';

import '../../../../adminpages/screens/evaulationadmin/widgets.dart';
import '../../model.dart';
import '../exam_karne_helper.dart';
import '../print_karne_helper.dart';
import '../sinav_karsilastirici_helper.dart';

class ExamReportMiniWidget extends StatelessWidget {
  final PortfolioExamReport? data;
  final List<PortfolioExamReport>? Function()? otherExamsData;
  final String? studentName;
  ExamReportMiniWidget(this.data, {this.otherExamsData, this.studentName});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      color: Fav.design.card.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: data!.exam.name.text.bold.make()),
              if (data!.exam.date != null)
                Column(
                  children: [
                    'examdate'.translate.text.fontSize(12).bold.color(Fav.design.disablePrimary).make(),
                    data!.exam.date!.dateFormat('d-MMM-yyyy').text.fontSize(12).color(Fav.design.disablePrimary).make(),
                  ],
                ),
            ],
          ),
          8.heightBox,
          data!.exam.explanation.text.make(),
          8.heightBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyMiniRaisedButton(
                  text: 'compare'.translate,
                  onPressed: () {
                    ExamComparator.compare(examListWithResults: otherExamsData!()!.reversed.toList(), currentReport: data, studentName: studentName);
                  }).pr16,
              MyMiniRaisedButton(
                  text: 'examine'.translate,
                  onPressed: () {
                    Fav.to(ExamReportWidget(data));
                  }),
            ],
          )
        ],
      ).p12,
    );
  }
}

class ExamReportWidget extends StatelessWidget {
  final PortfolioExamReport? data;

  ExamReportWidget(this.data);

  static const List<double> widthListLessons = [100, 50, 250, 250, 100];
  static const List<double> heightListLessons = [50, 30];
  final List<Color> colorListLessons = Iterable.generate(120)
      .map(
        (_) => RandomColor().randomColor(colorBrightness: Fav.design.brightness == Brightness.dark ? ColorBrightness.dark : ColorBrightness.light),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final isWritebleQuestionEnable = data!.examType.lessons!.any((element) => element.wQuestionCount! > 0);
    const type = 0;

    return AppScaffold(
        topBar: TopBar(leadingTitle: data!.exam.name, middle: data!.exam.date!.dateFormat('d-MMM, HH:mm').text.color(Fav.design.appBar.text).make(), trailingActions: [
          Icons.print.icon.color(Fav.design.appBar.text).onPressed(() {
            PrintKarneHelper.print(data!);
          }).make()
        ]),
        topActions: TopActionsTitle(title: data!.result.rSName!),
        body: Body.singleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              8.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [ExamKarneHelper.mBookLetType(data!)],
              ),
              8.heightBox,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...ExamKarneHelper.lessonResultHeader<Widget>(isWritebleQuestionEnable, type),
                        ExamKarneHelper.mBasariGrafigiHeaderWidget(),
                        16.widthBox,
                        ExamKarneHelper.studentAnswersHeader(type, 1),
                      ],
                    ),
                    for (var l = 0; l < data!.examType.lessons!.length; l++)
                      Builder(builder: (context) {
                        final item = data!.examType.lessons![l];
                        final result = data!.result.testResults![item.key]!;

                        return Row(
                          children: [
                            ...ExamKarneHelper.lessonResultStudent<Widget>(isWritebleQuestionEnable, item, result, type, 1),
                            SizedBox(
                              width: widthListLessons[2],
                              height: heightListLessons[1],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  [result.n! / item.questionCount!, Colors.greenAccent],
                                  [result.classAwerage! / item.questionCount!, Colors.deepPurpleAccent],
                                  [result.schoolAwerage! / item.questionCount!, Colors.pinkAccent],
                                  [result.generalAwerage! / item.questionCount!, Colors.blueAccent],
                                ]
                                    .map((e) => ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: LinearProgressIndicator(
                                            backgroundColor: (e[1] as Color).withAlpha(50),
                                            value: e[0] as double?,
                                            valueColor: AlwaysStoppedAnimation<Color>(e[1] as Color),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                            16.widthBox,
                            SizedBox(
                              //     width: widthListLessons[3],
                              height: heightListLessons[1],
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    CellWidget(
                                      width: 15,
                                      margin: 0,
                                      height: heightListLessons[1],
                                      background: Colors.blueAccent,
                                      fontSize: 7,
                                      padding: 0,
                                      text: '\n' + 'student'.translate.firstXcharacter(1)! + '\n' + 'answer'.translate.firstXcharacter(1)!,
                                    ),
                                    for (var sa = 0; sa < [result.studentAnswers!.length, result.realAnswers!.length].min; sa++)
                                      CellWidget(
                                        width: 12,
                                        margin: 0,
                                        height: heightListLessons[1],
                                        background: result.studentAnswers![sa] == ' '
                                            ? Colors.amber
                                            : result.studentAnswers![sa] == result.realAnswers![sa]
                                                ? Colors.green
                                                : Colors.redAccent,
                                        fontSize: 7,
                                        padding: 0,
                                        text: '${sa + 1}\n' + result.studentAnswers![sa].toUpperCase() + '\n' + result.realAnswers![sa].toUpperCase(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                  ],
                ),
              ),
              16.heightBox,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...ExamKarneHelper.orderHeader<Widget>(0),
                        16.widthBox,
                        Container(
                          width: widthListLessons[2],
                          height: heightListLessons[0],
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: colorListLessons[31].withAlpha(50), borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            children: [
                              Expanded(child: 'eg'.translate.text.bold.make()),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ['student'.translate, Colors.greenAccent],
                                  ['class'.translate, Colors.deepPurpleAccent],
                                  ['school'.translate, Colors.pinkAccent],
                                  ['general'.translate, Colors.blueAccent],
                                ]
                                    .map(
                                      (e) => Row(
                                        children: [
                                          CircleAvatar(radius: 2, backgroundColor: e[1] as Color?).pr2,
                                          (e[0] as String).text.fontSize(8).make().pr4,
                                        ],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    ...ExamKarneHelper.orderStudentResult(0, data!)
                  ],
                ),
              ),
              if (data!.earningResultKeyMap != null)
                LessonResultCell<Widget>(
                  height: heightListLessons[1],
                  background: colorListLessons[49].withAlpha(50),
                  text: 'earningstatisticshead'.translate,
                  fontSize: 12,
                  bold: true,
                )(type)
                    .pt16,
              if (data!.earningResultKeyMap != null) ...ExamKarneHelper.mKazanimList<Widget>(data!, 0, isWritebleQuestionEnable),
            ],
          ).p8,
        ));
  }
}
