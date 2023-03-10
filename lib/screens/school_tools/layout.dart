import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/glassicons.dart';
import '../../helpers/manager_authority_helper.dart';
import '../main/widgetsettingspage/layout.dart';
import 'prepare_my_student/helper.dart';
import 'school_widgets/school_widget_helper.dart';

class SchoolToolsPage extends StatelessWidget {
  final bool forMiniScreen;
  SchoolToolsPage({
    this.forMiniScreen = true,
  });
  @override
  Widget build(BuildContext context) {
    final _prepareMyStudentWidgetList = PrepareMyStudentHelper.getPrepareMyStudentWidget();
    final _linkWidgetList = SchoolWidgetHelper.getLinkWidgets();
    final _counterWidgetList = SchoolWidgetHelper.getCounterWidgets();

    return AppScaffold(
      isFullScreenWidget: forMiniScreen ? true : false,
      scaffoldBackgroundColor: forMiniScreen ? null : Colors.transparent,
      topBar: TopBar(leadingTitle: 'tools'.translate, hideBackButton: !forMiniScreen, trailingActions: [
        if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki2())
          AddIcon(onPressed: () {
            Fav.to(WidgetSettingsPage());
          }),
      ]),
      topActions: TopActionsTitle(title: "tools".translate, imgUrl: GlassIcons.tag.imgUrl, color: GlassIcons.tag.color),
      body: Body.singleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_prepareMyStudentWidgetList != null)
            _ToolPagesRow(
              children: _prepareMyStudentWidgetList,
              name: 'kindergardenstudenttools'.translate,
            ),
          if (_linkWidgetList != null)
            _ToolPagesRow(
              children: _linkWidgetList,
              name: 'shortcuts'.translate,
            ),
          if (_counterWidgetList != null)
            _ToolPagesRow(
              children: _counterWidgetList,
              name: 'counter'.translate,
            ),
        ],
      )),
    );
  }
}

class _ToolPagesRow extends StatelessWidget {
  final List<Widget>? children;
  final String? name;
  _ToolPagesRow({
    this.children,
    this.name,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        name.text.fontSize(24).bold.make(),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: children!,
          ),
        ),
      ],
    );
  }
}
