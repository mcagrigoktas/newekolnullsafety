import 'package:mcg_extension/mcg_extension.dart';
import 'mainschoolsettings.dart' deferred as school_settings;

class SchoolSettingsMainRoutes {
  SchoolSettingsMainRoutes._();

  static Future<void>? goSchoolSettings() async {
    OverLoading.show();
    await school_settings.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(school_settings.SchoolSettingsPage());
  }
}
