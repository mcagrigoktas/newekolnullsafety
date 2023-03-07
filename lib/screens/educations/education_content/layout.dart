import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart' as wp;

import '../education_editors/model.dart';
import '../model.dart';
import 'controller.dart';

class EducationContent extends StatelessWidget {
  final Education? education;
  EducationContent({required this.education});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<EducationContentController>(
        init: EducationContentController(education),
        builder: (controller) {
          return AppScaffold(
            topBar: TopBar(leadingTitle: 'educationlist'.translate),
            topActions: TopActionsTitle(title: education!.name!, color: Fav.design.primaryText),
            body: Body.child(
                maxWidth: 720,
                child: IndexedTreeView<EducationNode>(
                  initialItem: controller.initialRoot,
                  controller: controller.treeViewController as IndexedTreeViewController<EducationNode>?,
                  expansionBehavior: ExpansionBehavior.collapseOthersAndSnapToTop,
                  expansionIndicator: ExpansionIndicator(expandIcon: SizedBox(), collapseIcon: SizedBox()),
                  shrinkWrap: true,
                  showRootNode: false,
                  indentPadding: 16,
                  padding: Inset.hv(8, 16),
                  builder: (context, level, item) {
                    final _itemExpanded = item.meta != null && item.meta!['is_expanded'] == true;

                    return item.isRoot
                        ? SizedBox()
                        : Card(
                            margin: Inset(4),
                            color: Fav.design.card.background,
                            child: InkWell(
                              onTap: () {
                                if (item.type != EducationNodeType.none) {
                                  controller.openItem(item);
                                } else {
                                  controller.treeViewController!.toggleNodeExpandCollapse(item);
                                }
                              },
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      width: 36,
                                      decoration: BoxDecoration(
                                        color: MyPalette.getColorFromCount(item.level),
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(28),
                                          topRight: Radius.circular(28),
                                        ),
                                      ),
                                      child: (item.parent!.childrenAsList.indexOf(item) + 1).toString().text.bold.fontSize(18).color(Colors.white).make().center,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          item.title.text.bold.maxLines(2).fontSize(18).make(),
                                          if (item.subTitle.safeLength > 1) item.subTitle.text.maxLines(2).make(),
                                        ],
                                      ).p8,
                                    ),
                                    if (item.children.isNotEmpty)
                                      wp.AdvancedIcons(
                                        state: !_itemExpanded ? wp.AdvancedIconState.primary : wp.AdvancedIconState.secondary,
                                        secondIcon: MdiIcons.arrowRightCircle,
                                        firstIcon: MdiIcons.arrowDownCircle,
                                        firstIconColor: Fav.design.primaryText,
                                        secondIconColor: Fav.design.primaryText,
                                      ).p16.center
                                    // else if (item.type == EducationNodeType.youtube)
                                    //   MdiIcons.youtube.icon.color(Color(0xffFF0000)).make().px8
                                    else if (item.type == EducationNodeType.video)
                                      if (item.data1.getYoutubeIdFromUrl != null) MdiIcons.youtube.icon.color(Color(0xffFF0000)).make().px8 else MdiIcons.youtube.icon.color(Color(0xffFF0000)).make().px8
                                    else if (item.type == EducationNodeType.pdfReadPage)
                                      MdiIcons.filePdfBox.icon.color(Color(0xffFF0000)).make().px8
                                    else
                                      SizedBox()
                                  ],
                                ),
                              ),
                            ));
                  },
                )),
          );
        });
  }
}
