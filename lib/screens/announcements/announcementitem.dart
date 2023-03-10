import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcpages/documentview.dart';
import 'package:mypackage/srcpages/photoview.dart';
import 'package:mypackage/srcpages/youtube_player/youtubevideopreview.dart';

import '../../adminpages/screens/evaulationadmin/exams/model.dart';
import '../../adminpages/screens/evaulationadmin/onlineexam/controller.dart';
import '../../adminpages/screens/evaulationadmin/onlineexam/layout.dart';
import '../../appbloc/appvar.dart';
import '../../helpers/glassicons.dart';
import '../../helpers/manager_authority_helper.dart';
import '../../localization/usefully_words.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import '../managerscreens/othersettings/user_permission/user_permission.dart';
import '../survey/route_management.dart';
import 'helper.dart';
import 'shareannouncements.dart';

class AnnouncementItem extends StatelessWidget {
  final Announcement? announcement;
  final bool forWidgetMenu;
  AnnouncementItem({this.announcement, this.forWidgetMenu = false});

  @override
  Widget build(BuildContext context) {
    List<Widget> extralist = [];

    bool _isExamAnnounement = false;
    if (announcement!.examFileList != null && announcement!.examFileList!.isNotEmpty) {
      _isExamAnnounement = true;
      extralist.add(Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
        child: MyMiniRaisedButton(
          elevation: 0,
          text: "examfiles".translate,
          onPressed: () {
            AnnonuncementItemHelper.openExamFileList(announcement!.examFileList, context);
          },
          color: const Color(0xffFAE9E7),
          iconData: MdiIcons.file,
          textColor: const Color(0xffE56E60),
        ),
      ));
    }
    if (announcement!.onlineForms != null) {
      _isExamAnnounement = true;
      final examEntries = announcement!.onlineForms!.entries.toList();
      for (var i = 0; i < examEntries.length; i++) {
        final seisonNo = (examEntries[i].key as String).replaceAll('seison', '');
        extralist.add(Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
          child: MyMiniRaisedButton(
            elevation: 0,
            text: "enterexam".translate + (examEntries.length > 1 ? (' ' + 'seison'.translate + ': $seisonNo') : ''),
            onPressed: () {
              Fav.guardTo(OlineExamMain(), binding: BindingsBuilder(() => Get.put<OnlineExamController>(OnlineExamController(announcement!.extraData, announcement!.key, int.tryParse(seisonNo)))));
            },
            color: const Color(0xffE7E9F6),
            iconData: MdiIcons.accountQuestion,
            textColor: const Color(0xff3D4991),
          ),
        ));
      }
    }

    Widget? imageWidget;
    if (announcement!.imgList != null && announcement!.imgList!.isNotEmpty) {
      imageWidget = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 70),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: Swiper(
              key: PageStorageKey(announcement!.key + 'annonucement'),
              itemBuilder: (BuildContext context, int index) {
                return Hero(
                    tag: announcement!.imgList![index],
                    child: MyCachedImage(
                      placeholder: true,
                      fit: BoxFit.cover,
                      imgUrl: announcement!.imgList![index],
                      width: double.infinity,
                    ));
              },
              onTap: (index) {
                AnnonuncementItemHelper.openPhoto(announcement!.imgList!, index);
              },
              //  indicatorLayout: PageIndicatorLayout.WARM,
              autoplayDelay: 3000,
              duration: 1000,
              autoplay: true,
              autoplayDisableOnInteraction: true,
              loop: false,

              itemCount: announcement!.imgList!.length,
              pagination: null,
            ),
          ),
        ),
      );
    }

    announcement!.fileList?.forEach((url) {
      extralist.add(Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
        child: MyMiniRaisedButton(
          elevation: 0,
          text: isWeb ? "downloadfile".translate : "openfile".translate,
          onPressed: () {
            AnnonuncementItemHelper.openFile(url);
          },
          color: const Color(0xffE7F0EA),
          iconData: MdiIcons.paperclip,
          textColor: const Color(0xff2F731F),
        ),
      ));
    });

    if (announcement!.url.safeLength > 5) {
      extralist.add(Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
        child: MyMiniRaisedButton(
          elevation: 0,
          text: "golink".translate,
          onPressed: () {
            AnnonuncementItemHelper.goLink(announcement!.url);
          },
          color: const Color(0xffE5EDFA),
          iconData: MdiIcons.link,
          textColor: const Color(0xff265BC6),
        ),
      ));
    }
    if (announcement!.surveyKey.safeLength > 5) {
      extralist.add(Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
        child: MyMiniRaisedButton(
          elevation: 0,
          text: "gosurvey".translate,
          onPressed: () {
            AnnonuncementItemHelper.goSurvey(announcement);
          },
          color: const Color(0xffF3E8DD),
          iconData: MdiIcons.formatListCheckbox,
          textColor: const Color(0xffBC7228),
        ),
      ));
    }

    // Yayınlanmamışsa idareci için yayınla butonu öğretmen için onay bekliyor yazısı oluşturur.
    if (!(announcement!.isPublish ?? false)) {
      if (AppVar.appBloc.hesapBilgileri.gtT) {
        extralist.add(Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
          child: MyMiniRaisedButton(
            onPressed: () {},
            elevation: 0,
            text: "waitingpublish".translate,
            color: const Color(0xffFAEEF2),
            iconData: MdiIcons.timerSand,
            textColor: const Color(0xffB34064),
          ),
        ));
      } else if (AppVar.appBloc.hesapBilgileri.gtM) {
        extralist.add(Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
          child: MyMiniRaisedButton(
            elevation: 0,
            text: "publish".translate,
            onPressed: () {
              AnnonuncementItemHelper.publish(announcement);
            },
            color: const Color(0xffFAEEF2),
            iconData: IconsaxOutline.send_2,
            textColor: const Color(0xffB34064),
          ),
        ));
      }
    }

    Widget? optionWidget;
    if (AppVar.appBloc.hesapBilgileri.gtT || AuthorityHelper.hasYetki4(warning: false)) {
      optionWidget = PopupMenuButton<String?>(
        tooltip: 'Menu',
        child: SizedBox(width: 32.0, height: 32.0, child: Icon(Icons.more_vert, size: 20.0, color: Fav.design.primaryText.withAlpha(180))),
        // child: MyMiniRaisedButton(text: ".",color: appBloc.appTheme.disablePink,),
        itemBuilder: (context) {
          return <PopupMenuEntry<String>>[
            if (AppVar.appBloc.hesapBilgileri.gtM || AppVar.appBloc.hesapBilgileri.uid == announcement!.senderKey) PopupMenuItem(value: "pinned", child: Text(((announcement!.isPinned ?? false) ? "notpinned" : "pinned").translate)),
            announcement!.targetList!.contains('onlyteachers') ? PopupMenuItem(value: "onlyteachers", child: Text("onlyteachersshared".translate)) : PopupMenuItem(value: "targetlist", child: Text("targetlist".translate)),
            const PopupMenuDivider(),
            if (AppVar.appBloc.hesapBilgileri.gtM || AppVar.appBloc.hesapBilgileri.uid == announcement!.senderKey) PopupMenuItem(value: "edit", child: Text("edit".translate)),
            if (AppVar.appBloc.hesapBilgileri.gtM || AppVar.appBloc.hesapBilgileri.uid == announcement!.senderKey) PopupMenuItem(value: "delete", child: Text(Words.delete)),
          ];
        },
        onSelected: (value) {
          if (Fav.noConnection()) return;
          if (value == "delete") AnnonuncementItemHelper.delete(announcement);
          if (value == "edit") AnnonuncementItemHelper.edit(announcement, forWidgetMenu);
          if (value == "pinned") AnnonuncementItemHelper.pinned(announcement, !(announcement!.isPinned ?? false));
          if (value == "targetlist") AnnonuncementItemHelper.operTargetList(announcement);
        },
      );
    }

    Widget current = Column(
      children: <Widget>[
        (forWidgetMenu ? 6 : 12).heightBox,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            if (announcement!.isPinned ?? false) Padding(padding: const EdgeInsets.only(right: 8.0), child: Icon(MdiIcons.mapMarker, color: GlassIcons.announcementIcon.color, size: 18.0)),
            Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    announcement!.title.text.color(forWidgetMenu ? const Color(0xFF3B1736) : Fav.design.primaryText).maxLines(1).autoSize.fontSize(forWidgetMenu ? 16.0 : 18.0).bold.make(),
                    Row(
                      children: [
                        if (announcement!.senderName != null) announcement!.senderName.text.color(forWidgetMenu ? const Color(0xFF3B1736) : Fav.design.primaryText.withAlpha(180)).autoSize.fontSize(8).make(),
                        if (announcement!.senderName != null) 8.widthBox,
                        Flexible(child: announcement!.getCreteTimeText.text.color(forWidgetMenu ? const Color(0xFF3B1736) : Fav.design.primaryText.withAlpha(180)).fontSize(8).make()),
                      ],
                    ),
                  ],
                )),
            if (optionWidget != null) optionWidget,
          ],
        ),
        10.heightBox,
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (imageWidget != null) imageWidget.pr16,
            Expanded(child: Text(announcement!.content!, style: TextStyle(color: forWidgetMenu ? const Color(0xFF3B1736) : Fav.design.primaryText, fontSize: forWidgetMenu ? 14 : 15.5))),
          ],
        ),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: extralist),
        (forWidgetMenu ? 6 : 12).heightBox,
      ],
    );

    return Container(
      padding: context.screenWidth > 600 ? const EdgeInsets.all(8) : const EdgeInsets.symmetric(horizontal: 8),
      decoration: _isExamAnnounement
          ? BoxDecoration(
              color: const Color(0x08DA9B52),
              borderRadius: BorderRadius.circular(forWidgetMenu ? 8 : 16),
              border: Border.all(color: const Color(0xffDA9B52), width: 2),
            )
          : null
      // BoxDecoration(
      //     color: Fav.design.scaffold.background,
      //     boxShadow: [
      //       BoxShadow(
      //         offset: Offset(3, 3),
      //         color: Fav.design.primaryText.withAlpha(2),
      //         blurRadius: 5,
      //         spreadRadius: 5,
      //       ),
      //       BoxShadow(
      //         offset: Offset(-3, -3),
      //         color: Fav.design.primaryText.withAlpha(2),
      //         blurRadius: 5,
      //         spreadRadius: 5,
      //       )
      //     ],
      //     borderRadius: BorderRadius.circular(forWidgetMenu ? 8 : 16),
      //   )
      ,
      child: current,
    );
  }
}

