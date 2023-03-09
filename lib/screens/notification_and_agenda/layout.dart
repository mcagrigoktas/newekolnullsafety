import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../helpers/glassicons.dart';
import '../main/app_widgets/z_mainwidget.dart';
import '../main/macos_dock/macos_dock.dart';
import 'agenda/layout.dart';
import 'notification/layout.dart';
import 'other_widget/layout.dart';

class NotificationAndAgendaBigScreenPage extends StatelessWidget {
  NotificationAndAgendaBigScreenPage();
  @override
  Widget build(BuildContext context) {
    final _padding = context.screenHeight > 600 ? 16.0 : 8.0;
    return Row(
      children: [
        Expanded(
            child: Column(
          children: [
            Expanded(child: _NotificationWidget()),
            OtherWidgetForMainMenu(),
          ],
        )),
        _padding.widthBox,
        Expanded(child: _AgendaWidget()),
      ],
    );
  }
}

class NotificationAndAgendaMiniScreenWidget extends StatelessWidget {
  NotificationAndAgendaMiniScreenWidget();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          16.heightBox,
          _NotificationAndAgendaWidget(),
          OtherWidgetForMainMenu(),
          16.heightBox,
          SmallScreenDockItems(),
          16.heightBox,
          context.screenBottomPadding.heightBox,
        ],
      ),
    );
  }
}

class _NotificationAndAgendaWidget extends StatefulWidget {
  _NotificationAndAgendaWidget();

  @override
  State<_NotificationAndAgendaWidget> createState() => _NotificationAndAgendaWidgetState();
}

class _NotificationAndAgendaWidgetState extends State<_NotificationAndAgendaWidget> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Container(constraints: BoxConstraints(maxHeight: Get.context!.screenHeight / 2), child: NotificationWidgetContent(forMiniScreen: true)),
      SizedBox(height: Get.context!.screenHeight / 2, child: AgendaWidgetContent()),
    ];

    return Container(
      // constraints: forMiniScreen ? BoxConstraints(maxHeight: 460) : null,
      decoration: BoxDecoration(
        color: Fav.design.others['widget.primaryBackground'],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Fav.design.primaryText.withAlpha(15), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2C2E60).withOpacity(0.01),
            blurRadius: 2,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          12.heightBox,
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 12),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedOpacity(
                    opacity: _index == 0 ? 1.0 : 0.85,
                    duration: 200.milliseconds,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        if (_index == 1)
                          setState(() {
                            _index = 0;
                          });
                      },
                      child: _NotificationNameWidget(),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  width: 1,
                  height: 30,
                  color: Fav.design.primaryText.withAlpha(15),
                ),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: _index == 1 ? 1.0 : 0.85,
                    duration: 200.milliseconds,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        if (_index == 0)
                          setState(() {
                            _index = 1;
                          });
                      },
                      child: _AgendaNameWidget(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          8.heightBox,
          Stack(
            children: [
              AnimatedAlign(
                duration: 200.milliseconds,
                alignment: Alignment(_index == 1 ? 1 : -1, 0.0),
                child: AnimatedContainer(
                  margin: _index == 0 ? EdgeInsets.only(left: 48) : EdgeInsets.only(right: 48),
                  duration: 200.milliseconds,
                  width: context.width / 5,
                  height: 2,
                  color: _index == 1 ? GlassIcons.agenda.color : GlassIcons.notifcation.color,
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Fav.design.primaryText.withAlpha(13),
              ),
            ],
          ),
          AnimatedSize(
            duration: 222.milliseconds,
            child: IndexedStack(
              index: _index,
              children: [
                ...children.map((e) {
                  final _itemIndex = children.indexOf(e);
                  return AnimatedOpacity(
                    opacity: _index == _itemIndex ? 1.0 : 0.0,
                    duration: 200.milliseconds,
                    child: Offstage(offstage: _index != _itemIndex, child: e),
                  );
                }).toList()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationWidget extends StatelessWidget {
  _NotificationWidget();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Fav.design.others['widget.primaryBackground'], borderRadius: BorderRadius.circular(24), boxShadow: [
        BoxShadow(
          color: const Color(0xff2C2E60).withOpacity(0.01),
          blurRadius: 2,
          spreadRadius: 2,
          offset: const Offset(0, 0),
        ),
      ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
            child: _NotificationNameWidget(),
          ),
          Flexible(child: NotificationWidgetContent()),
          8.heightBox,
        ],
      ),
    );
  }
}

class _AgendaWidget extends StatelessWidget {
  _AgendaWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Fav.design.others['widget.primaryBackground'], borderRadius: BorderRadius.circular(24), boxShadow: [
        BoxShadow(
          color: const Color(0xff2C2E60).withOpacity(0.01),
          blurRadius: 2,
          spreadRadius: 2,
          offset: const Offset(0, 0),
        ),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
            child: _AgendaNameWidget(),
          ),
          Flexible(child: AgendaWidgetContent().px16),
          8.heightBox,
        ],
      ),
    );
  }
}

class _AgendaNameWidget extends StatelessWidget {
  final _controller = Get.find<MacOSDockController>();

  _AgendaNameWidget();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _isSmallLayout = _controller.isSmallLayoutEnable;
      final _badgeCount = _controller.agendaBadge.value;
      final _hintText = _badgeCount < 1 ? 'agendawidgethint'.translate : 'agendawidgethint2'.argsTranslate({'count': _badgeCount});

