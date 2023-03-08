import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../assets.dart';
import '../../helpers/appfunctions.dart';
import '../../helpers/glassicons.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import '../../widgets/studentcirclelist.dart';
import 'editstickers.dart';

class StickersPage extends StatefulWidget {
  final bool forMiniScreen;
  StickersPage({this.forMiniScreen = true});

  @override
  StickersPageState createState() {
    return StickersPageState();
  }
}

class StickersPageState extends State<StickersPage> with AppFunctions {
  bool isLoadingSave = false;
  List<Student> _ogrenciListesi = [];
  String? seciliOgrenciKey = "";
  Map receivingStudentStickerData = {};

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int? segmentIndex = 0;

  void getStudentStickers(BuildContext context) {
    if (seciliOgrenciKey!.length < 3) return;

    if (Fav.noConnection()) return;

    OverLoading.show();
    receivingStudentStickerData.clear();
    StickerService.dbStudentStickersRef(seciliOgrenciKey).once().then((snapshot) async {
      await OverLoading.close();
      setState(() {
        if (snapshot?.value != null) {
          receivingStudentStickerData = snapshot!.value ?? {};
        }
      });
    });
  }

  Future<void> onItemTap(context, Sticker item) async {
    if (item.isHome! && AppVar.appBloc.hesapBilgileri.gtMT) {
      OverAlert.show(type: AlertType.danger, message: 'stickerwarning1'.translate);
      return;
    }
    if (!item.isHome! && AppVar.appBloc.hesapBilgileri.gtS) {
      OverAlert.show(type: AlertType.danger, message: 'stickerwarning2'.translate);
      return;
    }

    final value = await OverBottomSheet.show(BottomSheetPanel.simpleList(
      title: item.title,
      subTitle: item.content ?? '',
      items: [
        BottomSheetItem(name: 'givestar'.translate, icon: Icons.star, itemColor: Fav.design.primary, value: 0),
        BottomSheetItem(name: 'erasestar'.translate, icon: Icons.star_border, itemColor: Fav.design.primaryText, value: 1),
        BottomSheetItem.cancel(),
      ],
    ));

    if (value != null) {
      if (value == 0) {
        await giveStar(item);
      } else if (value == 1) {
        await eraseStar(item);
      }
    }
  }

  Future<void> giveStar(Sticker sticker) async {
    if (Fav.noConnection()) return;

    var kullanilanData = AppVar.appBloc.hesapBilgileri.gtS ? AppVar.appBloc.stickerService!.data : receivingStudentStickerData;

    final existingStarCount = (kullanilanData[sticker.key] ?? {})['stars'] ?? 0;
    OverLoading.show();
    if (sticker.extraData > existingStarCount) {
      await StickerService.dbSetStickersStar(
        AppVar.appBloc.hesapBilgileri.gtS ? AppVar.appBloc.hesapBilgileri.uid : seciliOgrenciKey!,
        sticker,
        existingStarCount + 1,
        sendNotification: AppVar.appBloc.hesapBilgileri.gtMT,
      ).then((_) {
        kullanilanData[sticker.key] ??= {};

        setState(() {
          kullanilanData[sticker.key]['stars'] = existingStarCount + 1;
        });

        OverAlert.saveSuc();
      });
    } else {
      OverAlert.saveErr();
    }
    await OverLoading.close();
  }

  Future<void> eraseStar(Sticker sticker) async {
    var kullanilanData = AppVar.appBloc.hesapBilgileri.gtS ? AppVar.appBloc.stickerService!.data : receivingStudentStickerData;

    if (Fav.noConnection()) return;

    final existingStarCount = (kullanilanData[sticker.key] ?? {})['stars'] ?? 0;
    if (0 < existingStarCount) {
      OverLoading.show();
      await StickerService.dbSetStickersStar(
        AppVar.appBloc.hesapBilgileri.gtS ? AppVar.appBloc.hesapBilgileri.uid : seciliOgrenciKey!,
        sticker,
        existingStarCount - 1,
      ).then((_) {
        setState(() {
          kullanilanData[sticker.key]['stars'] = existingStarCount - 1;
        });

        OverAlert.saveSuc();
      });
      await OverLoading.close();
    } else {
      OverAlert.saveErr();
    }
  }

