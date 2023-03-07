import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/appfunctions.dart';
import '../../../helpers/print/otherprint.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import '../../models/models.dart';
import '../../qbankbloc/getdataservice.dart';

class TestStatisticsPage extends StatefulWidget {
  final Kitap? book;
  final String? testKey;
  TestStatisticsPage({
    this.book,
    this.testKey,
  });

  @override
  _TestStatisticsPageState createState() => _TestStatisticsPageState();
}

class _TestStatisticsPageState extends State<TestStatisticsPage> with AppFunctions {
  String? classKey;
  List<String?> ogretmenSinifListesi = [];
  List<Class> sinifListesi = [];

  Map? statisticsData;
  bool isLoading = false;

  void onChanged(String classKey) {
    setState(() {
      this.classKey = classKey;
    });
  }

  @override
  void initState() {
    super.initState();

    if (AppVar.appBloc.hesapBilgileri.gtT) {
      ogretmenSinifListesi = TeacherFunctions.getTeacherClassList();
    }
    sinifListesi = AppVar.appBloc.classService!.dataList.where((sinif) {
      if (AppVar.appBloc.hesapBilgileri.gtM) return true;
      return ogretmenSinifListesi.contains(sinif.key);
    }).toList();

    setState(() {
      isLoading = true;
    });
    QBGetDataService.getSchoolTestStatistics(widget.book!.bookKey, widget.testKey, AppVar.qbankBloc.hesapBilgileri.kurumID).then((snap) {
      if (snap?.value == null) {
        OverAlert.show(type: AlertType.danger, message: 'neverstudentusetest'.translate);
      } else {
        statisticsData = snap!.value;
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  String timeRemaining(int duration) {
    return (duration / 60000).floor().toString() + ' ' + 'shortminute'.translate + ' ${((duration / 1000 % 60).toStringAsFixed(0))} ${'shortsecond'.translate}';
  }

  // String changeResultFirstCharacter(String character) {
  //   if (character == 'D') return '+';
  //   if (character == 'Y') return 'x';
  //   return '?';
  // }

  String changeResultCharacters(String result) {
    return result.replaceAll('D', '+').replaceAll('Y', '-').replaceAll('B', '?');
  }

  List<List<String?>> getData() {
    return AppVar.appBloc.studentService!.dataList
        .where((stuent) => stuent.classKeyList.contains(classKey))
        .map((e) => [
              e.name,
              ((statisticsData![e.key] ?? {})['ds'] ?? '-').toString(),
              ((statisticsData![e.key] ?? {})['ys'] ?? '-').toString(),
              ((statisticsData![e.key] ?? {})['bs'] ?? '-').toString(),
              (statisticsData![e.key] ?? {})['sure'] == null ? '-' : timeRemaining((statisticsData![e.key] ?? {})['sure']),
              (statisticsData![e.key] ?? {})['results'] == null ? '' : changeResultCharacters((statisticsData![e.key] ?? {})['results'])
            ])
        .toList()
      ..insert(0, [
        'name'.translate,
        'ds'.translate,
        'ys'.translate,
        'bs'.translate,
        'time'.translate,
        'resultsquestionstatistics'.translate,
      ]);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        topBar: TopBar(
          leadingTitle: widget.book!.name1,
          trailingActions: [
            MyMiniRaisedButton(
              text: Words.print,
              onPressed: () {
                OtherPrint.printQbankTestStatistics(getData());
              },
              iconData: Icons.print,
            ),
          ],
        ),
        topActions: TopActionsTitleWithChild(
            title: TopActionsTitle(title: 'studentstatistics'.translate),
            child: Column(
              children: [
                if (sinifListesi.isNotEmpty)
                  AdvanceDropdown(
                    name: "chooseclass".translate,
                    iconData: MdiIcons.googleClassroom,
                    items: sinifListesi
                        .map((sinif) => DropdownItem(
                              name: sinif.name,
                              value: sinif.key,
                            ))
                        .toList(),
                    onChanged: onChanged,
                  ),
              ],
            )),
        body: Body.child(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: isLoading
                    ? MyProgressIndicator(isCentered: true)
                    : statisticsData == null
                        ? EmptyState(text: 'chooseclass'.translate)
                        : Builder(builder: (context) {
                            final List<List<String?>> data = getData();

                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: data
                                    .map((studentData) => Row(
                                          children: <Widget>[
                                            Container(
                                              color: Fav.design.primaryText.withOpacity(0.1),
                                              margin: const EdgeInsets.all(1),
                                              padding: const EdgeInsets.all(8),
                                              width: 130,
                                              child: Text(studentData[0]!, maxLines: 1, style: TextStyle(fontSize: 14, color: Fav.design.primaryText)),
                                            ),
                                            Container(
                                              color: Colors.green.withOpacity(0.1),
                                              alignment: Alignment.center,
                                              margin: const EdgeInsets.all(1),
                                              padding: const EdgeInsets.all(8),
                                              width: 50,
                                              child: Text(
                                                studentData[1]!,
                                                maxLines: 1,
                                                style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              color: Colors.red.withOpacity(0.1),
                                              alignment: Alignment.center,
                                              margin: const EdgeInsets.all(1),
                                              padding: const EdgeInsets.all(8),
                                              width: 50,
                                              child: Text(
                                                studentData[2]!,
                                                maxLines: 1,
                                                style: const TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              color: Colors.amber.withOpacity(0.1),
                                              alignment: Alignment.center,
                                              margin: const EdgeInsets.all(1),
                                              padding: const EdgeInsets.all(8),
                                              width: 50,
                                              child: Text(
                                                studentData[3]!,
                                                maxLines: 1,
                                                style: const TextStyle(fontSize: 14, color: Colors.amber, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              color: Colors.purple.withOpacity(0.1),
                                              alignment: Alignment.center,
                                              margin: const EdgeInsets.all(1),
                                              padding: const EdgeInsets.all(8),
                                              width: 100,
                                              child: Text(
                                                studentData[4]!,
                                                maxLines: 1,
                                                style: const TextStyle(fontSize: 14, color: Colors.purple, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            data.indexOf(studentData) == 0
                                                ? Container(
                                                    color: Colors.deepOrangeAccent.withOpacity(0.1),
                                                    alignment: Alignment.center,
                                                    margin: const EdgeInsets.all(1),
                                                    padding: const EdgeInsets.all(8),
                                                    child: Text(
                                                      studentData[5]!,
                                                      maxLines: 1,
                                                      style: const TextStyle(fontSize: 14, color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold),
                                                    ),
                                                  )
                                                : Container(
                                                    color: Colors.deepOrangeAccent.withOpacity(0.1),
                                                    alignment: Alignment.center,
                                                    margin: const EdgeInsets.all(1),
                                                    //  padding: EdgeInsets.all(8),
                                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                                      for (var i = 0; i < studentData[5]!.length; i++)
                                                        Container(
                                                          padding: const EdgeInsets.all(2),
                                                          margin: const EdgeInsets.only(right: 1),
                                                          color: studentData[5]!.substring(i, i + 1) == '+'
                                                              ? Colors.green
                                                              : studentData[5]!.substring(i, i + 1) == '-'
                                                                  ? Colors.red
                                                                  : Colors.amber,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: <Widget>[
                                                              Text('${i + 1}', style: const TextStyle(fontSize: 10)),
                                                              Text(
                                                                studentData[5]!.substring(i, i + 1),
                                                                style: const TextStyle(fontSize: 10),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                    ]),
                                                  ),
                                          ],
                                        ))
                                    .toList());
                          })),
          ),
        ));
  }
}
