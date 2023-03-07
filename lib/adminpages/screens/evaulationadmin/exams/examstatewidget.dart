import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import 'bookletdefine/model.dart';
import 'model.dart';

class ExamStateWidget extends StatelessWidget {
  final Exam? selectedItem;
  ExamStateWidget(this.selectedItem);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Column(
          children: [
            'exambooklet'.translate.text.bold.make().p8,
            ...selectedItem!.bookLetsData!.entries.map((e) => ExamStateWidget1(e)).toList(),
          ],
        ),
      ),
    );
  }
}

class ExamStateWidget1 extends StatefulWidget {
  final MapEntry<String, BookLetModel?> bookLet;
  ExamStateWidget1(this.bookLet);

  @override
  _ExamStateWidget1State createState() => _ExamStateWidget1State();
}

class _ExamStateWidget1State extends State<ExamStateWidget1> {
  NotificationRole? notificationRole;

  @override
  void initState() {
    notificationRole = widget.bookLet.value!.notificationRole ?? NotificationRole.invisibleBookLet;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Fav.design.card.background,
      child: Column(
        children: [
          8.heightBox,
          ('seison'.translate + ' ' + widget.bookLet.key.replaceAll('seison', '')).toUpperCase().text.bold.color(Fav.design.primaryText).make(),
          Row(
            children: [
              8.widthBox,
              RotatedBox(
                quarterTurns: 3,
                child: 'beforeexam'.translate.text.color(Colors.white).make().stadium(background: Colors.amber),
              ),
              Expanded(
                child: Column(
                  children: [
                    CheckboxListTile(
                      dense: true,
                      activeColor: Fav.design.primary,
                      title: 'invisibleBookLet'.translate.text.bold.color(Fav.design.primaryText).fontSize(16).make(),
                      subtitle: 'invisibleBookLet2'.translate.text.fontSize(8).make(),
                      value: widget.bookLet.value!.notificationRole == NotificationRole.invisibleBookLet,
                      onChanged: (value) {
                        setState(() {
                          widget.bookLet.value!.notificationRole = NotificationRole.invisibleBookLet;
                        });
                      },
                    ).p4,
                    CheckboxListTile(
                      dense: true,
                      activeColor: Fav.design.primary,
                      title: 'preparedownloadexam'.translate.text.bold.color(Fav.design.primaryText).fontSize(16).make(),
                      subtitle: 'downloadBookletNotVisible'.translate.text.fontSize(8).make(),
                      value: widget.bookLet.value!.notificationRole == NotificationRole.downloadBookletNotVisible,
                      onChanged: (value) {
                        setState(() {
                          widget.bookLet.value!.notificationRole = NotificationRole.downloadBookletNotVisible;
                        });
                      },
                    ).p4,
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              8.widthBox,
              RotatedBox(
                quarterTurns: 3,
                child: 'onexam'.translate.text.color(Colors.white).make().stadium(background: Colors.lightBlue),
              ),
              Expanded(
                child: Column(
                  children: [
                    CheckboxListTile(
                      dense: true,
                      activeColor: Fav.design.primary,
                      title: 'startexam'.translate.text.bold.color(Fav.design.primaryText).fontSize(16).make(),
                      subtitle: 'visibleBookLetAndOpticForm'.translate.text.fontSize(8).make(),
                      value: widget.bookLet.value!.notificationRole == NotificationRole.visibleBookLetAndOpticForm,
                      onChanged: (value) {
                        setState(() {
                          widget.bookLet.value!.notificationRole = NotificationRole.visibleBookLetAndOpticForm;
                        });
                      },
                    ).p4,
                    CheckboxListTile(
                      dense: true,
                      activeColor: Fav.design.primary,
                      title: 'finishexam'.translate.text.bold.color(Fav.design.primaryText).fontSize(16).make(),
                      subtitle: 'onlySendResultButton'.translate.text.fontSize(8).make(),
                      value: widget.bookLet.value!.notificationRole == NotificationRole.onlySendResultButton,
                      onChanged: (value) {
                        setState(() {
                          widget.bookLet.value!.notificationRole = NotificationRole.onlySendResultButton;
                        });
                      },
                    ).p4,
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              8.widthBox,
              RotatedBox(
                quarterTurns: 3,
                child: 'afterexam'.translate.text.color(Colors.white).make().stadium(background: Colors.purple),
              ),
              Expanded(
                child: Column(
                  children: [
                    CheckboxListTile(
                      dense: true,
                      activeColor: Fav.design.primary,
                      title: 'closeexam'.translate.text.bold.color(Fav.design.primaryText).fontSize(16).make(),
                      subtitle: 'invisibleBookLetAndInvisibleOpticForm'.translate.text.fontSize(8).make(),
                      value: widget.bookLet.value!.notificationRole == NotificationRole.invisibleBookLetAndInvisibleOpticForm,
                      onChanged: (value) {
                        setState(() {
                          widget.bookLet.value!.notificationRole = NotificationRole.invisibleBookLetAndInvisibleOpticForm;
                        });
                      },
                    ).p4,
                    CheckboxListTile(
                      dense: true,
                      activeColor: Fav.design.primary,
                      title: 'showexam'.translate.text.bold.color(Fav.design.primaryText).fontSize(16).make(),
                      subtitle: 'visibleBookLetAndInvisibleOpticForm'.translate.text.fontSize(8).make(),
                      value: widget.bookLet.value!.notificationRole == NotificationRole.visibleBookLetAndInvisibleOpticForm,
                      onChanged: (value) {
                        setState(() {
                          widget.bookLet.value!.notificationRole = NotificationRole.visibleBookLetAndInvisibleOpticForm;
                        });
                      },
                    ).p4,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
