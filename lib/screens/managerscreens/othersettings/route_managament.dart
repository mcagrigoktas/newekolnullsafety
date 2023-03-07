import 'package:mcg_extension/mcg_extension.dart';
import 'user_permission/layout.dart' deferred as user_permission;

class OtherSettingsMainRoutes {
  OtherSettingsMainRoutes._();

  static Future<void>? goUserPermissionPage() async {
    OverLoading.show();
    await user_permission.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(user_permission.UserPermissionPageLayout());
  }
}
