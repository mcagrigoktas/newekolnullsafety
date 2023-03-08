import 'dart:async';

import 'package:flutter_sms/flutter_sms.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../appbloc/appvar.dart';
import '../appbloc/databaseconfig.dart';
import '../flavors/appconfig.dart';
import '../models/models.dart';
import '../screens/managerscreens/schoolsettings/models/mutlu_cell.dart';

class UserAccountSmsModel {
  List<String>? numbers;
  String? username;
  String? password;
  String? kurumId;

  UserAccountSmsModel({this.username, this.password, this.kurumId, this.numbers});
}

class AppLinkHelper {
  AppLinkHelper._();

  static void _init() {
    if (AppVar.appBloc.appConfig.marketData == null) {
      if (AppVar.appBloc.hesapBilgileri.isEkid) {
        AppVar.appBloc.appConfig.marketData = DatabaseStarter.marketLinks['elseifekid'];
      } else {
        AppVar.appBloc.appConfig.marketData = DatabaseStarter.marketLinks['elseif'];
      }
    }
  }

  static MarketData? _getMarketData({String? appName}) {
    if (appName != null) return DatabaseStarter.marketLinks[appName];
    return AppVar.appBloc.appConfig.marketData ?? DatabaseStarter.marketLinks[AppVar.appBloc.schoolInfoService!.singleData!.appName!];
  }

  // static String _getAndroidUrl({String appName}) {
  //   if (appName != null) return DatabaseStarter.marketLinks[appName]?.androidUrl;
  //   return AppVar.appBloc.appConfig.marketData.androidUrl ?? DatabaseStarter.marketLinks[AppVar.appBloc.schoolInfoService.singleData.appName]?.androidUrl;
  // }

  // static String _getIosUrl({String appName}) {
  //   if (appName != null) return DatabaseStarter.marketLinks[appName]?.iosUrl;
  //   return AppVar.appBloc.appConfig.marketData.iosUrl ?? DatabaseStarter.marketLinks[AppVar.appBloc.schoolInfoService.singleData.appName]?.iosUrl;
  // }

  // static String _getWebUrl({String appName}) {
  //   if (appName != null) return DatabaseStarter.marketLinks[appName]?.webUrl;
  //   return AppVar.appBloc.appConfig.marketData.webUrl ?? DatabaseStarter.marketLinks[AppVar.appBloc.schoolInfoService.singleData.appName]?.webUrl;
  // }

  // static String _getAppName({String appName}) {
  //   if (appName != null) return DatabaseStarter.marketLinks[appName]?.name;
  //   return AppVar.appBloc.appConfig.marketData.name ?? DatabaseStarter.marketLinks[AppVar.appBloc.schoolInfoService.singleData.appName]?.name;
  // }

  // static String _getSaver() {
  //   return AppVar.appBloc.appConfig.marketData.saver ?? DatabaseStarter.marketLinks[AppVar.appBloc.schoolInfoService.singleData.appName]?.saver ?? 'elseif';
  // }

  static String _getAppMarketInfo({String? appName}) {
    _init();
    String message = '';

    final _marketData = _getMarketData(appName: appName);

    if (_marketData != null) {
      message += (_marketData.name) + '\n';

      if (_marketData.webUrl.safeLength > 0) message += 'smsaccount10'.translate + ' ' + _marketData.webUrl + '\n';

      if (_marketData.androidUrl.safeLength > 0) message += 'smsaccount1'.translate + ' ' + _marketData.androidUrl + '\n';

      if (_marketData.iosUrl.safeLength > 0) message += 'smsaccount2'.translate + ' ' + _marketData.iosUrl + '\n';
    }
    return message;
  }

  static String getUserInfoMessage(UserAccountSmsModel model, {String? appName}) {
    String message = _getAppMarketInfo(appName: appName) + 'smsaccount3'.translate + ' ' + model.username! + '\n' + 'smsaccount4'.translate + ' ' + model.password!;
    if ((AppVar.appBloc.appConfig.serverIdList ?? []).length != 1) {
      message += '\n' + 'smsaccount5'.translate + ' ' + model.kurumId!;
    }
    return message;
  }
}

class SmsModel {
  List<String>? numbers;
  String? message;

  SmsModel({required this.message, required this.numbers});
}

class SmsSender {
  SmsSender._();

  static Future<bool> sendUserAccountWithSms(List<UserAccountSmsModel> smsModelList, {String? appName}) async {
    smsModelList.removeWhere((element) => element.numbers == null || element.numbers!.isEmpty);

    final _smsModelList = <SmsModel>[];

    smsModelList.forEach((userAccountSmsModel) {
      final _messageText = AppLinkHelper.getUserInfoMessage(userAccountSmsModel, appName: appName);
      _smsModelList.add(SmsModel(message: _messageText, numbers: userAccountSmsModel.numbers));
    });

    return sendSms(_smsModelList, mobilePhoneCanBeUsed: true, sureAlertVisible: true, dataIsUserAccountInfo: true);
  }

