import 'package:mcg_extension/mcg_extension.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../helpers/appfunctions.dart';
import '../../../../models/accountdata.dart';
import '../../../loginscreen/loginscreen.dart';

class UserImageHelper {
  UserImageHelper._();
  static const placeHolderImage = 'https://firebasestorage.googleapis.com/v0/b/elseifekid.appspot.com/o/appimages%2Fnopicture.png?alt=media&token=9d51b05e-fd4b-43b9-9c9e-210bb10238db';

  static const ekolAllUserPrefKey = 'ekolAllUserM';

  static List<HesapBilgileri> _getAllUser() {
    final Map _allSavedUsers = Fav.securePreferences.getMap(ekolAllUserPrefKey);
    //  if (_allSavedUsers == null) return [];

    List<HesapBilgileri> _accountList = [];
    _allSavedUsers.forEach((k, v) {
      _accountList.add(HesapBilgileri()..setHesapBilgileri(accountInfo: v));
    });
    _accountList.removeWhere((element) {
      return !element.isSturdy;
    });
    return _accountList;
  }

  ///Ekol icerisindeki giris yapmis kullanicilardan  birine aitse dondurur supermanageri falan dondurmez.
  static HesapBilgileri? getThisUser(String uid) {
    return _getAllUser().firstWhereOrNull((element) => element.uid == uid && (element.gtM || element.gtS || element.gtT || element.gtTransporter));
  }

  ///Ekol icerisindeki giris yapmis kullanicilardan gelen uid listesinden herhangi biri varsa ilkini gonderir.
  static HesapBilgileri? getAnyUserInThisUserList(List<String> uidList) {
    return _getAllUser().firstWhereOrNull((element) => uidList.contains(element.uid) && (element.gtM || element.gtS || element.gtT || element.gtTransporter));
  }

  static List<HesapBilgileri> getAllUserForMenuType(SelectUserMenuType menuType) {
    return _getAllUser().where((hesap) {
      return menuType == SelectUserMenuType.LoginScreen || (hesap.uid.toString() + hesap.kurumID.toString() != (AppVar.appBloc.hesapBilgileri.uid).toString() + (AppVar.appBloc.hesapBilgileri.kurumID).toString());
    }).toList();
  }

  static String? getUserImageUrl(HesapBilgileri hesap) {
    String? imgUrl;
    if (hesap.kurumID == AppVar.appBloc.hesapBilgileri.kurumID) {
      imgUrl = AppFunctions2.whatIsProfileImgUrl(hesap.uid);
    }

    if (imgUrl?.startsWithHttp ?? false) return imgUrl;
    return (hesap.imgUrl?.startsWithHttp ?? false) ? hesap.imgUrl : placeHolderImage;
  }

  static void selectAccount(HesapBilgileri? hesap, SelectUserMenuType menuType) {
    if (Fav.noConnection()) {
      return;
    }
    if (hesap!.uid != AppVar.appBloc.hesapBilgileri.uid || hesap.kurumID != AppVar.appBloc.hesapBilgileri.kurumID) {
      if (hesap.girisTuru == 200) {
        final _page = EkolSignInPage(
          username: hesap.username,
          password: hesap.password,
          serverId: hesap.kurumID,
        );
        if (menuType == SelectUserMenuType.ProfileImage) {
          Fav.to(_page);
        } else {
          Get.offAll(() => _page);
        }
        return;
      }
      hesap.savePreferences();
      //! Eskiden asagidaki gibiydi
      // accountList.where((item) => item.uid == hesap.uid && item.kurumID == hesap.kurumID).first.savePreferences();
      AppVar.appBloc.appConfig.ekolRestartApp!(true);
    } else if (hesap.uid == AppVar.appBloc.hesapBilgileri.uid && hesap.kurumID == AppVar.appBloc.hesapBilgileri.kurumID) {
      if (menuType == SelectUserMenuType.LoginScreen) {
        Get.back();
      }
    }
  }
}

enum SelectUserMenuType { LoginScreen, ProfileImage }
