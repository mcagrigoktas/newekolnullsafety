import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/appfunctions.dart';
import '../../../models/models.dart';
import 'videochatappointment.dart';

class VideoChatItem extends StatelessWidget {
  final VideoLessonProgramModel item;
  final Function([bool?])? managerScreenRefreshFunction;
  VideoChatItem(this.item, {this.managerScreenRefreshFunction});
  @override
  Widget build(BuildContext context) {
    final appBloc = AppVar.appBloc;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final imgUrl = (AppFunctions2.whatIsProfileImgUrl(item.teacherKey, exceptStudent: true) ?? '');

    return Opacity(
      opacity: item.endTime! < now ? 0.5 : 1,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0, top: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Fav.design.bottomNavigationBar.background,
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 2.0)],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Text(
                      item.lessonName!,
                      style: TextStyle(color: Fav.design.accentText, fontSize: 18.0, fontWeight: FontWeight.bold),
                    )),
                Text(
                  item.startTime!.dateFormat("d-MMMM / HH:mm-") + item.endTime!.dateFormat("HH:mm"),
                  style: TextStyle(color: Fav.design.primaryText, fontSize: 11.0),
                ),
              ],
            ),
            8.heightBox,
            Text(
              item.explanation!,
              style: TextStyle(color: Fav.design.primaryText),
            ),
            8.heightBox,
            Row(
              children: <Widget>[
                Expanded(
                    child: Row(
                  children: <Widget>[
                    if (imgUrl.startsWithHttp)
                      CircularProfileAvatar(
                        imageUrl: imgUrl,
                        backgroundColor: Fav.design.scaffold.background,
                        radius: 12.0,
                      ),
                    if (imgUrl.startsWithHttp) 12.widthBox,
                    Expanded(
                        child: Text(
                      AppFunctions2.whatIsThisName(item.teacherKey, exceptStudent: true) ?? 'erasedperson'.translate,
                      style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
                    )),
                  ],
                )),
                if (appBloc.hesapBilgileri.gtS && item.endTime! > now)
                  MyMiniRaisedButton(
                    text: "makeanappointment".translate,
                    onPressed: () {
                      Fav.to(
                          VideoChatAppointment(
                            itemKey: item.key!,
                            lessonName: item.lessonName,
                            teacherImgUrl: imgUrl,
                            dateString: item.startTime!.dateFormat("d-MMMM-yyyy"),
                          ),
                          preventDuplicates: false);
                    },
                    color: Fav.design.primary,
                  ),
                if (appBloc.hesapBilgileri.gtMT)
                  MyMiniRaisedButton(
                    text: "examine".translate,
                    onPressed: () async {
                      await Fav.to(
                          VideoChatAppointment(
                            itemKey: item.key!,
                            lessonName: item.lessonName,
                            teacherImgUrl: imgUrl,
                            dateString: item.startTime!.dateFormat("d-MMMM-yyyy"),
                          ),
                          preventDuplicates: false);
                      if (appBloc.hesapBilgileri.gtM) {
                        managerScreenRefreshFunction!(true);
                      }
                    },
                    color: Fav.design.primary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