class AnnonuncementItemHelper {
  AnnonuncementItemHelper._();

  static void openPhoto(List<String> urlList, index) => Fav.to(PhotoView(
        urlList: urlList,
        index: index,
      ));

  static void openFile(String url) => DocumentView.openTypeList(url);

  static void goLink(String? url) {
    if (Fav.noConnection()) return;
    url.launch(LaunchType.url);
  }

  static void goSurvey(Announcement? announcement) {
    SurveyMainRoutes.goSurveyFillPage(announcement);
  }

  static Future<void> publish(Announcement? item) async {
    if (Fav.noConnection()) return;

    if (AuthorityHelper.hasYetki4(warning: true) == false) return;
    OverLoading.show();
    await AnnouncementService.publishAnnouncement(item!).then((_) {
      OverAlert.saveSuc();
    }).catchError((_) {
      OverAlert.saveErr();
    });
    await OverLoading.close();
  }

  static void edit(Announcement? item, bool forWidgetMenu) => Fav.guardTo(
        ShareAnnouncements(
          existingAnnouncement: item,
          previousPageTitle: forWidgetMenu ? 'menu1'.translate : 'announcements'.translate,
        ),
      );

  static Future<void> delete(Announcement? item) async {
    if (Fav.noConnection()) return;

    if (AppVar.appBloc.hesapBilgileri.gtS) return;
    //Guvenlik
    if (AppVar.appBloc.hesapBilgileri.gtT && AppVar.appBloc.hesapBilgileri.uid != item!.senderKey) return;
    //Guvenlik
    if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki4(warning: true) == false) return;

