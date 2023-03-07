import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import 'appconfig.dart';
import 'appentry/qbankappentry.dart';
import 'mainhelper.dart';
import 'themelist/helper.dart';

Future<void> main() async {
  Get.put<AppConfig>(
      AppConfig(
          appType: AppType.qbank,
          databaseVersion: 0,
//        appId: "qbank",
//        isNeedServerID: false,
          appName: "T-area",
          technicalSupportMail: 'goldenteknikdestek@gmail.com',
          technicalSupportPhone: '+905529514330',
          googleTextThemeList: [],
          themeList: [
            ThemeListModel.qbankDarkTheme(),
            ThemeListModel.qbankLightTheme(),
          ]),
      permanent: true);
  await MainHelper().initializeBeforeRunApp();
  runApp(QbankAppEntry());
}
