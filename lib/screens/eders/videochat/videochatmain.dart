import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/appfunctions.dart';
import '../../../helpers/glassicons.dart';
import '../../../models/models.dart';
import '../../../services/dataservice.dart';
import '../livebroadcast/live_area/eager_live_area_starter.dart';
import 'helper.dart';
import 'makevideochatprogram.dart';
import 'videochatitem.dart';

class VideoChatMain extends StatelessWidget {
  final bool forMiniScreen;
  VideoChatMain({
    this.forMiniScreen = true,
  });
  @override
  Widget build(BuildContext context) {
    return AppVar.appBloc.hesapBilgileri.gtM
        ? VideoChatManagerScreen(forMiniScreen: forMiniScreen)
        : AppVar.appBloc.hesapBilgileri.gtT
            ? VideoChatTeacherScreen(forMiniScreen: forMiniScreen)
            : VideoChatStudentScreen(forMiniScreen: forMiniScreen);
  }
}

class VideoChatManagerScreen extends StatefulWidget {
  final bool forMiniScreen;
  final bool forStudent;
  final String? initialTeacherKey;

  VideoChatManagerScreen({
    this.forStudent = false,
    this.forMiniScreen = true,
    this.initialTeacherKey,
  });

  @override
  State<VideoChatManagerScreen> createState() => _VideoChatManagerScreenState();
}

class _VideoChatManagerScreenState extends State<VideoChatManagerScreen> {
  String? _teacherKey;
  List<VideoLessonProgramModel>? _dataList;
  List<VideoLessonProgramModel> _filteredList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTeacherKey != null) {
      Future.delayed(15.milliseconds).then((value) {
        _teacherKey = widget.initialTeacherKey;
        fetchData();
      });
    }
  }

  void fetchData([bool? force]) {
    if (force == true) {
      _dataList = null;
    }
    if (_dataList != null) {
      setState(() {
        _filteredList = _dataList!.where((item) => (item.teacherKey == _teacherKey || _teacherKey == 'all') && item.aktif != false).toList();
      });
    } else {
      var appBloc = AppVar.appBloc;
      if (_teacherKey == null) {
        return;
      }
      setState(() {
        _dataList = null;
        isLoading = true;
      });

      VideoChatService.dbGetallActiveVideoLesson().once(orderByChild: 'endTime', startAt: DateTime.now().millisecondsSinceEpoch).then((snap) {
        _dataList = [];
        if (snap?.value != null) {
          (snap!.value as Map).forEach((k, v) => _dataList!.add(VideoLessonProgramModel.fromJson(v, k)));
          _dataList!.sort((a, b) => b.startTime! - a.startTime!);
        }

        // Ogrenci hedef listede yoksa o program gosterilmez
        if (appBloc.hesapBilgileri.gtS) {
          _dataList!.removeWhere((program) => !(program.targetList!.any((item) => ['alluser', ...appBloc.hesapBilgileri.classKeyList, appBloc.hesapBilgileri.uid].contains(item))));
        }
        isLoading = false;
        _filteredList = _dataList!.where((item) => (item.teacherKey == _teacherKey || _teacherKey == 'all') && item.aktif != false).toList();
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isFullScreenWidget: widget.forMiniScreen ? true : false,
      scaffoldBackgroundColor: widget.forMiniScreen ? null : Colors.transparent,
      topBar: TopBar(
        leadingTitle: 'menu1'.translate,
        hideBackButton: !widget.forMiniScreen,
        trailingActions: <Widget>[
          if (widget.forStudent == false && AppVar.appBloc.teacherService!.dataList.isNotEmpty)
            IconButton(
              onPressed: () async {
                await Fav.to(MakeVideoChatProgram(), preventDuplicates: false);
                if (AppVar.appBloc.hesapBilgileri.gtM) {
                  fetchData(true);
                }
              },
              icon: Icon(Icons.add, color: Fav.design.appBar.text),
            ),
        ],
      ),
      topActions: TopActionsTitleWithChild(
        title: TopActionsTitle(title: widget.forStudent ? 'makeanappointment'.translate : "p2pappointmentlesson".translate, imgUrl: GlassIcons.videoLesson.imgUrl, color: GlassIcons.videoLesson.color),
        child: AdvanceDropdown<String?>(
          searchbarEnableLength: 35,
          onChanged: (value) {
            _teacherKey = value;
            fetchData();
          },
          initialValue: _teacherKey,
          name: "teacher".translate,
          iconData: MdiIcons.humanMaleBoard,
          items: AppVar.appBloc.teacherService!.dataList.map((teacher) {
            return DropdownItem(value: teacher.key, name: teacher.name);
          }).toList()
            ..insert(0, DropdownItem(value: null, name: 'anitemchoose'.translate))
            ..insert(1, DropdownItem(value: 'all', name: 'all'.translate)),
        ),
      ),
      body: _teacherKey == null
          ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
          : isLoading
              ? Body.child(child: MyProgressIndicator(isCentered: true))
              : _filteredList.isEmpty
                  ? Body.child(
                      child: Center(
                      child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS),
                    ))
                  : Body.listviewBuilder(
                      maxWidth: 720,
                      itemCount: _filteredList.length,
                      itemBuilder: (context, index) {
                        return VideoChatItem(_filteredList[index], managerScreenRefreshFunction: fetchData);
                      }),
      //  bottomBar: EdersHelper.isOnlineClassLessonActive ? BottomBar(child: EdersPageChanger(initialPageType: PageType.P2pAppointmentLesson)) : null,
    );
  }
}

