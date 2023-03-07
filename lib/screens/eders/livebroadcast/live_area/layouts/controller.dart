import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../../appbloc/appvar.dart';
import '../../../../../library_helper/excel/eager.dart';
import '../../../../../models/allmodel.dart';
import '../../../../../services/dataservice.dart';
import '../apps/jitsimeetnew/jitsihelper.dart';
import 'livelessonmenutoolbarekol.dart';
import 'widgets/advancedClass/controller.dart';

class OnlineLessonController extends GetxController {
  ///Buna artik ihtiyac yok gibi
  bool isLeftPanelEnable = true;
  InAppWebViewController? mobileWebview;
  Function(String)? postMessageToIframe;
  Map<String, bool> rollCallStudentresult = {};
  Map<String, List<DeviceModel>> inputDevices = {};

  final LiveLessonType? liveLessonType;

  ExtraMenuType extraMenuType =
      // kIsWeb ? ExtraMenuType.chats :
      ExtraMenuType.closed;
  String? youtubeStreamKey;

  List<Student> targetList = [];
  List<OnlineUserModel> onlineUsers = [];
  List<List<String>> logData = [];
  bool isBackButtonPressed = false;
  bool isRollCallLoading = false;

  bool get isScreenShareButtonEnable => AppVar.appBloc.hesapBilgileri.gtMT && liveLessonType == LiveLessonType.Jitsi && kIsWeb;
  bool get isOnlineUserListEnable => AppVar.appBloc.hesapBilgileri.gtMT && (liveLessonType == LiveLessonType.Agora || liveLessonType == LiveLessonType.Jitsi);
  bool get isLogDataEnable => AppVar.appBloc.hesapBilgileri.gtMT && (liveLessonType == LiveLessonType.Agora || liveLessonType == LiveLessonType.Jitsi);
  bool get isCamMicEnable => (liveLessonType == LiveLessonType.Agora || liveLessonType == LiveLessonType.Jitsi);
  bool get isMuteEveryoneEnable => AppVar.appBloc.hesapBilgileri.gtMT && liveLessonType == LiveLessonType.Jitsi;
  bool get isViewChangeEnable => liveLessonType == LiveLessonType.Agora || liveLessonType == LiveLessonType.Jitsi;
  bool get isYoutubeShareEnable => AppVar.appBloc.hesapBilgileri.gtMT && liveLessonType == LiveLessonType.Jitsi;
  bool get isOtherButtonEnable => liveLessonType == LiveLessonType.Jitsi;
  bool get settingButtonEnable => AppVar.appBloc.hesapBilgileri.gtMT;

  String? get channelName => liveBroadcastItem!.channelName;
  final LiveBroadcastModel? liveBroadcastItem;

  ///Ders programindan geliyorsa
  final Lesson? lesson;

  VideoChatSettings videoChatSettings = VideoChatSettings();

  OnlineLessonController({this.liveBroadcastItem, this.lesson, this.liveLessonType});

  StreamSubscription? chatSubscription;
  StreamSubscription? settingsSubscription;
  List<LiveLessonChatModel> messageValue = [];
  //todo mesajlalr acildiginda false yap
  int newMessageReceived = 0;
  bool messgeSending = false;
  final messageController = TextEditingController();
  final messageScrollController = ScrollController();

  Future<void> scrollChat() async {
    if (extraMenuType == ExtraMenuType.chats) {
      await 22.wait;
      await messageScrollController.animateTo(messageScrollController.position.maxScrollExtent, duration: 333.milliseconds, curve: Curves.ease);
    }
  }

  late DateTime lessonStartTime;
  late AdvancedClassController classRoomController;

  final bool mobileJitsiWebview = true;
  @override
  void onInit() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    classRoomController = Get.put<AdvancedClassController>(AdvancedClassController());
    lessonStartTime = DateTime.now();
    if (AppVar.appBloc.hesapBilgileri.gtMT) {
      AppVar.appBloc.studentService!.dataList.forEach((element) {
        if (liveBroadcastItem!.targetList!.contains("alluser")) {
          targetList.add(element);
        }
        if (liveBroadcastItem!.targetList!.any((item) => [...element.classKeyList, element.key].contains(item))) {
          targetList.add(element);
        }
      });
    }

