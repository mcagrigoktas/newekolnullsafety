import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../generallyscreens/birthdaypage/layout.dart';
import '../../../main/menu_list_helper.dart';
import 'controller.dart';
import 'user_permission.dart';

class UserPermissionPageLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserPermissionPageController>(
      init: UserPermissionPageController(),
      builder: (controller) {
        return AppScaffold(
          topBar: TopBar(leadingTitle: 'back'.translate),
          topActions: TopActionsTitle(title: 'permissionlist'.translate),
          body: Body.singleChildScrollView(
              maxWidth: 720,
              child: Form(
                key: controller.formKey,
                child: MiniFormStack(
                  children: [
                    FormStackItem(
                        name: 'communicationpermissions'.translate,
                        child: Column(
                          children: [
                            if (AppVar.appBloc.hesapBilgileri.isEkid)
                              MySwitch(
                                initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.preparemystudent] ?? false,
                                name: "preparemystudentph".translate,
                                iconData: MdiIcons.eyeCheck,
                                onSaved: (value) {
                                  controller.data[PermissionEnum.preparemystudent] = value;
                                },
                              ),
                            _PermissionTile(
                              name: 'teachermaxpincount'.translate,
                              icon: Icons.pin_drop,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: AdvanceDropdown<int>(
                                      iconData: Icons.pin_drop,
                                      items: List.generate(6, (index) => DropdownItem(name: '$index', value: index)).toList()..add(DropdownItem(name: 'unlimited'.translate, value: 100)),
                                      onSaved: (value) {
                                        controller.data[PermissionEnum.teacherMaxPinAnnouncement] = value;
                                      },
                                      initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.teacherMaxPinAnnouncement] ?? 100,
                                      padding: Inset.h(8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            MySwitch(
                              initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.teacherAnnouncementsSharing] ?? false,
                              name: "teacherAnnouncementsSharing".translate,
                              iconData: MdiIcons.eyeCheck,
                              onSaved: (value) {
                                controller.data[PermissionEnum.teacherAnnouncementsSharing] = value;
                              },
                              onChanged: (value) {
                                controller.update();
                              },
                            ),
                            MySwitch(
                              initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.teacherSocialSharing] ?? false,
                              name: "teacherSocialSharing".translate,
                              iconData: MdiIcons.eyeCheck,
                              onSaved: (value) {
                                controller.data[PermissionEnum.teacherSocialSharing] = value;
                              },
                              onChanged: (value) {
                                controller.update();
                              },
                            ),
                            MySwitch(
                              initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.sendnotifyunpublisheditem] ?? false,
                              name: "sendnotifyunpublisheditem".translate,
                              iconData: MdiIcons.eyeCheck,
                              onSaved: (value) {
                                controller.data[PermissionEnum.sendnotifyunpublisheditem] = value;
                              },
                            ),
                            MySwitch(
                              initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.teacherCallParent] ?? false,
                              name: "teacherCallParent".translate,
                              iconData: MdiIcons.eyeCheck,
                              onSaved: (value) {
                                controller.data[PermissionEnum.teacherCallParent] = value;
                              },
                            ),
                            MySwitch(
                              initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.teacherMessageParent] ?? true,
                              name: "teacherMessageParent".translate,
                              iconData: MdiIcons.eyeCheck,
                              onSaved: (value) {
                                controller.data[PermissionEnum.teacherMessageParent] = value;
                              },
                            ),
                            MySwitch(
                              initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.teacherMessageManager] ?? false,
                              name: "teacherMessageManager".translate,
                              iconData: MdiIcons.eyeCheck,
                              onSaved: (value) {
                                controller.data[PermissionEnum.teacherMessageManager] = value;
                              },
                            ),
                            MySwitch(
                              initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.teacherMailParent] ?? false,
                              name: "teacherMailParent".translate,
                              iconData: MdiIcons.eyeCheck,
                              onSaved: (value) {
                                controller.data[PermissionEnum.teacherMailParent] = value;
                              },
                            ),
                            Container(
                              decoration: context.screenWidth < 720 ? BoxDecoration(color: Fav.design.primaryText.withAlpha(10), borderRadius: BorderRadius.circular(9)) : null,
                              child: Column(
                                children: [
                                  if (context.screenWidth < 720) 'hourblockhint'.translate.text.make().paddingOnly(left: 54),
                                  _PermissionTile(
                                    name: context.screenWidth < 720 ? '' : 'hourblockhint'.translate,
                                    icon: Icons.timer_off,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 135,
                                          child: AdvanceDropdown<int>(
                                            iconData: Icons.lock_clock,
                                            items: Iterable.generate(24, (e) => e).map((item) => DropdownItem(name: '$item:00', value: item)).toList(),
                                            onSaved: (value) {
                                              controller.data[PermissionEnum.bannedClockStartTime] = value;
                                            },
                                            initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.bannedClockStartTime] ?? 0,
                                            padding: Inset.h(8),
                                          ),
                                        ),
                                        '-'.translate.text.make(),
                                        SizedBox(
                                          width: 135,
                                          child: AdvanceDropdown<int>(
                                            iconData: Icons.lock_clock,
                                            items: Iterable.generate(24, (e) => e).map((item) => DropdownItem(name: '$item:00', value: item)).toList(),
                                            onSaved: (value) {
                                              controller.data[PermissionEnum.bannedClockEndTime] = value;
                                            },
                                            initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.bannedClockEndTime] ?? 23,
                                            padding: Inset.h(8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                    FormStackItem(
                        name: 'educationpermissions'.translate,
                        child: Column(
                          children: [
                            if (MenuList.hasTimeTable())
                              MySwitch(
                                initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.rollcallautonotification] ?? false,
                                name: "rollcallautonotification".translate,
                                iconData: MdiIcons.eyeCheck,
                                onSaved: (value) {
                                  controller.data[PermissionEnum.rollcallautonotification] = value;
                                },
                              ),
                            if (AppVar.appBloc.hesapBilgileri.isEkolOrUni || MenuList.hasTimeTable())
                              MySwitch(
                                initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.teacherHomeWorkSharing] ?? false,
                                name: "teacherHomeWorkSharing".translate,
                                iconData: MdiIcons.eyeCheck,
                                onSaved: (value) {
                                  controller.data[PermissionEnum.teacherHomeWorkSharing] = value;
                                },
                              ),
                            if (MenuList.hasTimeTable() || MenuList.hasSimpleP2P())
                              _PermissionTile(
                                name: 'banForP2PInDays'.translate,
                                icon: Icons.contact_support_sharp,
                                child: SizedBox(
                                  width: 135,
                                  child: AdvanceDropdown<int>(
                                    searchbarEnableLength: 1000,
                                    items: Iterable.generate(21, (e) => e + 1).map((e) => DropdownItem(name: '$e', value: e)).toList(),
                                    onSaved: (value) {
                                      controller.data[PermissionEnum.banForP2PInDays] = value;
                                    },
                                    initialValue: (AppVar.appBloc.permissionService!.data[PermissionEnum.banForP2PInDays] ?? 7),
                                    validatorRules: ValidatorRules(req: true),
                                  ),
                                ),
                              ),
                            if (MenuList.hasTimeTable())
                              MySwitch(
                                initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.studentCanP2PRequest] ?? false,
                                name: "studentCanP2PRequest".translate,
                                iconData: MdiIcons.eyeCheck,
                                onSaved: (value) {
                                  controller.data[PermissionEnum.studentCanP2PRequest] = value;
                                },
                              ),
                            if (MenuList.hasTimeTable())
                              MyMultiSelect(
                                name: 'p2prequesttimes'.translate,
                                initialValue: List<String>.from(AppVar.appBloc.permissionService!.data[PermissionEnum.p2pRequestTimes] ?? ['1', '2']),
                                context: context,
                                items: [
                                  MyMultiSelectItem('0', 'sameweek'.translate),
                                  MyMultiSelectItem('1', 'nextweek'.translate),
                                  MyMultiSelectItem('2', 'week2later'.translate),
                                ],
                                title: 'p2prequesttimes'.translate,
                                iconData: MdiIcons.eyeCheck,
                                validatorRules: ValidatorRules(minLength: 1),
                                onSaved: (value) {
                                  controller.data[PermissionEnum.p2pRequestTimes] = value;
                                },
                              ),
                            if (MenuList.hasSimpleP2P())
                              _PermissionTile(
                                name: 'p2pp1'.translate,
                                icon: Icons.contact_support_sharp,
                                child: SizedBox(
                                  width: 135,
                                  child: AdvanceDropdown<int>(
                                    items: Iterable.generate(25, (e) => e + 1).map((e) => DropdownItem(name: '$e', value: e)).toList(),
                                    onSaved: (value) {
                                      controller.data[PermissionEnum.p2pp1] = value;
                                    },
                                    initialValue: (AppVar.appBloc.permissionService!.data[PermissionEnum.p2pp1] ?? 1),
                                    validatorRules: ValidatorRules(req: true),
                                  ),
                                ),
                              ),
                            if (MenuList.hasSimpleP2P())
                              _PermissionTile(
                                name: 'p2pp2'.translate,
                                icon: Icons.contact_support_sharp,
                                child: SizedBox(
                                  width: 135,
                                  child: AdvanceDropdown<int>(
                                    searchbarEnableLength: 100,
                                    items: Iterable.generate(5, (e) => e + 1).map((e) => DropdownItem(name: '$e', value: e)).toList(),
                                    onSaved: (value) {
                                      controller.data[PermissionEnum.p2pp2] = value;
                                    },
                                    initialValue: (AppVar.appBloc.permissionService!.data[PermissionEnum.p2pp2] ?? 1),
                                    validatorRules: ValidatorRules(req: true),
                                  ),
                                ),
                              ),
                            if (MenuList.hasSimpleP2P())
                              _PermissionTile(
                                name: 'p2pp3'.translate,
                                icon: Icons.contact_support_sharp,
                                child: SizedBox(
                                  width: 135,
                                  child: AdvanceDropdown<int>(
                                    items: Iterable.generate(5, (e) => e + 1).map((e) => DropdownItem(name: '$e', value: e)).toList(),
                                    onSaved: (value) {
                                      controller.data[PermissionEnum.p2pp3] = value;
                                    },
                                    initialValue: (AppVar.appBloc.permissionService!.data[PermissionEnum.p2pp3] ?? 1),
                                    validatorRules: ValidatorRules(req: true),
                                  ),
                                ),
                              ),
                            if (MenuList.hasSimpleP2P())
                              _PermissionTile(
                                name: 'p2pp4'.translate,
                                icon: Icons.contact_support_sharp,
                                child: SizedBox(
                                  width: 135,
                                  child: AdvanceDropdown<int>(
                                    items: Iterable.generate(5, (e) => e + 1).map((e) => DropdownItem(name: '$e', value: e)).toList(),
                                    onSaved: (value) {
                                      controller.data[PermissionEnum.p2pp4] = value;
                                    },
                                    initialValue: (AppVar.appBloc.permissionService!.data[PermissionEnum.p2pp4] ?? 1),
                                    validatorRules: ValidatorRules(req: true),
                                  ),
                                ),
                              ),
                            if (MenuList.hasSimpleP2P())
                              MySwitch(
                                initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.p2pp5] ?? true,
                                name: "p2pp5".translate,
                                iconData: MdiIcons.eyeCheck,
                                onSaved: (value) {
                                  controller.data[PermissionEnum.p2pp5] = value;
                                },
                              ),
                            if (MenuList.hasSimpleP2P() || MenuList.hasTimeTable())
                              MySwitch(
                                initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.sendTeacherNotificationForP2p] ?? false,
                                name: "sendTeacherNotificationForP2p".translate,
                                iconData: MdiIcons.eyeCheck,
                                onSaved: (value) {
                                  controller.data[PermissionEnum.sendTeacherNotificationForP2p] = value;
                                },
                              ),
                            //? Ilerde simple p2p ile ilgili student requests yazacagin zaman bunu acabilirsin
                            // if (MenuList.hasSimpleP2P() && false)
                            //   MySwitch(
                            //     initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.p2pp6] ?? false,
                            //     name: "p2pp6".translate,
                            //     iconData: MdiIcons.eyeCheck,
                            //     onSaved: (value) {
                            //       controller.data[PermissionEnum.p2pp6] = value;
                            //     },
                            //   ),
                            if (MenuList.hasVideoLesson())
                              MySwitch(
                                initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.teacherCanDeleteOwnELesson] ?? false,
                                name: "tcdoel".translate,
                                iconData: MdiIcons.eyeCheck,
                                onSaved: (value) {
                                  controller.data[PermissionEnum.teacherCanDeleteOwnELesson] = value;
                                },
                              ),
                          ],
                        )),
                    FormStackItem(
                        name: 'otherpermissions'.translate,
                        child: Column(
                          children: [
                            MySwitch(
                              initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.studentCanChangePhoto] ?? true,
                              name: "studentcanchangephoto".translate,
                              iconData: MdiIcons.eyeCheck,
                              onSaved: (value) {
                                controller.data[PermissionEnum.studentCanChangePhoto] = value;
                              },
                            ),
                            if (MenuList.hasBirthdayList())
                              MySwitch(
                                initialValue: AppVar.appBloc.permissionService!.data[PermissionEnum.addBirthdayItemsInAgenda] ?? true,
                                name: "blaa".translate,
                                iconData: MdiIcons.eyeCheck,
                                onSaved: (value) {
                                  controller.data[PermissionEnum.addBirthdayItemsInAgenda] = value;
                                  () {
                                    BirthDayHelper.addAgendaBirthdayItems();
                                  }.delay(2200);
                                },
                              ),
                          ],
                        )),
                  ],
                ),
              )),
          bottomBar: BottomBar.saveButton(onPressed: controller.submit, isLoading: controller.isLoading),
        );
      },
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final Widget? child;
  final IconData? icon;
  final String? name;
  _PermissionTile({this.child, this.icon, this.name});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        16.widthBox,
        Icon(icon, color: Fav.design.primaryText),
        16.widthBox,
        Expanded(child: name.text.maxLines(2).autoSize.make()),
        child!,
      ],
    );
  }
}
