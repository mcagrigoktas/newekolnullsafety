import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../flavors/appconfig.dart';
//import 'pages/permissions.dart';
import 'pages/school_options.dart';
import 'pages/schoolinfopage.dart';
import 'pages/terms/termspage.dart';

class SchoolSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffoldWithTabBar(
      topBar: TopBar(leadingTitle: 'menu1'.translate),
      title: TopActionsTitle(title: "schoolsettings".translate),
      tabs: [
        ScaffoldTabMenu(name: "schoolinfo".translate, value: 0, body: Body.singleChildScrollView(child: SchoolInfoPage(), maxWidth: 600)),
        if (AppVar.appConfig.smsCountry == Country.tr) ScaffoldTabMenu(name: "settings".translate, value: 3, body: Body.singleChildScrollView(child: SchoolOptions(), maxWidth: 600)),
        //  ScaffoldTabMenu(name: "permissionlist".translate, value: 1, body: Body.singleChildScrollView(child: PermissionsPage(), maxWidth: 600)),
        ScaffoldTabMenu(name: "termsettings".translate, value: 2, body: Body.singleChildScrollView(child: Terms(), maxWidth: 600)),
      ],
    );
  }
}
