import 'package:flutter/foundation.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../../services/dataservice.dart';
import 'model.dart';

class ChangeLogPostController extends BaseController {
  List<String> langList = ['tr'];
  ChangeLogPostItem data = ChangeLogPostItem();
  ChangeLogPostController();

  int typeIndex = 0;
  final saveLocation = 'Changelogs/Media';

  List<ChangeLogPostItem> dataFetcherList = [];
  @override
  void onInit() {
    ChangeLogService.dbGetChangelog().onValue().listen((event) {
      if (event?.value != null) dataFetcherList = (event!.value as Map).entries.map((e) => ChangeLogPostItem.fromJson(e.value, e.key)).toList();
      dataFetcherList.sort((a, b) => b.timeStamp! - a.timeStamp!);
      update();
    });
    super.onInit();
  }

  void save() {
    data = ChangeLogPostItem();
    if (formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;

      if (typeIndex == 1 && data.youtubeLink.getYoutubeIdFromUrl == null) {
        OverAlert.show(type: AlertType.danger, message: 'youtubelinkerr'.translate);
        return;
      }

      if (data.key.safeLength < 6) data.key = 6.makeKey.toLowerCase();

      OverLoading.show();

      ChangeLogService.sendChangelogData(data).then((a) async {
        await OverLoading.close(state: true);
      }).catchError((error) {
        log(error);
        OverLoading.close(state: false);
      });
    }
  }

  Future<void> publish() async {
    final sure = await Over.sure();
    if (sure != true) return;
    OverLoading.show();
    final Map data = (await ChangeLogService.dbGetChangelog().once())!.value;
    final bundleData = DataZip.zipFromJsonData(data);
    await Storage()
        .uploadBytes(
      //? Breaking changes
      MyFile(byteData: Uint8List.fromList(bundleData), name: 'changelogsbundle.txt'),
      saveLocation,
      'changelogsbundle.txt',
      dataImportance: DataImportance.veryHigh,
      forceUseThisName: true,
    )
        .then((value) {
      // FirebaseFunctionService.changeRemoteConfigValue(parameterGroup: 'RemoteChanges', parameter: 'changelogversion', data: 1000000.random, valueType: ValueType.NUMBER).then((value) {
      //   log(value);
      // }).catchError((err) {
      //   log(err);
      // });

      OverAlert.saveSuc();
    }).catchError((err) {
      OverAlert.saveErr();
    });
    await OverLoading.close();
  }
}

enum ChangeLogPostType { changelog, fix }

enum ChangeLogAppTarget { ekid, ekol, all }
