import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcpages/documentview.dart';
import 'package:mypackage/srcpages/photoview.dart';

import '../../appbloc/appvar.dart';
import '../../localization/usefully_words.dart';
import '../../services/dataservice.dart';
import '../../services/pushnotificationservice.dart';
import 'homework/checkhomework.dart';
import 'homework_helper.dart';
import 'hwwidget.helper.dart';
import 'modelshw.dart';

class HomeWorkWidget extends StatelessWidget {
  final HomeWork? homeWork;
  final int? dividerStyle;
  final bool publishButton;
  final bool deleteButton;
  final bool checkButton;
  final bool showLessonName;
  final bool tapOn;
  final bool showClassName;
  HomeWorkWidget({this.homeWork, this.dividerStyle, this.publishButton = false, this.deleteButton = true, this.checkButton = true, this.showLessonName = false, this.tapOn = true, this.showClassName = false});

  Future<void> itemTap(BuildContext context) async {
    List<List> actions = [
      if (homeWork!.tur != 3 && checkButton) [1, Icons.assignment, 'checkhomework'.translate],
      if (homeWork!.tur != 3 && publishButton) [2, Icons.share, 'publish'.translate],
      if (deleteButton == true) [0, Icons.delete, Words.delete]
    ];

    if (actions.isEmpty) return;

    var _value = await OverBottomSheet.show(BottomSheetPanel.simpleList(
      title: 'chooseprocess'.translate,
      items: actions.map((e) => BottomSheetItem(name: e[2], icon: e[1], value: e[0])).toList()..add(BottomSheetItem.cancel()),
    ));

    // var value = await Sheet.make(
    //   title: 'chooseprocess'.translate,
    //   cancelAction: SheetAction.cancel(),
    //   actions: actions
    //       .map((e) => SheetAction(
    //           onPressed: () {
    //             Get.back(result: e[0]);
    //           },
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: <Widget>[
    //               Icon(e[1], color: Fav.design.sheet.itemText),
    //               16.widthBox,
    //               Text(
    //                 e[2],
    //                 style: TextStyle(fontSize: 16.0, color: Fav.design.sheet.itemText, fontWeight: FontWeight.bold),
    //               ),
    //             ],
    //           )))
    //       .toList(),
    // );

    if (_value == 0) {
      bool sure = await Over.sure();
      if (sure != true) return;

      List<String?> contactlist = AppVar.appBloc.studentService!.dataList.where((student) => student.classKeyList.contains(homeWork!.classKey)).map((student) => student.key).toList();
      if (contactlist.isEmpty) {
        return;
      }

      HomeWorkService.deleteHomeWork(homeWork!.key, homeWork!.classKey, homeWork!.lessonKey, contactlist, homeWork!.teacherKey).then((_) {
        OverAlert.deleteSuc();
      }).catchError((_) {
        OverAlert.deleteErr();
      }).unawaited;
    }

    if (_value == 2) {
      List<String?> contactlist = AppVar.appBloc.studentService!.dataList.where((student) => student.classKeyList.contains(homeWork!.classKey)).map((student) => student.key).toList();
      if (contactlist.isEmpty) {
        return;
      }

      HomeWorkService.publishHomeWork(homeWork!.key, homeWork!.classKey, homeWork!.lessonKey, contactlist, homeWork!.teacherKey).then((_) {
        EkolPushNotificationService.sendMultipleNotification(HomeWorkHelper.getNotificationHeader(homeWork!.tur) + ': ' + homeWork!.title!, homeWork!.content, contactlist, NotificationArgs(tag: 'homework'));
        OverAlert.saveSuc();
      }).catchError((_) {
        OverAlert.saveErr();
      }).unawaited;
    }

    if (_value == 1) {
      Fav.guardTo(CheckHomeWork(homeWork: homeWork))!.unawaited;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> extralist = [const Spacer()];
    homeWork!.imgList?.forEach((url) {
      extralist.add(Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: GestureDetector(
          onTap: () {
            Fav.to(PhotoView(urlList: [url]));
          },
          child: Hero(
            tag: url,
            child: Container(
              width: 48,
              height: 36,
              decoration: BoxDecoration(
                image: DecorationImage(image: CacheHelper.imageProvider(imgUrl: url), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Fav.design.primary.withAlpha(200), width: 0.5),
              ),
            ),
          ),
        ),
      ));
    });
    homeWork!.fileList?.forEach((url) {
      extralist.add(Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
        child: MyMiniRaisedButton(
          text: "openfile".translate,
          onPressed: () {
            DocumentView.openTypeList(url);
          },
          color: Fav.design.primary,
        ),
      ));
    });
    if ((homeWork!.url ?? "").length > 10) {
      extralist.add(Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
        child: MyMiniRaisedButton(
          text: "golink".translate,
          onPressed: () {
            homeWork!.url.launch(LaunchType.url);
          },
          color: Fav.design.primary,
        ),
      ));
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          homeWork!.checkNote == null
              ? Container(
                  margin: const EdgeInsets.only(top: 12),
                  alignment: Alignment.topCenter,
                  width: 60,
                  height: 25,
                  child: (homeWork!.tur != 3 ? homeWork!.getEndDateText : '📝').text.fontSize(17).bold.maxLines(1).autoSize.make(),
                )
              : Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      alignment: Alignment.center,
                      width: 60,
                      height: 25,
                      child: (homeWork!.tur != 3 ? homeWork!.getEndDateText : '📝').text.fontSize(17).bold.maxLines(1).autoSize.make(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        shape: const StadiumBorder(),
                        color: Fav.design.primary,
                      ),
                      child: HomeWorkWidgetHelper.getNote(homeWork!.checkNote!),
                    ),
                  ],
                ),
          8.widthBox,
          Column(
            children: <Widget>[
              Container(
                height: 17,
                width: 2,
                color: dividerStyle == 0 || dividerStyle == 3 ? Colors.transparent : Fav.design.primaryText.withAlpha(70),
              ),
              CircleAvatar(
                radius: 6,
                backgroundColor: homeWork!.tur == 1 ? Colors.blue : (homeWork!.tur == 2 ? Colors.redAccent : Colors.amber),
              ),
              Expanded(
                  child: Container(
                width: 2,
                color: dividerStyle == 2 || dividerStyle == 3 ? Colors.transparent : Fav.design.primaryText.withAlpha(70),
              )),
            ],
          ),
          8.widthBox,
          Expanded(
            child: GestureDetector(
              onTap: AppVar.appBloc.hesapBilgileri.gtMT && tapOn == true
                  ? () {
                      itemTap(context);
                    }
                  : null,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Fav.design.bottomNavigationBar.background,
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 2.0)],
                  borderRadius: BorderRadius.circular(12.0),
                  //! Burada istenirse ogretmen harici bir paylasima farkli bir border verilebilir. border: Border.all(color: homeWork.senderKey.safeLength>0 && homeWork.senderKey.contains('anager')|| ?Fav.design.bottomNavigationBar.background : Colors.white),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: Text(
                          homeWork!.title ?? '...',
                          style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
                        )),
                        Text(
                          homeWork!.getTimeStampText,
                          style: TextStyle(color: Fav.design.primaryText.withAlpha(180), fontSize: 10),
                        ),
                        //    if(AppVar.appBloc.hesapBilgileri.gtT) SizedBox(height:18,width: 18,child:IconButton(icon:Icon(Icons.more_vert,size: 18,color:   Fav.design.primaryText.withAlpha(180),),padding: EdgeInsets.all(0.0),onPressed: (){itemTap(context);},)),
                      ],
                    ),
                    4.heightBox,
                    Text(
                      homeWork!.content ?? '...',
                      style: TextStyle(color: Fav.design.primaryText),
                    ),
                    if (extralist.length > 1)
                      Row(
                        children: extralist,
                      ),
                    if (showClassName || showLessonName)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: <Widget>[
                            if (showClassName && homeWork!.className != null)
                              Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: ShapeDecoration(shape: const StadiumBorder(), color: Fav.design.primaryText.withAlpha(30)),
                                  child: Text(
                                    homeWork!.className!,
                                    style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 13),
                                  )),
                            if (showLessonName && homeWork!.lessonName != null)
                              Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: ShapeDecoration(shape: const StadiumBorder(), color: Fav.design.primaryText.withAlpha(30)),
                                  child: Text(
                                    homeWork!.lessonName!,
                                    style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 13),
                                  )),
                          ],
                        ),
                      ),
                    if (!(homeWork!.isPublish ?? false) && AppVar.appBloc.hesapBilgileri.gtMT)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "waitingpublish".translate,
                          style: const TextStyle(color: Colors.red, fontSize: 12.0),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
