import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../common/clock.dart';
import '../common/optionnames.dart';
import '../common/pdfcontroller/native_pdf_view.dart';
import '../common/result.dart';
import 'controller.dart';

class PdfBookWithOptic extends StatelessWidget {
  PdfBookWithOptic();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PdfBookWithOpticController>(builder: (controller) {
      final _topBar = TopBar(leadingTitle: 'bookcontents'.translate);
      Body _body;
      DrawerPanel? _panel;
      if (controller.isPdfPreparing) {
        _body = Body.child(
            child: MyProgressIndicator(
          text: 'bookdownloading'.translate,
        ));
      } else {
        final _pdfView = PdfBoookView(
          pageSnapping: true,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          controller: controller.pdfController,
          documentLoader: MyProgressIndicator(isCentered: true),
          errorBuilder: (err) => EmptyState(text: err.toString()),
          onDocumentLoaded: controller.documentLoaded,
        );
        Widget _bodyChild;
        if (context.screenWidth > 800) {
          _bodyChild = Row(
            children: [Expanded(child: _pdfView), SizedBox(width: 170, child: OlineExamOpticForm())],
          );
        } else {
          _bodyChild = _pdfView;
          _panel = DrawerPanel(
            drawer: Drawer(
              child: OlineExamOpticForm(),
            ),
            isRightDrawer: true,
          );
          _topBar.addTrailingActions(Icons.menu.icon
              .color(Fav.design.appBar.text)
              .onPressed(() {
                controller.scaffoldKey.currentState!.openEndDrawer();
              })
              .make()
              .p8);
        }

        _body = Body.child(
            child: KeyedSubtree(
          key: const Key('MainBookLet'),
          child: _bodyChild,
        ));
      }

      final _bottomBar = controller.isPdfPreparing
          ? null
          : BottomBar(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icons.west_sharp.icon.padding(4).color(Fav.design.primaryText).onPressed(controller.previousPage).make(),
                Container(
                  width: 100,
                  alignment: Alignment.center,
                  child: controller.pageNoText.text.make(),
                ),
                Icons.east_sharp.icon.padding(4).color(Fav.design.primaryText).onPressed(controller.nextPage).make(),
              ],
            ));

      return AppScaffold(
        scaffoldKey: controller.scaffoldKey,
        topBar: _topBar,
        body: _body,
        bottomBar: _bottomBar,
        drawerPanel: _panel,
      );
    });
  }
}

class OlineExamOpticForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PdfBookWithOpticController controller = Get.find();

    List<Widget> _options = [];

    for (var q = 0; q < controller.questionCount; q++) {
      final _item = controller.answerKeyItemsEntries[q];

      if (_item.value.type == 0) {
        _options.add(Container(
          color: Fav.design.primaryText.withAlpha(q.isEven ? 5 : 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 18, child: '${q + 1}'.text.bold.make()),
              for (var c = 0; c < controller.numberOfOptions!; c++)
                GestureDetector(
                  onTap: () {
                    controller.answerKeyData[_item.key] = optionNames[c];
                    controller.update();
                  },
                  onLongPress: () {
                    controller.answerKeyData[_item.key] = '';
                    controller.update();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: controller.answerKeyData[_item.key] == optionNames[c] ? Colors.greenAccent : Fav.design.primaryText.withAlpha(20), shape: BoxShape.circle),
                    width: 24,
                    height: 24,
                    child: optionNames[c].text.bold.make(),
                  ),
                ),
            ],
          ).py8.px4,
        ));
      } else {
        _options.add(Column(
          children: [
            MyTextField(
              onChanged: (value) {
                controller.answerKeyData[_item.key] = value;
              },
              labelText: '${q + 1}',
              initialValue: controller.answerKeyData[_item.key],
            )
          ],
        ));
      }
    }

    Widget current = Container(
      width: 225.0.clamp(150.0, context.width - 100.0),
      height: double.infinity,
      color: Fav.design.scaffold.background,
      padding: EdgeInsets.only(top: context.screenTopPadding),
      child: Column(
        children: [
          Obx(() => ClockWidget(duration: controller.gecenSure.value)),
          if (controller.testCozuldu!) ResultWidget(dogruSayisi: controller.dogruSayisi, yanlisSayisi: controller.yanlisSayisi, bosSayisi: controller.bosSayisi, book: controller.book),
          Expanded(
            child: IgnorePointer(
              ignoring: controller.testCozuldu!,
              child: SingleChildScrollView(
                child: Column(
                  children: [..._options],
                ),
              ),
            ),
          ),
          MyRaisedButton(
            onPressed: !controller.testCozuldu!
                ? () {
                    controller.alertTestiKontrolEtSifirla(0);
                  }
                : () {
                    controller.alertTestiKontrolEtSifirla(1);
                  },
            iconData: Icons.check_circle,
            text: controller.testCozuldu! ? 'testreset'.translate : 'testfinish'.translate,
          ).paddingOnly(bottom: context.screenBottomPadding),
        ],
      ),
    );

    return current;
  }
}
