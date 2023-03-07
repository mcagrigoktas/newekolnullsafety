import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/appfunctions.dart';
import '../managerscreens/programsettings/programlistmodels.dart';
import 'widgets.dart';

class RehberlikWidget extends StatefulWidget {
  @override
  _RehberlikWidgetState createState() => _RehberlikWidgetState();
}

class _RehberlikWidgetState extends State<RehberlikWidget> {
  Widget _buildWidget = Container();
  TimeTableSettings timeTableSettings = TimeTableSettings();

  @override
  void initState() {
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      _buildWidget = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: TeacherFunctions.getGuidanceClassList()
            .map((sinif) => Container(
                  height: timeTableSettings.lessonNumberHeight + 13,
                  padding: Inset.hv(8, 4),
                  decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4.0), boxShadow: [BoxShadow(color: Colors.amber.withAlpha(180), blurRadius: 1)]),
                  margin: const EdgeInsets.all(1),
                  child: Text(sinif.name!, style: const TextStyle(color: Colors.white)),
                ))
            .toList(),
      );
    } else if (AppVar.appBloc.hesapBilgileri.gtS) {
      final _sinif = AppVar.appBloc.classService!.dataListItem(AppVar.appBloc.hesapBilgileri.class0!);
      //  .singleWhere((sinif) => sinif.key == appBloc.hesapBilgileri.class0, orElse: () => null);
      if (_sinif != null) {
        final _teacher = AppVar.appBloc.teacherService!.dataListItem(_sinif.classTeacher!);
        String _teacherName = '';
        if (_teacher != null) {
          _teacherName = ' (${_teacher.name})';
        }

        _buildWidget = Container(
          height: timeTableSettings.lessonNumberHeight + 13,
          padding: Inset.hv(8, 4),
          decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4.0), boxShadow: [BoxShadow(color: Colors.amber.withAlpha(180), blurRadius: 1)]),
          margin: const EdgeInsets.all(1),
          child: Text(_sinif.name! + _teacherName, style: const TextStyle(color: Colors.white)),
        );
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TimeTableLessonCellWidget(
          width: 80,
          height: timeTableSettings.lessonNumberHeight + 13,
          boxColor: Fav.design.bottomNavigationBar.background,
          boxShadowColor: Fav.design.bottomNavigationBar.background.withAlpha(180),
          text1: 'guidance'.translate + ':',
          text1Style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
          text2Style: TextStyle(color: Fav.design.primaryText, fontSize: 8),
          autoFitChild: true,
        ),
        2.widthBox,
        _buildWidget,
        16.widthBox,
      ],
    );
  }
}
