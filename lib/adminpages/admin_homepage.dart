import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../appbloc/appvar.dart';
import '../appbloc/databaseconfig.model_helper.dart';
import 'helpers/delete_social_network.dart';
import 'screens/appchanges/changelogs/layout.dart';
import 'screens/changeschoolinfopages/changeschoolinfomain.dart';
import 'screens/evaulationadmin/evaulationadminmain.dart';
import 'screens/makeschoolgroup/layout.dart';
import 'screens/opendemoschool.dart';
import 'screens/openschoolpage.dart';
import 'screens/reviewschoolinfopages/reviewschoolinfomain.dart';
import 'screens/supermanagerpages/supermanagermain.dart';

class AdminHomePage extends StatelessWidget {
  final SuperUserInfo user;
  final User? firebaseUser;

  AdminHomePage(this.user, this.firebaseUser);
  @override
  Widget build(BuildContext context) {
    if (firebaseUser!.email!.isEmpty) return SizedBox();
    if (Get.isRegistered<SuperUserInfo>() == false) return SizedBox();
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AppScaffold(
        topBar: TopBar(leadingTitle: 'back'.translate, hideBackButton: true),
        topActions: TopActionsTitle(title: "Admin Home Page".translate),
        body: Body.singleChildScrollView(
          maxWidth: 720,
          child: AnimatedGroupWidget(
            children: <Widget>[
              MenuButton(
                name: "Review School Info".translate,
                iconData: Icons.add_location_alt,
                gradient: MyPalette.getGradient(324),
                onTap: () {
                  Fav.guardTo(ReviewSchoolInfoMainPage());
                },
              ),
              MenuButton(
                name: "Open Demo School".translate,
                iconData: Icons.padding,
                gradient: MyPalette.getGradient(325),
                onTap: () {
                  Fav.guardTo(OpenDemoSchoolInfoPage());
                },
              ),
              if (user.hasRegisterChool)
                MenuButton(
                  name: "Register School".translate,
                  iconData: Icons.add_business,
                  gradient: MyPalette.getGradient(326),
                  onTap: () {
                    Fav.guardTo(OpenSchoolInfoPage());
                  },
                ),
              if (user.hasChangeSchoolInfo)
                MenuButton(
                  name: "Change School Info".translate,
                  iconData: Icons.business_outlined,
                  gradient: MyPalette.getGradient(327),
                  onTap: () {
                    Fav.guardTo(ChangeSchoolInfoMainPage());
                  },
                ),
              if (user.hasSuperManagerRegister)
                MenuButton(
                  name: "Super Manager Settings".translate,
                  iconData: Icons.supervised_user_circle_outlined,
                  gradient: MyPalette.getGradient(328),
                  onTap: () {
                    Fav.guardTo(SuperManagerMainPage());
                  },
                ),

              if (user.isDeveloper)
                MenuButton(
                  name: "Delete Social Ag Data".translate,
                  iconData: Icons.delete,
                  gradient: MyPalette.getGradient(234),
                  onTap: () async {
                    final _sure = await Over.sure();
                    if (_sure) await DeleteSocialNetworkData.delete();
                  },
                ),
              if (user.hasAddEvaulationData)
                MenuButton(
                  name: "Evaulation Settings".translate,
                  iconData: Icons.assistant,
                  gradient: MyPalette.getGradient(444),
                  onTap: () {
                    Fav.guardTo(EvaluationAdminMain());
                  },
                ),
              // MenuButton(
              //   name: "Education Settings".translate,
              //   iconData: MdiIcons.bookEducation,
              //   gradient: MyPalette.getGradient(188),
              //   onTap: () {
              //     Fav.guardTo(EducationList(
              //       isAdmin: true,
              //       adminServerId: user.email,
              //     ));
              //   },
              // ),
              MenuButton(
                name: "Kurum gruplari".translate,
                iconData: MdiIcons.group,
                gradient: MyPalette.getGradient(189),
                onTap: () {
                  Fav.guardTo(MakeSchoolGroup());
                },
              ),

              MenuButton(
                name: "ChangeLogs".translate,
                iconData: Icons.devices_other,
                gradient: MyPalette.getGradient(31),
                onTap: () {
                  Fav.guardTo(ChangeLogPost(user));
                },
              ),

              MyRaisedButton(
                text: 'SignOut',
                onPressed: () async {
                  if (await Over.sure()) {
                    if (Get.isRegistered<SuperUserInfo>()) await Get.delete<SuperUserInfo>(force: true);
                    await FirebaseAuth.instance.signOut();
                    AppVar.appBloc.appConfig.ekolRestartApp!(true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
