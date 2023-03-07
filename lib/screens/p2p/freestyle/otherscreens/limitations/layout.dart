import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../localization/usefully_words.dart';
import 'controller.dart';

class P2PLimitations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<P2PLimitationsController>(builder: (controller) {
      return AppScaffold(
          topBar: TopBar(
            leadingTitle: 'p2pmenuname'.translate,
            trailingActions: [
              MyProgressButton(
                onPressed: controller.submit,
                label: Words.save,
                isLoading: controller.isLoading,
              )
            ],
          ),
          topActions: TopActionsTitle(
            title: 'teacherlimitations'.translate,
          ),
          body: controller.timesModel == null
              ? Body.child(
                  child: EmptyState(text: 'schooltimeswarning'.translate),
                )
              : Body.singleChildScrollView(
                  maxWidth: 720,
                  child: Column(
                    key: controller.refreshKey,
                    children: [
                      ...AppVar.appBloc.teacherService!.dataList
                          .map((teacher) => Card(
                                color: Fav.design.card.background,
                                child: Column(
                                  children: [
                                    teacher.name.text.color(Fav.design.card.text).bold.make().pt8,
                                    const Divider(),
                                    ...Iterable.generate(7, (i) => '${i + 1}')
                                        .where((element) => controller.timesModel!.activeDays!.contains(element))
                                        .map((day) => Row(
                                              children: <Widget>[
                                                16.widthBox,
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    McgFunctions.getDayNameFromDayOfWeek(int.tryParse(day)!),
                                                    style: TextStyle(color: Fav.design.primaryText),
                                                  ),
                                                ),
                                                Expanded(
                                                    flex: 3,
                                                    child: MyTimePicker(
                                                        onChanged: (value) {
                                                          controller.setTeacherTimes(teacher.key, int.tryParse(day), 0, value);
                                                        },
                                                        hasIcon: false,
                                                        initialValue: controller.getTeacherTimes(teacher.key, int.tryParse(day))!.first)),
                                                const Text('-'),
                                                Expanded(
                                                    flex: 3,
                                                    child: MyTimePicker(
                                                        onChanged: (value) {
                                                          controller.setTeacherTimes(teacher.key, int.tryParse(day), 1, value);
                                                        },
                                                        hasIcon: false,
                                                        initialValue: controller.getTeacherTimes(teacher.key, int.tryParse(day))!.last)),
                                              ],
                                            ))
                                        .toList(),
                                  ],
                                ),
                              ))
                          .toList()
                    ],
                  ),
                ));
    });
  }
}
