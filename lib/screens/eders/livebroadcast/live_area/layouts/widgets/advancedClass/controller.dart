import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../../../../appbloc/appvar.dart';
import '../../controller.dart';
import '../../livelessonmenutoolbarekol.dart';
import 'getelement/shared.dart';

class AdvancedClassController extends GetxController {
  OnlineLessonController get onlineLessonController => Get.find<OnlineLessonController>();
  int layoutType = 2;
  void changeLayoutType() {
    bigWidgetKey = null;
    layoutType = layoutType == 1 ? 2 : 1;
    update();
  }

  double participantWidth = 160;
  double participantHeigth = 120;
  double padding = 2;

  bool _participantIsHost(int girisTuru, String? uid) => girisTuru < 30 && onlineLessonController.liveBroadcastItem!.teacherKey == uid;
  // ignore: unused_element
  bool get _meIsHost => _participantIsHost(AppVar.appBloc.hesapBilgileri.girisTuru, AppVar.appBloc.hesapBilgileri.uid);

  Widget hostEmptyWidget = MyProgressIndicator(
    isCentered: true,
    color: Fav.design.primary,
    text: 'hostwaiting'.translate,
    size: 14,
  );

  String? bigWidgetKey;
  Map<String, Holder> participantHolders = {};

  String get ownKey => AppVar.appBloc.hesapBilgileri.name.changeTurkishCharacter! + '*' + AppVar.appBloc.hesapBilgileri.uid + '*W*' + AppVar.appBloc.hesapBilgileri.girisTuru.toString();
  dynamic get ownElement => Fav.readSeasonCache(ownKey + 'Element');
  dynamic participantElement(String uid) => Fav.readSeasonCache(uid + 'Element');

  dynamic getWebElement(String webUid) {
    if (webUid == 'ScreenShare') {
      participantHolders[webUid] = Holder(
        isHost: false,
        isLocal: false,
        isScreenShare: true,
        widget: AdvancedClassHelper.setupParticipantWidget(webUid),
        webUid: webUid,
      );
    } else {
      final model = OnlineUserModel.fromText(webUid);

      participantHolders[webUid] = Holder(
        widget: AdvancedClassHelper.setupParticipantWidget(webUid),
        isLocal: false,
        isScreenShare: false,
        isHost: _participantIsHost(model.girisTuru!, model.uid),
        model: model,
        webUid: webUid,
      );
    }
    100.wait.then((value) {
      update();
    });
    return participantElement(webUid);
  }

  void removeWebElement(String webUid) {
    participantHolders.remove(webUid);
    50.wait.then((value) {
      update();
    });
  }

  @override
  void onInit() {
    super.onInit();

    participantHolders[ownKey] = Holder(
      widget: AdvancedClassHelper.setupParticipantWidget(ownKey),
      isLocal: true,
      isScreenShare: false,
      isHost: false, //todo bu aslinda isMeHost ollacak ama 2 tane  goruntu olusmamasi icin fallse  yapildi
      webUid: ownKey,
    );
  }
}

class Holder {
  Widget? widget;
  bool? isHost;
  bool? isLocal;
  bool? isScreenShare;
  OnlineUserModel? model;
  String? webUid;
  Holder({this.isHost, this.isLocal, this.model, this.widget, this.isScreenShare, this.webUid});
}
