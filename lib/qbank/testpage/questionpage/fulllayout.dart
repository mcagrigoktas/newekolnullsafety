import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import 'fulllayouthelper/ekol/questionlayout.dart';
import 'qbnakdrawer.dart';
import 'questionnavigationbar.dart';

class TestPageQuestion extends StatelessWidget {
  TestPageQuestion();

  @override
  Widget build(BuildContext context) {
    final questionPageBloc = AppVar.questionPageController;

    return StreamBuilder(
      stream: questionPageBloc.soruYenile,
      initialData: false,
      builder: (context, snapshot) {
        final bool hasntDrawerNeed = context.screenWidth > 800 && kIsWeb;
        final soruYerlesimi = EkolQuestionLayout();

        Widget current = Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [questionPageBloc.theme!.backgroundColor!, questionPageBloc.theme!.backgroundColor!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              image: DecorationImage(
                image: AssetImage(questionPageBloc.patternImageUrl),
                fit: BoxFit.cover,
              )),
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(child: soruYerlesimi),
        );

        final appBar = PreferredSize(preferredSize: const Size.fromHeight(0.0), child: Container(color: questionPageBloc.theme!.bookColor));

        if (hasntDrawerNeed) {
          current = Row(
            children: [Expanded(child: current), SizedBox(width: 230, child: QBankDrawer())],
          );
          return Scaffold(
            key: AppVar.questionPageController.scaffoldKey,
            backgroundColor: questionPageBloc.theme!.backgroundColor,
            appBar: appBar,
            body: current,
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          );
        }

        return Scaffold(
          key: AppVar.questionPageController.scaffoldKey,
          backgroundColor: questionPageBloc.theme!.backgroundColor,
          endDrawer: Drawer(child: QBankDrawer()),
          appBar: appBar,
          body: current,
          bottomNavigationBar: QuestionNavigationBar(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        );
      },
    );
  }
}
