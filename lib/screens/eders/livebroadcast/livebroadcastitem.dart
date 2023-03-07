import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/appfunctions.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';
import 'broadcaststarter/broadcaststarthelper.dart';
import 'makeprogram/makebroadcastprogram.dart';

class LiveBroadcastItem extends StatelessWidget with AppFunctions {
  final LiveBroadcastModel? item;
  LiveBroadcastItem({this.item});

  Future<void> delete(String? itemKey) async {
    bool sure = await Over.sure(message: 'deletesure'.translate);
    if (sure == true) {
      LiveBroadCastService.deleteBroadcastProgram(itemKey).then((value) => OverAlert.deleteSuc()).catchError((err) => OverAlert.deleteErr()).unawaited;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final imgUrl = (AppFunctions2.whatIsProfileImgUrl(item!.teacherKey, exceptStudent: true) ?? '');
    final teacherName = AppFunctions2.whatIsThisName(item!.teacherKey, exceptStudent: true);
    if (teacherName == null) return const SizedBox();
    return Opacity(
      opacity: item!.timeType != 1 && item!.endTime! < now ? 0.5 : 1,
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
                Expanded(flex: 1, child: Text(item!.lessonName!, style: TextStyle(color: Fav.design.card.text, fontSize: 18.0, fontWeight: FontWeight.bold))),
                if ((item!.timeType ?? 0) == 0)
                  Text(
                    item!.startTime!.dateFormat("d-MMMM / HH:mm-") + item!.endTime!.dateFormat("HH:mm"),
                    style: TextStyle(color: Fav.design.card.text, fontSize: 11.0),
                  ),
                if ((item!.timeType ?? 0) == 1)
                  Text(
                    'pinned1'.translate,
                    style: TextStyle(color: Fav.design.card.text, fontSize: 11.0),
                  ),
                if ((AppVar.appBloc.hesapBilgileri.uid == item!.teacherKey && AppVar.appBloc.hesapBilgileri.gtT) || AppVar.appBloc.hesapBilgileri.gtM)
                  MyPopupMenuButton(
                    itemBuilder: (context) {
                      return <PopupMenuEntry>[
                        PopupMenuItem(value: 1, child: Text('edit'.translate)),
                        PopupMenuItem(value: 0, child: Text(Words.delete)),
                      ];
                    },
                    child: Padding(padding: const EdgeInsets.only(left: 4.0), child: Icon(Icons.more_vert, color: Fav.design.card.button)),
                    onSelected: (value) async {
                      if (value == 0) {
                        delete(item!.key).unawaited;
                      }
                      if (value == 1) {
                        await Fav.guardTo(MakeLiveBroadcastProgram(existingItem: item));
                      }
                    },
                  ),
              ],
            ),
            8.heightBox,
            Text(item!.explanation!, style: TextStyle(color: Fav.design.card.variantText)),
            8.heightBox,
            Row(
              children: <Widget>[
                Expanded(
                    child: Row(
                  children: <Widget>[
                    if (imgUrl.startsWithHttp) CircularProfileAvatar(imageUrl: imgUrl, backgroundColor: Fav.design.scaffold.background, radius: 12.0).pr8,
                    Expanded(child: Text(teacherName, style: TextStyle(color: Fav.design.card.text, fontWeight: FontWeight.bold))),
                  ],
                )),
                BroadcastHelper.broadcastStartWidget(context, item!)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
