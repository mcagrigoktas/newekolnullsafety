import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../adminpages/screens/evaulationadmin/helper.dart';
import '../screens/educations/education_editors/layout.dart';
import '../screens/generallyscreens/edit_profile/change_password.dart';
import '../screens/loginscreen/loginscreen.dart';
import '../screens/managerscreens/evaulation/evaulationmain.dart';
import 'schoolreview/supermanagerreviewmain.dart';
import 'shareannouncements.dart';

class SuperManagerHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(
          leadingTitle: 'signout'.translate,
          backButtonPressed: () {
            Get.offAll(() => EkolSignInPage());
          }),
      topActions: TopActionsTitle(title: "manageinstutions".translate),
      body: Body.child(
        maxWidth: 480,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              name: 'schoollist'.translate,
              iconData: Icons.list_alt,
              gradient: MyPalette.getGradient(324),
              onTap: () {
                Fav.guardTo(SuperManagerReviewMainPage());
              },
            ),
            MenuButton(
              name: "shareannouncements".translate,
              iconData: Icons.announcement,
              gradient: MyPalette.getGradient(325),
              onTap: () {
                Fav.guardTo(ShareSuperManagerAnnouncements());
              },
            ),
            MenuButton(
              name: "evaulationscreenname".translate,
              iconData: MdiIcons.exclamation,
              gradient: MyPalette.getGradient(326),
              onTap: () {
                Fav.guardTo(EvaluationMain(EvaulationUserType.supermanager));
              },
            ),
            MenuButton(
              name: "Education Settings".translate,
              iconData: MdiIcons.bookEducation,
              gradient: MyPalette.getGradient(188),
              onTap: () {
                Fav.guardTo(EducationList());
              },
            ),
            32.heightBox,
            ListTile(
              onTap: () {
                Fav.to(ChangePasswordPage(
                  accountIsSuperManager: true,
                ));
              },
              title: 'changepassword'.translate.text.make(),
              leading: MdiIcons.lockReset.icon.color(Fav.design.primary).make(),
            ),
          ],
        ),
      ),
    );
  }
}
