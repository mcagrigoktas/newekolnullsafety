import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import 'appconfig.dart';
import 'appentry/qbankappentry.dart';
//import 'package:flutter/scheduler.dart' show timeDilation;
import 'mainhelper.dart';
import 'themelist/helper.dart';

Future<void> main() async {
  Get.put<AppConfig>(
      AppConfig(
        databaseVersion: 0,
        appType: AppType.qbank,
        appName: "QBANK",
        technicalSupportMail: 'goldenteknikdestek@gmail.com',
        technicalSupportPhone: '+905529514330',
        googleTextThemeList: [],
        themeList: [
          ThemeListModel.qbankDarkTheme(),
          ThemeListModel.qbankLightTheme(),
        ],
      ),
      permanent: true);
  //timeDilation = 6.0;
  await MainHelper().initializeBeforeRunApp();
  runApp(QbankAppEntry());
}
