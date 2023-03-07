import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/databaseconfig.model_helper.dart';
import '../../../../helpers/glassicons.dart';
import '../../../../localization/usefully_words.dart';
import 'controller.dart';
import 'post_item.dart';

// enum SocialFileType { Photo, Video, YoutubeVideo }

class ChangeLogPost extends StatelessWidget {
  final SuperUserInfo user;
  ChangeLogPost(this.user);
  @override
  Widget build(BuildContext context) {
    Get.findOrPut<PhotoVideoCompressSetting>(createFunction: () => PhotoVideoCompressSetting());
    return GetBuilder<ChangeLogPostController>(
        init: ChangeLogPostController(),
        builder: (controller) {
          final _dataList = controller.dataFetcherList;
          final _itemsWidget = ListView.builder(
              itemCount: _dataList.length,
              itemBuilder: (context, index) {
                final _item = _dataList[index];

                return PostItemWidget(
                  index: index,
                  isFirst: index == 0,
                  isLast: index == _dataList.length - 1,
                  item: _item,
                  comingToDeveloperPage: true,
                );
              });
          final _formWidget = MyForm(
            formKey: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AdvanceDropdown<String>(
                    name: 'Dil',
                    items: [DropdownItem(value: 'tr', name: 'Turkce')],
                    initialValue: controller.langList.first,
                    onSaved: (value) {
                      controller.data.targetLang = value;
                    },
                    validatorRules: ValidatorRules(req: true, minLength: 1),
                  ),
                  AdvanceDropdown<ChangeLogAppTarget>(
                    name: 'Hedef',
                    items: [
                      DropdownItem(value: ChangeLogAppTarget.all, name: 'Hepsi'),
                      DropdownItem(value: ChangeLogAppTarget.ekol, name: 'Ekol'),
                      DropdownItem(value: ChangeLogAppTarget.ekid, name: 'Ekid'),
                    ],
                    initialValue: ChangeLogAppTarget.all,
                    onSaved: (value) {
                      controller.data.appTarget = value;
                    },
                    validatorRules: ValidatorRules(req: true, minLength: 1),
                  ),
                  AdvanceDropdown<ChangeLogPostType>(
                    name: 'Post Turu',
                    items: [
                      DropdownItem(value: ChangeLogPostType.changelog, name: 'ChangeLog'),
                      DropdownItem(value: ChangeLogPostType.fix, name: 'Fix'),
                    ],
                    initialValue: ChangeLogPostType.changelog,
                    onSaved: (value) {
                      controller.data.postype = value;
                    },
                    validatorRules: ValidatorRules(req: true, minLength: 1),
                  ),
                  MyDateTimePicker(
                    initialValue: DateTime.now().millisecondsSinceEpoch,
                    onSaved: (value) {
                      controller.data.timeStamp = value;
                    },
                    title: 'date'.translate,
                  ),
                  MyTextFormField(
                    labelText: "header".translate,
                    iconData: MdiIcons.commentTextMultipleOutline,
                    onSaved: (value) {
                      controller.data.title = value;
                    },
                    validatorRules: ValidatorRules(minLength: 0, maxLength: 30),
                  ),
                  MyTextFormField(
                    labelText: "comment".translate,
                    iconData: MdiIcons.commentTextMultipleOutline,
                    onSaved: (value) {
                      controller.data.content = value;
                    },
                    validatorRules: ValidatorRules(minLength: 0, maxLength: 2500),
                    maxLines: null,
                  ),
                  MyTextFormField(
                    initialValue: '',
                    labelText: "Youtube link".translate,
                    iconData: MdiIcons.youtube,
                    validatorRules: ValidatorRules(req: false, minLength: 10, noGap: true),
                    onSaved: (value) {
                      controller.data.youtubeLink = value;
                    },
                  ),
                  MyMultiplePhotoUploadWidget(
                    dataImportance: DataImportance.veryHigh,
                    saveLocation: controller.saveLocation,
                    maxPhotoCount: 20,
                    onSaved: (value) {
                      if (value != null) {
                        controller.data.imgList = List<String>.from(value);
                      }
                    },
                  ),
                  16.heightBox,
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: MyRaisedButton(
                        color: GlassIcons.social.color,
                        text: Words.save,
                        iconData: Icons.save,
                        onPressed: controller.save,
                      ),
                    ),
                  ),
                  16.heightBox,
                  if (isWeb)
                    Text(
                      'videoonlyemobile'.translate,
                      style: TextStyle(color: Fav.design.disablePrimary),
                    ),
                ],
              ),
            ),
          );

          return AppScaffold(
            topBar: TopBar(leadingTitle: 'back'.translate),
            topActions: TopActionsTitle(title: "shareannouncements".translate, color: GlassIcons.social.color),
            body: Body.child(
                withSelectionArea: true,
                child: context.screenWidth > 720
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _formWidget),
                          Expanded(child: _itemsWidget),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(child: _formWidget),
                          Expanded(child: _itemsWidget),
                        ],
                      )),
            bottomBar: BottomBar.row(children: [
              if (user.hasChangeLogPost)
                MyRaisedButton(
                  color: GlassIcons.dailyReport.color,
                  text: 'publish'.translate,
                  iconData: Icons.share,
                  onPressed: controller.publish,
                )
            ]),
          );
        });
  }
}
