import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../../appbloc/appvar.dart';
import '../../drawpage.dart';
import '../../questionappbar.dart';
import '../ekol/cozumpaneli.dart';
import 'questionpanel.dart';
import 'secenekPanel.dart';

class PdfQuestionLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final questionPageController = AppVar.questionPageController;
    final bool portrait = questionPageController.portrait;
    final bool tablet = questionPageController.tablet;
    final bool hasntDrawerNeed = context.screenWidth > 800 && kIsWeb;

    double appBarHeight = 56.0;
    if (!tablet && !portrait) {
      appBarHeight = 26.0;
    }

    Widget soruPaneli = PdfSoruPaneli();
    Widget secenekPaneli = PdfSecenekPaneli();
    Widget cozumPaneli = questionPageController.testCozuldu! ? EkolCozumPaneli() : const SizedBox();

    late Widget soruYerlesimi;

    if (tablet) {
      const questionPadding = kIsWeb ? EdgeInsets.all(16) : EdgeInsets.all(64);
      if (questionPageController.ekranUstuYazma == false || questionPageController.testCozuldu!) {
        soruYerlesimi = Column(
          children: <Widget>[
            QuestionAppBar(
              hasntDrawerNeed: hasntDrawerNeed,
              title: Text(
                "${'question'.translate} ${questionPageController.secilenSoruIndex! + 1}",
                style: TextStyle(color: questionPageController.theme!.isLight! ? Colors.white : questionPageController.theme!.primaryTextColor, fontSize: appBarHeight < 50.0 ? 14.0 : 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 1,
              child: ListView(
                padding: questionPadding,
                children: <Widget>[
                  soruPaneli,
                  secenekPaneli,
                  cozumPaneli,
                ],
              ),
            ),
          ],
        );
      }
      // Soru üzerine Çözebilme
      else if (/*portrait&&*/ questionPageController.ekranUstuYazma == true) {
        soruYerlesimi = Column(
          children: <Widget>[
            QuestionAppBar(
              hasntDrawerNeed: hasntDrawerNeed,
              title: Text(
                "${'question'.translate} ${questionPageController.secilenSoruIndex! + 1}",
                style: TextStyle(color: questionPageController.theme!.isLight! ? Colors.white : questionPageController.theme!.primaryTextColor, fontSize: appBarHeight < 50.0 ? 14.0 : 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 1,
              child: Stack(
                children: <Widget>[
                  ListView(
                    padding: questionPadding,
                    children: <Widget>[
                      soruPaneli,
                      secenekPaneli,
                      cozumPaneli,
                    ],
                  ),
                  Positioned(
                    child: PaintPage(backGroundColor: Colors.transparent),
                    left: 0.0,
                    right: 0.0,
                    top: 0.0,
                    bottom: 0.0,
                  ),
                ],
              ),
            )
          ],
        );
      }
    } else /*Tablet değilse*/ {
      if (portrait) {
        soruYerlesimi = Column(
          children: <Widget>[
            QuestionAppBar(
              title: Text(
                "${'question'.translate} ${questionPageController.secilenSoruIndex! + 1}",
                style: TextStyle(color: questionPageController.theme!.isLight! ? Colors.white : questionPageController.theme!.primaryTextColor, fontSize: appBarHeight < 50.0 ? 14.0 : 24.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 1,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(0.0),
                children: <Widget>[
                  soruPaneli,
                  secenekPaneli,
                  cozumPaneli,
                ],
              ),
            ),
          ],
        );
      }
      // Yatay TestÇözülmemişse
      else if (!questionPageController.testCozuldu! && questionPageController.ekranUstuYazma == false) {
        soruYerlesimi = Column(
          children: <Widget>[
            QuestionMiniAppBar(
              title: Text(
                "${'question'.translate} ${questionPageController.secilenSoruIndex! + 1}",
                textAlign: TextAlign.center,
                style: TextStyle(color: questionPageController.theme!.isLight! ? Colors.white : AppVar.questionPageController.theme!.primaryTextColor),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      child: soruPaneli,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      child: secenekPaneli,
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      } else if (!questionPageController.testCozuldu! && questionPageController.ekranUstuYazma == true) {
        soruYerlesimi = Column(
          children: <Widget>[
            QuestionMiniAppBar(
              title: Text(
                "${'question'.translate} ${questionPageController.secilenSoruIndex! + 1}",
                textAlign: TextAlign.center,
                style: TextStyle(color: questionPageController.theme!.isLight! ? Colors.white : AppVar.questionPageController.theme!.primaryTextColor),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      children: [
                        soruPaneli,
                        secenekPaneli,
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                        height: double.infinity,
                        child: PaintPage(
                          backGroundColor: Colors.transparent,
                        )),
                  ),
                ],
              ),
            )
          ],
        );
      }
      // Yatay Test Çözülmüşse
      else {
        soruYerlesimi = Column(
          children: <Widget>[
            QuestionMiniAppBar(
              drawPanelIcon: false,
              title: Text(
                "${'question'.translate} ${questionPageController.secilenSoruIndex! + 1}",
                textAlign: TextAlign.center,
                style: TextStyle(color: questionPageController.theme!.isLight! ? Colors.white : AppVar.questionPageController.theme!.primaryTextColor),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.all(0.0),
                      children: <Widget>[
                        soruPaneli,
                        secenekPaneli,
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      child: cozumPaneli,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    }
    return soruYerlesimi;
  }
}
