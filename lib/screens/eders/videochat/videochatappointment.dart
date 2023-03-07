import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../helpers/appfunctions.dart';
import '../../../helpers/manager_authority_helper.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import '../../../services/dataservice.dart';
import '../../managerscreens/othersettings/user_permission/user_permission.dart';
import '../livebroadcast/live_area/eager_live_area_starter.dart';

class VideoChatAppointment extends StatefulWidget {
  final String? itemKey;
  final String? lessonName;
  final String? dateString;
  final String? teacherImgUrl;
  VideoChatAppointment({this.itemKey, this.lessonName, this.dateString, this.teacherImgUrl});
  @override
  _VideoChatAppointmentState createState() => _VideoChatAppointmentState();
}

class _VideoChatAppointmentState extends State<VideoChatAppointment> with AppFunctions {
  VideoLessonProgramModel? _program;
  late StreamSubscription _subscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subscription = VideoChatService.dbGetVideoLessonProgram(widget.itemKey).onValue().listen((event) {
      setState(() {
        _program = VideoLessonProgramModel.fromJson(event!.value, event.key);
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  //Ogrenci dersi reserve eder
  void _makeReserve(int lessonNo) {
    if (_isLoading) return;

    if (Fav.noConnection()) return;

//Hedef listesinde ogrenci var mi?
    bool targetListContain = false;
    if (_program!.targetList!.contains("alluser")) {
      targetListContain = true;
    }
    if (_program!.targetList!.any((item) => [...AppVar.appBloc.hesapBilgileri.classKeyList, AppVar.appBloc.hesapBilgileri.uid].contains(item))) {
      targetListContain = true;
    }
    if (!targetListContain) {
      OverAlert.show(type: AlertType.danger, message: 'targetlistnotcontain'.translate);
      return;
    }

    int? lastLessonTime = 0;
    AppVar.appBloc.videoChatStudentService!.dataList.forEach((lesson) {
      if (lesson.startTime! > lastLessonTime! && lesson.teacherKey == _program!.teacherKey && lesson.aktif != false) {
        lastLessonTime = lesson.startTime;
      }
    });
    var derslerArasiSure = _program!.lessons[lessonNo].startTime! - lastLessonTime!;
    if (derslerArasiSure < 0) {
      derslerArasiSure *= -1;
    }
    if (derslerArasiSure < _program!.blockDay! * 24 * 60 * 60 * 1000) {
      OverAlert.show(type: AlertType.danger, message: '(' + _program!.blockDay.toString() + ' ' + 'dayhint'.translate + ') ' + 'videolessonblockhint'.translate);
      return;
    }

    _isLoading = true;
    var studentData = VideoLessonStudentModel()
      ..startTime = _program!.lessons[lessonNo].startTime
      ..endTime = _program!.lessons[lessonNo].endTime
      ..teacherKey = _program!.teacherKey
      ..lessonName = _program!.lessonName
      ..explanation = _program!.explanation;

    VideoChatService.saveReserveLesson(_program!.key!, lessonNo, studentData.mapForSave()).then((_) {
      _isLoading = false;
      OverAlert.saveSuc();
    }).catchError((_) {
      _isLoading = false;
      OverAlert.saveErr();
    });
  }

  //Ogretmen herhangi bir ogrenci icin dersi reserve eder
  Future<void> _makeTeacherReserve(int lessonNo) async {
    if (_isLoading) return;

    if (Fav.noConnection()) return;

    var studentKey = await OverPage.openChoosebleListViewFromMap(
      data: AppVar.appBloc.studentService!.dataList.where((student) {
        if (_program!.targetList!.contains("alluser")) return true;

        if (_program!.targetList!.any((item) => [...student.classKeyList, student.key].contains(item))) return true;

        return false;
      }).fold({}, (p, e) => p..[e.key] = e.name),
      title: 'choosestudent'.translate,
    );

//Hedef listesiyi goster
    // var studentKey = await showCupertinoModalPopup(
    //   context: context,
    //   builder: (context) {
    //     return CupertinoActionSheet(
    //       title: Text(
    //         'choosestudent'.translate,
    //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Fav.design.sheet.headerText),
    //       ),
    //       actions: AppVar.appBloc.studentService.dataList
    //           .where((student) {
    //             if (_program.targetList.contains("alluser")) return true;

    //             if (_program.targetList.any((item) => [...student.classKeyList, student.key].contains(item))) return true;

    //             return false;
    //           })
    //           .map(
    //             (student) => CupertinoActionSheetAction(
    //                 onPressed: () {
    //                   Navigator.pop(context, student.key);
    //                 },
    //                 child: Text(
    //                   student.name,
    //                   style: TextStyle(fontSize: 16.0, color: Fav.design.sheet.itemText, fontWeight: FontWeight.bold),
    //                 )),
    //           )
    //           .toList(),
    //       cancelButton: CupertinoActionSheetAction(
    //           isDefaultAction: true,
    //           onPressed: () {
    //             Navigator.pop(context, null);
    //           },
    //           child: Text('cancel'.translate)),
    //     );
    //   },
    // );
    if (studentKey == null) return;

    _isLoading = true;
    var studentData = VideoLessonStudentModel()
      ..startTime = _program!.lessons[lessonNo].startTime
      ..endTime = _program!.lessons[lessonNo].endTime
      ..teacherKey = _program!.teacherKey
      ..lessonName = _program!.lessonName
      ..explanation = _program!.explanation;

    await VideoChatService.saveTeacherReserveLesson(_program!, lessonNo, studentData.mapForSave(), studentKey).then((_) {
      _isLoading = false;
      OverAlert.saveSuc();
    }).catchError((_) {
      _isLoading = false;
      OverAlert.saveErr();
    });
  }

  //Ogrenci dersi iptal eder
  Future<void> _cancelReserve(int lessonNo) async {
    if (_isLoading) return;

    if (Fav.noConnection()) return;

    _isLoading = true;
    await VideoChatService.cancelReserveLesson(_program!, lessonNo).then((_) {
      _isLoading = false;
      OverAlert.saveSuc();
    }).catchError((_) {
      _isLoading = false;
      OverAlert.saveErr();
    });
  }

  //Dersi baslatir
  Future<void> _startLesson(int lessonNo) async {
    if ((await PermissionManager.microphoneAndCamera()) == false) return;

    // bool spyVisible = false;

    ///spyvisible agoraya gecilmezse kaldir
//    if (AppVar.appBloc.hesapBilgileri.gtM) {
//      spyVisible = await showCupertinoModalPopup(
//        context: context,
//        builder: (context) {
//          return CupertinoActionSheet(
//            title: Text(
//               'chooseprocess'),
//              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color:  Fav.design.sheet.headerText),
//            ),
//            actions: [
//              CupertinoActionSheetAction(
//                  onPressed: () {
//                    Navigator.pop(context, false);
//                  },
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      Icon(Icons.phone_in_talk, color:  Fav.design.sheet.itemText),
//                      16.width,
//                      Text( 'videolessonmaagerspeak'), style: TextStyle(fontSize: 16.0, color:  Fav.design.sheet.itemText, fontWeight: FontWeight.bold)),
//                    ],
//                  )),
//              CupertinoActionSheetAction(
//                  onPressed: () {
//                    Navigator.pop(context, true);
//                  },
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      Icon(Icons.hearing, color:  Fav.design.sheet.itemText),
//                      16.width,
//                      Text( 'videolessonmaagerspy'), style: TextStyle(fontSize: 16.0, color:  Fav.design.sheet.itemText, fontWeight: FontWeight.bold)),
//                    ],
//                  )),
//            ],
//            cancelButton: CupertinoActionSheetAction(
//                isDefaultAction: true,
//                onPressed: () {
//                  Navigator.pop(context, null);
//                },
//                child: Text( 'cancel'))),
//          );
//        },
//      );
//    }

    //  if (spyVisible == null) return;

    List<String?> users = [_program!.teacherKey, _program!.lessons[lessonNo].studentKey];
    users.sort((a, b) => a!.compareTo(b!));
    await LiveAreaStarter.startVideoChat(
      channelName: users[0]! + users[1]!,
      //  spyVisible: spyVisible,
      studentKey: _program!.lessons[lessonNo].studentKey!,
    );
  }

  //Ogretmen dersi iptal eder
  Future<void> _cancelReserve2(int lessonNo) async {
    if (_isLoading) return;

    if (Fav.noConnection()) return;

    bool sure = await Over.sure();
    if (sure == true) {
      _isLoading = true;
      await VideoChatService.cancelReserveLesson(_program!, lessonNo, _program!.lessons[lessonNo].studentKey).then((_) {
        _isLoading = false;
        OverAlert.saveSuc();
      }).catchError((_) {
        _isLoading = false;
        OverAlert.saveErr();
      });
    }
  }

  //Butun programi siler
  Future<void> delete() async {
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      if (UserPermissionList.hasDeletePermissionTeacherOwnELesson() == false) {
        OverAlert.show(message: 'notauthorized'.translate);
        return;
      }
    } else if (AppVar.appBloc.hesapBilgileri.gtM) {
      if (AuthorityHelper.hasYetki4(warning: true) == false) return;
    }

    bool sure = await Over.sure(message: 'videolessonprogramdeletealert'.translate);
    if (sure == true) {
      OverLoading.show();
      await VideoChatService.deleteVideoLessonProgram(_program!).then((_) {
        Get.back();
        OverAlert.deleteSuc();
      }).catchError((_) {
        OverAlert.deleteErr();
      });
      await OverLoading.close();
    }
  }

  Future<void> _operTargetList(VideoLessonProgramModel? item) async {
    if (Fav.noConnection()) return;

    final List listviewChildren = AppVar.appBloc.studentService!.dataList.where((ogrenci) {
      return item!.targetList!.any((itemm) => ["alluser", ...ogrenci.classKeyList, ogrenci.key].contains(itemm));
    }).map((ogrenci) {
      return ListTile(title: Text(ogrenci.name!, style: TextStyle(color: Fav.design.primaryText)));
    }).toList();

    if (listviewChildren.isNotEmpty) {
      listviewChildren.insert(
          0,
          ListTile(
            title: item!.targetList!.contains("alluser")
                ? Text("allusers".translate, style: TextStyle(color: Fav.design.primary))
                : Wrap(
                    children: AppVar.appBloc.classService!.dataList.where((sinif) {
                      return item.targetList!.contains(sinif.key);
                    }).map((sinif) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        decoration: const ShapeDecoration(color: Colors.amber, shape: StadiumBorder()),
                        child: Text(sinif.name!, style: const TextStyle(color: Colors.black87)),
                      );
                    }).toList(),
                  ),
          ));
      await showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: listviewChildren as List<Widget>,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(
        leadingTitle: "videolesson".translate,
        trailingActions: <Widget>[
          if (AppVar.appBloc.hesapBilgileri.gtMT)
            PopupMenuButton(
              tooltip: 'Menu',
              child: SizedBox(
                width: 32.0,
                height: 32.0,
                child: Icon(
                  Icons.more_vert,
                  size: 20.0,
                  color: Fav.design.appBar.text,
                ),
              ),
              itemBuilder: (context) {
                return <PopupMenuEntry>[
                  PopupMenuItem(value: "targetlist", child: Text("targetlist".translate)),
                  const PopupMenuDivider(),
                  if (_program != null && _program!.endTime! > DateTime.now().millisecondsSinceEpoch) PopupMenuItem(value: "delete", child: Text(Words.delete)),
                ];
              },
              onSelected: (dynamic value) {
                if (Fav.noConnection()) return;

                if (value == "delete") delete();

                if (value == "targetlist") _operTargetList(_program);
              },
            ),
          8.widthBox,
          if (widget.teacherImgUrl.startsWithHttp)
            CircularProfileAvatar(
              imageUrl: widget.teacherImgUrl,
              backgroundColor: Fav.design.scaffold.background,
              radius: 18.0,
            ),
        ],
      ),
      topActions: TopActionsTitleWithChild(
        title: TopActionsTitle(title: widget.lessonName!),
        child: widget.dateString.text.color(Fav.design.appBar.text).make(),
      ),
      body: _program == null
          ? Body.child(
              child: MyProgressIndicator(
              isCentered: true,
            ))
          : Body.staggeredGridViewBuilder(
              maxWidth: 720,
              crossAxisCount: context.screenWidth > 600 ? 2 : 1,
              itemCount: _program!.lessons.length,
              itemBuilder: (context, index) {
                final item = _program!.lessons[index];
                final imgUrl = (AppFunctions2.whatIsProfileImgUrl(item.studentKey ?? 'yok', onlyStudent: true) ?? '');
                String subtitle;
                if (item.studentKey != null) {
                  if (AppVar.appBloc.hesapBilgileri.gtS) {
                    subtitle = (item.studentKey == AppVar.appBloc.hesapBilgileri.uid ? 'yourreserve' : 'fullappointment').translate;
                  } else {
                    subtitle = AppFunctions2.whatIsThisName(item.studentKey, onlyStudent: true) ?? 'erasedstudent'.translate;
                  }
                } else {
                  subtitle = 'emptyappointment'.translate;
                }

                return Container(
                  width: double.infinity,
                  //  margin: const EdgeInsets.only(bottom: 4.0, left: 8.0, right: 8.0, top: 8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Fav.design.bottomNavigationBar.background,
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 2.0)],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(backgroundColor: item.state == 0 ? Colors.greenAccent : Colors.redAccent, radius: 6),
                      12.widthBox,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.startTime!.dateFormat("HH:mm-") + item.endTime!.dateFormat("HH:mm"),
                              style: TextStyle(color: Fav.design.accentText, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: <Widget>[
                                if (imgUrl.startsWithHttp)
                                  Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: CircularProfileAvatar(
                                        imageUrl: imgUrl,
                                        backgroundColor: Fav.design.scaffold.background,
                                        radius: 12.0,
                                      )),
                                Expanded(
                                    child: Text(
                                  subtitle,
                                  style: TextStyle(color: Fav.design.primaryText),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (AppVar.appBloc.hesapBilgileri.gtS && item.state == 0 && DateTime.now().millisecondsSinceEpoch < item.endTime!)
                        MyMiniRaisedButton(
                          text: 'makereserve'.translate,
                          onPressed: () {
                            _makeReserve(index);
                          },
                          color: Colors.greenAccent,
                        ),
                      if (AppVar.appBloc.hesapBilgileri.gtS && item.state == 1 && item.studentKey == AppVar.appBloc.hesapBilgileri.uid)
                        MyMiniRaisedButton(
                          text: 'cancelreserve'.translate,
                          onPressed: () {
                            _cancelReserve(index);
                          },
                          color: Colors.redAccent,
                        ),
                      if (AppVar.appBloc.hesapBilgileri.gtMT && item.state == 0 && /*DateTime.now().millisecondsSinceEpoch>item.startTime-3600000&&*/ DateTime.now().millisecondsSinceEpoch < item.endTime! + 3600000)
                        MyMiniRaisedButton(
                          text: 'makereserve'.translate,
                          onPressed: () {
                            _makeTeacherReserve(index);
                          },
                          color: Fav.design.primary,
                        ),
                      if (AppVar.appBloc.hesapBilgileri.gtMT && item.state == 1 && DateTime.now().millisecondsSinceEpoch > item.startTime! - 3600000 && DateTime.now().millisecondsSinceEpoch < item.endTime! + 3600000)
                        MyMiniRaisedButton(
                          text: 'startvideolesson'.translate,
                          onPressed: () {
                            _startLesson(index);
                          },
                          color: Fav.design.primary,
                        ),
                      if (AppVar.appBloc.hesapBilgileri.gtMT && item.state == 1)
                        PopupMenuButton(
                          tooltip: 'Menu',
                          child: SizedBox(
                            width: 32.0,
                            height: 32.0,
                            child: Icon(
                              Icons.more_vert,
                              size: 20.0,
                              color: Fav.design.disablePrimary,
                            ),
                          ),
                          itemBuilder: (context) {
                            return <PopupMenuEntry>[
                              PopupMenuItem(
                                value: "deletereservestudent",
                                child: Text("deletereservestudent".translate),
                              ),
                            ];
                          },
                          onSelected: (dynamic value) {
                            if (Fav.noConnection()) return;

                            if (value == "deletereservestudent") {
                              _cancelReserve2(index);
                            }
                          },
                        ),
                    ],
                  ),
                );
              }),
    );
  }
}
