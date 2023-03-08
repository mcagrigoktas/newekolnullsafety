import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../models/accountdata.dart';
import '../../../models/notification.dart';
import '../../../services/dataservice.dart';

class StudentScreenTransporterInfo extends StatefulWidget {
  @override
  State<StudentScreenTransporterInfo> createState() => _StudentScreenTransporterInfoState();
}

class _StudentScreenTransporterInfoState extends State<StudentScreenTransporterInfo> {
  final _delayDuration = Duration(minutes: isDebugMode ? 1 : 5);
  @override
  Widget build(BuildContext context) {
    final _transporter = AppVar.appBloc.hesapBilgileri.studentTransporter;

    final _notificationTimGuarded = Fav.checkTimeGuardNotAllowed('t_s_nc_11', duration: _delayDuration, usePreferences: true);
    return AppScaffold(
        topBar: TopBar(leadingTitle: 'menu1'.translate),
        topActions: TopActionsTitle(title: _transporter == null ? 'transporterinfo'.translate : (_transporter.profileName! + ' / ' + (_transporter.plate ?? ''))),
        body: _transporter == null
            ? Body.child(
                child: EmptyState(
                emptyStateWidget: EmptyStateWidget.NORECORDS,
              ))
            : Body.singleChildScrollView(
                child: Column(
                children: [
                  if (_transporter.driverPhone.safeLength > 6)
                    ListTile(
                      onTap: () {
                        _transporter.driverPhone.launch(LaunchType.call);
                      },
                      trailing: Icon(Icons.phone, color: Colors.green),
                      title: Text(_transporter.driverName!, style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
                      subtitle: Text(_transporter.driverPhone!, style: TextStyle(color: Fav.design.primaryText)),
                    ),
                  if (_transporter.employeePhone.safeLength > 6)
                    ListTile(
                      onTap: () {
                        _transporter.employeePhone.launch(LaunchType.call);
                      },
                      trailing: Icon(Icons.phone, color: Colors.green),
                      title: Text(_transporter.employeeName!, style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
                      subtitle: Text(_transporter.employeePhone!, style: TextStyle(color: Fav.design.primaryText)),
                    ),
                  ElevatedButton(
                      onPressed: _notificationTimGuarded
                          ? () {}
                          : () async {
                              if (Fav.noConnection()) return;
                              final _sure = await Over.sure(message: 't_s_nc_1'.translate);
                              if (_sure != true) return;
                              Fav.timeGuardFunction('t_s_nc_11', _delayDuration, () async {
                                final _notification = InAppNotification(type: NotificationType.service);
                                _notification
                                  ..key = 6.makeKey
                                  ..title = AppVar.appBloc.hesapBilgileri.name
                                  ..content = 't_s_nc_2'.translate
                                  ..senderKey = AppVar.appBloc.hesapBilgileri.uid;
                                OverLoading.show();
                                await InAppNotificationService.sendInAppNotification(_notification, _transporter.key).then((value) {
                                  OverAlert.saveSuc();
                                }).catchError((err) {
                                  OverAlert.saveErr();
                                });
                                await OverLoading.close();
                                setState(() {});
                              }, usePreferences: true);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Fav.design.primary,
                      ),
                      child: (_notificationTimGuarded ? 'sendnotificationsuc' : 't_s_nc_1').translate.text.center.color(Colors.white).fontSize(20).make()),
                ],
              )));
  }
}
