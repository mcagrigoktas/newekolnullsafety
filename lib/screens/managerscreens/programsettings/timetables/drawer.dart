import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import '../helper.dart';
import 'asc/asc_export.dart';
import 'asc/asc_import.dart';
import 'controller.dart';
import 'print/widgets.dart';

class DrawerWidget extends StatelessWidget {
  final _controller = Get.find<TimaTableEditController>();

  @override
  Widget build(BuildContext context) {
    if (_controller.drawerType == DrawerType.menu) {
      Widget _current;
      _current = Column(
        children: <Widget>[
          8.heightBox,
          Text(
            'timetableprocesslist'.translate,
            style: TextStyle(color: Fav.design.primaryText, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: Text(
                  'cleartimetablehint'.translate,
                  style: TextStyle(color: Fav.design.primaryText.withAlpha(180), fontSize: 10),
                )),
                MyMiniRaisedButton(onPressed: _controller.clearTimeTable, text: 'cleartimetable'.translate),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: Text(
                  'savetimetablehint'.translate,
                  style: TextStyle(color: Fav.design.primaryText.withAlpha(180), fontSize: 10),
                )),
                Obx(
                  () => MyProgressButton(
                    mini: true,
                    onPressed: _controller.saveTimeTable,
                    label: Words.save,
                    isLoading: _controller.isLoadingSave.value,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: Text(
                  'sharetimetablehint'.translate,
                  style: TextStyle(color: Fav.design.primaryText.withAlpha(180), fontSize: 10),
                )),
                Obx(() => MyProgressButton(
                      mini: true,
                      onPressed: _controller.share,
                      label: 'share'.translate,
                      isLoading: _controller.isLoadingShare.value,
                    )),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          Text(
            'settings'.translate,
            style: TextStyle(color: Fav.design.primaryText, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          AdvanceDropdown<int>(
              iconData: MdiIcons.resize,
              initialValue: _controller.timeTableSettings.size,
              name: 'cellsize'.translate,
              items: [DropdownItem(name: 'small'.translate, value: 1), DropdownItem(name: 'medium'.translate, value: 2), DropdownItem(name: 'large'.translate, value: 3)],
              onChanged: (value) {
                _controller.timeTableSettings.changeCellSize(value);
                _controller.update();
                //  setState(() {});
              }),
          8.heightBox,
          AdvanceDropdown<bool>(
              iconData: MdiIcons.tablet,
              initialValue: _controller.timeTableSettings.boxColorIsTeacher,
              name: 'boxcolor'.translate,
              items: [
                DropdownItem(name: 'teacherboxcolor'.translate, value: true),
                DropdownItem(name: 'lessonboxcolor'.translate, value: false),
              ],
              onChanged: (value) {
                _controller.timeTableSettings.boxColorIsTeacher = value;
                _controller.update();
                //    setState(() {});
              }),
          8.heightBox,
          MyMultiSelect(
            name: 'visibledays'.translate,
            initialValue: List<String>.from(_controller.timeTableSettings.visibleDays!),
            context: context,
            items: (List<String>.from(AppVar.appBloc.schoolTimesService!.dataList.last.activeDays!)..sort((a, b) => a.compareTo(b))).map((day) => MyMultiSelectItem(day, DateTime(2019, 7, int.tryParse(day)!).dateFormat('EEEE'))).toList(),
            title: 'visibledays'.translate,
            iconData: MdiIcons.angular,
            onChanged: (value) {
              _controller.timeTableSettings.visibleDays = (value!)..sort((a, b) => a.compareTo(b));
              _controller.update();
            },
          ),
          8.heightBox,
          MyMultiSelect(
            name: 'visibleclass0'.translate,
            initialValue: List<String>.from(_controller.timeTableSettings.visibleClass!),
            context: context,
            items: AppVar.appBloc.classService!.dataList.map((sinif) => MyMultiSelectItem(sinif.key, sinif.name + (sinif.classType == 1 ? ('(' + ('classtype1').translate.substring(0, 1)) + ')' : ''))).toList(),
            title: 'visibleclass0'.translate,
            iconData: MdiIcons.eyeCheckOutline,
            onChanged: (value) {
              _controller.timeTableSettings.visibleClass = value;
              _controller.update();
            },
          ),
          // if (AppVar.appBloc.hesapBilgileri.kurumID.startsWith('demo'))
          Column(
            children: [
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyMiniRaisedButton(
                    onPressed: AscExportHelper.export,
                    text: 'ASC Export',
                  ),
                  MyMiniRaisedButton(
                    onPressed: AscImportHelper.import,
                    text: 'ASC Import',
                  ),
                ],
              ).px8,
            ],
          ),
        ],
      );
      return SafeArea(
        child: SingleChildScrollView(
          child: _current,
        ),
      );
    } else if (_controller.drawerType == DrawerType.settings) {
      Widget _current;
      _current = Column(
        children: [
          'publishedtimetables'.translate.text.bold.color(Fav.design.primaryText).make().pt8,
          Divider(),
          ...AppVar.appBloc.tableProgramService!.data.entries.toList().reversed.map((e) {
            Map _data = e.value;
            int _timeStamp = _data['timeStamp'];
            Map? _programData = _data['classProgram'];
            //  Map? _times = _data['times'];

            return ListTile(
              title: _timeStamp.dateFormat('d-MMM-yyyy, HH:mm').text.make(),
              trailing: TextButton(
                child: 'sendtable'.translate.text.make(),
                onPressed: () {
                  _controller.programData.clear();
                  _controller.programData.addAll(jsonDecode(jsonEncode(_programData)));
                  _controller.programData = ProgramHelper.makeProgramSturdy(_controller.programData, _controller.timesModel);
                  _controller.update();

                  Get.back();
                },
                style: TextButton.styleFrom(foregroundColor: Fav.design.primary),
              ),
            );
          }).toList()
        ],
      );
      return SafeArea(
        child: SingleChildScrollView(
          child: _current,
        ),
      );
    } else if (_controller.drawerType == DrawerType.print) {
      return SafeArea(
        child: FormStack(initialIndex: 0, children: [
          FormStackItem(name: 'fullprogram'.translate, child: FullProgramPrint()),
          FormStackItem(name: 'teacherprogrammenuname'.translate, child: TeacherProgramPrint()),
          FormStackItem(name: 'classprogrammenuname'.translate, child: ClassProgramPrint()),
        ]).p8,
      );
    }

    return SizedBox();
  }
}

enum DrawerType { settings, menu, print }
