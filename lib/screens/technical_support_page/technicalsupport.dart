import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../appbloc/appvar.dart';
import 'helper.dart';
import 'recovery_data_page.dart';

class TechnicalSupportPage extends StatelessWidget {
  TechnicalSupportPage();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        topBar: TopBar(leadingTitle: 'menu1'.translate),
        topActions: TopActionsTitle(
          title: 'callcenter'.translate,
        ),
        body: Body.child(
          maxWidth: 640,
          child: FormStack(
            initialIndex: 0,
            children: [
              FormStackItem(
                  name: 'contactinfo'.translate,
                  child: Column(
                    children: [
                      16.heightBox,
                      if (AppVar.appBloc.hesapBilgileri.gtM && AppVar.appBloc.appConfig.technicalSupportPhone.safeLength > 1)
                        MenuButton(
                          name: "callus".translate,
                          iconData: MdiIcons.phone,
                          gradient: MyPalette.getGradient(1777),
                          onTap: () {
                            AppVar.appBloc.appConfig.technicalSupportPhone.launch(LaunchType.call);
                          },
                        ),
                      if (AppVar.appBloc.appConfig.technicalSupportMail.safeLength > 1)
                        MenuButton(
                          name: "writeus".translate,
                          iconData: MdiIcons.leadPencil,
                          gradient: MyPalette.getGradient(192),
                          onTap: () async {
                            if (Fav.noConnection()) return;
                            var _result = await OverBottomSheet.show(BottomSheetPanel.simpleList(title: 'writeus'.translate, subTitle: 'writeushint'.translate, items: [
                              BottomSheetItem(name: 'refreshappdata'.translate, value: 2),
                              BottomSheetItem(name: 'sendmail'.translate, value: 1),
                              BottomSheetItem.cancel(),
                            ]));

                            if (_result == 1) {
                              await AppVar.appBloc.appConfig.technicalSupportMail.launch(LaunchType.mail);
                            } else if (_result == 2) {
                              await TecnicalSupportHelper.clearVersionAndRestartApp();
                            }
                          },
                        ),
                    ],
                  )),
              FormStackItem(
                  name: 'fixproblem'.translate,
                  child: Column(
                    children: [
                      16.heightBox,
                      if (!isWeb)
                        MenuButton(
                          name: "notificationnotcoming".translate,
                          iconData: MdiIcons.bellBadgeOutline,
                          gradient: MyPalette.getGradient(590),
                          onTap: () {
                            if (Fav.noConnection()) return;
                            Fav.timeGuardFunction(
                                'NotificationComingControl',
                                Duration(minutes: 5),
                                () {
                                  TecnicalSupportHelper.fixNotificationIssue();
                                },
                                usePreferences: true,
                                elseFunction: () {
                                  OverAlert.show(message: 'checkdone'.translate);
                                });
                          },
                        ),
                      MenuButton(
                        name: "refreshappdata".translate,
                        iconData: MdiIcons.databaseRefresh,
                        gradient: MyPalette.getGradient(62),
                        onTap: () async {
                          if (Fav.noConnection()) return;
                          final _sure = await Over.sure(
                            message: 'refreshappdatahint'.translate,
                            yesText: 'start'.translate,
                          );
                          if (_sure == true) {
                            Fav.timeGuardFunction(
                                'clearAllData',
                                Duration(days: 1),
                                () {
                                  TecnicalSupportHelper.clearVersionAndRestartApp();
                                },
                                usePreferences: true,
                                elseFunction: () {
                                  OverAlert.show(message: 'checkdone'.translate);
                                });
                          }
                        },
                      ),
                    ],
                  )),
              if (AppVar.appBloc.hesapBilgileri.gtM)
                FormStackItem(
                    name: 'recoverinfo'.translate,
                    child: Column(
                      children: [
                        16.heightBox,
                        MenuButton(
                          name: "recoverstudent".translate,
                          iconData: MdiIcons.recycle,
                          gradient: MyPalette.getGradient(1777),
                          onTap: () {
                            Fav.to(RecoverPage(tur: 0));
                          },
                        ),
                        MenuButton(
                          name: "recoverclass".translate,
                          iconData: MdiIcons.recycle,
                          gradient: MyPalette.getGradient(1777),
                          onTap: () {
                            Fav.to(RecoverPage(tur: 1));
                          },
                        ),
                        MenuButton(
                          name: "recoverteacher".translate,
                          iconData: MdiIcons.recycle,
                          gradient: MyPalette.getGradient(1777),
                          onTap: () {
                            Fav.to(RecoverPage(tur: 2));
                          },
                        ),
                        MenuButton(
                          name: "recoverlesson".translate,
                          iconData: MdiIcons.recycle,
                          gradient: MyPalette.getGradient(1777),
                          onTap: () {
                            Fav.to(RecoverPage(tur: 3));
                          },
                        ),
                      ],
                    )),
            ],
          ).p4,
        ));
  }
}
