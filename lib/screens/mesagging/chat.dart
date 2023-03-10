import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../assets.dart';
import '../../helpers/appfunctions.dart';
import '../../helpers/glassicons.dart';
import '../../models/allmodel.dart';
import '../../services/dataservice.dart';
import '../../services/smssender.dart';
import 'chat_ui.dart';
import 'message_child_item.dart';
import 'sound_recorder.dart';

class ChatScreen extends StatefulWidget {
  final MesaggingPreview? mesaggingPreview;

  final bool? ghost;
  //Veli ile ozel mesajlasabilme

  final String? ghostUid;

  ChatScreen({this.mesaggingPreview, this.ghost, this.ghostUid});

  @override
  ChatScreenState createState() {
    return ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen> with AppFunctions {
  String get _targetKey => widget.mesaggingPreview!.senderKey!;
  String? get _targetName => widget.mesaggingPreview!.senderName;
  String? get _targetImgUrl => widget.mesaggingPreview!.senderImgUrl;
  // Student student;
  bool _isLoading = false;
  int? _targetLoginTime = 0;

  ///Veli 1 veya 2 nin son giris tarihini ceker
  int? _targetLoginTimeParent = 0;
  int? _targetLoginTimeParent2 = 0;
  StreamSubscription? _loginTimeSubscription;
  StreamSubscription? _loginTimeSubscriptionParent;
  StreamSubscription? _loginTimeSubscriptionParent2;
  final _textEditingController = TextEditingController();
  MiniFetcher<ChatModel>? _chatFetcher;
  int? _pageType = 0; //0 Ogretmen  Ogrenci . 1 Ogrentmen veli isParent true ve parenttype 1. 2 veli isparent ve parenttype 2

  late bool _smsButtonIsEnabled;

  bool get _smsButtonIsAcitve => _smsButtonIsEnabled && Fav.preferences.getBool('smsButtonIsAcitve', false)!;
  Future<void> _changeSmsButtonStatus() async {
    await Fav.preferences.setBool('smsButtonIsAcitve', !_smsButtonIsAcitve);
    (_smsButtonIsAcitve ? 'smssendactive' : 'smssendpassive').translate.showAlert();
    setState(() {});
  }

//Target student ise buraya esler
  Student? _student;
  @override
  void initState() {
    super.initState();

    if (AppVar.appBloc.hesapBilgileri.gtMT) {
      _student = AppVar.appBloc.studentService!.dataListItem(_targetKey);
    }

    _smsButtonIsEnabled = AppVar.appBloc.schoolInfoService!.singleData!.smsConfig.isSturdy && AppVar.appBloc.hesapBilgileri.gtMT;

    if (AppVar.appBloc.hesapBilgileri.isParent) {
      if (AppVar.appBloc.hesapBilgileri.parentNo == 2) {
        _pageType = 2;
      } else {
        _pageType = 1;
      }
    }

    _loginTimeSubscription = MessageService.dbMessageLoginTime(_targetKey).onValue().listen((event) async {
      await 100.wait;
      if (event?.value != null && mounted) {
        setState(() {
          _targetLoginTime = event!.value;
        });
      }
    });

    if (!AppVar.appBloc.hesapBilgileri.isEkid && AppVar.appBloc.hesapBilgileri.gtMT) {
      _loginTimeSubscriptionParent = MessageService.dbMessageLoginTime(_targetKey + 'parent').onValue().listen((event) {
        if (event?.value != null) {
          setState(() {
            _targetLoginTimeParent = event!.value;
          });
        }
      });
    }

    if (AppVar.appBloc.hesapBilgileri.gtMT && widget.mesaggingPreview!.targetGirisTuru == 30 && _student!.parentState == 2) {
      _loginTimeSubscriptionParent2 = MessageService.dbMessageLoginTime(_targetKey + 'parent2').onValue().listen((event) {
        if (event?.value != null) {
          setState(() {
            _targetLoginTimeParent2 = event!.value;
          });
        }
      });
    }

    _fetchMessageData();
  }

  List<ChatModel>? _dataList;

  void _fetchMessageData() {
    String boxKey = AppVar.appBloc.hesapBilgileri.kurumID.toString() + (widget.ghost == true ? '20' : AppVar.appBloc.hesapBilgileri.girisTuru).toString() + (widget.ghost == true ? widget.ghostUid : AppVar.appBloc.hesapBilgileri.uid).toString() + (_targetKey).toString();

    _chatFetcher = MiniFetcher<ChatModel>(boxKey, FetchType.LISTEN,
        multipleData: true,
        jsonParse: (key, value) => ChatModel.fromJson(value, key),
        lastUpdateKey: 'timeStamp',
        maxCount: 250,
        sortFunction: (ChatModel i1, ChatModel i2) => i2.timeStamp - i1.timeStamp,
        removeFunction: (a) => a.message == null,
        queryRef: MessageService.dbChats(_targetKey, widget.ghostUid),
        getValueAfter: (_) {
          setState(() {
            _dataList = _chatFetcher!.dataList;
          });
        },
        getValueAfterOnlyDatabaseQuery: (value) {
          if (widget.ghost == false) {
            if (AppVar.appBloc.hesapBilgileri.gtS && AppVar.appBloc.hesapBilgileri.isParent) {
              if (AppVar.appBloc.hesapBilgileri.parentNo == 2) {
                MessageService.setMessageLoginTime(AppVar.appBloc.hesapBilgileri.uid + 'parent2');
              } else {
                MessageService.setMessageLoginTime(AppVar.appBloc.hesapBilgileri.uid + 'parent');
              }
            } else {
              MessageService.setMessageLoginTime(AppVar.appBloc.hesapBilgileri.uid);
            }
          }
        });
  }

  @override
  void dispose() {
    _loginTimeSubscription?.cancel();
    _loginTimeSubscriptionParent?.cancel();
    _loginTimeSubscriptionParent2?.cancel();
    _chatFetcher?.dispose();
    if (widget.ghost == false) {
      Fav.preferences.setInt('${AppVar.appBloc.hesapBilgileri.uid}$_targetKey${AppVar.appBloc.hesapBilgileri.termKey}messageread', DateTime.now().millisecondsSinceEpoch);

      if (AppVar.appBloc.hesapBilgileri.gtS && AppVar.appBloc.hesapBilgileri.isParent) {
        MessageService.setFalseNewMessage(isParent: true, parentNo: AppVar.appBloc.hesapBilgileri.parentNo);
      } else {
        MessageService.setFalseNewMessage(isParent: false);
      }

      // final value = AppVar.appBloc.subjectBottomNavigationBarWarning.value;
      // if (value['messages'] == true) {
      //   value['messages'] = false;
      //   AppVar.appBloc.subjectBottomNavigationBarWarning.sink.add(value);
      // }
    }

    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    //  List<ChatModel> chatList = pageType == 1 ? (_dataList..removeWhere((element) => element.isParent != true)) : (_dataList..removeWhere((element) => element.isParent == true));
    List<ChatModel>? chatList = _dataList?.where((element) {
      if (widget.ghost == true) return true;
      //   log(element.parentNo.toString() + ':' + element.message);
      if (_pageType == 0 && element.isParent != true) return true;
      if (_pageType == 1 && element.isParent == true && (element.parentNo == 1 || element.parentNo == 5)) return true;
      if (_pageType == 2 && element.isParent == true && (element.parentNo == 2 || element.parentNo == 5)) return true;
      return false;
    }).toList();

    return ChatUi(
      scrollController: _scrollController,
      trailing: (_targetImgUrl ?? "").startsWith("http") ? Hero(tag: _targetKey, child: CircularProfileAvatar(imageUrl: _targetImgUrl, backgroundColor: Fav.design.scaffold.background, radius: 16.0)).pr8 : null,
      title: _targetName,
      bottom: Column(
        children: [
          if (!widget.ghost!) 8.heightBox,
          AnimatedContainer(
            duration: const Duration(milliseconds: 333),
            height: _chatFetcher?.refresh.valueOrNull != true ? 29 : 0,
            child: _chatFetcher?.refresh.valueOrNull != true
                ? RiveSimpeLoopAnimation.asset(
                    url: Assets.rive.ekolRIV,
                    artboard: 'LOADING',
                    animation: 'play',
                    width: 25,
                    heigth: 25,
                  ).paddingOnly(top: 2, right: 0, bottom: 2, left: 0)
                : null,
          ),
          if (!widget.ghost! && !(AppVar.appBloc.hesapBilgileri.gtS && AppVar.appBloc.hesapBilgileri.isParent && _pageType == 0))
            Row(
              children: <Widget>[
                Icons.add_rounded.icon.color(GlassIcons.messagesIcon.color).onPressed(_addFile).padding(6).make(),
                Expanded(
                    flex: 1,
                    child: CupertinoTextField(
                      controller: _textEditingController,
                      maxLines: null,
                      style: TextStyle(color: Fav.design.primaryText),
                      decoration: BoxDecoration(
                        color: Fav.design.primaryText.withAlpha(8),
                        border: Border.all(color: Fav.design.primaryText.withAlpha(10)),
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      ),
                      suffix: SizedBox(
                        width: 40.0,
                        height: 40.0,
                        child: _isLoading ? MyProgressIndicator(isCentered: true, color: GlassIcons.messagesIcon.color, size: 24.0) : IconButton(icon: Icon(Icons.send, color: GlassIcons.messagesIcon.color), onPressed: _sendMessage),
                      ),
                    )),
                if (!isWeb)
                  SoundRecorder(
                      iconColor: GlassIcons.messagesIcon.color,
                      audioUploaded: (url) {
                        _sendAudio(url);
                      }),
                if (_smsButtonIsEnabled)
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _changeSmsButtonStatus,
                    child: Column(
                      children: [
                        Icons.sms.icon.color(_smsButtonIsAcitve ? GlassIcons.messagesIcon.color : Fav.design.primaryText.withAlpha(120)).padding(0).make(),
                        'SMS'.text.color(_smsButtonIsAcitve ? GlassIcons.messagesIcon.color : Fav.design.primaryText.withAlpha(120)).fontSize(8).make(),
                      ],
                    ).p8,
                  )
                else
                  16.widthBox,
              ],
            ),
          8.heightBox,
        ],
      ),
      largeTitleActions: (widget.ghost == true || widget.mesaggingPreview!.isManagerAndTeacherChats)
          ? const SizedBox()
          : Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!AppVar.appBloc.hesapBilgileri.isEkid && (AppVar.appBloc.hesapBilgileri.gtMT || AppVar.appBloc.hesapBilgileri.isParent))
                    CupertinoSlidingSegmentedControl<int>(
                      groupValue: _pageType,
                      children: {
                        0: Text(
                          'messagesegment1'.translate,
                          textAlign: TextAlign.center,
                        ),
                        if (AppVar.appBloc.hesapBilgileri.gtMT || AppVar.appBloc.hesapBilgileri.parentNo == 1)
                          1: Text(
                            AppVar.appBloc.hesapBilgileri.gtS
                                ? 'messagesegment2'.translate
                                : _student?.parentState == 2
                                    ? 'mother'.translate
                                    : 'messagesegment2'.translate,
                          ),
                        if (AppVar.appBloc.hesapBilgileri.parentNo == 2 || _student?.parentState == 2)
                          2: Text(
                            AppVar.appBloc.hesapBilgileri.gtS ? 'messagesegment2'.translate : 'father'.translate,
                          )
                      },
                      onValueChanged: (value) {
                        setState(() {
                          _pageType = value;
                        });
                      },
                    ).px4,
                  if (AppVar.appBloc.hesapBilgileri.isEkid && AppVar.appBloc.hesapBilgileri.gtMT && _student?.parentState == 2)
                    CupertinoSlidingSegmentedControl<int>(
                      groupValue: _pageType,
                      children: {
                        0: Text('mother'.translate),
                        2: Text('father'.translate),
                      },
                      onValueChanged: (value) {
                        setState(() {
                          _pageType = value;
                        });
                      },
                    ).px4,
                  if (AppVar.appBloc.hesapBilgileri.isEkol && AppVar.appBloc.hesapBilgileri.gtMT && _pageType! > 0)
                    Text(
                      'parentmessagehint1'.translate,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Fav.design.primaryText.withOpacity(0.7), fontSize: 10),
                    ).pt2,
                ],
              ).py8,
            ),
      body: chatList == null
          ? MyProgressIndicator(isCentered: true)
          : (chatList.isEmpty
              ? Center(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS))
              : GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0 + context.screenBottomPadding + 64),
                          itemCount: chatList.length,
                          itemBuilder: (context, index) {
                            final item = chatList[index];

                            if (item.aktif == false) return Align(alignment: Alignment.topRight, child: 'erasedmessage'.translate.text.color(Colors.amber).make().stadium(background: Colors.amber.withAlpha(20))).py8;

                            Widget _messageChildItem = MessageChildItem(item, item.owner == true);
                            _messageChildItem = ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: (context.screenWidth * 0.65).clamp(0.0, 350.0),
                              ),
                              child: _messageChildItem,
                            );

                            return item.owner == true
                                ? Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      if (index == 0 && item.withSms != true && item.timeStamp > DateTime.now().millisecondsSinceEpoch - const Duration(minutes: 10).inMilliseconds)
                                        Icons.delete.icon.color(Colors.red).onPressed(() {
                                          deleteMessage(item);
                                        }).make(),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (item.withSms == true) 'SMS'.text.bold.fontSize(8).color(Colors.white).make().rounded(background: Colors.yellow[700], borderRadius: 4, padding: Inset(2)).px4,
                                              Icon(Icons.done_all,
                                                  size: 16.0,
                                                  color: item.timeStamp <=
                                                          (_pageType == 0 || AppVar.appBloc.hesapBilgileri.isParent
                                                              ? _targetLoginTime
                                                              : _pageType == 1
                                                                  ? _targetLoginTimeParent
                                                                  : _targetLoginTimeParent2)
                                                      ? Colors.blue
                                                      : Colors.grey.withAlpha(200)),
                                            ],
                                          ),
                                          Text(item.timeStampText, style: TextStyle(color: Fav.design.disablePrimary, fontSize: 9.0)),
                                        ],
                                      ),
                                      ChatBubble(
                                        clipper: ChatBubbleClipper3(type: BubbleType.sendBubble),
                                        //   backGroundColor: Fav.design.customDesign3.accent,
                                        backGroundColor: GlassIcons.messagesIcon.color,
                                        elevation: 1,
                                        shadowColor: GlassIcons.messagesIcon.color.hue30,
                                        margin: const EdgeInsets.only(left: 8, top: 8),
                                        child: _messageChildItem,
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      ChatBubble(
                                        clipper: ChatBubbleClipper3(type: BubbleType.receiverBubble),
                                        backGroundColor: Fav.design.customDesign3.primary,
                                        elevation: 1,
                                        shadowColor: Fav.design.customDesign3.primary.hue30,
                                        margin: const EdgeInsets.only(right: 8, top: 8),
                                        child: _messageChildItem,
                                      ),
                                      Text(item.timeStampText, style: TextStyle(color: Fav.design.disablePrimary, fontSize: 9.0)),
                                    ],
                                  );
                          }),
                    ),
                  ),
                )),
    );
  }

  Future<void> _sendFile() async {
    if (Fav.noConnection()) return;

    MyFile? file = await FilePicker.pickFile(fileType: FileType.ANY);
    if (file == null) return debugPrint("Dosya boş");
    String fileName = file.fileName;
    if (!fileName.contains("doc") && !fileName.contains("xls") && !fileName.contains("ppt") && !fileName.contains("txt") && !fileName.contains("pdf")) {
      OverAlert.show(type: AlertType.danger, message: 'filenosupport'.translate);
      return;
    }
    OverLoading.show();
    var url = await Storage().uploadBytes(file, "${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/MessageFiles", fileName, dataImportance: DataImportance.medium);
    await OverLoading.close();
    if (url == null) return OverAlert.saveErr();
    _textEditingController.value = TextEditingValue(text: fileName);
    await _sendMessage(fileUrl: url);
  }

  Future<void> deleteMessage(ChatModel model) async {
    var sure = await Over.sure();

    if (sure) {
      await _sendMessage(deleteMessage: model);
    }
  }

  Future<bool> _sendMessageWithSms(String _message) async {
    if (_message.isEmpty) return false;
    final _numbers = <String>[];

    if (widget.mesaggingPreview!.targetGirisTuru == 10) {
      final _manager = AppVar.appBloc.managerService!.dataListItem(_targetKey);
      if (_manager != null && _manager.phone.safeLength > 4) _numbers.add(_manager.phone!);
    } else if (widget.mesaggingPreview!.targetGirisTuru == 20) {
      final _teacher = AppVar.appBloc.teacherService!.dataListItem(_targetKey);
      if (_teacher != null && _teacher.phone.safeLength > 4) _numbers.add(_teacher.phone!);
    } else if (widget.mesaggingPreview!.targetGirisTuru == 30) {
      final _student = AppVar.appBloc.studentService!.dataListItem(_targetKey);
      if (_student != null) {
        if (AppVar.appBloc.hesapBilgileri.isEkid) {
          _numbers.addAll([
            if (_student.fatherPhone.safeLength > 4) _student.fatherPhone!,
            if (_student.motherPhone.safeLength > 4) _student.motherPhone!,
          ]);
        } else if (_pageType == 0) {
          if (_student.studentPhone.safeLength > 4) _numbers.add(_student.studentPhone!);
        } else if (_pageType == 1) {
          _numbers.addAll([
            if (_student.fatherPhone.safeLength > 4) _student.fatherPhone!,
            if (_student.motherPhone.safeLength > 4) _student.motherPhone!,
          ]);
        }
      }
    }

    if (_numbers.isEmpty) {
      'couldntfindphone'.translate.showAlert(AlertType.warning);
      return false;
    }

    final _smsModel = SmsModel(message: _message, numbers: _numbers);

    setState(() {
      _isLoading = true;
    });
    final _result = await SmsSender.sendSms([_smsModel], dataIsUserAccountInfo: false, mobilePhoneCanBeUsed: false, sureAlertVisible: false);
    setState(() {
      _isLoading = false;
    });
    if (_result == false) return false;

    // 'smssended'.translate.showAlert(AlertType.successful);
    return true;
  }

  Future<bool> _sendMessage({imageUrl, fileUrl, videoUrl, audioUrl, thumbnailUrl, imgList, ChatModel? deleteMessage}) async {
    if (Fav.noConnection()) return false;

    final _message = _textEditingController.text.trim();
    _textEditingController.text = "";
    if (deleteMessage == null && (_message.isEmpty && imageUrl == null && fileUrl == null && videoUrl == null && audioUrl == null)) return false;
    if (AppFunctions2.isHourPermission() == false) return false;

    if (_smsButtonIsAcitve) {
      final _result = await _sendMessageWithSms(_message);

      if (_result != true) return false;
    }

    setState(() {
      _isLoading = true;
    });

    bool _isParent = false;
    if (!AppVar.appBloc.hesapBilgileri.isEkid) {
      _isParent = _pageType! > 0;
    } else {
      if (AppVar.appBloc.hesapBilgileri.gtMT) {
        if (_student?.parentState == 2 && _pageType == 2) _isParent = true;
      } else {
        if (AppVar.appBloc.hesapBilgileri.parentNo == 2) _isParent = true;
      }
    }

    var _chatMessage = deleteMessage != null
        ? (deleteMessage..aktif = false)
        : (ChatModel()
          ..message = _message
          ..timeStamp = databaseTime
          ..imageUrl = imageUrl ?? imgList?.first
          ..imgList = imgList
          ..fileUrl = fileUrl
          ..videoUrl = videoUrl
          ..audioUrl = audioUrl
          ..thumbnailUrl = thumbnailUrl
          ..isParent = _isParent
          ..withSms = _smsButtonIsAcitve == true ? true : null);
    if (_pageType == 2) _chatMessage.parentNo = 2;

    final _messageSendCompleter = Completer<bool>();

    String? parentVisibleCodeForNotification;
    if (AppVar.appBloc.hesapBilgileri.gtMT) {
      if (AppVar.appBloc.hesapBilgileri.isEkid) {
        if (_student?.parentState == 2) {
          if (_pageType == 2) {
            parentVisibleCodeForNotification = '2';
          } else {
            parentVisibleCodeForNotification = '1';
          }
        } else {
          parentVisibleCodeForNotification = '0';
        }
      }
      if (!AppVar.appBloc.hesapBilgileri.isEkid) {
        if (_pageType! > 0) {
          parentVisibleCodeForNotification = _pageType.toString();
        }
      }
    }

    MessageService.sendMultipleMessage(
      [_targetKey],
      _chatMessage, // ..removeWhere((k, v) => v == null),
      {
        _targetKey: MesaggingPreview(
          senderImgUrl: _targetImgUrl,
          senderKey: _targetKey,
          senderName: _targetName,
          timeStamp: databaseTime,
          lastMessage: deleteMessage != null ? 'erasedmessage'.translate : _message,
          isParent: _isParent,
          parentNo: _pageType == 2 ? 2 : null,
        )
      },
      MesaggingPreview(
          senderName: AppVar.appBloc.hesapBilgileri.name,
          senderImgUrl: AppVar.appBloc.hesapBilgileri.imgUrl,
          senderKey: AppVar.appBloc.hesapBilgileri.uid,
          timeStamp: databaseTime,
          lastMessage: deleteMessage != null ? 'erasedmessage'.translate : _message,
          isParent: _isParent,
          parentNo: _pageType == 2 ? 2 : null),
      forParentMessageMenu: _pageType! > 0 || (AppVar.appBloc.hesapBilgileri.isEkid && ((AppVar.appBloc.hesapBilgileri.gtMT && _student?.parentState == 2) || (AppVar.appBloc.hesapBilgileri.gtS && AppVar.appBloc.hesapBilgileri.parentState == 2))),
      existingKey: deleteMessage?.key,
      parentVisibleCodeForNotification: parentVisibleCodeForNotification,
    ).then((_) {
      setState(() {
        _isLoading = false;
        //  textEditingController.text = "";
      });
      _messageSendCompleter.complete(true);
    }).catchError((_) {
      setState(() {
        _isLoading = false;
      });
      FocusScope.of(context).requestFocus(FocusNode());
      OverAlert.show(type: AlertType.danger, message: "messagesenterr".translate);
      _messageSendCompleter.complete(false);
    }).unawaited;

    return _messageSendCompleter.future;
  }

  Future<void> _addFile() async {
    if (Fav.noConnection()) return;
    if (AppFunctions2.isHourPermission() == false) return;

    final value = await OverBottomSheet.show(BottomSheetPanel.simpleList(title: 'chooseprocess'.translate, items: [
      BottomSheetItem(name: 'addfile'.translate, icon: Icons.insert_drive_file, value: 0),
      BottomSheetItem(name: 'addimage'.translate, icon: Icons.image, value: 1),
      if (Get.find<ServerSettings>().videoServerActive) BottomSheetItem(name: 'addvideo'.translate, icon: Icons.ondemand_video, value: 2),
      BottomSheetItem.cancel(),
    ]));

    // final value = await showCupertinoModalPopup(
    //   context: context,
    //   builder: (context) {
    //     return CupertinoActionSheet(
    //       actions: {
    //         0: [Icons.insert_drive_file, 'addfile'],
    //         1: [Icons.image, 'addimage'],
    //         if (Get.find<ServerSettings>().videoServerActive) 2: [Icons.ondemand_video, 'addvideo'],
    //       }
    //           .entries
    //           .map((e) => CupertinoActionSheetAction(
    //               onPressed: () => Navigator.pop(context, e.key),
    //               child: Row(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: <Widget>[Icon(e.value.first, color: Fav.design.sheet.itemText), 16.widthBox, Text((e.value.last as String).translate, style: TextStyle(fontSize: 16.0, color: Fav.design.sheet.itemText))],
    //               )))
    //           .toList(),
    //       cancelButton: CupertinoActionSheetAction(isDefaultAction: true, onPressed: Get.back, child: Text("cancel".translate)),
    //     );
    //   },
    // );

    if (value == 0) await _sendFile();
    if (value == 1) await _sendMultiplePhoto();
    if (value == 2) await _sendVideo();
  }

  // Future<void> sendPhoto() async {
  //   if (Fav.noConnection()) return;

  //   var request = await PhotoPicker.pickSinglePhotoAndUpload(
  //     context,
  //     saveLocation: "${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/MessageImages",
  //   );

  //   if (request == null) return;

  //   textEditingController.value = TextEditingValue(text: 'picture'.translate);
  //   sendMessage(imageUrl: request);
  // }

  String getSaveLocation(String type) => "aa_MF" + '/' + DateTime.now().dateFormat("yyyy-MM") + '/' + type + '/' + AppVar.appBloc.hesapBilgileri.kurumID;

  Future<void> _sendMultiplePhoto() async {
    if (Fav.noConnection()) return;

    var request = await PhotoPicker.pickMultiplePhotoAndUpload(
      saveLocation: getSaveLocation('Img'),
      maxPhotoCount: 10,
    );

    if (request == null) return;

    _textEditingController.value = TextEditingValue(text: 'picture'.translate);
    await _sendMessage(imgList: request);
  }

  Future<void> _sendAudio(String url) async {
    if (Fav.noConnection()) {
      _textEditingController.value = TextEditingValue(text: 'audio_message'.translate);
      return;
    }

    _textEditingController.value = TextEditingValue(text: 'audio_message'.translate);
    await _sendMessage(audioUrl: url);
  }

  Future<void> _sendVideo() async {
    if (Fav.noConnection()) return;

    CompressedVideoData? videoData = await VideoHelper.pickVideoAndUpload(
      saveLocation: getSaveLocation('Vid'),
    );

    if (videoData == null) return;

    _textEditingController.value = TextEditingValue(text: 'video'.translate);
    await _sendMessage(videoUrl: videoData.videoUrl, thumbnailUrl: videoData.thumbnailUrl);
  }
}
