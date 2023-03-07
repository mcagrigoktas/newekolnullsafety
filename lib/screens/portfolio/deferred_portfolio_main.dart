import 'package:flutter/cupertino.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../../models/notification.dart';
import '../main/macos_dock/macos_dock.dart';
import 'model.dart';
import 'portfolio_manager_main.dart';
import 'portfolio_students_main.dart';

class DeferredPortfolioMain extends StatelessWidget {
  final bool forMiniScreen;
  DeferredPortfolioMain({
    this.forMiniScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    PortfolioType initialIndex = Get.find<MacOSDockController>().getPageArgs(PageName.pM) as PortfolioType? ?? PortfolioType.examreport;

    if (AppVar.appBloc.hesapBilgileri.gtMT) {
      return PortfolioTeachersMain(initialIndex: initialIndex);
    } else {
      return PortfolioStudentsMain(forMiniScreen: forMiniScreen, initialIndex: initialIndex);
    }
  }
}
