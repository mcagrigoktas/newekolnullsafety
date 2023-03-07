import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../../localization/usefully_words.dart';
import '../../helper.dart';
import 'controller.dart';
import 'model.dart';

class EarningList extends StatelessWidget {
  final EvaulationUserType girisTuru;
  final MiniFetcher<EarningItem>? earningListFetcher;
  final String? genelMudurlukKurumId;
  EarningList(this.earningListFetcher, this.girisTuru, this.genelMudurlukKurumId);

  @override
  Widget build(BuildContext context) {
    if (girisTuru == EvaulationUserType.admin) {
      return AppScaffold(
        topBar: TopBar(),
        body: Body(
            child: Center(
          child: 'Admin Sayfasinda bu islem icin kilitli'.text.make(),
        )),
      );
    }
    return GetBuilder<EarningListController>(
        init: EarningListController(earningListFetcher, girisTuru, genelMudurlukKurumId),
        builder: (controller) {
          final Widget _newButton = Icons.add.icon.color(Fav.design.appBar.text).onPressed(controller.clickNewItem).make();

          final Widget _middle = (controller.newItem != null
                  ? 'new'.translate
                  : controller.selectedItem != null
                      ? controller.selectedItem!.name
                      : controller.menuName.translate)
              .text
              .bold
              .color(Fav.design.primary)
              .maxLines(1)
              .fontSize(18)
              .autoSize
              .make();

          final _topBar = controller.newItem != null
              ? RTopBar.sameAll(leadingIcon: Icons.clear_rounded, leadingTitle: 'cancelnewentry'.translate, backButtonPressed: controller.cancelNewEntry, middle: _middle)
              : RTopBar(
                  mainLeadingTitle: 'menu1'.translate,
                  leadingTitleMainEqualBoth: true,
                  detailLeadingTitle: controller.menuName.translate,
                  detailBackButtonPressed: controller.detailBackButtonPressed,
                  detailTrailingActions: [
                    _newButton,
                  ],
                  mainTrailingActions: [_newButton],
                  bothTrailingActions: [
                    _newButton,
                  ],
                  mainMiddle: _middle,
                  detailMiddle: _middle,
                  bothMiddle: _middle,
                );
          Body? _leftBody;
          Body? _rightBody;
          if (controller.isPageLoading) {
            _leftBody = Body.child(child: MyProgressIndicator(isCentered: true));
          } else if (controller.newItem == null && controller.itemList.isEmpty) {
            _leftBody = Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDSWITHPLUS));
          } else {
            _leftBody = controller.newItem != null
                ? null
                : Body.listviewBuilder(
                    pageStorageKey: controller.listViewPageStorageKey,
                    listviewFirstWidget: MySearchBar(
                      onChanged: (text) {
                        controller.makeFilter(text);
                        controller.update();
                      },
                      resultCount: controller.filteredItemList.length,
                      initialText: controller.filteredText,
                    ).p4,
                    itemCount: controller.filteredItemList.length,
                    itemBuilder: (context, index) => MyCupertinoListTile(
                      title: controller.filteredItemList[index].name,
                      onTap: () {
                        controller.selectItem(controller.filteredItemList[index]);
                      },
                      isSelected: controller.filteredItemList[index].key == controller.itemData?.key,
                    ),
                  );

            _rightBody = controller.itemData == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : Body.singleChildScrollView(
                    maxWidth: 720,
                    withKeyboardCloserGesture: true,
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: <Widget>[
                          MyTextFormField(
                            labelText: 'name'.translate,
                            initialValue: controller.itemData!.name,
                            iconData: MdiIcons.account,
                            validatorRules: ValidatorRules(req: true, minLength: 6),
                            onSaved: (value) {
                              controller.itemData!.name = value;
                            },
                          ),
                          MyTextFormField(
                            maxLines: null,
                            labelText: 'content'.translate,
                            hintText: 'enterbuttonhint'.translate,
                            initialValue: controller.itemData!.content,
                            iconData: MdiIcons.text,
                            validatorRules: ValidatorRules(req: true, minLength: 30),
                            onSaved: (value) {
                              controller.itemData!.content = value;
                            },
                          ),
                        ],
                      ),
                    ));
          }

          RBottomBar? _bottomBar;
          if (controller.itemData != null && (controller.visibleScreen == VisibleScreen.detail)) {
            Widget _bottomChild = Row(
              children: [
                if (controller.selectedItem != null)
                  ConfirmButton(
                    title: Words.delete,
                    sureText: 'sure'.translate,
                    iconData: Icons.delete,
                    yesPressed: controller.delete,
                  ).pl16,
                const Spacer(),
                MyProgressButton(
                  onPressed: controller.save,
                  label: Words.save,
                  isLoading: controller.isLoading,
                ).pr16
              ],
            );
            _bottomBar = RBottomBar(
              bothChild: _bottomChild,
              detailChild: _bottomChild,
            );
          }

          return AppResponsiveScaffold(
            topBar: _topBar,
            leftBody: _leftBody,
            rightBody: _rightBody,
            visibleScreen: controller.visibleScreen,
            bottomBar: _bottomBar,
          );
        });
  }
}