class VideoChatTeacherScreen extends StatelessWidget {
  final bool forMiniScreen;
  VideoChatTeacherScreen({
    this.forMiniScreen = true,
  });
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        initialData: false,
        stream: AppVar.appBloc.videoChatTeacherService!.stream,
        builder: (context, snap) {
          Body _body;
          if (!snap.hasData) {
            _body = Body.child(child: MyProgressIndicator(isCentered: true));
          } else {
            final _dataList = AppVar.appBloc.videoChatTeacherService!.dataList;
            if (_dataList.isEmpty) {
              _body = Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS));
            } else {
              _body = Body.listviewBuilder(
                  itemCount: AppVar.appBloc.videoChatTeacherService!.dataList.length,
                  itemBuilder: (context, index) {
                    return VideoChatItem(AppVar.appBloc.videoChatTeacherService!.dataList[index]);
                  });
            }
          }

          return AppScaffold(
            isFullScreenWidget: forMiniScreen ? true : false,
            scaffoldBackgroundColor: forMiniScreen ? null : Colors.transparent,
            topBar: TopBar(
              hideBackButton: !forMiniScreen,
              leadingTitle: 'menu1'.translate,
              trailingActions: <Widget>[
                if (AppVar.appBloc.teacherService!.dataList.isNotEmpty)
                  IconButton(
                    onPressed: () async {
                      await Fav.to(MakeVideoChatProgram(), preventDuplicates: false);
                    },
                    icon: Icon(Icons.add, color: Fav.design.appBar.text),
                  ),
              ],
            ),
            topActions: TopActionsTitle(
              title: "p2pappointmentlesson".translate,
              imgUrl: GlassIcons.videoLesson.imgUrl,
              color: GlassIcons.videoLesson.color,
            ),
            body: _body,
            // bottomBar: EdersHelper.isOnlineClassLessonActive
            //     ? BottomBar(
            //         child: EdersPageChanger(initialPageType: PageType.P2pAppointmentLesson),
            //       )
            //     : null,
          );
        });
  }
}

class VideoChatStudentScreen extends StatelessWidget {
  final bool forMiniScreen;
  VideoChatStudentScreen({
    this.forMiniScreen = true,
  });
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: AppVar.appBloc.videoChatStudentService!.stream,
        initialData: false,
        builder: (context, snap) {
          final int now = DateTime.now().millisecondsSinceEpoch;
          Body _body;
          if (!snap.hasData || snap.data == false) {
            _body = Body.child(child: MyProgressIndicator(isCentered: true));
          } else {
            final _dataList = VideoChatHelper.getVideoChatDataForStudent();
            if (_dataList.isEmpty) {
              _body = Body.child(
                  child: Center(
                child: EmptyState(text: "norecords".translate),
              ));
            } else {
              _body = Body.listviewBuilder(
                  itemCount: _dataList.length,
                  itemBuilder: (context, index) {
                    final item = _dataList[index];
                    final imgUrl = (AppFunctions2.whatIsProfileImgUrl(item.teacherKey, exceptStudent: true) ?? '');

                    return Opacity(
                      opacity: item.endTime! < now - 3600000 ? 0.5 : 1,
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
                                  style: TextStyle(
                                    color: Fav.design.primaryText,
                                    fontSize: 11.0,
                                  ),
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
                                if (item.startTime! - 3600000 < DateTime.now().millisecondsSinceEpoch && item.endTime! + 3600000 > DateTime.now().millisecondsSinceEpoch)
                                  MyMiniRaisedButton(
                                    text: "startvideolesson".translate,
                                    onPressed: () async {
                                      List<String?> users = [item.teacherKey, AppVar.appBloc.hesapBilgileri.uid];
                                      users.sort((a, b) => a!.compareTo(b!));

                                      if ((await PermissionManager.microphoneAndCamera()) == false) return;

                                      LiveAreaStarter.startVideoChat(channelName: users[0]! + users[1]!).unawaited;
                                    },
                                    color: Fav.design.primary,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            }
          }

          return AppScaffold(
            isFullScreenWidget: forMiniScreen ? true : false,
            scaffoldBackgroundColor: forMiniScreen ? null : Colors.transparent,
            topBar: TopBar(
              hideBackButton: !forMiniScreen,
              leadingTitle: 'menu1'.translate,
              trailingActions: <Widget>[
                if (AppVar.appBloc.teacherService!.dataList.isNotEmpty)
                  MyMiniRaisedButton(
                    text: "makeanappointment".translate,
                    onPressed: () {
                      Fav.to(VideoChatManagerScreen(forStudent: true), preventDuplicates: false);
                    },
                    color: Fav.design.primary,
                  ),
              ],
            ),
            topActions: TopActionsTitle(
              title: "p2pappointmentlesson".translate,
              imgUrl: GlassIcons.videoLesson.imgUrl,
              color: GlassIcons.videoLesson.color,
            ),
            body: _body,
            // bottomBar: EdersHelper.isOnlineClassLessonActive
            //     ? BottomBar(
            //         child: EdersPageChanger(initialPageType: PageType.P2pAppointmentLesson),
            //       )
            //     : null,
          );
        });
  }
}