  @override
  void initState() {
    super.initState();

    //warning uyarisi temizleniyor bottomnaviagationbardan
    // final value = AppVar.appBloc.subjectBottomNavigationBarWarning.value;
    // if (value['stickers'] == true) {
    //   value['stickers'] = false;
    //   AppVar.appBloc.subjectBottomNavigationBarWarning.sink.add(value);
    // }
    // Fav.preferences.setInt(StickerHelper.lastStickerPageEntryTimePrefKey, DateTime.now().millisecondsSinceEpoch);

    late List<String?> teacherClassList;
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      teacherClassList = TeacherFunctions.getTeacherClassList();
    }
    late List<String?> teacherGuidanceClassList;
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      teacherGuidanceClassList = getGuidanceClassList();
    }

    if (AppVar.appBloc.hesapBilgileri.gtMT) {
      _ogrenciListesi = AppVar.appBloc.studentService!.dataList.where((student) {
        if (AppVar.appBloc.hesapBilgileri.gtM) {
          return true;
        }
        if (AppVar.appBloc.hesapBilgileri.gtT && (teacherGuidanceClassList.any((item) => student.classKeyList.contains(item)))) {
          return true;
        }

        if (AppVar.appBloc.hesapBilgileri.gtT && AppVar.appBloc.hesapBilgileri.teacherSeeAllClass!) {
          return true;
        }
        if (AppVar.appBloc.hesapBilgileri.gtT && (teacherClassList.any((item) => student.classKeyList.contains(item)))) {
          return true;
        }

        return false;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppVar.appBloc.hesapBilgileri.gtS) {
      return StreamBuilder<Object>(
          stream: AppVar.appBloc.stickersProfileService!.stream,
          builder: (context, snapshot) {
            return StreamBuilder<Object>(
                stream: AppVar.appBloc.stickerService!.stream,
                builder: (context, snapshot) {
                  List<Sticker> stickersList = AppVar.appBloc.stickersProfileService!.dataList.where((sticker) => sticker.classKey == AppVar.appBloc.hesapBilgileri.class0).toList();

                  return AppScaffold(
                    isFullScreenWidget: widget.forMiniScreen ? true : false,
                    scaffoldBackgroundColor: widget.forMiniScreen ? null : Colors.transparent,
                    topBar: TopBar(
                      leadingTitle: 'menu1'.translate,
                      hideBackButton: !widget.forMiniScreen,
                    ),
                    topActions: stickersList.isNotEmpty
                        ? TopActionsTitleWithChild(
                            title: TopActionsTitle(
                              title: "stickersmenuname".translate,
                              color: GlassIcons.stickers.color,
                              imgUrl: GlassIcons.stickers.imgUrl,
                            ),
                            child: CupertinoSlidingSegmentedControl(
                              groupValue: segmentIndex,
                              onValueChanged: (dynamic value) {
                                setState(() {
                                  segmentIndex = value;
                                });
                              },
                              children: {0: Text('activerewards'.translate), 1: Text('wonrewards'.translate)},
                            ),
                          )
                        : TopActionsTitle(
                            title: "stickersmenuname".translate,
                            color: GlassIcons.stickers.color,
                            imgUrl: GlassIcons.stickers.imgUrl,
                          ),
                    body: stickersList.isNotEmpty
                        ? Body(
                            maxWidth: 840,
                            singleChildScroll: MyForm(
                              formKey: formKey,
                              child: Column(
                                children: <Widget>[
                                  8.heightBox,
                                  _buildStickersTiles(stickersList),
                                  12.heightBox,
                                ],
                              ),
                            ))
                        : Body(
                            child: Center(
                              child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS),
                            ),
                          ),
                  );
                });
          });
    }

    return StreamBuilder<Object>(
        stream: AppVar.appBloc.stickersProfileService!.stream,
        builder: (context, snapshot) {
          return AppScaffold(
            isFullScreenWidget: widget.forMiniScreen ? true : false,
            scaffoldBackgroundColor: widget.forMiniScreen ? null : Colors.transparent,
            topBar: TopBar(
              leadingTitle: 'menu1'.translate,
              hideBackButton: !widget.forMiniScreen,
              trailingActions: <Widget>[
                IconButton(
                  onPressed: () {
                    if (seciliOgrenciKey!.length < 3) {
                      OverAlert.show(type: AlertType.danger, message: "choosestudent".translate);
                      return;
                    }
                    final classKey = _ogrenciListesi.singleWhere((student) => student.key == seciliOgrenciKey).class0;
                    if (classKey == null) {
                      OverAlert.show(type: AlertType.danger, message: "classmissing".translate);
                      return;
                    }
                    Fav.to(EditStickers(classKey: classKey), preventDuplicates: false);
                  },
                  icon: Icon(Icons.edit, color: Fav.design.appBar.text),
                ),
              ],
            ),
            topActions: _ogrenciListesi.isEmpty
                ? TopActionsTitle(
                    title: "stickersmenuname".translate,
                    color: GlassIcons.stickers.color,
                    imgUrl: GlassIcons.stickers.imgUrl,
                  )
                : seciliOgrenciKey!.length < 3
                    ? TopActionsTitleWithChild(
                        title: TopActionsTitle(
                          title: "stickersmenuname".translate,
                          color: GlassIcons.stickers.color,
                          imgUrl: GlassIcons.stickers.imgUrl,
                        ),
                        child: 'choosestudent'.translate.text.make())
                    : TopActionsTitleWithChild(
                        title: TopActionsTitle(
                          title: "stickersmenuname".translate,
                          color: GlassIcons.stickers.color,
                          imgUrl: GlassIcons.stickers.imgUrl,
                        ),
                        child: Column(
                          children: [
                            StudentCircleList(
                              isRow: true,
                              selectedKey: seciliOgrenciKey,
                              scrollKey: '87yhnm',
                              studentList: _ogrenciListesi,
                              onPressed: (value) {
                                seciliOgrenciKey = value;
                                setState(() {
                                  formKey = GlobalKey<FormState>();
                                });
                                getStudentStickers(context);
                              },
                              foregroundColor: Colors.black.withAlpha(150),
                              borderColor: GlassIcons.stickers.color!.withAlpha(100),
                            ),
                            CupertinoSlidingSegmentedControl(
                              groupValue: segmentIndex,
                              onValueChanged: (dynamic value) {
                                setState(() {
                                  segmentIndex = value;
                                });
                              },
                              children: {0: Text('activerewards'.translate), 1: Text('wonrewards'.translate)},
                            )
                          ],
                        )),
            body: _ogrenciListesi.isEmpty
                ? Body(
                    child: Center(
                        child: EmptyState(
                      text: "nostudent".translate,
                    )),
                  )
                : seciliOgrenciKey!.length < 3
                    ? Body(
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
                                borderColor: GlassIcons.stickers.color!.withAlpha(100),
                                onTap: () {
                                  seciliOgrenciKey = _ogrenciListesi[index].key;
                                  setState(() {
                                    formKey = GlobalKey<FormState>();
                                  });
                                  getStudentStickers(context);
                                }),
                          );
                        })
                    : _buildTeacherForm(context),
          );
        });
  }

  Body _buildTeacherForm(BuildContext context) {
    var classKey = _ogrenciListesi.singleWhere((student) => student.key == seciliOgrenciKey).class0;
    List<Sticker> stickersList = AppVar.appBloc.stickersProfileService!.dataList.where((sticker) => sticker.classKey == classKey).toList();

    if (stickersList.isEmpty) {
      return Body(child: Center(child: EmptyState(text: "createstickersprofile".translate)));
    } else {
      return Body(
        maxWidth: 840,
        singleChildScroll: MyForm(
          formKey: formKey,
          child: _buildStickersTiles(stickersList),
        ),
      );
    }
  }

  Widget _buildStickersTiles(List<Sticker> stickersList) {
    var kullanilanData = AppVar.appBloc.hesapBilgileri.gtS ? AppVar.appBloc.stickerService!.data : receivingStudentStickerData;

    List<Widget> homeWidgets = [];
    List<Widget> schoolWidgets = [];

//    if(segmentIndex==0&&sticker.status ==StickerStatus.active) {return ((sticker.extraData)> ((kullanilanData[sticker.key]??{})['stars'] ?? 0)) ;}
//    if(segmentIndex==1&&sticker.status == StickerStatus.deactive) {return true;}
//    return ((sticker.extraData)<= ((kullanilanData[sticker.key]??{})['stars'] ?? 0))  ;

    stickersList.where((sticker) {
      if (segmentIndex == 0 && sticker.status == StickerStatus.active) {
        return true;
      }
      if (segmentIndex == 1 && sticker.status == StickerStatus.deactive) {
        return true;
      }
      return false;
    }).forEach((sticker) {
      if (sticker.extraData is int) {
        (sticker.isHome! ? homeWidgets : schoolWidgets).add(ListTile(
          dense: true,
          onTap: segmentIndex == 0
              ? () {
                  onItemTap(context, sticker);
                }
              : null,
          title: Text(
            sticker.title!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            sticker.content!,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
          leading: SizedBox(
            width: 38,
            height: 38,
            child: MyCachedImage(width: 38.0, height: 38.0, imgUrl: sticker.iconUrl, alignment: Alignment.center),
          ),
          trailing: SizedBox(
            width: (((sticker.extraData as int) / 2).ceil()) * 24.1,
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: Iterable.generate((sticker.extraData as int)).map((count) {
                return Icon(
                  ((count + 1) <= ((kullanilanData[sticker.key] ?? {})['stars'] ?? 0)) ? Icons.star : Icons.star_border,
                  color: Fav.design.primary,
                );
              }).toList(),
            ),
          ),
        ));
      }
    });

    // ev widgterlara başlık ekler
    if (homeWidgets.isNotEmpty) {
      homeWidgets.insert(
          0,
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "home".translate,
              style: TextStyle(color: Fav.design.primary, fontWeight: FontWeight.bold),
            ),
          ));
      homeWidgets.insert(1, const Divider());
    }
    // okul widgetlara balşık ekler
    if (schoolWidgets.isNotEmpty) {
      schoolWidgets.insert(
          0,
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "school".translate,
              style: TextStyle(color: Fav.design.primary, fontWeight: FontWeight.bold),
            ),
          ));
      schoolWidgets.insert(1, const Divider());
    }

    return Column(
      children: <Widget>[
        segmentIndex == 1
            ? RiveSimpeLoopAnimation.asset(
                url: Assets.rive.ekolRIV,
                artboard: 'GOLD_MEDAL',
                animation: 'play',
                width: 152,
                heigth: 152,
              )
            : const SizedBox(),
        AnimatedGroupWidget(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0,
                      spreadRadius: 1,
                      offset: Offset(1.0, 1.0),
                    )
                  ],
                  color: Fav.design.card.background),
              child: Column(
                children: schoolWidgets,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0,
                      spreadRadius: 1,
                      offset: Offset(1.0, 1.0),
                    )
                  ],
                  color: Fav.design.card.background),
              child: Column(
                children: homeWidgets,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
