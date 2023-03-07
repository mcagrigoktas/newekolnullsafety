import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import 'model.dart';

class P2PEditSchoolHelper {
  P2PEditSchoolHelper._();
  static Future<List<SimpeP2PDraftItem>?> add() async {
    final _formKey = GlobalKey<FormState>();
    List<int>? _dayList;
    int? _startTime;
    int? _endTime;
    late int _lessonDuration;
    late int _breakDuration;
    late int _lessonCountForBreak;

    Widget _current = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MultiSelectRow<int>(
          title: 'p2pdayshint'.translate,
          items: [1, 2, 3, 4, 5, 6, 7].map((day) => DropdownItem<int>(value: day, name: McgFunctions.getDayNameFromDayOfWeek(day, format: 'EEE'))).toList(),
          onSaved: (value) {
            _dayList = value;
          },
          validatorRules: ValidatorRules(minLength: 1, req: true),
        ),
        Row(
          children: [
            Expanded(
                child: MyTimePicker(
              title: 'starttime'.translate,
              initialValue: 600,
              onSaved: (value) {
                _startTime = value;
              },
            )),
            Expanded(
                child: MyTimePicker(
              title: 'endtime'.translate,
              initialValue: 1080,
              onSaved: (value) {
                _endTime = value;
              },
            )),
          ],
        ),
        AdvanceDropdown<int>(
          name: 'videocalllessonduration'.translate + ' (' + 'minute'.translate + ')',
          items: [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60].map((e) => DropdownItem(name: e.toString(), value: e)).toList(),
          onSaved: (value) {
            _lessonDuration = value;
          },
          iconData: Icons.hourglass_bottom_rounded,
          initialValue: 20,
        ),
        Row(
          children: [
            Expanded(
                child: AdvanceDropdown<int>(
              name: 'videocalllessonbreakduration'.translate + ' (' + 'minute'.translate + ')',
              items: [5, 10, 15, 20, 25, 30].map((e) => DropdownItem(name: e.toString(), value: e)).toList(),
              onSaved: (value) {
                _breakDuration = value;
              },
              iconData: Icons.hourglass_disabled_rounded,
              initialValue: 10,
            )),
            Expanded(
                child: AdvanceDropdown<int>(
              name: 'videocalllessoncountforbreak'.translate,
              items: [1, 2, 3, 4, 5].map((e) => DropdownItem(name: e.toString(), value: e)).toList(),
              onSaved: (value) {
                _lessonCountForBreak = value;
              },
              iconData: Icons.hourglass_disabled_rounded,
              initialValue: 2,
            )),
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: MyRaisedButton(
                  onPressed: () {
                    if (_formKey.currentState!.checkAndSave()) {
                      if (_endTime! <= _startTime!) {
                        OverDialog.closeDialog();
                      } else {
                        List<SimpeP2PDraftItem> _itemList = [];
                        int _controlTime = _startTime!;
                        int _controlBreakCount = 0;
                        while (_controlTime + _lessonDuration <= _endTime!) {
                          _dayList!.forEach((_dayNo) {
                            final _item = SimpeP2PDraftItem(dayNo: _dayNo, startTime: _controlTime, endTime: _controlTime + _lessonDuration, key: 'L_${_dayNo}_${_controlTime}_${_controlTime + _lessonDuration}');
                            _itemList.add(_item);
                          });
                          _controlTime += _lessonDuration;

                          _controlBreakCount++;
                          if (_controlBreakCount % _lessonCountForBreak == 0) _controlTime += _breakDuration;
                        }

                        OverDialog.selectDialog(_itemList);
                      }
                    }
                  },
                  text: 'add'.translate)
              .pr16,
        )
      ],
    ).p8;

    _current = Form(
      key: _formKey,
      child: _current,
    );

    return await (OverDialog.show(DialogPanel.child(child: _current)));
  }
}
