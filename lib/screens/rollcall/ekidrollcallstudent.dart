// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import 'helper.dart';

class EkidRolCallStudentModel extends DatabaseItem {
  String? classKey;
  int? value;
  int? date;
  String? stringDate;
  int? lastUpdate;
  EkidRolCallStudentModel({this.value, this.classKey, this.date, this.stringDate});

  EkidRolCallStudentModel.fromJson(Map snapshot, this.stringDate) {
    value = snapshot['value'];
    classKey = snapshot['classKey'];
    date = snapshot['date'];
    lastUpdate = snapshot['lastUpdate'] ?? 0;
  }

  @override
  bool active() => true;
}

class EkidRollCallStudentPage extends StatelessWidget {
//  'classKey' : widget.sinif.key,
//  'value' : value,
//  'date' : DateTime.now().millisecondsSinceEpoch,

  /// Bu ekrana idareci ve ogrenci saygasindan baglanilabilir eger idareci saygasindan baglanilirsa scaffolda gerek yok
  /// ayrica ogrencinin datasi zaten appbloc ta var. idareci bakiyorsa datayi gondermeli

  final bool hasScaffold;
  EkidRollCallStudentPage({this.hasScaffold = true, this.itemList});
  List<EkidRolCallStudentModel>? itemList;

  int rollcall1 = 0;
  int rollcall0 = 0;

  @override
  Widget build(BuildContext context) {
    RollCallHelper.saveLastLoginTime();

    if (AppVar.appBloc.hesapBilgileri.gtS) {
      itemList = List<EkidRolCallStudentModel>.from(AppVar.appBloc.studentRollCallService!.dataList);
    }

    // List<EkidRolCallStudentModel> itemList = [];

    // data.forEach((date, value) {
    //   itemList.add(EkidRolCallStudentModel(value: value['value'], classKey: value['classKey'], date: value['date'], stringDate: date));
    // });
    itemList!.sort((a, b) => a.date! - b.date!);

    Widget current = Column(
      children: [
        //   Text( 'rcstudenthint'),style: TextStyle(color:  Fav.design.primaryText),),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              if (rollcall0 > 0)
                Container(
                  width: 90,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(shape: const StadiumBorder(), color: RollCallHelper.getRollCallEkidStatusColor(0)),
                  child: Text(
                    'rollcall0'.translate + ': $rollcall0',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              if (rollcall1 > 0)
                Container(
                  width: 90,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(shape: const StadiumBorder(), color: RollCallHelper.getRollCallEkidStatusColor(1)),
                  child: Text(
                    'rollcall1'.translate + ': $rollcall1',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
        ...itemList!
            .map((item) => ListTile(
                  title: Text(
                    item.stringDate!,
                    style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
                  ),
                  trailing: Container(
                    width: 90,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(shape: const StadiumBorder(), color: RollCallHelper.getRollCallEkidStatusColor(item.value)),
                    child: Text(
                      'rollcall${item.value}'.translate,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ))
            .toList()
      ],
    );

    if (!hasScaffold) {
      return SingleChildScrollView(child: current);
    }

    return AppScaffold(
      topBar: TopBar(leadingTitle: 'menu1'.translate),
      topActions: TopActionsTitle(title: 'rollcallinfo'.translate),
      body: Body.singleChildScrollView(child: current, maxWidth: 540),
    );
  }
}
