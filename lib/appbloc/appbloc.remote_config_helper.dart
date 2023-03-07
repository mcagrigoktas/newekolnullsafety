import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../services/remote_control.dart';
import 'appbloc.dart';
import 'appvar.dart';

class AppblocRemoteConfigHelper {
  AppblocRemoteConfigHelper._();

  static AppBloc get _appBloc => AppVar.appBloc;
  static Future<void> startRemoteConfigProcesses() async {
    await _getRemoteConfigData();
    _checkAppVersion().unawaited;
    _checkServerData();
  }

  static Future<void> _getRemoteConfigData() async {
    final _defaults = <String, dynamic>{};
    await RemoteConfig.instance(defaults: _defaults);
  }

  static void _checkServerData() {
    Get.find<ServerSettings>()
      ..firebaseBucket = RemoteConfig.getString('f_b')
      ..videoServerActive = RemoteConfig.getBool('video_active')
      ..doStorageSettings = S3StorageSettings.fromMcgEncMap(RemoteConfig.getString('dosettings'))
      ..contaboStorageSettings = S3StorageSettings.fromMcgEncMap(RemoteConfig.getString('cosettings'));

    Get.find<PhotoVideoCompressSetting>()
      ..videoSizeMinHeight = RemoteConfig.getInt('video_size_max_height')
      ..photoMaxSelectableCount = RemoteConfig.getInt('photo_max_selectable_count');

    Get.find<RemoteControlValues>().liveBroadcastPIPEnable = RemoteConfig.getBool('pipEnabled') == true;
    Get.find<RemoteControlValues>().excelIsSpreadSheet = RemoteConfig.getBool('excelIsSpreadSheet') == true;
    Get.find<RemoteControlValues>().agoraAppId = (RemoteConfig.getString('ag_ai')).replaceAll('mcg', '');
    Get.find<RemoteControlValues>().cryptedMap = RemoteConfig.getBool('cryptedMap');
    Get.find<RemoteControlValues>().broadcaststartpage = RemoteConfig.getBool('broadcaststartpage');
    Get.find<RemoteControlValues>().jitsiJwtData = RemoteConfig.getString('jAD');
    Get.find<RemoteControlValues>().useFirestoreForSocial = RemoteConfig.getBool('useFirestoreForSocial') == true || isDebugMode;
    // Get.find<RemoteControlValues>().useFirestoreForSocial = (RemoteConfig.getBool('useRealTimeDatabaseForSocial') == true ? false : true) || isDebugMode;

    Future.delayed(1000.milliseconds).then((value) {
      Get.find<PhotoVideoCompressSetting>().maxDuration = _appBloc.schoolInfoService?.singleData?.getMaxVideoDuration ?? Duration(seconds: RemoteConfig.getInt('video_max_second'));
    });
  }

  static Future<void> _checkAppVersion() async {
    if (isWeb) return;
    await 1000.wait;
    final packageName = await PackagaManager.getPackageName();
    final buildNumber = await PackagaManager.getBuildNumber();

    final key = (packageName + (isIOS ? 'ios' : 'android')).replaceAll('.', '');
    final int lastVersion = RemoteConfig.getInt(key);
    final version = int.tryParse(buildNumber) ?? 100000;

    if (lastVersion > version) {
      await Over.sure(title: 'hasupdate'.translate, yesText: 'startupdate'.translate).then((value) {
        if (value == true) {
          (isIOS ? _appBloc.appConfig.marketData!.iosUrl : _appBloc.appConfig.marketData!.androidUrl).launch(LaunchType.url);
        }
      });
    }
  }
}
