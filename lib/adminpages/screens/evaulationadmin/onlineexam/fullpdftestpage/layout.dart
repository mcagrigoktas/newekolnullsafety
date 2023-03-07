import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../../qbank/testscreens/common/optionnames.dart';
import '../../../../../qbank/testscreens/pdfbook/layout.dart';
import 'controller.dart';

class FullPdfTestPage extends StatelessWidget {
  FullPdfTestPage();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FullPdfTestPageController>(
      builder: (controller) {
        Widget bodyWidget;
        List<Widget> trailingWidgets;
        trailingWidgets = [
          if (controller.durationText().safeLength > 0)
            Align(
              alignment: Alignment.center,
              child: Tooltip(
                message: 'examhourhint'.translate,
                child: controller.durationText().text.color(Fav.design.appBar.text).center.make().stadium(background: Fav.design.appBar.text.withAlpha(30)),
              ).px8,
            ),
        ];
        if (context.screenWidth > 720) {
          bodyWidget = Row(
            children: [Expanded(child: OlineExamBookLet(trailingActions: trailingWidgets)), SizedBox(width: 170, child: OlineExamOpticForm())],
          );
        } else {
          trailingWidgets.add(Icons.menu.icon
              .color(Fav.design.appBar.text)
              .onPressed(() {
                controller.scaffoldKey.currentState!.openEndDrawer();
              })
              .make()
              .p8);

          bodyWidget = OlineExamBookLet(
            trailingActions: trailingWidgets,
            drawer: OlineExamOpticForm(),
          );
        }

        return bodyWidget;
      },
    );
  }
}

class OlineExamOpticForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FullPdfTestPageController controller = Get.find();

    Widget current = Container(
      width: 225.0.clamp(150.0, context.width - 100.0),
      height: double.infinity,
      color: Fav.design.scaffold.background,
      padding: EdgeInsets.only(top: context.screenTopPadding),
      child: SingleChildScrollView(
          child: Column(
        children: [
          Container(height: 44, alignment: Alignment.center, child: controller.testName.text.bold.center.color(Fav.design.primary).make().p4),
          for (var q = 0; q < controller.questionCount!; q++)
            Container(
              color: Fav.design.primaryText.withAlpha(q.isEven ? 5 : 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 18, child: '${q + controller.firstQuestionNo!}'.text.bold.make()),
                  for (var c = 0; c < controller.numberOfOptions!; c++)
                    GestureDetector(
                      onTap: () {
                        controller.clickAnswer(q, optionNames[c]);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: controller.answerKeyData[controller.testKey]![q] == optionNames[c] ? Colors.greenAccent : Fav.design.primaryText.withAlpha(20), shape: BoxShape.circle),
                        width: 24,
                        height: 24,
                        child: optionNames[c].text.bold.make(),
                      ),
                    ),
                ],
              ).py8.px4,
            ),
          if ((controller.wQuestionCount ?? 0) > 0)
            Column(
              children: [
                'writiblequestion'.translate.text.bold.color(Fav.design.primaryText).make().pt8,
                for (var c = 1; c < controller.wQuestionCount! + 1; c++)
                  MyTextField(
                    onChanged: (value) {
                      controller.wQuestionOnChange(controller.testKey!, c, value);
                    },
                    labelText: '$c',
                    initialValue: controller.getWQuestionAnswer(controller.testKey!, c),
                  )
              ],
            )
        ],
      )),
    );
    if (!controller.isOpticFormClickable) {
      current = GestureDetector(
        onTap: () {
          'opticformdisable'.translate.showAlert();
        },
        child: AbsorbPointer(
          absorbing: true,
          child: current,
        ),
      );
    }

    return current;
  }
}

class OlineExamBookLet extends StatelessWidget {
  final Widget? drawer;
  final List<Widget>? trailingActions;
  OlineExamBookLet({this.drawer, this.trailingActions});
  @override
  Widget build(BuildContext context) {
    final FullPdfTestPageController controller = Get.find<FullPdfTestPageController>();
    return KeyedSubtree(
        key: const Key('MainBookLet'),
        child: PdfBook(
          goToPageButtonVisible: true,
          scaffoldKey: controller.scaffoldKey,
          topBar: TopBar(leadingTitle: 'back'.translate, trailingActions: trailingActions),
          drawerPanel: drawer == null ? null : DrawerPanel(drawer: Drawer(child: drawer), isRightDrawer: true),
        ));

    //   PdfBoookView(
    //     pageSnapping: false,
    //     scrollDirection: Axis.vertical,
    //     physics: const NeverScrollableScrollPhysics(),
    //     controller: controller.pdfController,
    //     documentLoader: MyProgressIndicator(isCentered: true),
    //     errorBuilder: (err) => EmptyState(text: err.toString()),
    //     onDocumentLoaded: controller.documentLoaded,
    //   ),
    // );
  }
}
