import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../localization/usefully_words.dart';
import '../../../widgets/targetlistwidget.dart';
import 'controller.dart';

class WidgetSettingsPage extends StatelessWidget {
  WidgetSettingsPage();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WidgetSettingsPageController>(
        init: WidgetSettingsPageController(),
        builder: (controller) {
          return AppScaffold(
            topBar: TopBar(
              leadingTitle: 'menu1'.translate,
            ),
            topActions: TopActionsTitle(title: 'widgetsettings'.translate),
            body: Body.singleChildScrollView(
                scrollController: controller.scrollController,
                child: MyForm(
                  formKey: controller.formKey,
                  child: Column(
                    children: [
                      // if (kIsWeb)
                      //   DropDownMenu<int>(
                      //       name: 'favoriteswidgettype'.translate,
                      //       value: Fav.preferences.getInt('favoriteswidgettype', 1),
                      //       items: [
                      //         DropdownItem<int>(name: 'off'.translate, value: 0),
                      //         DropdownItem<int>(name: 'type'.translate + ': 1', value: 1),
                      //         DropdownItem<int>(name: 'type'.translate + ': 2', value: 2),
                      //       ],
                      //       onChanged: (value) {
                      //         Fav.preferences.setInt('favoriteswidgettype', value);
                      //         controller.update();
                      //       }),
                      ...controller.widgetList.map((e) {
                        final _isLargeScreen = context.width > 720;
                        Widget _current = const SizedBox();

                        final _removeButton = CupertinoIcons.clear_circled_solid.icon.color(Colors.redAccent).onPressed(() async {
                          final _sure = await Over.sure();
                          if (_sure) {
                            controller.widgetList.remove(e);
                            controller.formKey = GlobalKey<FormState>();
                            controller.update();
                          }
                        }).make();

                        if (e.isLinkWidget) {
                          Widget _nameWidget = MyTextFormField(
                            initialValue: e.name,
                            validatorRules: ValidatorRules(minLength: 3, req: true),
                            hintText: 'name'.translate,
                            onSaved: (value) {
                              e.name = value;
                            },
                          );
                          if (_isLargeScreen) _nameWidget = Expanded(child: _nameWidget, flex: 1);
                          Widget _photoWidget = MyPhotoUploadWidget(
                            initialValue: e.linkWidgetImageUrl,
                            saveLocation: AppVar.appBloc.hesapBilgileri.kurumID! + '/' + "WidgetFiles",
                            validatorRules: ValidatorRules(req: true, minLength: 3),
                            onSaved: (value) {
                              if (value != null) {
                                e.linkWidgetImageUrl = value;
                              }
                            },
                          );
                          Widget _linkUrl = MyTextFormField(
                            initialValue: e.linkWidgetUrl,
                            validatorRules: ValidatorRules(minLength: 3, req: true),
                            hintText: 'link'.translate,
                            onSaved: (value) {
                              e.linkWidgetUrl = value;
                            },
                          );
                          if (_isLargeScreen) _linkUrl = Expanded(child: _linkUrl, flex: 3);
                          Widget _targetList = TargetListWidget(
                            onSaved: (value) {
                              e.targetList = value;
                            },
                            initialValue: e.targetList ?? ['onlyteachers'],
                          );
                          final _childList = [_nameWidget, _linkUrl, _photoWidget];
                          _current = Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                                      child: 'linkwidget'.translate.text.bold.fontSize(24).make(),
                                    ),
                                  ),
                                  _removeButton,
                                ],
                              ),
                              _targetList,
                              _isLargeScreen ? Row(children: _childList) : Column(children: _childList),
                            ],
                          );
                        } else if (e.isCounterWidget) {
                          Widget _nameWidget = MyTextFormField(
                            initialValue: e.name,
                            validatorRules: ValidatorRules(minLength: 3, req: true),
                            hintText: 'name'.translate,
                            onSaved: (value) {
                              e.name = value;
                            },
                          );
                          if (_isLargeScreen) _nameWidget = Expanded(child: _nameWidget, flex: 1);
                          Widget _timeWidget = MyDateTimePicker(
                            initialValue: e.countTime,
                            onSaved: (value) {
                              if (value != null) {
                                e.countTime = value;
                              }
                            },
                            firstYear: DateTime.now().year,
                            lastYear: DateTime.now().year + 2,
                          );
                          if (_isLargeScreen) _timeWidget = Expanded(child: _timeWidget, flex: 2);

                          Widget _targetList = TargetListWidget(
                            onSaved: (value) {
                              e.targetList = value;
                            },
                            initialValue: e.targetList ?? ['onlyteachers'],
                          );
                          final Widget _hintWidget = 'counterwidgetwarning'.translate.text.color(Fav.design.card.text).center.fontSize(10).make().p2;
                          final _childList = [_nameWidget, _timeWidget];
                          _current = Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                                      child: 'counterwidget'.translate.text.bold.fontSize(24).make(),
                                    ),
                                  ),
                                  _removeButton,
                                ],
                              ),
                              _targetList,
                              _isLargeScreen ? Row(children: _childList) : Column(children: _childList),
                              _hintWidget,
                            ],
                          );
                        } else {
                          return const SizedBox();
                        }

                        return Card(color: Fav.design.card.background, child: _current);
                      }).toList()
                    ],
                  ),
                )),
            bottomBar: BottomBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyRaisedButton(onPressed: controller.addwidget, text: 'addwidget'.translate),
                  MyProgressButton(onPressed: controller.save, label: Words.save),
                ],
              ),
            ),
          );
        });
  }
}
