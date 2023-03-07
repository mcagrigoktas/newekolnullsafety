import 'package:flutter/material.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../models/models.dart';
import '../../../secenekname.dart';
import '../helper.dart';

class PdfSecenekPaneli extends StatelessWidget {
  PdfSecenekPaneli();

  @override
  Widget build(BuildContext context) {
    final Question question = AppVar.questionPageController.getTest!.questions[AppVar.questionPageController.secilenSoruIndex!];
    return Row(
      children: <Widget>[for (var i = 0; i < (question.optionType.autoOptionCount ?? 5); i++) Expanded(child: AutoSecenekBack(name: QbankLayoutHelper.getOptionName(i)))],
    );
  }
}

class AutoSecenekBack extends StatelessWidget {
  final String? name;

  AutoSecenekBack({this.name});

  Future<void> secenegiIsaretle(BuildContext context) async {
    await AppVar.questionPageController.clickSecenek(name, context);
  }

  @override
  Widget build(BuildContext context) {
    Widget secenekName = SecenekName(incomingMenu: 1, name: name);

    return GestureDetector(
        onTap: () {
          secenegiIsaretle(context);
        },
        child: AnimatedOpacity(
          opacity: AppVar.questionPageController.secenekDurumu[name] == 1 ? 0.18 : 1.0,
          duration: const Duration(milliseconds: 333),
          child: AnimatedContainer(
            padding: const EdgeInsets.all(8),
            duration: const Duration(milliseconds: 333),
            margin: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 0.0, right: 0.0),
            child: secenekName,
          ),
        ));
  }
}
