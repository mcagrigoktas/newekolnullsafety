import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import 'appconfig.dart';
import 'appconfigs.dart';
import 'appentry/ekolappentry.dart';
import 'mainhelper.dart';

Future<void> main() async {
  //timeDilation = 6;
  if (isWeb) return runApp(const Center(child: Text('Only Mobile')));
  Get.put<AppConfig>(AppConfigs.getAppConfigs(FlavorType.speedsis), permanent: true);
  await MainHelper().initializeBeforeRunApp();
  runApp(AppEntry());
}
