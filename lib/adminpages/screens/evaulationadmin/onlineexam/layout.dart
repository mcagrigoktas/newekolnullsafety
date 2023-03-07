import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mcg_database/downloadmanager/downloadmanaer_shared.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../appbloc/appvar.dart';
import '../exams/bookletdefine/model.dart';
import 'controller.dart';

class OlineExamMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnlineExamController>(
      builder: (controller) {
        Widget bodyWidget;
        List<Widget> trailingWidgets;

        //todo uyarinin yazisimi yaz
        if (controller.newBookLetData?.notificationRole == null) return Container();

        if (controller.isBookletDownloading) return MyProgressIndicator(isCentered: true, text: 'exampreparing'.translate).inScaffold;

        if (controller.newBookLetData!.notificationRole == NotificationRole.downloadBookletNotVisible && !controller.isBookletReviewing) {
          trailingWidgets = [];
          bodyWidget = Center(child: 'exampreparingsuc'.translate.text.color(Colors.white).center.make().p16.stadium().px16);
        } else if (controller.newBookLetData!.notificationRole == NotificationRole.onlySendResultButton && !controller.isBookletReviewing) {
          trailingWidgets = [];
          bodyWidget = !AppVar.appBloc.hesapBilgileri.gtS
              ? Container()
              : controller.dataSended!
                  ? Center(child: 'sendedexamdataforreview'.translate.text.color(Colors.white).make().stadium())
                  : Center(
                      child: MyRaisedButton(
                        onPressed: () {
                          controller.sendExamDataForReview();
                        },
                        text: 'sendexamdataforreview'.translate,
                      ),
                    );
        } else if (controller.newBookLetData?.notificationRole?.isVisibleBooklet == true || controller.isBookletReviewing) {
          bodyWidget = SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: controller.examType.lessons!
                      .where((element) => controller.bookLetData.lessonBookLetFiles!.keys.contains(element.key))
                      .map((e) => Card(
                            margin: const EdgeInsets.all(16),
                            color: Fav.design.card.background,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: Column(
                                children: [
                                  controller.lessonData(e.key)!.name.text.fontSize(18).bold.make(),
                                  (controller.lessonData(e.key)!.questionCount.toString() + ' ' + 'soruplural'.translate).text.fontSize(14).make().pt8,
                                  if (controller.newBookLetData!.notificationRole.examStarting) ('solvedquestioncount'.translate + ": " + controller.solvedQuestionCount(e.key).toString()).text.fontSize(10).make().pt8,
                                  if (controller.lessonData(e.key)!.wQuestionCount! > 0) (controller.lessonData(e.key)!.wQuestionCount.toString() + ' ' + 'writiblequestion'.translate).text.fontSize(14).make(),
                                  MyRaisedButton(
                                    text: 'solve'.translate,
                                    onPressed: () {
                                      controller.clickLesson(e.key);
                                    },
                                  ).pt8,
                                ],
                              ).p16,
                            ),
                          ))
                      .toList(),
                ),
                controller.sendExamDataForReviewWidget,
                if (controller.newBookLetData!.notificationRole.examStarting) controller.examStartTime.text.color(Fav.design.primary).make().p8,
                if (controller.newBookLetData!.notificationRole.examStarting) controller.examEndTime.text.color(Fav.design.primary).make().p8,
                if (controller.bookLetData.bookletIsDownladable == true && kIsWeb)
                  MyMiniRaisedButton(
                    onPressed: () async {
                      await DownloadManager.saveFileToDisk(data: controller.activePdfData, fileName: 'exam'.translate + 2.makeKey + '.pdf');
                      controller.bookletPdfFiles.forEach((key, value) {
                        DownloadManager.saveFileToDisk(data: value, fileName: controller.lessonData(key)!.name! + 2.makeKey + '.pdf');
                      });
                    },
                    text: 'savebooklet'.translate,
                  ),
              ],
            ),
          );
          trailingWidgets = [
            if (controller.newBookLetData!.notificationRole.examStarting && controller.durationText != '')
              Tooltip(
                message: 'examhourhint'.translate,
                child: controller.durationText.text.color(Fav.design.appBar.text).make().stadium(background: Fav.design.appBar.text.withAlpha(30)),
              ).px8,
          ];
        } else {
          bodyWidget = EmptyState(text: 'examisclosed'.translate);
          trailingWidgets = [];
        }
        return AppScaffold(
          topBar: TopBar(trailingActions: trailingWidgets, leadingTitle: 'back'.translate),
          topActions: TopActionsTitleWithChild(title: TopActionsTitle(title: controller.examAnnouncement?.title ?? 'exam'.translate), child: controller.examAnnouncement?.content == null ? SizedBox() : controller.examAnnouncement!.content.text.make()),
          body: Body.child(child: bodyWidget),
        );
      },
    );
  }
}
