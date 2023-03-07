import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/srcpages/youtube_player/youtube_player_shared.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../models/models.dart';
import '../../../qbankrichtext/questionwidgets.dart';

class EkolCozumPaneli extends StatelessWidget with QuestionWidget {
  @override
  Widget build(BuildContext context) {
    Question question = AppVar.questionPageController.getTest!.questions[AppVar.questionPageController.secilenSoruIndex!];

    List<Widget> children = [];

    children.add(
      Container(
        width: 120.0,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(color: AppVar.questionPageController.theme!.bookColor, boxShadow: [BoxShadow(blurRadius: 4.0, color: AppVar.questionPageController.theme!.primaryGradient.colors.first)], borderRadius: const BorderRadius.all(Radius.circular(12.0))),
        margin: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'answer'.translate,
              style: const TextStyle(color: Colors.white),
            ),
            if (question.questionType == QuestionType.SECENEKLI)
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 12.0,
                child: Text(
                  question.answer.option ?? '?',
                  style: TextStyle(color: AppVar.questionPageController.theme!.bookColor),
                ),
              ),
          ],
        ),
      ),
    );

    children.add(8.heightBox);

    if (question.solution == null) {
      children.add(Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Fav.secondaryDesign.accent, borderRadius: BorderRadius.circular(12)),
        child: Text(
          'solutionprepare'.translate,
          style: TextStyle(color: AppVar.questionPageController.theme!.primaryTextColor, fontWeight: FontWeight.bold),
        ),
      ));
    }

    question.solution?.forEach((item) {
      if (item.type != 104) {
        var satir = Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(gradient: AppVar.questionPageController.theme!.questionBgGradient, boxShadow: [BoxShadow(blurRadius: 4.0, color: AppVar.questionPageController.theme!.questionBgGradient!.colors.first)], borderRadius: const BorderRadius.all(Radius.circular(12.0))),
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: questionWidget(
            data: item,
          ),
        );
        children.add(satir);
      } else {
        children.add(ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 300, height: 168, child: MyYoutubeWidget(item.youtubeVideo!.trim()))));
      }
    });

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: children,
      ),
    );
  }
}
