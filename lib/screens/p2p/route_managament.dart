import 'package:mcg_extension/mcg_extension.dart';
import 'freestyle/layout.dart' deferred as freestyle_p2p;

class P2PMainRoutes {
  P2PMainRoutes._();

  static Future<void>? goFreeStyleP2PScreen() async {
    OverLoading.show();
    await freestyle_p2p.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(freestyle_p2p.P2PMain());
  }
}
