// import 'package:mcg_extension/mcg_extension.dart';

// import '../../appbloc/appvar.dart';
// import '../../models/notification.dart';
// import '../main/macos_dock/macos_dock.dart';

// class StickerHelper {
//   StickerHelper._();
//   //! Burasi Yeni data geldikce yapilacak degisiklikler
//   static void afterStickerNewData() {
//     Fav.preferences.setInt(lastNewDataTimePrefKey, DateTime.now().millisecondsSinceEpoch);
//     calculateNewItemBadge();
//   }

//   static const stickerIconTag = DockItemTag.sticker;
//   static const stickerNotificationType = NotificationType.stickers;
//   static String get lastStickerPageEntryTimePrefKey => '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}${AppVar.appBloc.hesapBilgileri.uid}laststickerpagelogintime';
//   static String get lastNewDataTimePrefKey => '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}${AppVar.appBloc.hesapBilgileri.uid}lastStickerNewDataTime';
//   static void calculateNewItemBadge() {
//     // tododanger burasi yeni bildirim sekline cevrilmesi gerekebilir NotificationGroup tan sonra kaldirildi
//     // if (Fav.preferences.getInt(lastNewDataTimePrefKey, 0) > Fav.preferences.getInt(lastStickerPageEntryTimePrefKey, 0)) {
//     //   Get.find<MacOSDockController>().replaceThisTagBadgeData(stickerNotificationType, [1]);
//     // } else {
//     //   Get.find<MacOSDockController>().replaceThisTagBadgeData(stickerNotificationType, null);
//     // }
//   }
//   //!
// }
