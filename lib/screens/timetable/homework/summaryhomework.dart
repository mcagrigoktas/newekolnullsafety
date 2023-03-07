import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../../flavors/mainhelper.dart';
import '../hwwidget.dart';
import '../modelshw.dart';

class SummaryHomework extends StatefulWidget {
  SummaryHomework();

  @override
  _SummaryHomeworkState createState() => _SummaryHomeworkState();
}

class _SummaryHomeworkState extends State<SummaryHomework> {
  List<HomeWork>? hwList;
  late StreamSubscription _refresher;

  Future<void> getData() async {
    var data = await Fav.securePreferences.getHiveMap("${AppVar.appBloc.hesapBilgileri.uid}${AppVar.appBloc.hesapBilgileri.termKey}HomeWorkAnalyse" + AppConst.preferenecesBoxVersion.toString());
    if (data.keys.isEmpty) return;

    hwList = [];
    data.forEach((key, value) => hwList!.add(HomeWork.fromJson(value, key)));
    hwList!.sort((b, a) => (b.checkDate ?? b.timeStamp) - (a.checkDate ?? a.timeStamp));
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();

    _refresher = AppVar.appBloc.tableProgramService!.stream.listen((_) {
      getData();
    });
  }

  @override
  void dispose() {
    _refresher.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hwList == null || hwList!.isEmpty) {
      return Center(child: Text('noupcomingentries'.translate));
    }

    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: hwList!.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          return HomeWorkWidget(
            publishButton: false,
            showLessonName: true,
            showClassName: AppVar.appBloc.hesapBilgileri.gtS ? false : true,
            tapOn: false,
            homeWork: hwList![index],
            dividerStyle: hwList!.length == 1 ? 3 : (index == 0 ? 0 : (index == hwList!.length - 1 ? 2 : 1)),
          );
        });
  }
}
