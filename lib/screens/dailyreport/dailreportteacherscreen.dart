import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/appfunctions.dart';
import '../../helpers/glassicons.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import '../../widgets/studentcirclelist.dart';
import '../main/menu_list_helper.dart';
import '../rollcall/ekidrollcallteacher.dart';
import 'editdailyreport.dart';

const _kStudentListStyleKey = 'dailyReportStudentListIsDropdown';

class DailyReportTeacherScreen extends StatefulWidget {
  final bool forMiniScreen;
  DailyReportTeacherScreen({
    this.forMiniScreen = true,
  });
  @override
  _DailyReportTeacherScreenState createState() => _DailyReportTeacherScreenState();
}

class _DailyReportTeacherScreenState extends State<DailyReportTeacherScreen> with AppFunctions {
  int? _dateMillis = DateTime.now().millisecondsSinceEpoch;
  // bool _isLoadingSend = false;
  List<Student> _ogrenciListesi = [];
  String? _seciliOgrenciKey = "";
  final _sendingStudentReportData = {};
  final Map _savingStudentReportData = {};
  Map _receivingStudentReportData = {};

  bool get _receivingStudentReportDataAktif => _receivingStudentReportData['aktif'] == null ? false : (_receivingStudentReportData['aktif']['value'] == '1');
  bool get _receivingStudentReportDataEatListOn => _receivingStudentReportData['aktif'] == null ? false : (_receivingStudentReportData['aktif']['isEatListOn'] == true);

  final Map<String?, TextEditingController> _controllerList = {};
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _refreshPageData() {
    // controllerList.values.forEach((c) => c.dispose());
    _controllerList.clear();
    _formKey = GlobalKey<FormState>();
  }

  Future<void> _getStudentDailyReport() async {
    if (_seciliOgrenciKey!.length < 3) return;
    if (Fav.noConnection()) return;

    OverLoading.show();
    _receivingStudentReportData.clear();
    await DailyReportService.dbStudentDailyReports(_dateMillis!.dateFormat("dd-MM-yyyy"), _seciliOgrenciKey).once().then((snapshot) async {
      await OverLoading.close();
      setState(() {
        _refreshPageData();
        _receivingStudentReportData = snapshot?.value ?? {};

        if (_receivingStudentReportDataEatListOn && !isLoadingEat) {
          _getDayEatList();
        }
      });
    }).catchError((e) async {
      await OverLoading.close();
    });
  }

  void _sendStudentReport(bool aktif) {
    if (Fav.noConnection()) return;

    if (AppVar.appBloc.realTime.dateFormat("d-MM-yyyy") != DateTime.now().dateFormat("d-MM-yyyy")) {
      OverAlert.show(message: "errtimedevice".translate, type: AlertType.danger);
      return;
    }
    if (_dateMillis!.dateFormat("d-MM-yyyy") != DateTime.now().dateFormat("d-MM-yyyy")) {
      OverAlert.show(message: "errsavetimedaily".translate, type: AlertType.danger);
      return;
    }

    if (_seciliOgrenciKey.safeLength < 3) return;

    _sendingStudentReportData.clear();
    _formKey.currentState!.save();

    _sendingStudentReportData["aktif"] = {'icon': 'et99c.png', 'tur': 1, 'value': aktif ? '1' : '0', 'isEatListOn': isEatListOn};
    _sendingStudentReportData["timeStamp"] = databaseTime;

    _sendingStudentReportData["sortinglist"] = _sendingStudentReportData.keys.toList();
    OverLoading.show();

    DailyReportService.dbSetStudentDailyReport(_seciliOgrenciKey, _dateMillis!.dateFormat("dd-MM-yyyy"), _sendingStudentReportData).then((_) {
      setState(() async {
        _receivingStudentReportData = _sendingStudentReportData;
        await OverLoading.close();
        OverAlert.saveSuc();
        _refreshPageData();
      });
    }).catchError((_) async {
      await OverLoading.close();
      OverAlert.saveErr();
    });
  }

