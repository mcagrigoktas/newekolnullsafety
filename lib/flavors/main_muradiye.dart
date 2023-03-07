import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import 'appconfig.dart';
import 'appconfigs.dart';
import 'appentry/ekolappentry.dart';
import 'mainhelper.dart';

Future<void> main() async {
  if (isWeb) return runApp(const Center(child: Text('Only Mobile')));

  Get.put<AppConfig>(AppConfigs.getAppConfigs(FlavorType.muradiye), permanent: true);
  await MainHelper().initializeBeforeRunApp();
  runApp(AppEntry());
}
