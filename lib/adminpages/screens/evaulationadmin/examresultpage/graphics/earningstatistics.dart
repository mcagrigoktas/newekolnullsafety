import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:random_color/random_color.dart';

import '../../../../../appbloc/appvar.dart';
import '../../helper.dart';
import '../../widgets.dart';
import '../controller.dart';

class EarningStatistics extends StatelessWidget {
  EarningStatistics();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExamResultViewController>();
    List<Color> colorListLessons = Iterable.generate(300)
        .map(
          (_) => RandomColor().randomColor(colorBrightness: Fav.design.brightness == Brightness.dark ? ColorBrightness.dark : ColorBrightness.light),
        )
        .toList();

    final allLessonEarningEntries = controller.examResultBigData.earningResult!.entries.toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 600,
        child: Card(
          color: Fav.design.card.background,
          child: Column(
            children: [
              8.heightBox,
              'earningstatisticshead'.translate.text.fontSize(16).bold.make(),
              8.heightBox,
              Column(
                children: [
                  for (var l = 0; l < allLessonEarningEntries.length; l++)
                    Column(
                      children: [
                        Row(
                          children: [
                            CellWidget(
                              text: allLessonEarningEntries[l].key,
                              background: colorListLessons[l].withAlpha(30),
                            )
                          ],
                        ),
                        Builder(builder: (_) {
                          final allEarningEntries = allLessonEarningEntries[l].value.entries.where((element) {
                            if (element.key == 'general') return true;
                            if (controller.girisTuru == EvaulationUserType.school) {
                              if (element.key!.split('school').last.startsWith(AppVar.appBloc.hesapBilgileri.kurumID!)) return true;
                            }
                            if (controller.girisTuru != EvaulationUserType.school) {
                              if (element.key!.contains('class')) return false;
                            }
                            return true;
                          }).toList();
                          return Column(
                            children: [
                              for (var e = 0; e < allEarningEntries.length; e++)
                                Card(
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        CellWidget(
                                          text: allEarningEntries[e].key,
                                          background: colorListLessons[20 + e].withAlpha(30),
                                        ),
                                        SizedBox(
                                          width: 300,
                                          child: Builder(builder: (context) {
                                            final allData = allEarningEntries[e].value.entries.toList();
                                            return Column(
                                              children: [
                                                for (var d = 0; d < allData.length; d++)
                                                  Row(
                                                    children: [
                                                      MiniCellWidget(
                                                        width: 130,
                                                        background: colorListLessons[30 + d].withAlpha(30),
                                                        text: allData[d].key == 'general'
                                                            ? 'general'.translate
                                                            : allData[d].key.endsWith('noclass')
                                                                ? 'noclass'.translate
                                                                : allData[d].key.contains('class')
                                                                    ? allData[d].key.split('class').last
                                                                    : allData[d].key.replaceAll('school', ''),
                                                      ),
                                                      Expanded(
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(3),
                                                          child: LinearProgressIndicator(
                                                            minHeight: 6,
                                                            backgroundColor: Fav.design.primaryText.withAlpha(50),
                                                            value: allData[d].value['d']! / allData[d].value.values.toList().sum,
                                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                                //Color.fromRGBO((254 * (1 - allData[d].value['d'] / allData[d].value.values.toList().sum)).toInt(), (254 * (allData[d].value['d'] / allData[d].value.values.toList().sum)).toInt(), 0, 1)
                                                                allData[d].value['d']! / allData[d].value.values.toList().sum > 0.7
                                                                    ? Colors.green
                                                                    : allData[d].value['d']! / allData[d].value.values.toList().sum > 0.3
                                                                        ? Colors.amber
                                                                        : Colors.red),
                                                          ),
                                                        ).p2,
                                                      ),
                                                    ],
                                                  )
                                              ],
                                            );
                                          }),
                                        )
                                      ],
                                    ),
                                  ).p4,
                                ),
                            ],
                          );
                        })
                      ],
                    ).pb12
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