  //Idareci gunluk girilen ogrenci listesini gorebilir
  Future<void> _operStudentFormSendingList() async {
    if (Fav.noConnection()) return;

    late List<String?> teacherClassList;
    if (AppVar.appBloc.hesapBilgileri.gtT) teacherClassList = TeacherFunctions.getTeacherClassList();

    OverLoading.show();
    final logsValue = await DailyReportService.dbSendingDaliyReportStudentList(_dateMillis!.dateFormat("dd-MM-yyyy")).once();
    await OverLoading.close();
    Map logs = logsValue?.value ?? {};

    int allCount = 0, count = 0;
    final List listviewChildren = AppVar.appBloc.studentService!.dataList.where((student) {
      if (AppVar.appBloc.hesapBilgileri.gtM) return true;

      if (AppVar.appBloc.hesapBilgileri.gtT) return teacherClassList.any((item) => student.classKeyList.contains(item));

      return false;
    }).map((ogrenci) {
      final bool sended = logs.containsKey(ogrenci.key);
      allCount++;
      if (sended) {
        count++;
      }
      return ListTile(
        title: Text(ogrenci.name!, style: TextStyle(color: Fav.design.primaryText)),
        trailing: Icon(Icons.done_all, color: sended ? Fav.design.customDesign4.primary : Fav.design.customDesign4.primary.withAlpha(30)),
      );
    }).toList();

    if (listviewChildren.isNotEmpty) {
      listviewChildren.insert(
          0,
          ListTile(
            title: Text(
              "sendingdailiyreportlist".translate + " - " + _dateMillis!.dateFormat("dd-MM-yyyy"),
              style: TextStyle(color: Fav.design.primary),
            ),
            trailing: Text(
              "$count/$allCount",
              style: TextStyle(color: Fav.design.customDesign4.primary, fontWeight: FontWeight.bold),
            ),
          ));
      await showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView(padding: const EdgeInsets.symmetric(horizontal: 16.0), children: listviewChildren as List<Widget>);
        },
      );
    }
  }

  Future<void> _onTapMenuButton() async {
    var value = await OverBottomSheet.show(
      BottomSheetPanel.simpleList(title: 'chooseprocess'.translate, items: [
        BottomSheetItem(name: 'editdailyreport'.translate, value: 0, icon: Icons.edit),
        BottomSheetItem(name: 'sendingdailiyreportlist'.translate, value: 1, icon: Icons.list),
        BottomSheetItem(name: 'changedesignstudentlist'.translate, value: 4, icon: Icons.lightbulb_circle_outlined),
        if (!isEatListOn) BottomSheetItem(name: 'yemeklerigetir'.translate, value: 3, icon: MdiIcons.foodForkDrink),
        if (!MenuList.hasTimeTable()) BottomSheetItem(name: 'makerollcall'.translate, value: 2, icon: Icons.assignment_ind),
      ]),
    );

    if (value == 4) {
      final existingValue = Fav.preferences.getBool(_kStudentListStyleKey, false)!;
      await Fav.preferences.setBool(_kStudentListStyleKey, !existingValue);
      setState(() {});
    }

    if (value == 0) {
      if (_seciliOgrenciKey!.length < 3) {
        OverAlert.show(type: AlertType.danger, message: "choosestudent".translate);
        return;
      }
      final classKey = _ogrenciListesi.singleWhere((student) => student.key == _seciliOgrenciKey).class0;
      if (classKey == null) {
        OverAlert.show(type: AlertType.danger, message: "classmissing".translate);
        return;
      }
      if (AppVar.appBloc.classService!.dataList.singleWhereOrNull((sinif) => sinif.key == classKey) == null) {
        OverAlert.show(type: AlertType.danger, message: "classmissing".translate);
        return;
      }

      Fav.to(EditDailyReport(classKey: classKey), preventDuplicates: false).unawaited;
    }
    if (value == 1) {
      _operStudentFormSendingList().unawaited;
    }
    if (value == 3) {
      _getDayEatList().unawaited;
    }
    if (value == 2) {
      if (_seciliOgrenciKey!.length < 3) {
        OverAlert.show(type: AlertType.danger, message: "choosestudent".translate);
        return;
      }
      final classKey = _ogrenciListesi.singleWhere((student) => student.key == _seciliOgrenciKey).class0;
      if (classKey == null) {
        OverAlert.show(type: AlertType.danger, message: "classmissing".translate);
        return;
      }
      if (AppVar.appBloc.hesapBilgileri.gtT && !getGuidanceClassList().contains(classKey)) {
        OverAlert.show(type: AlertType.danger, message: "youarenotguidancestudent".translate);
        return;
      }
      Fav.to(EkidRollCallTeacher(sinif: classKey)).unawaited;
    }
  }

  @override
  void initState() {
    super.initState();
    late List<String?> teacherClassList;

    if (AppVar.appBloc.hesapBilgileri.gtT) {
      teacherClassList = TeacherFunctions.getTeacherClassList();
    }

    if (AppVar.appBloc.hesapBilgileri.gtMT) {
      _ogrenciListesi = AppVar.appBloc.studentService!.dataList.where((student) {
        if (AppVar.appBloc.hesapBilgileri.gtM) return true;

        if (AppVar.appBloc.hesapBilgileri.gtT) return teacherClassList.any((item) => student.classKeyList.contains(item));

        return false;
      }).toList();
    }
  }

  bool isEatListOn = false;
  List<String> dayEatList = [];
  bool isLoadingEat = false;

  Future<void> _getDayEatList() async {
    setState(() {});
    if (isEatListOn) return;
    if (dayEatList.length > 1) return;
    if (Fav.noConnection()) return;

    setState(() {
      isLoadingEat = true;
    });
    EatService.dbDayEatList(_dateMillis!.dateFormat("dd-MM-yyyy")).once().then((snapshot) {
      setState(() {
        isLoadingEat = false;
        dayEatList.clear();
        if (snapshot?.value != null) {
          isEatListOn = true;
          dayEatList = List<String>.from(snapshot!.value);
          dayEatList.sort((a, b) {
            return a.compareTo(b);
          });
          _refreshPageData();
        } else {
          OverAlert.show(type: AlertType.danger, message: "eatlisterr".translate);
        }
      });
    }).unawaited;
  }

  @override
  void dispose() {
    _controllerList.values.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ogrenciListesi.isEmpty) {
      return AppScaffold(
        isFullScreenWidget: widget.forMiniScreen ? true : false,
        scaffoldBackgroundColor: widget.forMiniScreen ? null : Colors.transparent,
        topBar: TopBar(
          leadingTitle: 'menu1'.translate,
          hideBackButton: !widget.forMiniScreen,
        ),
        topActions: TopActionsTitle(title: "dailyreport".translate, imgUrl: GlassIcons.dailyReport.imgUrl, color: GlassIcons.dailyReport.color),
        body: Body(child: Center(child: EmptyState(text: "nostudent".translate))),
      );
    }

    if (_seciliOgrenciKey!.length < 3) {
      return AppScaffold(
          isFullScreenWidget: widget.forMiniScreen ? true : false,
          scaffoldBackgroundColor: widget.forMiniScreen ? null : Colors.transparent,
          topBar: TopBar(
            leadingTitle: 'menu1'.translate,
            hideBackButton: !widget.forMiniScreen,
          ),
          topActions: TopActionsTitleWithChild(
            title: TopActionsTitle(title: "dailyreport".translate, imgUrl: GlassIcons.dailyReport.imgUrl, color: GlassIcons.dailyReport.color),
            child: 'choosestudent'.translate.text.make(),
          ),
          body: Body(
              itemCount: _ogrenciListesi.length,
              maxWidth: 840,
              crossAxisCount: (context.screenWidth ~/ 100).clamp(1, 8),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CircularProfileAvatar(
                      //  imageUrl: (studentList[index].imgUrl ?? '') == '' ? 'https://firebasestorage.googleapis.com/v0/b/class-724.appspot.com/o/UygyulamaDosyalari%2Fekidemptyprofilephoto.png?alt=media&token=12cdc53f-3f87-484b-937c-a55d0ecad906' : (studentList[index].imgUrl ?? ''),
                      imageUrl: _ogrenciListesi[index].imgUrl,
                      borderWidth: 2,
                      radius: 100,
                      elevation: 5,
                      showInitialTextAbovePicture: true,
                      initialsText: _ogrenciListesi[index].name.text.center.autoSize.maxLines(2).fontSize(17).bold.color(Colors.white).make().p4,
                      foregroundColor: Colors.black.withAlpha(150),
                      borderColor: GlassIcons.dailyReport.color!.withAlpha(100),
                      onTap: () {
                        _seciliOgrenciKey = _ogrenciListesi[index].key;
                        setState(() {
                          _refreshPageData();
                        });
                        _getStudentDailyReport();
                      }),
                );
              }));
    }

    List<Map> dailyReportProfileData = List<Map>.from(AppVar.appBloc.dailyReportProfileService!.data[_ogrenciListesi.singleWhere((student) => student.key == _seciliOgrenciKey).class0] ?? []);

    return AppScaffold(
      isFullScreenWidget: widget.forMiniScreen ? true : false,
      scaffoldBackgroundColor: widget.forMiniScreen ? null : Colors.transparent,
      topBar: TopBar(
        hideBackButton: !widget.forMiniScreen,
        leadingTitle: 'menu1'.translate,
        trailingActions: <Widget>[
          FittedBox(
            child: MyDateChangeWidget2(
              textColor: Fav.design.appBar.text,
              initialValue: _dateMillis!,
              onChanged: (value) {
                setState(() {
                  _dateMillis = value;
                  _refreshPageData();
                  isEatListOn = false;
                  dayEatList.clear();
                  isLoadingEat = false;
                });
                _getStudentDailyReport();
              },
            ),
          ),
          8.widthBox,
          IconButton(
            onPressed: _onTapMenuButton,
            icon: Icon(MdiIcons.dotsVertical, color: Fav.design.appBar.text),
          ),
        ],
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              GlassIcons.dailyReport.imgUrl!,
              height: 24,
            ),
            3.widthBox,
            "dailyreport".translate.text.color(GlassIcons.dailyReport.color!).bold.make(),
          ],
        ),
      ),
      topActions: TopActions(
        child: AnimatedSwitcher(
          duration: 333.milliseconds,
          child: Fav.preferences.getBool(_kStudentListStyleKey, false)!
              ? AdvanceDropdown(
                  items: _ogrenciListesi.map((e) => DropdownItem(name: e.name, value: e.key)).toList(),
                  name: 'studentlist'.translate,
                  initialValue: _seciliOgrenciKey,
                  searchbarEnableLength: 10,
                  onChanged: (dynamic value) {
                    _seciliOgrenciKey = value;
                    setState(() {
                      _refreshPageData();
                    });
                    _getStudentDailyReport();
                  },
                )
              : StudentCircleList(
                  isRow: true,
                  selectedKey: _seciliOgrenciKey,
                  scrollKey: '87yhnm',
                  studentList: _ogrenciListesi,
                  onPressed: (value) {
                    _seciliOgrenciKey = value;
                    setState(() {
                      _refreshPageData();
                    });
                    _getStudentDailyReport();
                  },
                  foregroundColor: Colors.black.withAlpha(150),
                  borderColor: GlassIcons.dailyReport.color!.withAlpha(100),
                ),
        ),
      ),
      body: dailyReportProfileData.isEmpty ? Body(child: Center(child: EmptyState(text: "createdailyreportprofile".translate))) : _buildForm(dailyReportProfileData),
      floatingActionButton: dailyReportProfileData.isEmpty
          ? null
          : FloatingActionButton(
              mini: MediaQuery.of(context).size.shortestSide < 600,
              backgroundColor: Fav.design.primary,
              child: Icon(
                //  ((receivingStudentReportData?.keys?.length ?? 0) != 0)
                _receivingStudentReportDataAktif ? Icons.done_all : Icons.menu,
                color: /*((receivingStudentReportData?.keys?.length ?? 0) != 0) ? Colors.blueAccent :*/ Colors.white,
              ),
              onPressed: () async {
                var value = await OverBottomSheet.show(BottomSheetPanel.simpleList(
                  title: 'chooseprocess'.translate,
                  items: [
                    if (_receivingStudentReportDataAktif == false) BottomSheetItem(name: 'saveentryinfo'.translate, icon: Icons.save, value: 0),
                    BottomSheetItem(name: (_receivingStudentReportDataAktif ? "resend" : 'sendentryinfo').translate, icon: Icons.send, value: 1, bold: true),
                    BottomSheetItem.cancel(),
                  ],
                ));

                // var value = await showCupertinoModalPopup(
                //   context: context,
                //   builder: (context) {
                //     return CupertinoActionSheet(
                //       title: Text(
                //         'chooseprocess'.translate,
                //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Fav.design.sheet.headerText),
                //       ),
                //       actions: [
                //         if (_receivingStudentReportDataAktif == false) [0, Icons.save, 'saveentryinfo'.translate],
                //         [1, Icons.send, (_receivingStudentReportDataAktif ? "resend" : 'sendentryinfo').translate]
                //       ]
                //           .map(
                //             (e) => CupertinoActionSheetAction(
                //                 onPressed: () {
                //                   Navigator.pop(context, e[0]);
                //                 },
                //                 child: Row(
                //                   mainAxisAlignment: MainAxisAlignment.center,
                //                   children: <Widget>[
                //                     Icon(e[1], color: Fav.design.sheet.itemText),
                //                     16.widthBox,
                //                     Text(
                //                       e[2],
                //                       style: TextStyle(fontSize: 16.0, color: Fav.design.sheet.itemText, fontWeight: FontWeight.bold),
                //                     ),
                //                   ],
                //                 )),
                //           )
                //           .toList(),
                //       cancelButton: CupertinoActionSheetAction(
                //           isDefaultAction: true,
                //           onPressed: () {
                //             Navigator.pop(context, false);
                //           },
                //           child: Text('cancel'.translate)),
                //     );
                //   },
                // );
                if (value == 0) _sendStudentReport(false);
                if (value == 1) _sendStudentReport(true);
              }),
    );
  }

  Body _buildForm(List<Map> dailyReportProfileData) {
    List<DailyReport> dailyReportList = [];
    dailyReportProfileData.forEach((daily) {
      dailyReportList.add(DailyReport.fromJson(daily));
    });

    List<Widget> dailyWidgets = [];
    List<Widget> educationWidgets = [];

    // Yemek listesi açıksa yemek listesini ekler
    if (isEatListOn) {
      dayEatList.forEach((eatName) {
        dailyWidgets.add(Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: MyCachedImage(width: 38.0, height: 38.0, imgUrl: DailyReport(iconName: "et14c.png").iconUrl, alignment: Alignment.center),
            ),
            Expanded(
              child: MyDropDownField(
                initialValue: (_receivingStudentReportData[eatName.substring(1)] ?? {})["value"],
                name: eatName.substring(1),
                items: ['...', "yedi".translate, "azyedi".translate, "yemedi".translate, "drunk".translate, "didntdrunk".translate]
                    .map((options) => DropdownMenuItem(
                          child: Text(options),
                          value: options,
                        ))
                    .toList(),
                onSaved: (value) {
                  _sendingStudentReportData[eatName.substring(1)] = {"icon": "et14c.png", "value": value, 'tur': 0};
                  _savingStudentReportData[eatName.substring(1)] = value;
                },
              ),
            ),
          ],
        ));
      });
    }

    dailyReportList.forEach((daily) {
      TextEditingController? controller = _controllerList[daily.key];
      if (controller == null) {
        _controllerList[daily.key] = TextEditingController(text: (_receivingStudentReportData[daily.header] ?? {})["value"]);
        controller = _controllerList[daily.key];
      }

      if ((isEatListOn && (daily.key == "data1" || daily.key == "data2" || daily.key == "data3")) == false) {
        (daily.tur == 0 ? dailyWidgets : educationWidgets).add(Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: MyCachedImage(width: 38.0, height: 38.0, imgUrl: daily.iconUrl, alignment: Alignment.center),
            ),
            Expanded(
              child: daily.hasOption!
                  ? AdvanceDropdown(
                      nullValueText: '...',
                      initialValue: (_receivingStudentReportData[daily.header] ?? {})["value"],
                      name: daily.header,
                      // Üç noktayı değiştririen her ikisinide değiştri
                      items: (daily.options!..insert(0, "..."))
                          .map((option) => DropdownItem(
                                name: option,
                                value: option,
                              ))
                          .toList(),
                      onSaved: (dynamic value) {
                        _sendingStudentReportData[daily.header] = {"icon": daily.iconName, "value": value, "tur": daily.tur};
                        _savingStudentReportData[daily.key] = value;
                      },
                    )
                  : MyTextFormField(
                      controller: controller,
                      maxLines: null,
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0, right: 16),
                      labelText: daily.header,
                      onSaved: (String? value) {
                        if (value!.isNotEmpty) {
                          Fav.preferences.addLimitedStringList(daily.header!, value);
                          _sendingStudentReportData[daily.header] = {"icon": daily.iconName, "value": value, "tur": daily.tur};
                          _savingStudentReportData[daily.key] = value;
                        }
                      },
                      suffixIcon: Icons.content_paste.icon.color(Fav.design.disablePrimary).padding(12).size(16).onPressed(() async {
                        final _value = await OverBottomSheet.show(BottomSheetPanel.simpleList(
                          title: "shortcuttextlist".translate,
                          subTitle: "shotcuttexthint".translate,
                          items: [
                            ...Fav.preferences.getLimitedStringList(daily.header!, [])!.fold<List<BottomSheetItem>>([], (p, e) {
                              return p..add(BottomSheetItem(name: e, value: e));
                            }),
                            BottomSheetItem.cancel(),
                          ],
                        ));

                        if (_value != null) {
                          controller!.value = TextEditingValue(text: _value);
                        }
                      }).make(),
                    ),
            ),
          ],
        ));
      }
    });

    // günlük widgterlara başlık ekler
    dailyWidgets.insert(
        0,
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            "dailyreportsname1".translate,
            style: TextStyle(color: Fav.design.primary, fontWeight: FontWeight.bold),
          ),
        ));
    dailyWidgets.insert(1, const Divider());

    // Eğitim widgetlara balşık ekler
    if (educationWidgets.isNotEmpty) {
      educationWidgets.insert(
          0,
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Text(
              "dailyreportsname2".translate,
              style: TextStyle(color: Fav.design.primary, fontWeight: FontWeight.bold),
            ),
          ));
      educationWidgets.insert(1, const Divider());
    }

    TextEditingController? teacherNoteController = _controllerList['teacherController'];
    if (teacherNoteController == null) {
      _controllerList['teacherController'] = TextEditingController(text: _receivingStudentReportData["teacherNote"] ?? '');
      teacherNoteController = _controllerList['teacherController'];
    }
    return Body(
      maxWidth: 720,
      singleChildScroll: MyForm(
        formKey: _formKey,
        child: Column(
          children: <Widget>[
            MyTextFormField(
              controller: teacherNoteController,
              //      initialValue: receivingStudentReportData["teacherNote"] ?? savedData["teacherNote"],
              iconData: MdiIcons.sticker,
              labelText: "teachernote".translate,
              maxLines: null,
              onSaved: (value) {
                _sendingStudentReportData["teacherNote"] = value;
                Fav.preferences.addLimitedStringList("teacherNote", value!);
                _savingStudentReportData['teacherNote'] = value;
              },
              suffixIcon: Icons.content_paste.icon.color(Fav.design.disablePrimary).padding(12).size(16).onPressed(() async {
                final _value = await OverBottomSheet.show(BottomSheetPanel.simpleList(
                  title: "shortcuttextlist".translate,
                  subTitle: "shotcuttexthint".translate,
                  items: [
                    ...Fav.preferences.getLimitedStringList('teacherNote', [])!.fold<List<BottomSheetItem>>([], (p, e) {
                      return p..add(BottomSheetItem(name: e, value: e));
                    }),
                    BottomSheetItem.cancel(),
                  ],
                ));

                if (_value != null) {
                  teacherNoteController!.value = TextEditingValue(text: _value);
                }
              }).make(),
            ),
            8.heightBox,
            Group2Widget(
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 16,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5.0, spreadRadius: 1, offset: Offset(1.0, 1.0))], color: Fav.design.card.background),
                  child: Column(
                    children: dailyWidgets,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5.0, spreadRadius: 1, offset: Offset(1.0, 1.0))], color: Fav.design.card.background),
                  child: Column(
                    children: educationWidgets,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
