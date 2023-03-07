import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';
import '../../appbloc/minifetchers.dart';
import '../../helpers/firebase_helper.dart';
import '../../services/dataservice.dart';

class TecnicalSupportHelper {
  TecnicalSupportHelper._();
  static Future<void> clearVersionAndRestartApp() async {
    OverLoading.show();
    await Future.delayed(const Duration(milliseconds: 2000));

    List<Future> futureList = [];
    AppVar.appBloc.allService.forEach((service) async {
      final boxKey = service?.boxKey;

      if (boxKey.safeLength > 5) {
        futureList.add(service!.clearDatabase());
      }
    });

    await MiniFetchers.clearDataAllFetcher();
    await Future.wait(futureList);

    await OverLoading.close();

    AppVar.appBloc.appConfig.ekolRestartApp!(true);
  }

  static Future<void> fixNotificationIssue() async {
    //todo buraya bildirim izin kontrolunude yaz
    OverLoading.show();
    final _token = await FirebaseHelper.getToken();
    await OverLoading.close();
    if (_token == null) return;
    final String tokenPreferencesKey = "${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}${AppVar.appBloc.hesapBilgileri.girisTuru}${AppVar.appBloc.hesapBilgileri.uid}_token3";
    OverLoading.show();
    await SignInOutService.dbAddToken2(_token, await DeviceManager.getDeviceModel()).then((_) {
      Fav.preferences.setString(tokenPreferencesKey, _token);
      OverAlert.show(message: 'checkdone'.translate);
    });
    await OverLoading.close();
  }
}
