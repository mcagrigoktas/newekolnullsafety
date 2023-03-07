//import 'dart:async';
//
//
//import 'package:elseifekol/appbloc/appvar.dart';
//import 'package:myvideocall/broadcast.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/foundation.dart';
//import 'package:flutter/material.dart';
//
//import 'package:mypackage/myusefullfuncitons.dart';
//import 'package:mypackage/mywidgets.dart';
//import 'package:mypackage/srcpages/documentview.dart';
//import 'package:mypackage/srcpages/photoview.dart';
//import 'package:flutter/services.dart';
//import 'package:intl/intl.dart';
//import 'package:mcg_database/mcg_database.dart';
//import 'package:rxdart/rxdart.dart';
//
//import 'package:mcg_extension/mcg_extension.dart';
//
//class BroadcastChat extends StatefulWidget {
//  final AppBloc appBloc;
//  final String channelName;
//  final bool spyVisible;
//
//  final BehaviorSubject<bool> subjectStudentisSpeaker;
//  final Stream streamStudentisSpeaker;
//
//  BroadcastChat({this.appBloc, this.channelName, this.spyVisible = false, this.streamStudentisSpeaker, this.subjectStudentisSpeaker});
//
//  @override
//  _BroadcastChatState createState() => _BroadcastChatState();
//}
//
//class _BroadcastChatState extends State<BroadcastChat>  {
//  @override
//  void initState() {
//    if (widget.appBloc.hesapBilgileri.gtS) widget.appBloc.setDataService.saveLiveBroadcastStatus(widget.channelName, BroadcastStatusData(status: 1, isHandWake: 0).toJson());
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return WillPopScope(
//      onWillPop: () async {
//        OverAlert.show(type: AlertType.danger, text: 'pressnobutton'.translate, context: context);
//        return false;
//      },
//      child:   Scaffold(
//        backgroundColor: Fav.design.scaffold.background,
//        body: Stack(
//          children: <Widget>[
//            Positioned(
//                top: 0,
//                bottom: 0,
//                right: 0,
//                left: 0,
//                child: LiveBroadcastPage(
//                  streamStudentisSpeaker: widget.streamStudentisSpeaker,
//                  channelName: widget.channelName,
//                  agoraAppId: widget.appBloc.schoolInfoService.singleData.agoraAppId,
//                  myChannelUid: 0, //todo bu niye  0
//                  info: '${widget.appBloc.hesapBilgileri.kurumID}-${widget.appBloc.hesapBilgileri.uid}-${widget.appBloc.hesapBilgileri.girisTuru}',
//                  spyVisible: widget.spyVisible,
//                  doBeforeClose: () {
//                    if (widget.appBloc.hesapBilgileri.gtS)
//                      widget.appBloc.setDataService.saveLiveBroadcastStatus(
//                          widget.channelName,
//                          BroadcastStatusData(
//                            status: 2,
//                            isHandWake: 0,
//                          ).toJson());
//                  },
//                )),
//            Positioned(
//                top: context.screenHeight / 3,
//                bottom: 0,
//                right: 0, //context.screenWidth / 3,
//                left: 0,
//                child: Opacity(
//                  opacity: 0.75,
//                  child: SimpleChatScreen(
//                    appBloc: widget.appBloc,
//                    channelName: widget.channelName,
//                    subjectStudentisSpeaker: widget.subjectStudentisSpeaker,
//                  ),
//                )),
//          ],
//        ),
//      ),
//    );
//  }
//}
//
//class ChatModel {
//  String sender;
//  int timeStamp;
//  String imageUrl;
//  String fileUrl;
//  String message;
//  String senderName;
//
//  ChatModel.fromJson(Map snapshot) {
//    snapshot.forEach((key, value) {
//      if (key == "sender") {
//        sender = value;
//      } else if (key == "timeStamp") {
//        timeStamp = value;
//      } else if (key == "imageUrl") {
//        imageUrl = value;
//      } else if (key == "fileUrl") {
//        fileUrl = value;
//      } else if (key == "message") {
//        message = value;
//      } else if (key == "senderName") {
//        senderName = value;
//      }
//    });
//  }
//
//  String get timeStampText => DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(timeStamp));
//}
//
//class SimpleChatScreen extends StatefulWidget {
//  final AppBloc appBloc;
//  final String channelName;
//  final BehaviorSubject<bool> subjectStudentisSpeaker;
//  SimpleChatScreen({this.appBloc, this.channelName, this.subjectStudentisSpeaker});
//
//  @override
//  _SimpleChatScreenState createState() => _SimpleChatScreenState();
//}
//
//class _SimpleChatScreenState extends State<SimpleChatScreen> with  MyFunctions {
//  TextEditingController textEditingController = TextEditingController();
//  bool isLoading = false;
//
//  StreamSubscription streamSubscription;
//  StreamSubscription streamSubscriptionUser;
//  List<Snap> messageValue = [];
//
//  /// Username - status
//  List<BroadcastStatusData> users = [];
//
//  bool newMessageReceived = false;
//
//  ///0 kapali 1 mesaj 2 online student list
//  int screenType = 0;
//
//  @override
//  void initState() {
//    streamSubscription = widget.appBloc.getDataService.dbVideoChats(widget.channelName).onChildAdded(orderByKey: true, limitToLast: 10).listen((event) {
//      if (event.value == null) return;
//      //   messageValue.clear();
//      messageValue.add(Snap(event.key, event.value));
//      newMessageReceived = true;
//      messageValue.sort((s1, s2) => s1.value['timeStamp'] - s2.value['timeStamp']);
//      setState(() {});
//    });
//
//    if (!widget.appBloc.hesapBilgileri.gtS) {
//      widget.appBloc.getDataService.dbGetLiveBroadcastUser(widget.channelName).onValue().listen((event) {
//        users.clear();
//        if (event.value is Map) {
//          (event.value as Map).forEach((key, value) {
//            users.add(BroadcastStatusData.fromJson(value, key));
//          });
//        }
//        if (screenType == 2) {
//          setState(() {});
//        }
//      });
//    } else {
//      widget.appBloc.getDataService.dbGetStudentIsLiveSpeaker(widget.channelName).onValue().listen((event) {
//        widget.subjectStudentisSpeaker.add(event.value == 2);
//      });
//    }
//    super.initState();
//  }
//
//  @override
//  void dispose() {
//    streamSubscription?.cancel();
//    streamSubscriptionUser?.cancel();
//    super.dispose();
//  }
//
//  sendMessage(BuildContext context, {imageUrl, fileUrl}) async {
//    if ((textEditingController.text.length < 1 && imageUrl == null && fileUrl == null) || (Fav.noConnection() )) return;
//
//    setState(() {
//      isLoading = true;
//    });
//
//    widget.appBloc.setDataService
//        .addVideoChatsMessage(
//            widget.channelName,
//            {
//              "message": textEditingController.text,
//              "timeStamp": databaseTime,
//              'imageUrl': imageUrl,
//              'fileUrl': fileUrl,
//              'sender': widget.appBloc.hesapBilgileri.uid,
//              'senderName': widget.appBloc.hesapBilgileri.name,
//            }..removeWhere((k, v) => v == null))
//        .then((_) {
//      setState(() {
//        isLoading = false;
//        textEditingController.text = "";
//      });
//    }).catchError((_) {
//      FocusScope.of(context).requestFocus(new FocusNode());
//      Alert.alert( type: AlertType.danger, message:   "messagesenterr"));
//    });
//  }
//
//  addFile(context) async {
//    final value = await showCupertinoModalPopup(
//      context: context,
//      builder: (context) {
//        return CupertinoActionSheet(
//          actions: [
//            CupertinoActionSheetAction(
//                onPressed: () {
//                  Navigator.pop(context, 0);
//                },
//                child: Row(
//                  mainAxisSize: MainAxisSize.min,
//                  children: <Widget>[
//                    Icon(Icons.insert_drive_file, color: Fav.design.primary),
//                    16.width,
//                    Text(  'addfile'), style: TextStyle(fontSize: 16.0, color: widget.appBloc.theme.actionSheetItemTextColor)),
//                  ],
//                )),
//            CupertinoActionSheetAction(
//                onPressed: () {
//                  Navigator.pop(context, 1);
//                },
//                child: Row(
//                  mainAxisSize: MainAxisSize.min,
//                  children: <Widget>[
//                    Icon(Icons.image, color: Fav.design.primary),
//                    16.width,
//                    Text(  'addimage'), style: TextStyle(fontSize: 16.0, color: widget.appBloc.theme.actionSheetItemTextColor)),
//                  ],
//                )),
//          ],
//          cancelButton: CupertinoActionSheetAction(
//              isDefaultAction: true,
//              onPressed: () {
//                Get.back();
//              },
//              child: Text(  "cancel"))),
//        );
//      },
//    );
//
//    if (value != null) {
//      if (value == 0) {
//        sendFile(context);
//      } else if (value == 1) {
//        sendPhoto(context);
//      }
//    }
//  }
//
//  sendPhoto(context) async {
//    if (Fav.noConnection() ) return;
//
//    var request = await PhotoPicker.pickSinglePhotoAndUpload(
//      context,
//      storage: widget.appBloc.storage1,
//      saveLocation: "${widget.appBloc.hesapBilgileri.kurumID}/${widget.appBloc.hesapBilgileri.termKey}/MessageImages",
//      jpgQuality: 60,
//      jpgMaxLength: 1000,
//      webpMaxLength: 1200,
//      webpQuality: 80,
//    );
//    if (request == null) return OverAlert.saveErr();
//
//    textEditingController.value = TextEditingValue(text:   'picture'));
//    sendMessage(context, imageUrl: request);
//  }
//
//  sendFile(context) async {
//    if (Fav.noConnection() ) return;
//
//    MyFile file = await FilePicker.pickFile(fileType: FileType.ANY);
//
//    if (file == null) return debugPrint("Dosya boş");
//    String fileName = file.fileName != null ? file.fileName.split('/').last : 'file';
//    if (!fileName.contains("doc") && !fileName.contains("xls") && !fileName.contains("ppt") && !fileName.contains("txt") && !fileName.contains("pdf")) {
//      Alert.alert( type: AlertType.danger, message:   'filenosupport'));
//      return;
//    }
//
//    var url = await widget.appBloc.storage1.uploadFile(file, "${widget.appBloc.hesapBilgileri.kurumID}/${widget.appBloc.hesapBilgileri.termKey}/MessageFiles", fileName);
//
//    if (url == null) return OverAlert.saveErr();
//    textEditingController.value = TextEditingValue(text: fileName);
//    sendMessage(context, fileUrl: url);
//  }
//
//  Widget _buildChild(BuildContext context, ChatModel item, bool owner) {
//    if (item.imageUrl != null) {
//      return GestureDetector(
//          onTap: () {
//            PhotoView(
//              AppVar.cacheManager,
//              urlList: [item.imageUrl],
//            ).navigate(context);
//          },
//          child: MyCachedImage(imgUrl: item.imageUrl, width: 125, placeholder: true));
//    } else if (item.fileUrl != null) {
//      return GestureDetector(
//        onTap: () {
//          DocumentView(url: item.fileUrl).navigate(context);
//        },
//        child: owner
//            ? Text(
//                item.message,
//                style: TextStyle(color: AppVar.appBloc.theme.msgTextColor2, fontWeight: FontWeight.bold, fontSize: 18.0),
//                textAlign: TextAlign.right,
//              )
//            : Text(
//                item.message,
//                style: TextStyle(color: AppVar.appBloc.theme.msgTextColor1, fontWeight: FontWeight.bold, fontSize: 18.0),
//                textAlign: TextAlign.left,
//              ),
//      );
//    } else {
//      return owner
//          ? Text(
//              item.message,
//              style: TextStyle(color: AppVar.appBloc.theme.msgTextColor2),
//              textAlign: TextAlign.right,
//            )
//          : Text(
//              item.message,
//              style: TextStyle(color: AppVar.appBloc.theme.msgTextColor1),
//              textAlign: TextAlign.left,
//            );
//    }
//  }
//
//  ScrollController scrollController = ScrollController();
//
//  scroll() async {
//    await Future.delayed(Duration(milliseconds: 222));
//    scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 333), curve: Curves.ease);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      color: screenType == 0 ? Colors.transparent : Colors.black87,
//      child: AnimatedSwitcher(
//        duration: Duration(milliseconds: 333),
//        child: screenType == 0
//            ? Align(
//                alignment: Alignment.bottomLeft,
//                child: FloatingActionButton(
//                  mini: true,
//                  backgroundColor: newMessageReceived ? Colors.redAccent : Colors.redAccent.withAlpha(50),
//                  heroTag: 'banabirseyleranlat',
//                  child: Icon(newMessageReceived ? Icons.chat : Icons.chat_bubble_outline, color: Colors.white),
//                  onPressed: () {
//                    setState(() {
//                      newMessageReceived = false;
//                      screenType = 1;
//                    });
//                  },
//                ).padding(0, 0, 8, 8),
//              )
//            : Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  Expanded(
//                    child: screenType == 2
//                        ? Column(
//                            children: <Widget>[
//                              Row(
//                                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                children: <Widget>[
//                                  Chip(
//                                    backgroundColor: Colors.green,
//                                    label: Text( 'online') + ': ' + users.fold<int>(0, (p, e) => e.status == 1 ? p + 1 : p).toString(), style: TextStyle(color: Colors.white)),
//                                  ),
//                                  Chip(
//                                    backgroundColor: Colors.red,
//                                    label: Text( 'offline') + ': ' + users.fold<int>(0, (p, e) => e.status == 2 ? p + 1 : p).toString(), style: TextStyle(color: Colors.white)),
//                                  ),
//                                ],
//                              ),
//                              8.height,
//                              Expanded(
//                                child: ListView.builder(
//                                  padding: EdgeInsets.zero,
//                                  itemBuilder: (context, index) {
//                                    return ListTile(
//                                      leading: users[index].status == 1
//                                          ? IconButton(
//                                              icon: users[index].isHandWake == 2 ? Icon(Icons.call_end) : Icon(Icons.add_call),
//                                              color: users[index].isHandWake == 2 ? Colors.red : Colors.green,
//                                              onPressed: () {
//                                                SetDataService.addUserLiveBroadcastStatus(widget.channelName, users.map((e) => e.key).toList(), users[index].key, users[index].isHandWake == 2);
//                                              },
//                                            )
//                                          : SizedBox(),
//                                      title: Text(
//                                        users[index].name,
//                                        style: TextStyle(color:  Fav.design.primaryText),
//                                      ),
//                                      trailing: Chip(
//                                        backgroundColor: users[index].status == 1 ? Colors.green : Colors.red,
//                                        label: Text(
//                                          users[index].status == 1 ?  'online') :  'offline'),
//                                          style: TextStyle(color: Colors.white),
//                                        ),
//                                      ),
//                                    );
//                                  },
//                                  itemCount: users.length,
//                                ),
//                              ),
//                            ],
//                          )
//                        : ListView.builder(
//                            itemCount: messageValue.length,
//                            controller: scrollController,
//                            padding: EdgeInsets.symmetric(horizontal: 16),
//                            itemBuilder: (context, index) {
//                              var snapshot = messageValue[index];
//
//                              final ChatModel item = ChatModel.fromJson(snapshot.value);
//
//                              //burasini ogrenci sadece ogretmen mesajlarini gorsun diye yazdim
//                              if (widget.appBloc.hesapBilgileri.gtS && item.sender != widget.appBloc.hesapBilgileri.uid) {
//                                if (widget.appBloc.teacherService.dataListItem(item.sender) == null) return SizedBox();
//                              }
//
//                              scroll();
//
//                              return item.sender == widget.appBloc.hesapBilgileri.uid
//                                  ? Row(
//                                      mainAxisSize: MainAxisSize.max,
//                                      mainAxisAlignment: MainAxisAlignment.end,
//                                      crossAxisAlignment: CrossAxisAlignment.end,
//                                      children: <Widget>[
//                                        Text(item.timeStampText, style: TextStyle(color: widget.appBloc.theme.disablePrimaryColor, fontSize: 9.0)),
//                                        Flexible(
//                                          flex: 1,
//                                          child: Container(
//                                              child: _buildChild(context, item, true),
//                                              decoration: BoxDecoration(
//                                                color: widget.appBloc.theme.msgBgColor2,
//                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0), bottomLeft: Radius.circular(6.0)),
//                                              ),
//                                              padding: EdgeInsets.all(6.0),
//                                              margin: EdgeInsets.only(left: 8.0, top: 12.0)),
//                                        ),
//                                      ],
//                                    )
//                                  : Row(
//                                      mainAxisSize: MainAxisSize.max,
//                                      mainAxisAlignment: MainAxisAlignment.start,
//                                      crossAxisAlignment: CrossAxisAlignment.end,
//                                      children: <Widget>[
//                                        Flexible(
//                                          flex: 1,
//                                          child: Container(
//                                              child: _buildChild(context, item, false),
//                                              decoration: BoxDecoration(
//                                                color: widget.appBloc.theme.msgBgColor1,
//                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0), bottomRight: Radius.circular(6.0)),
//                                              ),
//                                              padding: EdgeInsets.all(6.0),
//                                              margin: EdgeInsets.only(right: 8.0, top: 12.0)),
//                                        ),
//                                        Text(item.senderName + ' ' + item.timeStampText, style: TextStyle(color: widget.appBloc.theme.disablePrimaryColor, fontSize: 9.0)),
//                                      ],
//                                    );
//                            },
//                          ),
//                  ),
//                  8.height,
//                  SafeArea(
//                    top: false,
//                    bottom: false,
//                    child: Row(
//                      children: <Widget>[
//                        8.width,
//                        FloatingActionButton(
//                          mini: true,
//                          backgroundColor: Colors.redAccent.withAlpha(50),
//                          heroTag: 'banabirseyleranlat2',
//                          child: Icon(Icons.close, color: Colors.white),
//                          onPressed: () {
//                            setState(() {
//                              newMessageReceived = false;
//                              screenType = 0;
//                            });
//                          },
//                        ),
//                        if (!widget.appBloc.hesapBilgileri.gtS)
//                          FloatingActionButton(
//                            mini: true,
//                            backgroundColor: Colors.green.withAlpha(50),
//                            heroTag: 'banabirseyleranlat3',
//                            child: Icon(Icons.people, color: Colors.white),
//                            onPressed: () {
//                              setState(() {
//                                screenType = 2;
//                              });
//                            },
//                          ),
//                        IconButton(
//                          padding: EdgeInsets.all(0),
//                          icon: Icon(Icons.attach_file, color: Fav.design.primary),
//                          onPressed: () {
//                            addFile(context);
//                          },
//                        ),
//                        Expanded(
//                            flex: 1,
//                            child: TextField(
//                                controller: textEditingController,
//                                maxLines: 1,
//                                style: TextStyle(color: Fav.design.primary),
//                                decoration: InputDecoration(
//                                    fillColor: Colors.white,
//                                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), gapPadding: 2.0, borderSide: BorderSide(color: Colors.redAccent)),
//                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), gapPadding: 2.0, borderSide: BorderSide(color: Colors.redAccent)),
//                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), gapPadding: 2.0, borderSide: BorderSide(color: Fav.design.primary)),
//                                    hintText: "",
//                                    labelText:   "writemessage"),
//                                    labelStyle: TextStyle(color:  Fav.design.primaryText.withAlpha(150)),
//                                    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//                                    hintStyle: TextStyle(fontSize: 12.0, color:  Fav.design.primaryText.withAlpha(150)),
//                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: Fav.design.primary))))),
//                        SizedBox(
//                            width: 40.0,
//                            height: 40.0,
//                            child: isLoading
//                                ? Center(
//                                    child: SizedBox(
//                                        width: 24.0,
//                                        height: 24.0,
//                                        child: CircularProgressIndicator(
//                                          valueColor: AlwaysStoppedAnimation(Fav.design.primary),
//                                        )))
//                                : IconButton(
//                                    icon: Icon(Icons.send, color: Fav.design.primary),
//                                    onPressed: () {
//                                      sendMessage(context);
//                                    })),
//                        16.width,
//                      ],
//                    ),
//                  ),
//                  8.height,
//                ],
//              ),
//      ),
//    );
//  }
//}
//
//class BroadcastStatusData {
//  /// 1-online 2-offline
//  int status;
//
//  /// 0 soz istemiyor 1 soz istiyor 2 soz verildi
//  int isHandWake;
//
//  String key;
//
//  String get name => key.split('---').first;
//  String get uid => key.split('---').last;
//
//  BroadcastStatusData({this.status, this.isHandWake, String key});
//
//  BroadcastStatusData.fromJson(Map json, key) {
//    this.key = key;
//    this.status = json['a'] ?? 0;
//    this.isHandWake = json['b'] ?? 0;
//  }
//
//  Map<String, dynamic> toJson() {
//    final Map<String, dynamic> data =   Map<String, dynamic>();
//    data['a'] = this.status;
//    data['b'] = this.isHandWake;
//    return data;
//  }
//}