    settingsSubscription = LiveBroadCastService.dbVideoChatSettings(channelName).onValue().listen((event) {
      if (event?.value != null) {
        Map? settingsData;
        if (AppVar.appBloc.hesapBilgileri.gtS) {
          settingsData = event!.value;
        } else {
          final Map receiving = event!.value;
          settingsData = receiving['settings'];
          rollCallStudentresult = receiving['hereList'] == null ? {} : Map<String, bool>.from(receiving['hereList']);
        }

        if (settingsData != null) {
          videoChatSettings = VideoChatSettings.fromJson(settingsData);
          settingsChange();
        } else {
          update();
        }
      }
    });

    super.onInit();
  }

  @override
  void onClose() {
    chatSubscription?.cancel().then((value) {
      chatSubscription = null;
    });
    settingsSubscription?.cancel();

    Get.delete<AdvancedClassController>();
    super.onClose();
  }

  void settingsChange() {
    chatControl();
    update();
  }

  Future<void> startRollCall() async {
    rollCallStudentresult.clear();
    isRollCallLoading = true;
    update();
    videoChatSettings.rollCallEnableType = 1;
    await LiveBroadCastService.startVideoChatRollCall(channelName, videoChatSettings.mapForSave());
    isRollCallLoading = false;
    update();
  }

  Future<void> stopRollCall({bool cancel = false}) async {
    isRollCallLoading = true;
    update();
    videoChatSettings.rollCallEnableType = 0;
    await LiveBroadCastService.setVideoChatSetting(channelName, videoChatSettings.mapForSave());
    isRollCallLoading = false;
    update();
    if (!cancel) {
      if (lesson != null) {
        openLessonRollCallScreen(rollCallStudentresult.keys.toList());
      } else {
        await ExcelLibraryHelper.export(
            targetList.fold<List<List<String?>>>([
              ['name'.translate, '']
            ], (p, e) => p..add([e.name, rollCallStudentresult[e.key!] == true ? 'rollcall0'.translate : 'rollcall1'.translate])),
            'rollcallstudentreview'.translate);
        closeOpenedPanel();
      }
    } else {
      closeOpenedPanel();
    }
  }

  bool strudentIAmHereSended = false;
  void iAmHere() {
    Fav.timeGuardFunction('channelNamerollcalllsaved', 15.seconds, () async {
      isRollCallLoading = true;
      update();

      await LiveBroadCastService.setIAmHere(channelName);
      strudentIAmHereSended = true;
      OverAlert.saveSuc();
      await Fav.preferences.setInt('channelNamerollcalllsaved', DateTime.now().millisecondsSinceEpoch);
      isRollCallLoading = false;
      update();
    });
  }

  void closeOpenedPanel() {
    extraMenuType = ExtraMenuType.closed;
    update();
  }

  void chatControl() {
    if (AppVar.appBloc.hesapBilgileri.gtMT) {
      if (chatSubscription == null) _subscribeChat();
    }
    if (AppVar.appBloc.hesapBilgileri.gtS) {
      if (chatSubscription != null && videoChatSettings.isChatDisable) {
        chatSubscription?.cancel().then((value) {
          chatSubscription = null;
        });
      } else if (chatSubscription == null && !videoChatSettings.isChatDisable) {
        _subscribeChat();
      }
    }
    if (videoChatSettings.isChatDisable && extraMenuType == ExtraMenuType.chats) {
      extraMenuType = ExtraMenuType.closed;
    }
  }

  Future<void> saveSettings() async {
    OverLoading.show();
    await LiveBroadCastService.setVideoChatSetting(channelName, videoChatSettings.mapForSave());
    await OverLoading.close();
  }

  void _subscribeChat() {
    messageValue.clear();
    chatSubscription = LiveBroadCastService.dbVideoChats(channelName).onChildAdded(orderByKey: true, limitToLast: 218763).listen((event) {
      if (event!.value == null) return;
      final model = LiveLessonChatModel.fromJson(event.value);
      if (model.message.safeLength < 1) {
        if (model.raiseHand == true && AppVar.appBloc.hesapBilgileri.gtMT && DateTime.now().difference(lessonStartTime).inSeconds > 10) {
          OverAlert.show(message: model.senderName! + ' ' + 'raisehanded'.translate);
        }
        return;
      }

      messageValue.add(model);

      if (extraMenuType != ExtraMenuType.chats) {
        if (AppVar.appBloc.hesapBilgileri.gtMT || videoChatSettings.isChatFullEnable) {
          newMessageReceived++;
        } else if (videoChatSettings.isChatOnlyTeacher && model.senderGirisTuru! < 25) {
          newMessageReceived++;
        }
      }
      messageValue.removeWhere((element) => (!videoChatSettings.isChatFullEnable && element.senderGirisTuru! > 25 && AppVar.appBloc.hesapBilgileri.gtS && AppVar.appBloc.hesapBilgileri.uid != element.senderKey));
      messageValue.sort((s1, s2) => s1.timeStamp - s2.timeStamp);
      update();
      scrollChat();
    });
  }

  void participantListChanged(value) {
    if (value is Map) {
      onlineUsers.clear();
      final Set<String> onlineUserStringList = {};
      value.forEach((key, value) {
        onlineUserStringList.add(value['displayName'].toString().trim());
      });

      //  onlineUserStringList.toSet().toList();
      onlineUserStringList.forEach((element) {
        onlineUsers.add(OnlineUserModel.fromText(element));
      });

      onlineUsers.removeWhere((element) => targetList.every((student) => student.key != element.uid));

      targetList.sort((a, b) {
        final aIsOnLine = onlineUsers.any((element) => element.uid == a.key);
        final bIsOnLine = onlineUsers.any((element) => element.uid == b.key);
        if (aIsOnLine == bIsOnLine) return a.name!.compareTo(b.name!);
        return aIsOnLine ? -1 : 1;
      });
      update();
    }
    //   kickParticipant();
  }

  void logDataReceived(value) {
    if (value is List) {
      logData.clear();
      value.forEach((element) {
        List<dynamic> data = List<dynamic>.from(element);

        if (data.first == 'participantJoined' || data.first == 'participantLeft') {
          logData.add([(data[1] as String).split('*').first, (data.first as String).translate, (data[2] as int).dateFormat("HH:mm:ss"), '']);
        } else if (data.first == 'participantKickedOut') {
          logData.add([(data[1] as String).split('*').first + ' -> ' + (data[2] as String).split('*').first, (data.first as String).translate, (data[3] as int).dateFormat("HH:mm:ss"), '***********']);
        }
      });
      logData.insert(0, ['name'.translate, '-', 'date'.translate, '-']);
      update();
    }
  }

  List<String> onlineUserList = [];
  void openLessonRollCallScreen(List<String> onlineUserList) {
    //  controller.onlineUsers.map((e) => e.uid).toList()
    this.onlineUserList = onlineUserList;
    extraMenuType = extraMenuType != ExtraMenuType.rollCallMenu ? ExtraMenuType.rollCallMenu : ExtraMenuType.closed;
    update();
  }

  void openRollCallScreen() {
    extraMenuType = extraMenuType != ExtraMenuType.rollCallMenuStarter ? ExtraMenuType.rollCallMenuStarter : ExtraMenuType.closed;
    update();
  }

  void sendDataLiveMenu(Map data) {
    final stringData = json.encode(data);

    try {
      if (kIsWeb) {
        if (postMessageToIframe != null) {
          postMessageToIframe!(stringData);
        }
      } else if (mobileWebview != null) {
        mobileWebview!.evaluateJavascript(source: "otherFunction(" + stringData + ");");
      }
    } catch (err) {
      log(err);
    }
  }

  Future<bool> disposeService() async {
    if (kIsWeb) {
      sendDataLiveMenu({'id': 10});
    }
    await 500.wait;
    return true;
  }

  Future<bool> muteEveryone() async {
    sendDataLiveMenu({'id': 0});
    return true;
  }

  Future<bool> startYoutubeStream() async {
    if (youtubeStreamKey.safeLength > 0) sendDataLiveMenu({'id': 1, 'data': youtubeStreamKey});
    update();
    return true;
  }

  Future<bool> stopYoutubeStream() async {
    sendDataLiveMenu({'id': 2});
    youtubeStreamKey = null;
    update();
    return true;
  }

  Future<bool> shareScreen() async {
    sendDataLiveMenu({'id': 3});
    return true;
  }

  Future<bool> setAudioInputDevice(DeviceModel model) async {
    sendDataLiveMenu({'id': 27, 'data': model.jitsiSendDataMap});
    return true;
  }

  Future<bool> setAudioOutputDevice(DeviceModel model) async {
    sendDataLiveMenu({'id': 28, 'data': model.jitsiSendDataMap});
    return true;
  }

  Future<bool> setCameraInputDevice(DeviceModel model) async {
    sendDataLiveMenu({'id': 29, 'data': model.jitsiSendDataMap});
    return true;
  }

  Future<void> onBackPressed() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.portraitDown, DeviceOrientation.portraitUp, DeviceOrientation.landscapeRight]);
    await disposeService();
    Get.back();
  }

  Future<bool> raiseHand() async {
    Fav.timeGuardFunction(AppVar.appBloc.hesapBilgileri.uid! + 'raiseHand', 5.seconds, () async {
      LiveLessonChatModel message = LiveLessonChatModel()
        ..senderKey = AppVar.appBloc.hesapBilgileri.uid
        ..senderGirisTuru = AppVar.appBloc.hesapBilgileri.girisTuru
        ..raiseHand = true
        ..senderName = AppVar.appBloc.hesapBilgileri.name
        ..timeStamp = databaseTime;

      await LiveBroadCastService.addVideoChatsMessage(channelName, message.mapForSave()).then((_) {});
      'raisehandsuc'.translate.showAlert();
    });

    return true;
  }

  bool micEneble = true;
  bool videoEnable = true;
  bool tileViewOpen = true;
  void audioStatusChange(value) {
    micEneble = value.toString() != 'false';
    update();
  }

  void videoStatusChange(value) {
    videoEnable = value.toString() != 'false';
    update();
  }

  void tileViewStatusChange(value) {
    tileViewOpen = value.toString() != 'false';
    update();
  }

  void deviceListReceived(value) {
    if (value != null) {
      if (liveLessonType == LiveLessonType.Jitsi) {
        (value as Map).forEach((type, devices) {
          if (devices is List) {
            inputDevices[type] = devices.map((e) => DeviceModel.jitsi(e, devices.indexOf(e) + 1)).toList();
          }
        });
      }

      update();
    }
  }

  void kickParticipant() {
    sendDataLiveMenu({'id': 3, 'data': 'ads'});
  }

  void changeMicStatus() {
    Fav.timeGuardFunction(AppVar.appBloc.hesapBilgileri.uid! + 'changeMicStatus', 1.seconds, () async {
      sendDataLiveMenu({'id': 7});
    });
  }

  void changeCamStatus() {
    Fav.timeGuardFunction(AppVar.appBloc.hesapBilgileri.uid! + 'changeCamStatus', 1.seconds, () async {
      sendDataLiveMenu({'id': 6});
    });
  }

  void changeTileViewStatus() {
    if (liveLessonType == LiveLessonType.Jitsi) {
      sendDataLiveMenu({'id': 8});
    }
    if (liveLessonType == LiveLessonType.Agora) {
      Get.find<AdvancedClassController>().changeLayoutType();
    }
  }
}

enum ExtraMenuType {
  closed,
  onlineStudentList,
  offlineStudentList,
  otherMenu,
  hints,
  logData,
  chats,
  rollCallMenu,

  settings,
  rollCallMenuStarter,
}

class VideoChatSettings {
  int? chatEnableType = 0;
  int rollCallEnableType = 0;

  VideoChatSettings();

  VideoChatSettings.fromJson(Map snapshot) {
    chatEnableType = snapshot['cE'] ?? 0;
    rollCallEnableType = snapshot['rC'] ?? 0;
  }

  Map<String, dynamic> mapForSave() {
    return {
      "cE": chatEnableType,
      "rC": rollCallEnableType,
    };
  }

  bool get isChatDisable => chatEnableType == 0;
  bool get isChatOnlyTeacher => chatEnableType == 1;
  bool get isChatFullEnable => chatEnableType == 2;

  bool get isRollCallEnable => rollCallEnableType == 1;
}
