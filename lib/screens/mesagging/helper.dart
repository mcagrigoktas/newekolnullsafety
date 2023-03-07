import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/appfunctions.dart';
import '../../models/chatmodel.dart';
import '../../models/notification.dart';
import '../main/macos_dock/macos_dock.dart';
import '../managerscreens/othersettings/user_permission/user_permission.dart';
import 'chat.dart';

class MessagePreviewHelper {
  MessagePreviewHelper._();

  static void afterMessagePreviewNewData() {
    calculateNewItemBadge();
  }

  static const messageIconTag = DockItemTag.messages;
  static const messageNotificationGroup = NotificationGroup.message;
  static String get lastMessagePreviewPageEntryTimePrefKey => '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.uid}messagepreviewpagelogintime';
  static void calculateNewItemBadge() {
    final messagepreviewpagelogintime = Fav.preferences.getInt(lastMessagePreviewPageEntryTimePrefKey, 0)!;

//todo eger veliye mesaj atildiysa ogrencidede widgetta okunmamaislar arasinda gozukkuyor. bi care bulabilirmisin. veliye ogrenci mesaji geldiginde
// fazladan gozukmesi problem yok ama ogrenci uygulamasinda veliye mesaj geldiginde yada anne baba ayri velilerde problem.
    final newMessagePreviewList = MessagePreviewHelper.getAllFilteredMesaggingPreviewList(AppVar.appBloc.messaggingPreviewService!.data).where((element) {
      if (element.timeStamp == null) return false;
      if (element.owner == true) return false;

      return element.timeStamp > messagepreviewpagelogintime;
    }).toList();

    if (newMessagePreviewList.isNotEmpty) {
      Get.find<MacOSDockController>().replaceThisTagNotificationList(messageNotificationGroup, [
        InAppNotification(type: NotificationType.message)
          ..title = 'newmessagepost'.argsTranslate({'count': newMessagePreviewList.length})
          ..lastUpdate = newMessagePreviewList.fold<int>(messagepreviewpagelogintime, (previousValue, element) => element.timeStamp > previousValue ? element.timeStamp : previousValue)
      ]);
    } else {
      Get.find<MacOSDockController>().replaceThisTagNotificationList(messageNotificationGroup, []);
    }
  }

  static Future<void> saveLastLoginTime() async {
    final _lastItem = Get.find<MacOSDockController>().messageNotificationList();
    if (_lastItem == null) return;
    await Fav.preferences.setInt(lastMessagePreviewPageEntryTimePrefKey, _lastItem.lastUpdate);
    calculateNewItemBadge();
  }

