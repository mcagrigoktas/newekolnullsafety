import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../../../localization/usefully_words.dart';
import '../../../common_p2p_helper.dart';
import 'controller.dart';

class StudentRequest extends StatelessWidget {
  StudentRequest();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StudentRequestController>(builder: (controller) {
      return AppScaffold(
        topBar: TopBar(leadingTitle: controller.lesson!.longName),
        topActions: TopActionsTitle(
          title: 'requestp2p'.translate,
        ),
        body: Body.singleChildScrollView(
          child: MyForm(
            formKey: controller.formKey,
            child: Column(
              children: [
                AdvanceDropdown(
                  iconData: Icons.calendar_today,
                  name: 'week'.translate,
                  initialValue: controller.week,
                  nullValueText: 'week'.translate,
                  items: CommonP2PHelper.weekItems,
                  validatorRules: ValidatorRules(req: true),
                  onChanged: (dynamic value) {
                    controller.weekChange(value);
                  },
                ),
                if (controller.existingP2PRequest != null)
                  Card(
                    color: Fav.design.card.background,
                    child: Column(
                      children: <List<String?>>[
                        ['week'.translate, controller.existingP2PRequest!.week.toString()],
                        ['day'.translate, (controller.existingP2PRequest!.dayList!..sort()).fold<String>('', ((p, e) => p + McgFunctions.getDayNameFromDayOfWeek(e!) + ' '))],
                        ['hour'.translate, controller.existingP2PRequest!.startHour!.timeToString + '-' + controller.existingP2PRequest!.endHour!.timeToString],
                        ['p2pteachernote'.translate, controller.existingP2PRequest!.note],
                      ]
                          .map<Widget>((e) => Row(
                                children: [
                                  Expanded(child: e.first.text.bold.make()),
                                  Expanded(child: e.last.text.make()),
                                ],
                              ).px16.py4)
                          .toList()
                        ..insert(0, 'lastp2prequest'.translate.text.color(Fav.design.primary).make()),
                    ),
                  ).p16,
                Column(
                  children: [
                    MyMultiSelect(
                      context: context,
                      initialValue: [],
                      iconData: Icons.account_box,
                      items: (Iterable.generate(7).where((element) => !controller.isThisWeekSelected || element >= CommonP2PHelper.currentWeekDay)).map((e) => MyMultiSelectItem((e + 1).toString(), McgFunctions.getDayNameFromDayOfWeek(e + 1))).toList(),
                      title: 'day'.translate,
                      name: 'p2prequestday'.translate,
                      onSaved: (value) {
                        controller.newP2PRequest.dayList = value!.map(int.tryParse).toList();
                      },
                      validatorRules: ValidatorRules(req: true, minLength: 1),
                    ),
                    Row(
                      children: <Widget>[
                        Icons.hourglass_bottom.icon.color(Colors.amberAccent).make().px8,
                        Expanded(flex: 3, child: Text('p2prequesthour'.translate, style: TextStyle(color: Fav.design.primaryText))),
                        Expanded(
                            flex: 3,
                            child: MyTimePicker(
                              onSaved: (value) {
                                controller.newP2PRequest.startHour = value;
                              },
                              hasIcon: false,
                              initialValue: 600,
                            )),
                        const Text('-'),
                        Expanded(
                            flex: 3,
                            child: MyTimePicker(
                              onSaved: (value) {
                                controller.newP2PRequest.endHour = value;
                              },
                              hasIcon: false,
                              initialValue: 1200,
                            )),
                      ],
                    ),
                    MyTextFormField(
                      iconData: Icons.note,
                      hintText: 'p2pteachernote'.translate,
                      initialValue: '',
                      onSaved: (value) {
                        controller.newP2PRequest.note = value;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomBar: BottomBar(
            child: Align(
          alignment: Alignment.centerRight,
          child: MyProgressButton(isLoading: controller.isLoading, onPressed: controller.submit, label: Words.save),
        ).pr16),
      );
    });
  }
}
