import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../../constant_settings.dart';
import '../../helpers/appfunctions.dart';
import '../../models/allmodel.dart';
import '../../models/notification.dart';
import '../../services/remote_control.dart';
import '../main/macos_dock/macos_dock.dart';

enum SocialType {
  photo,
  video,
  photoAndVideo,
}

class SocialHelper {
  SocialHelper._();

  static void afterSocialNewData() {
    calculateNewItemBadge();
  }

  static const socialIconTag = DockItemTag.social;
  static String get lastSocialPageEntryTimePrefKey => '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.uid}lastsocialpagelogintime' + (Get.find<RemoteControlValues>().useFirestoreForSocial == true ? 'N' : '');
  static void calculateNewItemBadge() {
    final lastsocialpagelogintime = Fav.preferences.getInt(lastSocialPageEntryTimePrefKey, DateTime.now().subtract(Duration(days: 15)).millisecondsSinceEpoch)!;

    int _unPublishedItemCount = 0;
    final newSocialList = SocialHelper.getAllFilteredSocialList(SocialType.photoAndVideo).where((element) {
      if (element.isPublish == false) _unPublishedItemCount++;
      return element.time > lastsocialpagelogintime;
    }).toList();

    List<InAppNotification> notificationList = [];
    List<InAppNotification> unPublishedSocialList = [];

    if (newSocialList.isNotEmpty) {
      notificationList.add(InAppNotification(type: NotificationType.social)
        ..title = 'newsocialpost'.argsTranslate({'count': newSocialList.length})
        ..lastUpdate = newSocialList.fold<int>(lastsocialpagelogintime, (previousValue, element) => element.time > previousValue ? element.time : previousValue));
    }

    if (AppVar.appBloc.hesapBilgileri.gtM && _unPublishedItemCount > 0) {
      unPublishedSocialList.add(InAppNotification(
        title: 'unpublishedsocial'.argsTranslate({'count': _unPublishedItemCount}),
        type: NotificationType.socialUnPublish,
      ));
    }
    Get.find<MacOSDockController>().replaceThisTagNotificationList(NotificationGroup.social, notificationList);
    Get.find<MacOSDockController>().replaceThisTagNotificationList(NotificationGroup.socialUnPublish, unPublishedSocialList);
  }

//type 0 photo 1 video 2 herikisi
  static List<SocialItem> getAllFilteredSocialList(SocialType? type) {
    late List<String?> _teacherClassList;
    if (AppVar.appBloc.hesapBilgileri.gtT) {
      _teacherClassList = TeacherFunctions.getTeacherClassList();
    }

    List<String?>? _studentClassKeyList;
    if (AppVar.appBloc.hesapBilgileri.gtS) {
      _studentClassKeyList = AppVar.appBloc.hesapBilgileri.classKeyList;
    }

    List<SocialItem> items;
    if (Get.find<RemoteControlValues>().useFirestoreForSocial) {
      items = AppVar.appBloc.newSocialService!.dataList.where((element) {
        if (type == SocialType.photo) return element.isPhoto;
        if (type == SocialType.video) return element.isVideo;
        if (type == SocialType.photoAndVideo) return element.isPhoto || element.isVideo;

        return false;
      }).toList()
        ..sort((a, b) => b.time - a.time);
    } else {
      items = (type == SocialType.photo
          ? AppVar.appBloc.socialService!.dataList
          : (type == SocialType.video ? AppVar.appBloc.videoService!.dataList : [...AppVar.appBloc.socialService!.dataList, ...AppVar.appBloc.videoService!.dataList]
            ..sort((a, b) => b.time - a.time)));
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final sixMonth = Duration(days: socialNetworkMaxDay).inMilliseconds;
    return items.where((item) {
      if (now - item.time > sixMonth) return false;

      if (item.senderKey == null) return false;
      if (item.aktif == false) return false;
      if ((item.imgList ?? []).isEmpty && (item.videoLink ?? '').isEmpty && (item.youtubeLink ?? '').isEmpty) return false;

      if (AppVar.appBloc.hesapBilgileri.gtM) {
        return true;
      } else if (AppVar.appBloc.hesapBilgileri.gtT) {
        if (item.targetList!.contains("alluser") || item.targetList!.contains("onlyteachers")) {
          return true;
        }
        if (item.senderKey == AppVar.appBloc.hesapBilgileri.uid) {
          return true;
        }
        if (item.targetList!.any((item) => _teacherClassList.contains(item))) {
          return true;
        }
      } else if (AppVar.appBloc.hesapBilgileri.gtS) {
        if (!(item.isPublish ?? false)) {
          return false;
        }
        if (item.targetList!.contains("alluser")) {
          return true;
        }
        if (item.targetList!.any((item) => [..._studentClassKeyList!, AppVar.appBloc.hesapBilgileri.uid].contains(item))) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  static Future<void> saveLastLoginTime() async {
    final _itemList = Get.find<MacOSDockController>().socialNotificationList();
    if (_itemList == null || _itemList.isEmpty) return;
    await Fav.preferences.setInt(lastSocialPageEntryTimePrefKey, _itemList.fold<int>(0, (p, e) => p > e.lastUpdate ? p : e.lastUpdate));
    calculateNewItemBadge();
  }
}