  static Future<bool> sendSms(List<SmsModel> dataList, {bool mobilePhoneCanBeUsed = true, bool sureAlertVisible = true, bool dataIsUserAccountInfo = false}) async {
    if (isWeb || !mobilePhoneCanBeUsed) {
      if (AppVar.appBloc.appConfig.smsCountry == Country.tr) {
        return _sendSmsWithMutluCell(dataList, sureAlertVisible: sureAlertVisible, dataIsUserAccountInfo: dataIsUserAccountInfo);
      } else {
        'smsnotconfigured'.translate.showAlert(AlertType.warning);
        return false;
      }
    } else {
      if (dataList.length == 1) {
        await sendSMS(message: dataList.first.message!, recipients: dataList.first.numbers!);
      } else {
        final SmsModel? _result = await (OverBottomSheet.show(BottomSheetPanel.list(
            multipleItemBackgrounds: true,
            title: 'anitemchoose'.translate,
            items: dataList
                .map(
                  (e) => BottomSheetItem(name: e.message!, value: e, suffix: e.numbers!.join('\n').text.make()),
                )
                .toList())));
        if (_result != null) await sendSMS(message: _result.message!, recipients: _result.numbers!);
      }
    }
    return true;
  }

  static Future<bool> _sendSmsWithMutluCell(List<SmsModel> dataList, {bool sureAlertVisible = true, bool dataIsUserAccountInfo = false}) async {
    // if (dataList == null) {
    //   OverAlert.anError();
    //   return false;
    // }

    dataList.removeWhere((element) => element.numbers == null || element.numbers!.isEmpty);

    MutluCellConfig? _mutluCellConfig;
    if (dataIsUserAccountInfo) {
      _mutluCellConfig = MutluCellConfig(
        username: DatabaseStarter.databaseConfig.mutluCellUsername,
        password: DatabaseStarter.databaseConfig.mutluCellPassword,
        originator: DatabaseStarter.databaseConfig.mutluCellOriginator,
      );
    } else {
      final _config = AppVar.appBloc.schoolInfoService!.singleData!.smsConfig;
      if (_config.isSturdy) _mutluCellConfig = _config.config<MutluCellConfig>();
    }
    if (_mutluCellConfig == null) {
      'smsnotconfigured'.translate.showAlert(AlertType.warning);
      return false;
    }

    final _phoneCount = dataList.fold<int>(0, (p, e) => p + e.numbers!.length);
    if (_phoneCount == 0) {
      OverAlert.show(type: AlertType.danger, message: 'couldntfindphone'.translate);
      return false;
    }
    final _allPhoneList = dataList.fold<String>('', (p, e) => p + e.numbers!.join(',') + '.');
    var sure = !sureAlertVisible ? true : await Over.sure(title: 'messagewillthisnomber'.translate + '(${"piece".argTranslate(_phoneCount.toString())})', message: _allPhoneList);
    if (sure != true) return false;

    var _mutluCellXmLPrefix = '<?xml version="1.0" encoding="UTF-8"?> <smspack ka="' + _mutluCellConfig.username! + '" pwd="' + _mutluCellConfig.password! + '" org="' + _mutluCellConfig.originator! + '"  charset="turkish"> ';
    var mutluCellMessagesPack = '';
    dataList.forEach((smsModel) {
      mutluCellMessagesPack += ' <mesaj> <metin>' + smsModel.message! + '</metin> <nums>' + smsModel.numbers!.fold<String>('', (p, e) => p + (p == '' ? '' : ',') + e) + '</nums></mesaj> ';
    });
    if (mutluCellMessagesPack.isEmpty) {
      OverAlert.show(type: AlertType.danger, message: 'couldntfindphone'.translate);
      return false;
    }
    var mutluCellXmLSuffix = ' </smspack>';
    var xml = _mutluCellXmLPrefix + mutluCellMessagesPack + mutluCellXmLSuffix;
    OverLoading.show(style: OverLoadingWidgetStyle(text: 'smssending'.translate));
    final _completer = Completer<bool>();
    await FirebaseFunctionService.callFirebaseHttp(method: HttpMethod.POST, url: 'https://smsgw.mutlucell.com/smsgw-ws/sndblkex', headers: {'content-type': 'text/xml;charset=turkish'}, body: xml).then((value) async {
      bool _hasError = false;
// 20: Post edilen xml eksik veya hatalı.
// 21: Kullanılan originatöre sahip değilsiniz
// 22: Kontörünüz yetersiz
// 23: Kullanıcı adı ya da parolanız hatalı.
// 24: Şu anda size ait başka bir işlem aktif.
// 25: SMSC Stopped (Bu hatayı alırsanız, işlemi 1-2 dk sonra tekrar deneyin)
// 30: Hesap Aktivasyonu sağlanmamış
      if (value is! Map) {
        _hasError = true;
      } else if (['20', '21', '22', '23', '24', '25', '30'].any((element) => element == value['body'].toString())) {
        _hasError = true;
      } else if (value['error'].toString() != 'null') {
        _hasError = true;
      }

      if (_hasError) {
        _completer.complete(false);
        log(value);
        await OverLoading.close();
        OverAlert.show(message: 'smssenderr'.translate, type: AlertType.danger);
      } else {
        _completer.complete(true);
        await OverLoading.close();
        OverAlert.show(message: 'smssended'.translate, type: AlertType.successful);
      }
    }).catchError((err) async {
      await OverLoading.close();
      OverAlert.saveErr();
      _completer.complete(false);
    });

    return _completer.future;
  }
}
