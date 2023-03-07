import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/appfunctions.dart';
import '../../../helpers/print/otherprint.dart';
import '../../../localization/usefully_words.dart';
import '../../main/macos_dock/macos_dock.dart';
import '../../managerscreens/othersettings/user_permission/user_permission.dart';
import '../../notification_and_agenda/agenda/layout.dart';

class BirthDayHelper {
  BirthDayHelper._();

  static late DateTime _now;

  static _BirtdayModel _calcDaysForBirthDayPage(String? label, int timeStamp) {
    final _birthDay = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    int _remainingDay;
    var _date1 = DateTime(_now.year, _birthDay.month, _birthDay.day);

    if (_date1.difference(_now).inDays > -1) {
      _remainingDay = _date1.difference(_now).inDays;
    } else {
      var _date2 = DateTime(_now.year + 1, _birthDay.month, _birthDay.day);
      _remainingDay = _date2.difference(_now).inDays;
    }

    return _BirtdayModel(label, _remainingDay, _birthDay);
  }

  static List<_BirtdayModel> getBirthDayListForBirthDayPage() {
    _now = DateTime.now();
    List<_BirtdayModel> _itemList = [];

    AppFunctions2.getStudentListForTeacherAndManager()!.forEach((student) {
      if (student.birthday != null && student.birthday! > 0) {
        _itemList.add(_calcDaysForBirthDayPage(student.name, student.birthday!));
      }

      if (student.motherBirthday != null && student.motherBirthday! > 0) {
        _itemList.add(_calcDaysForBirthDayPage(student.name! + ' (' + 'mother'.translate + ')', student.motherBirthday!));
      }
      if (student.fatherBirthday != null && student.fatherBirthday! > 0) {
        _itemList.add(_calcDaysForBirthDayPage(student.name! + ' (' + 'father'.translate + ')', student.fatherBirthday!));
      }
    });

    if (AppVar.appBloc.hesapBilgileri.gtM) {
      AppVar.appBloc.teacherService!.dataList.forEach((teacher) {
        if (teacher.birthday != null && teacher.birthday! > 0) {
          _itemList.add(_calcDaysForBirthDayPage(teacher.name, teacher.birthday!));
        }
      });
    }

    _itemList.sort((a, b) => a.remainingDay - b.remainingDay);

    return _itemList;
  }

//? Ajanda icin Dogum gununun ne zaman kutlanacaginin tarihi, texti ve kalan gun sayisini iceren _BirtdayModel dondurur
//? Eger dogum gunu 7 gun oncesi yada 15 gun sonrasi disindaysa null dondurur
  static _BirtdayModel? _calcDaysForAgenda(String? label, int timeStamp) {
    final _birthDay = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    var _date1 = DateTime(_now.year, _birthDay.month, _birthDay.day, 20);
    var _date2 = DateTime(_now.year - 1, _birthDay.month, _birthDay.day, 20);
    var _date3 = DateTime(_now.year + 1, _birthDay.month, _birthDay.day, 20);

    if (_date1.difference(_now).inDays > -7 && _date1.difference(_now).inDays < 14) {
      return _BirtdayModel(label, _date1.difference(_now).inDays, _date1);
    }
    if (_date2.difference(_now).inDays > -7 && _date2.difference(_now).inDays < 14) {
      return _BirtdayModel(label, _date2.difference(_now).inDays, _date2);
    }

    if (_date3.difference(_now).inDays > -7 && _date3.difference(_now).inDays < 14) {
      return _BirtdayModel(label, _date3.difference(_now).inDays, _date3);
    }

    return null;
  }

  static List<_BirtdayModel> _getBirthDayListForAgenda() {
    _now = DateTime.now();
    List<_BirtdayModel> _itemList = [];

    AppFunctions2.getStudentListForTeacherAndManager()!.forEach((student) {
      if (student.birthday != null && student.birthday! > 0) {
        _itemList.addIfNotNull(_calcDaysForAgenda(student.name, student.birthday!));
      }

      if (student.motherBirthday != null && student.motherBirthday! > 0) {
        _itemList.addIfNotNull(_calcDaysForAgenda(student.name! + ' (' + 'mother'.translate + ')', student.motherBirthday!));
      }

      if (student.fatherBirthday != null && student.fatherBirthday! > 0) {
        _itemList.addIfNotNull(_calcDaysForAgenda(student.name! + ' (' + 'father'.translate + ')', student.fatherBirthday!));
      }
    });

    if (AppVar.appBloc.hesapBilgileri.gtM) {
      AppVar.appBloc.teacherService!.dataList.forEach((teacher) {
        if (teacher.birthday != null && teacher.birthday! > 0) {
          _itemList.addIfNotNull(_calcDaysForAgenda(teacher.name, teacher.birthday!));
        }
      });
    }

    return _itemList;
  }

  static void addAgendaBirthdayItems() {
    if (AppVar.appBloc.hesapBilgileri.gtMT == false) return;
    () {
      if (UserPermissionList.addAgendaBirthdayItems()) {
        if (AppVar.appBloc.hesapBilgileri.gtMT) {
          final _birthDayItemList = _getBirthDayListForAgenda();
          final _agendaItemList = <Appointment>[];

          _birthDayItemList.forEach((_item) {
            final _appointment = Appointment(
              isAllDay: true,
              startTime: _item.date,
              endTime: _item.date,
              color: Fav.design.primaryText.withAlpha(150),
              subject: 'birthday2'.translate,
              resourceIds: ResourceIdRule(AgendaGroup.birthDay, otherKeys: [_item.label!]).idList,
            );
            _agendaItemList.add(_appointment);
          });

          Get.find<MacOSDockController>().replaceThisTagAgendaItems(AgendaGroup.birthDay, _agendaItemList);
        }
      } else {
        Get.find<MacOSDockController>().replaceThisTagAgendaItems(AgendaGroup.birthDay, null);
      }
    }.delay(1000);
  }
}

class BirthdayListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _itemList = BirthDayHelper.getBirthDayListForBirthDayPage();

    return AppScaffold(
      topBar: TopBar(
        leadingTitle: 'menu1'.translate,
        trailingActions: [
          MyMiniRaisedButton(
            text: Words.print,
            onPressed: () {
              OtherPrint.printBirthdayList();
            },
            iconData: Icons.print,
          ),
        ],
      ),
      topActions: TopActionsTitle(title: 'birthdaylist'.translate),
      body: Body.listviewBuilder(
        maxWidth: 540,
        itemCount: _itemList.length,
        itemBuilder: (context, index) {
          return Container(
            color: index % 2 == 0 ? Fav.design.primaryText.withAlpha(1) : Fav.design.primaryText.withAlpha(4),
            child: ListTile(
              title: Text(
                _itemList[index].label!,
                style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              trailing: Text(_itemList[index].date.dateFormat("d-MMM-yyyy"), style: TextStyle(color: Fav.design.primary, fontSize: 14)),
            ),
          );
        },
      ),
    );
  }
}

class _BirtdayModel {
  String? label;
  DateTime date;
  int remainingDay;

  _BirtdayModel(this.label, this.remainingDay, this.date);
}
