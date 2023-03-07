import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../managerscreens/othersettings/user_permission/user_permission.dart';

class CommonP2PHelper {
  CommonP2PHelper._();

  static int get currentWeekDay => DateTime.fromMillisecondsSinceEpoch(AppVar.appBloc.realTime).weekday;

  static List<DropdownItem> get weekItems {
    final _time = DateTime.fromMillisecondsSinceEpoch(AppVar.appBloc.realTime);

    final _nextWeekMondayTime = _time.add(Duration(days: 7 - currentWeekDay + 1));
    final _p2pRequestLimits = UserPermissionList.p2pRequestTimes();

    return [
      if (_p2pRequestLimits.contains('0')) _nextWeekMondayTime.subtract(Duration(days: 7)),
      if (_p2pRequestLimits.contains('1')) _nextWeekMondayTime,
      if (_p2pRequestLimits.contains('2')) _nextWeekMondayTime.add(Duration(days: 7)),

      // ...Iterable<int>.generate(_howManyNextWeekVisible).map((e) => _nextWeekMondayTime.add(Duration(days: e * 7))).toList()
    ]
        .map((e) => DropdownItem(
              name: '${e.millisecondsSinceEpoch.limit(_time.millisecondsSinceEpoch, e.millisecondsSinceEpoch).dateFormat('d-MMM EEE')} / ${e.add(const Duration(days: 6)).millisecondsSinceEpoch.dateFormat('d-MMM EEE')}',
              value: e.weekOfYear,
            ))
        .toList();
  }
}
