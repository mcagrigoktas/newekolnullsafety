import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../timetable/homework/homework_check_helper.dart';
import '../../timetable/hwwidget.helper.dart';

class HomeWorkMiniWidget extends StatelessWidget {
  final HomeWorkCheck data;
  HomeWorkMiniWidget(this.data);
  @override
  Widget build(BuildContext context) {
    final _lesson = AppVar.appBloc.lessonService!.dataListItem(data.lessonKey!);
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      color: Fav.design.card.background,
      child: Row(
        children: <Widget>[
          (_lesson?.longName ?? '').text.color(Colors.white).make().rounded(background: _lesson?.color?.parseColor ?? Colors.teal),
          16.widthBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data.title!,
                  style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  data.content!,
                  maxLines: 3,
                  style: TextStyle(
                    color: Fav.design.primaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 80, height: 40, child: FittedBox(child: HomeWorkWidgetHelper.getNote(data.noteText!))),
        ],
      ).p12,
    );
  }
}
