import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../models/models.dart';
import '../../../qbankrichtext/myrichtext.dart';
import '../../../qbankrichtext/questionwidgets.dart';
import '../../../secenekname.dart';
import '../helper.dart';
import '../pdf/secenekPanel.dart';

class EkolSecenekPaneli extends StatelessWidget with QuestionWidget {
  @override
  Widget build(BuildContext context) {
    final Question question = AppVar.questionPageController.getTest!.questions[AppVar.questionPageController.secilenSoruIndex!];

    if (question.options == null) {
      if (question.optionType.isAutoOptionsEnable) {
        return Row(
          children: <Widget>[for (var i = 0; i < question.optionType.autoOptionCount!; i++) Expanded(child: AutoSecenekBack(name: QbankLayoutHelper.getOptionName(i)))],
        );
      }
      return Container();
    }

    return StreamBuilder<Object>(
        //    key: Key('SecenekListesi${AppVar.questionPageController.secilenSoruIndex}'),
        stream: AppVar.questionPageController.secenekleriYenile,
        builder: (context, snapshot) {
          return LayoutBuilder(builder: (context, snapshot) {
            return Wrap(
              alignment: WrapAlignment.center,
              children: [
                if (question.optionGroupableList != null)
                  _SecenekBack2(
                    name: "G",
                    child: _SecenekWidgetGroup(
                      data: question.optionGroupableList,
                      name: "G",
                    ),
                  ),
                for (var i = 0; i < question.options!.length; i++)
                  Container(
                      width: question.optionType.sidebyside == false ? double.infinity : (snapshot.maxWidth / 2 - 1).floor().toDouble(),
                      padding: EdgeInsets.only(
                        top: question.optionType.sidebyside == false ? 3.0 : 5.0,
                        bottom: question.optionType.sidebyside == false ? 3.0 : 5.0,
                        left: question.optionType.sidebyside == false ? 12.0 : (i % 2 == 0 ? 12 : 6),
                        right: question.optionType.sidebyside == false ? 12.0 : (i % 2 == 1 ? 12 : 6),
                      ),
                      child: _SecenekBack(
                        name: QbankLayoutHelper.getOptionName(i),
                        child: SizedBox(
                            width: double.infinity,
                            child: question.optionGroupableList == null
                                ? questionWidget(
                                    data: question.options![i],
                                  )
                                : Row(
                                    children: question.options![i].text!
                                        .split('-*-')
                                        .map((item) => QuestionRow(type: question.options![i].type, text: item))
                                        .map((item) => questionWidget(
                                              data: item,
                                            ))
                                        .map((item) => Expanded(
                                              child: Container(
                                                child: item,
                                                alignment: Alignment.center,
                                              ),
                                            ))
                                        .toList(),
                                  )),
                      ))
              ],
            );
          });
        });
  }
}

class _SecenekBack extends StatelessWidget {
  final Widget? child;
  final String? name;

  _SecenekBack({this.child, this.name});

  void secenekEle(double velocity, BuildContext context) {
    if (velocity > 0) {
      AppVar.questionPageController.secenekDurumu[name] = 1;
      AppVar.questionPageController.setSecenekleriYenile.add(true);
    } else {
      AppVar.questionPageController.secenekDurumu[name] = 0;
      AppVar.questionPageController.setSecenekleriYenile.add(true);
    }
  }

  Future<void> secenegiIsaretle(BuildContext context) async {
    if (AppVar.questionPageController.secenekDurumu[name] == 0) {
      await AppVar.questionPageController.clickSecenek(name, context);
    } else {
      secenekEle(0.0, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget secenekName = SecenekName(incomingMenu: 1, name: name);

    Matrix4 matrix4 = Matrix4.translation(Vector3(0, 0, 0));
    if (AppVar.questionPageController.secenekDurumu[name] == 1) {
      matrix4 = Matrix4.translation(Vector3(75, 0, 0));
    }

    return GestureDetector(
        onTap: () {
          secenegiIsaretle(context);
        },
        onHorizontalDragEnd: (dragEndDetails) {
          secenekEle(dragEndDetails.primaryVelocity!, context);
        },
        child: AnimatedOpacity(
          opacity: AppVar.questionPageController.secenekDurumu[name] == 1 ? 0.18 : 1.0,
          duration: const Duration(milliseconds: 333),
          child: AnimatedContainer(
            transform: matrix4,
            duration: const Duration(milliseconds: 333),
            margin: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 0.0, right: 0.0),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(color: AppVar.questionPageController.theme!.optionBgColor, borderRadius: const BorderRadius.all(Radius.circular(12.0)), boxShadow: [BoxShadow(color: AppVar.questionPageController.theme!.optionShadowColor!, blurRadius: 4.0)]),
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0, right: 8.0),
                    child: child),
                secenekName,
              ],
            ),
          ),
        ));
  }
}

/// Gropup option arkaplani

class _SecenekBack2 extends StatelessWidget {
  final Widget? child;
  final String? name;

  _SecenekBack2({this.child, this.name});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 13.0, top: 2.0, bottom: 2.0, right: 4.0),
          child: Material(
            // color: Color(0xffEFF1F5),
            color: AppVar.questionPageController.theme!.optionBgColor!.withAlpha(10),
            shadowColor: const Color(0x441F314A),
            elevation: 1.0,
            borderRadius: BorderRadius.circular(20.0),
            child: Padding(padding: const EdgeInsets.only(left: 18.0, top: 8.0, bottom: 8.0, right: 8.0), child: child),
          ),
        ),
        SecenekName(incomingMenu: 1, name: "G")
      ],
    );
  }
}

class _SecenekWidgetGroup extends StatelessWidget {
  final List<String>? data;
  final String? name;

  _SecenekWidgetGroup({this.data, this.name});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    data!.forEach((text) {
      children.add(
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: MyRichText(text: text),
            width: double.infinity,
          ),
          flex: 1,
        ),
      );
    });

    return Row(
      children: children,
    );
  }
}
