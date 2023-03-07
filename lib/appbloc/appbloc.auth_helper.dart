import 'package:firebase_auth/firebase_auth.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../models/accountdata.dart';
import '../services/dataservice.dart';
import 'appbloc.dart';
import 'appvar.dart';
import 'jwt.dart';

class AppblocAuthHelper {
  AppblocAuthHelper._();

  static AppBloc get _appBloc => AppVar.appBloc;
  static HesapBilgileri get _hesapBilgileri => AppVar.appBloc.hesapBilgileri;
  static FirebaseAuth get _auth => _appBloc.auth;
  static Future<bool> signInWithToken() async {
    Fav.writeSeasonCache('signinlogData', '');

    //todo Super managerde yapilmali
    if (_hesapBilgileri.gtT || _hesapBilgileri.gtS || _hesapBilgileri.gtM || _hesapBilgileri.gtTransporter) {
      final userUid = _hesapBilgileri.kurumID! + '_' + _hesapBilgileri.girisTuru.toString() + '_' + _hesapBilgileri.uid!;
      if (_auth.currentUser?.uid == userUid) return true;
      Fav.writeSeasonCache('signinlogData', Fav.readSeasonCache('signinlogData') + '1-');
      if (_auth.currentUser != null) await _auth.signOut();
      Fav.writeSeasonCache('signinlogData', Fav.readSeasonCache('signinlogData') + '2-');

      if (_hesapBilgileri.signInToken.safeLength > 0) {
        try {
          Fav.writeSeasonCache('signinlogData', Fav.readSeasonCache('signinlogData') + '8-');
          final user = await _auth.signInWithCustomToken(_hesapBilgileri.signInToken!);
          if (user.user != null) return true;
        } catch (err) {
          Fav.writeSeasonCache('signinlogData', Fav.readSeasonCache('signinlogData') + '9$err-');
          log(err);
        }
      }

      Fav.writeSeasonCache('signinlogData', Fav.readSeasonCache('signinlogData') + '3-');
      final newToken = await Jwt.getUserAuthToken(
        uid: _hesapBilgileri.uid!,
        girisTuru: _hesapBilgileri.girisTuru,
        iM: _hesapBilgileri.gtM,
        iS: _hesapBilgileri.gtS,
        iT: _hesapBilgileri.gtT,
        kurumID: _hesapBilgileri.kurumID!,
      );
      Fav.writeSeasonCache('signinlogData', Fav.readSeasonCache('signinlogData') + '4-');
      if (newToken.safeLength > 0) {
        _hesapBilgileri.signInToken = newToken;
        await _hesapBilgileri.savePreferences();
        _hesapBilgileri.setHesapBilgileri();

        try {
          Fav.writeSeasonCache('signinlogData', Fav.readSeasonCache('signinlogData') + '5-');
          final user = await _auth.signInWithCustomToken(newToken!);
          Fav.writeSeasonCache('signinlogData', Fav.readSeasonCache('signinlogData') + '6-');
          return user.user != null;
        } catch (err) {
          Fav.writeSeasonCache('signinlogData', Fav.readSeasonCache('signinlogData') + '7$err-');
          log('SignIN Error $err');
          return false;
        }
      }
    }
    Fav.writeSeasonCache('signinlogData', Fav.readSeasonCache('signinlogData') + '10-');
    return false;
  }

  static void sendSignInError() {
    log('SigninLoginData: ' + Fav.readSeasonCache('signinlogData', '')!);
    Fav.timeGuardFunction('NonAuthLogin2', 15.days, () {
      _appBloc.firestore.updateFullField('DeveloperLogs/NonAuthUser', {
        _hesapBilgileri.kurumID!: {_hesapBilgileri.uid! + ' ' + _hesapBilgileri.name!: Fav.readSeasonCache('signinlogData', '')! + platformName}
      });
    }, usePreferences: true);
  }

  static void afterUserLoginProcess() {
    if (_hesapBilgileri.gtM) {
      Fav.timeGuardFunction(_hesapBilgileri.kurumID! + 'managerLogin', 3.days, () {
        SignInOutService.saveManagerLoginedTime();
      }, usePreferences: true);
    }
  }
}