  static List<MesaggingPreview> getAllFilteredMesaggingPreviewList(Map sourceDataList) {
    final List<MesaggingPreview> _dataList = [];
    final appBloc = AppVar.appBloc;
    final _teacherMessageManager = UserPermissionList.hasTeacherMessageManager();
    final _teacherMessageParent = UserPermissionList.hasTeacherMessageParent();
    if (appBloc.hesapBilgileri.gtM) {
      appBloc.managerService!.dataList.forEach((manager) {
        if (manager.key != appBloc.hesapBilgileri.uid) {
          final Map? preview = sourceDataList[manager.key];
          final _messagePreview = preview == null ? MesaggingPreview(senderName: manager.name, senderKey: manager.key, senderImgUrl: manager.imgUrl) : MesaggingPreview.fromJson(preview, manager.key);
          _messagePreview.additionalInfo = 'manager'.translate;
          _messagePreview.targetGirisTuru = 10;
          _messagePreview.userGirisTuru = 10;
          _dataList.add(_messagePreview);
        }
      });

      /// idareci ogretmen iliskisini acmak istyorsan burayi  ve asahidakini acmalisin
      if (_teacherMessageManager) {
        appBloc.teacherService!.dataList.forEach((teacher) {
          final Map? preview = sourceDataList[teacher.key];
          final _messagePreview = preview == null ? MesaggingPreview(senderName: teacher.name, senderKey: teacher.key, senderImgUrl: teacher.imgUrl) : (MesaggingPreview.fromJson(preview, teacher.key));
          _messagePreview.additionalInfo = teacher.branches == null || teacher.branches!.isEmpty ? 'teacher'.translate : teacher.branches!.first;
          _messagePreview.targetGirisTuru = 20;
          _messagePreview.userGirisTuru = 10;
          _dataList.add(_messagePreview);
        });
      }

      appBloc.studentService!.dataList.forEach((student) {
        final Map? preview = sourceDataList[student.key];
        final _messagePreview = preview == null ? MesaggingPreview(senderName: student.name, senderKey: student.key, senderImgUrl: student.imgUrl) : MesaggingPreview.fromJson(preview, student.key);
        _messagePreview.targetGirisTuru = 30;
        _messagePreview.userGirisTuru = 10;
        _dataList.add(_messagePreview);
      });
    } else if (appBloc.hesapBilgileri.gtT) {
      List<String?> teacherClassList = TeacherFunctions.getTeacherClassList();
      if (_teacherMessageManager) {
        appBloc.managerService!.dataList.forEach((manager) {
          final Map? preview = sourceDataList[manager.key];
          final _messagePreview = preview == null ? MesaggingPreview(senderName: manager.name, senderKey: manager.key, senderImgUrl: manager.imgUrl) : (MesaggingPreview.fromJson(preview, manager.key));
          _messagePreview.targetGirisTuru = 10;
          _messagePreview.userGirisTuru = 20;
          _messagePreview.additionalInfo = 'manager'.translate;
          _dataList.add(_messagePreview);
        });
      }
      if (_teacherMessageParent) {
        appBloc.studentService!.dataList.forEach((student) {
          if (teacherClassList.any((item) => student.classKeyList.contains(item)) || appBloc.hesapBilgileri.teacherSeeAllClass == true) {
            final Map? preview = sourceDataList[student.key];
            final _messagePreview = preview == null ? MesaggingPreview(senderName: student.name, senderKey: student.key, senderImgUrl: student.imgUrl) : MesaggingPreview.fromJson(preview, student.key);
            _messagePreview.targetGirisTuru = 30;
            _messagePreview.userGirisTuru = 20;
            _dataList.add(_messagePreview);
          }
        });
      }
    } else if (appBloc.hesapBilgileri.gtS) {
      appBloc.managerService!.dataList.forEach((manager) {
        final Map? preview = sourceDataList[manager.key];
        final _messagePreview = preview == null ? MesaggingPreview(senderName: manager.name, senderKey: manager.key, senderImgUrl: manager.imgUrl) : MesaggingPreview.fromJson(preview, manager.key);
        _messagePreview.targetGirisTuru = 10;
        _messagePreview.userGirisTuru = 30;
        _messagePreview.additionalInfo = 'manager'.translate;
        _dataList.add(_messagePreview);
      });

      if (_teacherMessageParent) {
        final listOfTeachers = StudentFunctions.listOfTeachersTheStudentCanSee();

        appBloc.teacherService!.dataList.forEach((teacher) {
          if (listOfTeachers.contains(teacher.key)) {
            final Map? preview = sourceDataList[teacher.key];
            final _messagePreview = preview == null ? MesaggingPreview(senderName: teacher.name, senderKey: teacher.key, senderImgUrl: teacher.imgUrl) : MesaggingPreview.fromJson(preview, teacher.key);
            _messagePreview.targetGirisTuru = 20;
            _messagePreview.userGirisTuru = 30;
            _messagePreview.additionalInfo = teacher.branches == null || teacher.branches!.isEmpty ? 'teacher'.translate : teacher.branches!.first;
            _dataList.add(_messagePreview);
          }
        });
      }
    }

    return _dataList;
  }

  static bool isNewMessage(bool ghost, MesaggingPreview? preview) {
    if (ghost == true) return false;
    if (preview!.owner == true) return false;
    bool newForDate = Fav.preferences.getInt('${AppVar.appBloc.hesapBilgileri.uid}${preview.senderKey}${AppVar.appBloc.hesapBilgileri.termKey}messageread', 1569877200000)! < (preview.timeStamp is int ? preview.timeStamp : 0);
    if (newForDate == false) return false;

    //Ogretmen ve idareci ise
    if (AppVar.appBloc.hesapBilgileri.gtMT) return true;

    // Ogrenci hesabiysa

    if (AppVar.appBloc.hesapBilgileri.isParent) {
      if (preview.isParent == false) return false;
      return preview.parentNo == AppVar.appBloc.hesapBilgileri.parentNo;
    } else {
      if (preview.isParent == true) return false;
      return true;
    }
  }

  static Future<void>? goChat(MesaggingPreview? item, bool ghost, String? ghostUid) async {
    return Fav.to(ChatScreen(mesaggingPreview: item, ghost: ghost, ghostUid: ghostUid), preventDuplicates: false);
  }
}