    OverLoading.show();
    await AnnouncementService.deleteAnnouncement(item!.key).then((_) {
      OverAlert.deleteSuc();
    }).catchError((_) {
      OverAlert.deleteErr();
    });
    await OverLoading.close();
  }

  static Future<void> pinned(Announcement? item, bool data) async {
    if (Fav.noConnection()) return;
    if (AppVar.appBloc.hesapBilgileri.gtT && data == true) {
      final _pinnedAnnouncementList = AnnouncementHelper.getAllFilteredAnnouncement().where((element) => element.isPinned == true);
      final _thisTeacherPinnedList = _pinnedAnnouncementList.where((element) => element.senderKey == AppVar.appBloc.hesapBilgileri.uid);
      if (_thisTeacherPinnedList.length >= UserPermissionList.teacherMaxPinAnnouncementCount()) {
        OverAlert.show(message: 'teachermaxpincounthint'.argsTranslate({'count': UserPermissionList.teacherMaxPinAnnouncementCount()}), type: AlertType.warning);
        return;
      }
    }

    OverLoading.show();
    await AnnouncementService.pinnedAnnouncement(item!, data);
    await OverLoading.close();
  }

  static Future<void> operTargetList(Announcement? item) async {
    if (Fav.noConnection()) return;

    OverLoading.show();
    final _logs = await AnnouncementService.getAnnouncementsLog();
    await OverLoading.close();
    if (_logs?.value == null) return;

    int _allCount = 0, _count = 0;
    final List<Widget> _listviewChildren = AppVar.appBloc.studentService!.dataList.where((ogrenci) {
      return item!.targetList!.any((itemm) => ["alluser", ...ogrenci.classKeyList, ogrenci.key].contains(itemm));
    }).map((ogrenci) {
      final bool seen = (_logs!.value[ogrenci.key] ?? 0) >= item!.createTime && item.isPublish!;
      _allCount++;
      if (seen) {
        _count++;
      }
      return Container(
        color: Fav.design.primaryText.withAlpha(_allCount.isEven ? 10 : 0),
        child: Row(
          children: [
            12.widthBox,
            Expanded(child: Text(ogrenci.name, style: TextStyle(color: Fav.design.primaryText, fontSize: 14))),
            4.widthBox,
            Icon(Icons.done_all, color: seen ? Colors.blueAccent : Fav.design.primaryText.withAlpha(35)),
            12.widthBox,
          ],
        ),
      );
    }).toList();

    OverPage.openModelBottomWithListView(
        itemBuilder: (context, index) {
          return _listviewChildren[index];
        },
        maxWidth: 540,
        itemCount: _listviewChildren.length,
        title: 'sender'.translate + ': ' + (item!.senderName ?? ''),
        extraWidget: Row(
          children: [
            Expanded(
              child: item.targetList!.contains("alluser")
                  ? Text("allstudents".translate, style: TextStyle(color: Fav.design.primary))
                  : Wrap(
                      children: AppVar.appBloc.classService!.dataList.where((sinif) {
                        return item.targetList!.contains(sinif.key);
                      }).map((sinif) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          decoration: const ShapeDecoration(color: Colors.amber, shape: StadiumBorder()),
                          child: Text(sinif.name, style: const TextStyle(color: Colors.black87)),
                        );
                      }).toList(),
                    ),
            ),
            8.widthBox,
            "$_count/$_allCount".translate.text.bold.color(Fav.design.primary).make(),
          ],
        ));
  }

  static Future<void> openExamFileList(List<ExamFile>? examFiles, BuildContext context) async {
    if (Fav.noConnection()) return;
    Map fileMap = examFiles!.fold({}, (p, e) => p..[e] = e.name);
    final value = await fileMap.selectOne<ExamFile>(title: 'examfiles'.translate);
    if (value == null) return;
    if (value.examFileType == ExamFileType.file) {
      openFile(value.url!);
    } else if (value.examFileType == ExamFileType.url) {
      await value.url.launch(LaunchType.url);
    } else if (value.examFileType == ExamFileType.youtubeVideo) {
      YoutubeHelper.play(value.url!);
    }
  }
}
