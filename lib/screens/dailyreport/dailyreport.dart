import 'package:flutter/material.dart';

import '../../appbloc/appvar.dart';
import 'dailreportteacherscreen.dart';
import 'dailyreportstudentscreen.dart';

class DailyReportPage extends StatelessWidget {
  final bool forMiniScreen;
  DailyReportPage({
    this.forMiniScreen = true,
  });
  @override
  Widget build(BuildContext context) {
    if (AppVar.appBloc.hesapBilgileri.gtS) {
      return StreamBuilder<Object>(
          stream: AppVar.appBloc.dailyReportService!.stream,
          builder: (context, snapshot) => DailyReportStudentScreen(
                forMiniScreen: forMiniScreen,
              ));
    }

    return StreamBuilder<Object>(
        stream: AppVar.appBloc.dailyReportProfileService!.stream,
        builder: (context, snapshot) {
          return DailyReportTeacherScreen(
            forMiniScreen: forMiniScreen,
          );
        });
  }
}
