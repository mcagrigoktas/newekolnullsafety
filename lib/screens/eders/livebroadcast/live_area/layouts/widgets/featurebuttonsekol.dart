import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../../../appbloc/appvar.dart';
import '../controller.dart';
import '../livelessonmenutoolbarekol.dart';
import 'advancedClass/controller.dart';

class FeatureButtons extends StatelessWidget {
  FeatureButtons();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnlineLessonController>();
    return SizedBox(
      width: 64,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(width: double.infinity),
              4.heightBox,
              FittedBox(
                fit: BoxFit.fitWidth,
                child: MyMiniRaisedButton(
                  text: 'close'.toUpperCase().translate,
                  color: Colors.redAccent,
                  boldText: true,
                  onPressed: () {
                    if (controller.isBackButtonPressed == false) {
                      controller.isBackButtonPressed = true;
                      controller.onBackPressed();
                    }
                  },
                ),
              ).px2,
              32.heightBox,
              // if (controller.extraMenuType != ExtraMenuType.closed)
              //   SideMenuShortCut(
              //     onTap: () {
              //       controller.extraMenuType = ExtraMenuType.closed;
              //       controller.update();
              //     },
              //     iconData: controller.extraMenuType == ExtraMenuType.closed ? Icons.arrow_back : Icons.close,
              //     iconColor: Colors.red,
              //     title: controller.extraMenuType == ExtraMenuType.closed ? 'back'.translate : 'close'.translate,
              //   ),
              if (controller.isOnlineUserListEnable)
                SideMenuShortCut(
                  onTap: () {
                    controller.extraMenuType = controller.extraMenuType != ExtraMenuType.onlineStudentList ? ExtraMenuType.onlineStudentList : ExtraMenuType.closed;
                    controller.update();
                  },
                  iconData: MdiIcons.accountCheck,
                  title: 'online'.translate,
                  extraTitle: controller.onlineUsers.length.toString(),
                  extraDataBacckgroundColor: Colors.green,
                ),
              if (controller.isOnlineUserListEnable)
                SideMenuShortCut(
                  onTap: () {
                    controller.extraMenuType = controller.extraMenuType != ExtraMenuType.offlineStudentList ? ExtraMenuType.offlineStudentList : ExtraMenuType.closed;
                    controller.update();
                  },
                  iconData: MdiIcons.accountOff,
                  title: 'offline'.translate,
                  extraTitle: (controller.targetList.length - controller.onlineUsers.length).toString(),
                  extraDataBacckgroundColor: Colors.red,
                ),
              if (controller.isLogDataEnable)
                SideMenuShortCut(
                  onTap: () {
                    controller.extraMenuType = controller.extraMenuType != ExtraMenuType.logData ? ExtraMenuType.logData : ExtraMenuType.closed;
                    controller.update();
                  },
                  iconData: Icons.data_usage,
                  title: 'logs'.translate,
                ),
              if (!controller.videoChatSettings.isChatDisable)
                SideMenuShortCut(
                  onTap: () {
                    controller.extraMenuType = controller.extraMenuType != ExtraMenuType.chats ? ExtraMenuType.chats : ExtraMenuType.closed;
                    controller.newMessageReceived = 0;
                    controller.update();
                    controller.scrollChat();
                  },
                  iconData: Icons.message,
                  title: 'chats'.translate,
                  extraDataBacckgroundColor: Colors.deepPurpleAccent,
                  extraTitle: controller.newMessageReceived == 0 ? null : controller.newMessageReceived.toString(),
                ),
              32.heightBox,
              if (controller.isCamMicEnable)
                SideMenuShortCut(
                  onTap: controller.changeMicStatus,
                  iconData: controller.micEneble ? Icons.mic : Icons.mic_off,
                  title: 'mic'.translate,
                ),
              if (controller.isCamMicEnable)
                SideMenuShortCut(
                  onTap: controller.changeCamStatus,
                  iconData: controller.videoEnable ? Icons.videocam : Icons.videocam_off,
                  title: 'cam'.translate,
                ),
              if (AppVar.appBloc.hesapBilgileri.gtS)
                SideMenuShortCut(
                  onTap: controller.raiseHand,
                  iconData: Icons.sports_handball,
                  title: 'raisehand'.translate,
                ),
              if (controller.isViewChangeEnable)
                SideMenuShortCut(
                  onTap: controller.changeTileViewStatus,
                  iconData: controller.liveLessonType == LiveLessonType.Jitsi ? (!controller.tileViewOpen ? Icons.view_comfortable : Icons.view_day) : (Get.find<AdvancedClassController>().layoutType == 1 ? Icons.view_comfortable : Icons.view_day),
                  title: 'view'.translate,
                ),
              32.heightBox,
              if (controller.isScreenShareButtonEnable)
                SideMenuShortCut(
                  onTap: controller.shareScreen,
                  iconData: Icons.screen_share,
                  title: 'screenshare'.translate,
                ),

              if (controller.isMuteEveryoneEnable)
                SideMenuShortCut(
                  onTap: controller.muteEveryone,
                  iconData: MdiIcons.volumeOff,
                  title: 'muteeveryone'.translate,
                ),
              if (AppVar.appBloc.hesapBilgileri.gtMT)
                SideMenuShortCut(
                  onTap: () {
                    controller.openRollCallScreen();
                  },
                  iconData: Icons.assignment_ind,
                  title: 'makerollcall'.translate,
                ),
              if (controller.settingButtonEnable)
                SideMenuShortCut(
                  onTap: () {
                    controller.extraMenuType = controller.extraMenuType != ExtraMenuType.settings ? ExtraMenuType.settings : ExtraMenuType.closed;
                    controller.update();
                  },
                  iconData: Icons.settings,
                  title: 'settings'.translate,
                ),
              if (controller.isOtherButtonEnable)
                SideMenuShortCut(
                  onTap: () {
                    controller.extraMenuType = controller.extraMenuType != ExtraMenuType.otherMenu ? ExtraMenuType.otherMenu : ExtraMenuType.closed;
                    controller.update();
                  },
                  iconData: MdiIcons.menu,
                  title: 'other'.translate,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SideMenuShortCut extends StatelessWidget {
  final Function()? onTap;
  final IconData? iconData;
  final String? title;
  final String? extraTitle;
  final Color? extraDataBacckgroundColor;
  final Color? iconColor;
  SideMenuShortCut({this.onTap, this.iconData, this.title, this.extraTitle, this.extraDataBacckgroundColor, this.iconColor});

  @override
  Widget build(BuildContext context) {
    ///todo illeride InkWell yapabilirsin
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Divider(color: Fav.design.primaryText.withAlpha(22), height: 1, endIndent: 4, indent: 4),
          8.heightBox,
          Icon(iconData, color: iconColor ?? Fav.design.primaryText),
          if (title != null) Text(title!, textAlign: TextAlign.center, style: TextStyle(color: Fav.design.primaryText, fontSize: 10)),
          if (extraTitle != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
              decoration: ShapeDecoration(shape: const StadiumBorder(), color: extraDataBacckgroundColor),
              child: Text(extraTitle!, style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          8.heightBox,
          Divider(color: Fav.design.primaryText.withAlpha(22), height: 1, endIndent: 4, indent: 4),
        ],
      ),
    );
  }
}
