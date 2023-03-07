import 'package:firebase_auth/firebase_auth.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../appbloc/databaseconfig.model_helper.dart';
import 'admin_homepage.dart' deferred as admin_home_page;

class AdminPagesMainRoutes {
  AdminPagesMainRoutes._();

  static Future<void>? goAdminPageHome(SuperUserInfo user, User? firebaseUser) async {
    OverLoading.show();
    await admin_home_page.loadLibrary();
    await OverLoading.close();
    return Fav.to(admin_home_page.AdminHomePage(user, firebaseUser));
  }
}
