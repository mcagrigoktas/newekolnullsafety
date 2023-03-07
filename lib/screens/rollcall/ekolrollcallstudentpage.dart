// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import 'helper.dart';

//?EkolRolCallStudentModel sadece bildirim sayfasina ogrenci icin yeni gelen itemlerin sayisini bulmada kullaniliyor
//? Halbuki ekidrollcallstudentmodel yeni data kaydetme disinda kullaniliyor
//? Hem EkolRolCallStudentModeli tamamen hemde ekidrollcallstudentmodeli kayit sirasinda kullansan iyi olur tabi once yazmalisin
class EkolRolCallStudentModel extends DatabaseItem {
  int? lastUpdate;
  EkolRolCallStudentModel();

  EkolRolCallStudentModel.fromJson(Map snapshot, String _) {
    lastUpdate = snapshot['lastUpdate'] ?? 0;
  }

  @override
  bool active() => true;
}

class EkolRollCallStudentPage extends StatelessWidget {
//  'lessonKey' : widget.lesson.key,
//  'classKey' : widget.sinif.key,
//  'value' : value,
//  'date' : DateTime.now().millisecondsSinceEpoch,
//  'lessonNo' : lessonNo,

  /// Bu ekrana idareci ve ogrenci sayfasindan baglanilabilir eger idareci sayfasindan baglanilirsa scaffolda gerek yok
  /// ayrica ogrencinin datasi zaten appbloc ta var. idareci bakiyorsa datayi gondermeli
  final bool hasScaffold;
  Map? data;
  EkolRollCallStudentPage({this.hasScaffold = true, this.data});

  int rollcall1 = 0;
  int rollcall2 = 0;
  int rollcall3 = 0;
  int rollcall4 = 0;
  int rollcall5 = 0;

  @override
  Widget build(BuildContext context) {
    RollCallHelper.saveLastLoginTime();

    //Map classNameCache ={};
    if (AppVar.appBloc.hesapBilgileri.gtS) {
      data = AppVar.appBloc.studentRollCallService!.data;
    }
    Map lessonNameCache = {};
    AppVar.appBloc.lessonService!.dataList.forEach((lesson) {
      lessonNameCache[lesson.key] = lesson.longName;
    });

    Map widgetMap = {};
    List<Widget> expendedList = [];

    data!.forEach((key, value) {
      if (value['value'] == 1) {
        rollcall1++;
      } else if (value['value'] == 2) {
        rollcall2++;
      } else if (value['value'] == 3) {
        rollcall3++;
      } else if (value['value'] == 4) {
        rollcall4++;
      } else if (value['value'] == 5) {
        rollcall5++;
      }

      final String date = (key as String).split('LN:').first;
      final String lesssonNo = key.split('LN:').last;
      List<Widget> existingList = widgetMap[date] ?? List<Widget>.from([]);
      existingList.add(Padding(
        key: Key(lesssonNo.toString()),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    lessonNameCache[value['lessonKey']] ?? 'lessonnameerr'.translate,
                    style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'lesson'.translate + ' ${value['lessonNo']}',
                    style: TextStyle(color: Fav.design.primaryText),
                  ),
                ],
              ),
            ),
            Container(
              width: 90,
              height: 28,
              alignment: Alignment.center,
              decoration: ShapeDecoration(shape: const StadiumBorder(), color: RollCallHelper.getRollCallStatusColor(value['value'])),
              child: Text(
                'rollcall${value['value']}'.translate,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ));
      existingList.sort((Widget a, Widget b) => a.key.toString().compareTo(b.key.toString()));
      widgetMap[date] = existingList;
    });

    final keyList = widgetMap.keys.toList();
    keyList.sort((date1, date2) {
      final date1List = date1.split('-');
      final date2List = date2.split('-');
      return (DateTime(int.tryParse(date1List[2])!, int.tryParse(date1List[1])!, int.tryParse(date1List[0])!).millisecondsSinceEpoch - DateTime(int.tryParse(date2List[2])!, int.tryParse(date2List[1])!, int.tryParse(date2List[0])!).millisecondsSinceEpoch) * -1;
    });

    for (var i = 0; i < keyList.length; i++) {
      final date = keyList[i];
      final widgetList = widgetMap[date];

      expendedList.add(ExpansionTile(
        title: Text(
          date,
          style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
        ),
        children: widgetList,
      ));
    }

    final _topActionWidget = Column(
      children: [
        Text(
          'rcstudenthint'.translate,
          style: TextStyle(color: Fav.design.primaryText),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              if (rollcall1 > 0)
                Container(
                  width: 90,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(shape: const StadiumBorder(), color: RollCallHelper.getRollCallStatusColor(1)),
                  child: Text(
                    'rollcall1'.translate + ': $rollcall1',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              if (rollcall2 > 0)
                Container(
                  width: 90,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(shape: const StadiumBorder(), color: RollCallHelper.getRollCallStatusColor(2)),
                  child: Text(
                    'rollcall2'.translate + ': $rollcall2',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              if (rollcall3 > 0)
                Container(
                  width: 90,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(shape: const StadiumBorder(), color: RollCallHelper.getRollCallStatusColor(3)),
                  child: Text(
                    'rollcall3'.translate + ': $rollcall3',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              if (rollcall4 > 0)
                Container(
                  width: 90,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(shape: const StadiumBorder(), color: RollCallHelper.getRollCallStatusColor(4)),
                  child: Text(
                    'rollcall4'.translate + ': $rollcall4',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              if (rollcall5 > 0)
                Container(
                  width: 90,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(shape: const StadiumBorder(), color: RollCallHelper.getRollCallStatusColor(5)),
                  child: Text(
                    'rollcall5'.translate + ': $rollcall5',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    final _bodyWidget = Column(
      children: [...expendedList],
    );

    if (!hasScaffold) {
      return SingleChildScrollView(
        child: Column(
          children: [_topActionWidget, _bodyWidget],
        ),
      );
    }

    return AppScaffold(
      topBar: TopBar(
        leadingTitle: 'menu1'.translate,
      ),
      topActions: TopActionsTitleWithChild(title: TopActionsTitle(title: 'rollcallinfo'.translate), child: _topActionWidget),
      body: Body.singleChildScrollView(child: _bodyWidget),
    );
  }
}
