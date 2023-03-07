import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../common/pdfcontroller/native_pdf_view.dart';
import 'controller.dart';

class PdfBook extends StatelessWidget {
  final bool goToPageButtonVisible;
  final bool painterEnable;
  final TopBar? topBar;
  final DrawerPanel? drawerPanel;
  final GlobalKey? scaffoldKey;
  PdfBook({this.goToPageButtonVisible = false, this.painterEnable = true, this.topBar, this.drawerPanel, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PdfBookController>(builder: (controller) {
      Widget _current = controller.isPdfPreparing
          ? MyProgressIndicator(text: 'bookdownloading'.translate)
          : KeyedSubtree(
              key: const Key('MainBookLet'),
              child: PdfBoookView(
                pageSnapping: true,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                controller: controller.pdfController,
                documentLoader: MyProgressIndicator(isCentered: true),
                errorBuilder: (err) => EmptyState(text: err.toString()),
                onDocumentLoaded: controller.documentLoaded,
              ),
            );

      _current = Stack(
        children: [
          Positioned.fill(child: _current),
          Positioned.fill(child: PainterWidget(key: key)),
        ],
      );

      return AppScaffold(
        blurVisiblePercentage: 0.8,
        scaffoldKey: scaffoldKey,
        topBar: topBar ?? TopBar(leadingTitle: 'bookcontents'.translate),
        body: Body.child(child: _current),
        drawerPanel: drawerPanel,
        bottomBar: controller.isPdfPreparing
            ? null
            : BottomBar(
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (context.screenWidth > 720)
                    SizedBox(
                      height: 20,
                      width: 100,
                      child: Stack(
                        children: [
                          Icons.zoom_in.icon.padding(0).size(20).color(Fav.design.primaryText).make(),
                          Slider(
                            min: 0.75,
                            max: 3.0,
                            thumbColor: Fav.design.primaryText,
                            value: controller.scaledValue,
                            onChanged: (value) {
                              controller.changeScaleValue(value);
                              controller.update();
                            },
                          ).pl8,
                        ],
                      ),
                    ),
                  Icons.west_sharp.icon.padding(4).color(Fav.design.primaryText).onPressed(controller.previousPage).make(),
                  Container(
                    width: 100,
                    alignment: Alignment.center,
                    child: controller.pageNoText.text.make(),
                  ),
                  Icons.east_sharp.icon.padding(4).color(Fav.design.primaryText).onPressed(controller.nextPage).make(),
                  if (goToPageButtonVisible)
                    Transform.scale(
                      scale: 0.8,
                      child: SizedBox(
                        width: 50,
                        child: CupertinoTextField(
                          style: TextStyle(color: Fav.design.primaryText),
                          placeholderStyle: TextStyle(color: Fav.design.primaryText.withAlpha(180)),
                          key: ValueKey('PageNoTextfield' + controller.pageNoText),
                          placeholder: 'go'.translate,
                          onSubmitted: (value) {
                            controller.goPage(value);
                          },
                        ),
                      ),
                    ),
                  BottomBorToolbar(),
                ],
              )),
      );
    });
  }
}