      if (_isSmallLayout) {
        return SizedBox(
          height: 36,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(GlassIcons.agenda.imgUrl!),
                    6.widthBox,
                    'agenda'.translate.text.color(GlassIcons.agenda.color!).autoSize.fontSize(18).maxLines(1).bold.make(),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: _badgeCount < 1
                    ? _hintText.text.end.color(Fav.design.widgetSecondaryText!).autoSize.fontSize(11).center.maxLines(1).make()
                    : AutoSizeText.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: _hintText.split('$_badgeCount').first),
                            TextSpan(text: '$_badgeCount', style: TextStyle(color: GlassIcons.agenda.color, fontWeight: FontWeight.w800, fontSize: 12)),
                            TextSpan(text: _hintText.split('$_badgeCount').last),
                          ],
                        ),
                        maxLines: 1,
                        maxFontSize: 18,
                        minFontSize: 8,
                        style: TextStyle(color: Fav.design.widgetSecondaryText, fontSize: 11),
                      ),
              ),
            ],
          ),
        );
      } else {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(GlassIcons.agenda.imgUrl!, height: 40),
            8.widthBox,
            Expanded(
              child: SizedBox(
                height: 48,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: 'agenda'.translate.text.color(GlassIcons.agenda.color!).autoSize.fontSize(24).maxLines(1).bold.make()),
                    Expanded(
                      flex: 3,
                      child: _badgeCount < 1
                          ? _hintText.text.end.color(Fav.design.widgetSecondaryText!).autoSize.fontSize(18).maxLines(1).make()
                          : AutoSizeText.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: _hintText.split('$_badgeCount').first),
                                  TextSpan(text: '$_badgeCount', style: TextStyle(color: GlassIcons.agenda.color, fontWeight: FontWeight.w800, fontSize: 21)),
                                  TextSpan(text: _hintText.split('$_badgeCount').last),
                                ],
                              ),
                              maxLines: 1,
                              maxFontSize: 18,
                              minFontSize: 8,
                              style: TextStyle(color: Fav.design.widgetSecondaryText, fontSize: 18),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    });
  }
}

class _NotificationNameWidget extends StatelessWidget {
  _NotificationNameWidget();
  final _controller = Get.find<MacOSDockController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _badgeCount = _controller.notificationBadge.value;
      final _hintText = _badgeCount < 1 ? 'notificationwidgethint'.translate : 'notificationwidgethint2'.argsTranslate({'count': _badgeCount});
      //  final _hintText = 'notificationwidgethint'.translate;
      final _isSmallLayout = _controller.isSmallLayoutEnable;

      if (_isSmallLayout) {
        return SizedBox(
          height: 36,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(GlassIcons.notifcation.imgUrl!),
                    6.widthBox,
                    'notifications'.translate.text.color(GlassIcons.notifcation.color!).autoSize.fontSize(18).maxLines(1).bold.make(),
                  ],
                ),
              ),
              // Expanded(flex: 2, child: _hintText.text.end.color(Fav.design.widgetSecondaryText).fontSize(_isSmallLayout ? 12 : 18).autoSize.maxLines(1).make()

              Expanded(
                flex: 3,
                child: _badgeCount < 1
                    ? _hintText.text.end.color(Fav.design.widgetSecondaryText!).fontSize(11).autoSize.maxLines(1).make()
                    : AutoSizeText.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: _hintText.split('$_badgeCount').first),
                            TextSpan(text: '$_badgeCount', style: TextStyle(color: GlassIcons.notifcation.color, fontWeight: FontWeight.w800, fontSize: 12)),
                            TextSpan(text: _hintText.split('$_badgeCount').last),
                          ],
                        ),
                        maxLines: 1,
                        maxFontSize: 18,
                        minFontSize: 8,
                        style: TextStyle(color: Fav.design.widgetSecondaryText, fontSize: 11),
                      ),
              ),
            ],
          ),
        );
      } else {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(GlassIcons.notifcation.imgUrl!, height: 40),
            8.widthBox,
            Expanded(
              child: SizedBox(
                height: 48,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: 'notifications'.translate.text.color(GlassIcons.notifcation.color!).autoSize.fontSize(24).maxLines(1).bold.make()),
                    // Expanded(flex: 2, child: _hintText.text.end.color(Fav.design.widgetSecondaryText).fontSize(_isSmallLayout ? 12 : 18).autoSize.maxLines(1).make()

                    Expanded(
                      flex: 3,
                      child: _badgeCount < 1
                          ? _hintText.text.end.color(Fav.design.widgetSecondaryText!).fontSize(18).autoSize.maxLines(1).make()
                          : AutoSizeText.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: _hintText.split('$_badgeCount').first),
                                  TextSpan(text: '$_badgeCount', style: TextStyle(color: GlassIcons.notifcation.color, fontWeight: FontWeight.w800, fontSize: 21)),
                                  TextSpan(text: _hintText.split('$_badgeCount').last),
                                ],
                              ),
                              maxLines: 1,
                              maxFontSize: 18,
                              minFontSize: 8,
                              style: TextStyle(color: Fav.design.widgetSecondaryText, fontSize: 18),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    });
  }
}
