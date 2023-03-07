import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../../assets.dart';
import '../../../helpers/appfunctions.dart';
import '../../../helpers/firebase_helper.dart';
import '../../../models/notification.dart';
import '../../../services/dataservice.dart';
import '../../managerscreens/othersettings/user_permission/user_permission.dart';
import 'tool_item_widget.dart';

class PrepareMyStudentHelper {
  PrepareMyStudentHelper._();

  static List<Widget>? getPrepareMyStudentWidget() {
    if (!AppVar.appBloc.hesapBilgileri.isEkid) return null;
    if (!AppVar.appBloc.hesapBilgileri.gtS) return null;
    if (UserPermissionList.hasPrepareMyStudent() != true) return null;
    final _widgetList = <Widget>[];
    _widgetList.addAll([
      ToolItem(
        imgAsset: Assets.images.pms1PNG,
        text: 'pms1'.translate,
        onTap: () async {
          final _techerlist = StudentFunctions.getGuidanceTecherList();
          if (_techerlist.isNotEmpty) {
            final _sure = await Over.sure();
            if (_sure != true) return;
            final _token = await FirebaseHelper.getToken();
            await Future.wait(_techerlist
                    .map((e) => InAppNotificationService.sendInAppNotification(
                          InAppNotification(type: NotificationType.prepareStudent)
                            ..argument = InAppNotificationArgument.addTokenAndCheck(
                              token: _token,
                            ).toJson()
                            ..key = AppVar.appBloc.hesapBilgileri.uid! + 'pms1'
                            ..senderKey = AppVar.appBloc.hesapBilgileri.uid
                            ..title = AppVar.appBloc.hesapBilgileri.name
                            ..content = 'pms1'.translate,
                          e,
                        ))
                    .toList())
                .then((value) => OverAlert.saveSuc())
                .catchError((e) => OverAlert.saveErr());
          } else {
            OverAlert.show(message: 'teachernotfound'.translate);
          }
        },
      ),
      ToolItem(
        imgAsset: Assets.images.pms2PNG,
        text: 'pms2'.translate,
        onTap: () async {
          final _techerlist = StudentFunctions.getGuidanceTecherList();
          if (_techerlist.isNotEmpty) {
            final _sure = await Over.sure();
            if (_sure != true) return;
            final _token = await FirebaseHelper.getToken();
            await Future.wait(_techerlist
                    .map((e) => InAppNotificationService.sendInAppNotification(
                          InAppNotification(type: NotificationType.iamcame)
                            ..argument = InAppNotificationArgument.addTokenAndCheck(
                              token: _token,
                            ).toJson()
                            ..key = AppVar.appBloc.hesapBilgileri.uid! + 'pms2'
                            ..senderKey = AppVar.appBloc.hesapBilgileri.uid
                            ..title = AppVar.appBloc.hesapBilgileri.name
                            ..content = 'pms2'.translate,
                          e,
                        ))
                    .toList())
                .then((value) => OverAlert.saveSuc())
                .catchError((e) => OverAlert.saveErr());
          } else {
            OverAlert.show(message: 'teachernotfound'.translate);
          }
        },
      ),
    ]);
    return _widgetList;
  }
}
