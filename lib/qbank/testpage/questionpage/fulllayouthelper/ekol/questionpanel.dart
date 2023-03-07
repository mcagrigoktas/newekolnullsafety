import 'package:flutter/material.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../models/models.dart';
import '../../../qbankrichtext/questionwidgets.dart';

class EkolSoruPaneli extends StatefulWidget {
  @override
  EkolSoruPaneliState createState() {
    return EkolSoruPaneliState();
  }
}

class EkolSoruPaneliState extends State<EkolSoruPaneli>
    with
        TickerProviderStateMixin, // todo single ticker olsa daha iyi olabilir hata almamak icin boyle yaptim
        QuestionWidget {
  @override
  Widget build(BuildContext context) {
    Question question = AppVar.questionPageController.getTest!.questions[AppVar.questionPageController.secilenSoruIndex!];

    if (question.soru == null) return Container();

    List<Widget> sorusatirlari = [];

    question.soru!.forEach((soruSatiri) {
      var satir = Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 8.0),
        child: questionWidget(data: soruSatiri),
      );
      sorusatirlari.add(satir);
    });

    Widget returnWidget;

    if (sorusatirlari.length == 1) {
      returnWidget = sorusatirlari[0];
    } else {
      returnWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: sorusatirlari,
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: AppVar.questionPageController.theme!.questionBgGradient,
        boxShadow: [BoxShadow(blurRadius: 4.0, color: AppVar.questionPageController.theme!.questionBgShadowColor!)],
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      margin: const EdgeInsets.all(8.0),
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: const Duration(milliseconds: 444),
        reverseDuration: const Duration(milliseconds: 444),
        child: returnWidget,
      ),
    );
  }
}
