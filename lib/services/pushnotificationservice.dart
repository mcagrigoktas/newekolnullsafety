import 'dart:async';

import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../appbloc/appvar.dart';

class EkolPushNotificationService {
  EkolPushNotificationService._();

  ///[parentVisibleCode] anne baba ayri bildirim icin gerekti.
  ///[forParentMessageMenu] anne babaya mesaj oldugunda true gelmeli.
  ///[forParentOtherMenu] mesaj menusu disinda diger menulerde anne babaya gonderilecekler icin.
  static Tuple2<List<String>, Map<String, List<String>>?> _getTokenList(List<String> uidList, {bool? forParentMessageMenu = false, bool forParentOtherMenu = false, String? parentVisibleCode}) {
    final List<String> _tokenList = [];

    Map<String, List<String>>? tokenMapF;
    if (AppVar.appBloc.notificationTokenService != null) {
      tokenMapF = AppVar.appBloc.notificationTokenService!.dataList.fold<Map<String, List<String>>>({}, (_currentList, _userTokenModel) {
        void _tokenListAddFunction() {
          if (_currentList.containsKey(_userTokenModel.userKey)) {
            _currentList[_userTokenModel.userKey] = [
              ..._currentList[_userTokenModel.userKey]!,
              ..._userTokenModel.tokenList,
            ];
          } else {
            _currentList[_userTokenModel.userKey] = _userTokenModel.tokenList;
          }
        }

        if (forParentMessageMenu == false && forParentOtherMenu == false) {
          _tokenListAddFunction();
        } else if (forParentOtherMenu == true) {
          if (AppVar.appBloc.hesapBilgileri.isEkid) {
            _tokenListAddFunction();
          } else if (_userTokenModel.userGirisTuruIsParent) {
            _tokenListAddFunction();
          }
        } else if (forParentMessageMenu == true) {
          if (AppVar.appBloc.hesapBilgileri.gtS || parentVisibleCode == null) {
            _tokenListAddFunction();
          } else {
            if (AppVar.appBloc.hesapBilgileri.isEkid) {
              if (parentVisibleCode == '0') {
                _tokenListAddFunction();
              }
              if (parentVisibleCode.contains('1') && _userTokenModel.userGirisTuruIsParent) {
                if (_userTokenModel.parentType != 2) _tokenListAddFunction();
              }
              if (parentVisibleCode.contains('2') && _userTokenModel.userGirisTuruIsParent) {
                if (_userTokenModel.parentType == 2) _tokenListAddFunction();
              }
            } else if (!AppVar.appBloc.hesapBilgileri.isEkid) {
              if (parentVisibleCode.contains('2') && _userTokenModel.userGirisTuruIsParent) {
                if (_userTokenModel.parentType == 2) _tokenListAddFunction();
              }
              if (parentVisibleCode.contains('1') && _userTokenModel.userGirisTuruIsParent) {
                if (_userTokenModel.parentType == 1) _tokenListAddFunction();
              }
            }
          }
        }

        return _currentList;
      });

      uidList.forEach((userKey) {
        if (tokenMapF![userKey] != null) _tokenList.addAll(List<String>.from(tokenMapF[userKey]!));
      });
    }

    return Tuple2(_tokenList.toSet().toList(), tokenMapF!..removeWhere((key, value) => !uidList.contains(key)));
  }

  static Future<void> sendMultipleNotification(String? baslik, String? icerik, List<String?> tergetList, NotificationArgs tag, {String? sound, String? channel, bool? forParentMessageMenu = false, bool forParentOtherMenu = false, String? parentVisibleCodeForNotification}) async {
    if (tergetList.contains('alluser')) {
      await FirebaseFunctionService.sendTopicNotification(baslik!, icerik!, AppVar.appBloc.hesapBilgileri.kurumID + 'pushnotification', sound: sound, tag: (tag..addUid('all')), channel: channel);
    } else {
      log(tergetList);
      List<String> uidList = [];

      if (AppVar.appBloc.studentService != null) {
        AppVar.appBloc.studentService!.dataList.where((student) => tergetList.contains(student.key) || tergetList.any((item) => student.classKeyList.contains(item))).forEach((student) {
          uidList.add(student.key);
        });
      }
      AppVar.appBloc.teacherService!.dataList.where((teacher) => tergetList.contains(teacher.key) || tergetList.contains('onlyteachers')).forEach((teacher) {
        uidList.add(teacher.key);
      });
      AppVar.appBloc.managerService!.dataList.where((manager) => tergetList.contains(manager.key)).forEach((manager) {
        uidList.add(manager.key!);
      });
      if (uidList.isEmpty) return;
      var sendingTokenData = _getTokenList(uidList, forParentMessageMenu: forParentMessageMenu, forParentOtherMenu: forParentOtherMenu, parentVisibleCode: parentVisibleCodeForNotification);
      if (sendingTokenData.item1.isEmpty) return;

      final _uidTokenData = sendingTokenData.item2!;

      List<NotificationItem> _notificationItemList = [];
      _uidTokenData.entries.forEach((element) {
        _notificationItemList.add(NotificationItem(
          tokenList: element.value,
          tag: (tag..addUid(element.key)),
        ));
      });

      return FirebaseFunctionService.sendAdvancetNotification(baslik: baslik, icerik: icerik, channel: channel, sound: sound, itemList: _notificationItemList);
      // List<Future> futureList = [];

      // await Future.wait(futureList);
    }
  }

  static Future<void> sendSingleNotification(String baslik, String icerik, String targetKey, NotificationArgs tag,
      {String? sound, String? channel, bool? forParentMessageMenu = false, bool forParentOtherMenu = false, String? parentVisibleCodeForNotification, List<String?>? sendOnlyThisTokenList}) async {
    var sendingTokenList = sendOnlyThisTokenList ?? (_getTokenList([targetKey], forParentMessageMenu: forParentMessageMenu, forParentOtherMenu: forParentOtherMenu, parentVisibleCode: parentVisibleCodeForNotification)).item1;
    if (sendingTokenList.isEmpty) return;

    await FirebaseFunctionService.sendTokenListNotification(baslik, icerik, sendingTokenList as List<String>, sound: sound, tag: (tag..addUid(targetKey)), channel: channel);
  }
}

class TokenModel extends DatabaseItem {
  String key;
  int? lastUpdate;
  Map<String, String>? tokenData;

  //Eger veli ise parentType bakmak icin
  int get parentType => key.startsWith('42') ? 2 : 1;

  TokenModel.fromJson(Map snapshot, this.key) {
    lastUpdate = snapshot['lastUpdate'];
    tokenData = Map<String, String>.from(snapshot['tl'] ?? {});
  }
  List<String> get tokenList => List<String>.from(tokenData!.keys);
  List<String> get deviceList => List<String>.from(tokenData!.values);
  int? get _userGirisTuru => int.tryParse(key.split('-G-').first);
  bool get userGirisTuruIsParent {
    return _userGirisTuru is int && _userGirisTuru! > 39 && _userGirisTuru! < 49;
  }

  String get userKey => key.split('-G-').last;

  @override
  String toString() {
    return 'ParentType: $parentType TokenData: $tokenData';
  }

  @override
  bool active() => true;
}
