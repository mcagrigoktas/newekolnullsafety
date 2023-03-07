import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../helpers/glassicons.dart';
import '../education_content/layout.dart';
import '../model.dart';
import 'controller.dart';

class EducationListEntrance extends StatelessWidget {
  final bool forMiniScreen;
  EducationListEntrance({
    this.forMiniScreen = true,
  });
  @override
  Widget build(BuildContext context) {
    return GetBuilder<EducationListEntranceController>(
        init: EducationListEntranceController(),
        builder: (controller) {
          return AppScaffold(
            isFullScreenWidget: forMiniScreen ? true : false,
            scaffoldBackgroundColor: forMiniScreen ? null : Colors.transparent,
            topBar: TopBar(
              leadingTitle: 'menu1'.translate,
              hideBackButton: !forMiniScreen,
            ),
            topActions: TopActionsTitleWithChild(
                title: forMiniScreen
                    ? TopActionsTitle(
                        title: 'educationlist'.translate,
                        color: GlassIcons.education.color,
                      )
                    : TopActionsTitle(
                        title: 'educationlist'.translate,
                        color: GlassIcons.education.color,
                        imgUrl: GlassIcons.education.imgUrl,
                      ),
                child: controller.classLevelList.length > 1
                    ? AdvanceDropdown(
                        onChanged: (dynamic value) {
                          controller.classLevel = value;
                          controller.filterItemList();
                          controller.update();
                        },
                        initialValue: controller.classLevel,
                        items: controller.classLevelList.map((e) => DropdownItem(value: e, name: ('classlevel' + e).translate)).toList(),
                        iconData: Icons.class_,
                      )
                    : SizedBox()),
            body: controller.itemList.isEmpty
                ? Body.child(child: EmptyState())
                : Body.staggeredGridViewBuilder(
                    padding: EdgeInsets.all(16),
                    crossAxisCount: context.width > 1200
                        ? 3
                        : context.width > 800
                            ? 2
                            : 1,
                    itemBuilder: (context, index) {
                      final _item = controller.itemList[index];
                      return GestureDetector(
                        onTap: () {
                          if (_item.type == EducationType.ekol) {
                            Fav.to(EducationContent(education: _item));
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MyCachedImage(imgUrl: _item.imgUrl!, width: 96, fit: BoxFit.cover),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [MyPalette.getColorFromCount(index), MyPalette.getColorFromCount(index).hue30], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dstATop),
                                          image: CacheHelper.imageProvider(imgUrl: _item.imgUrl!),
                                        )),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _item.name.text.color(Colors.white).bold.fontSize(24).make(),
                                        16.heightBox,
                                        _item.exp.text.color(Colors.white).make(),
                                      ],
                                    ).p16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: controller.itemList.length,
                  ),
          );
        });
  }
}
