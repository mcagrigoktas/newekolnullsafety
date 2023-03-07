import 'dart:async';

import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../../appbloc/databaseconfig.model_helper.dart';
import '../../../helpers/stringhelper.dart';

class DeleteSchoolHelper {
  DeleteSchoolHelper._();
  static SuperUserInfo get _superUser => Get.find<SuperUserInfo>();
  static Future<bool> delete(String key) async {
    if (Fav.noConnection()) return false;
    final appBloc = AppVar.appBloc;

    if (_superUser.isDeveloper != true) {
      OverAlert.show(type: AlertType.danger, message: 'Yetki hatasi');
      return false;
    }
    var value = await Over.sure(title: key, message: '$key serveridli okul silinecek.');
    await 333.wait;
    if (value == true) {
      var value2 = await Over.sure(message: '$key serveridli okul silinecek son kararinmi');
      if (value2 == true) {
        OverLoading.show();
        final _resultComplater = Completer<bool>();
        await Future.wait([
          appBloc.database2.set('${StringHelper.schools}/$key', null),
          appBloc.database3.set('${StringHelper.schools}/$key', null),
          appBloc.databaseAccounting.set('${StringHelper.schools}/$key', null),
          appBloc.databaseLogs.set('${StringHelper.schools}/$key', null),
          appBloc.databaseVersions.set('${StringHelper.schools}/$key', null),
          appBloc.databaseProgram.set('${StringHelper.schools}/$key', null),
        ]).then((results) async {
          await Future.wait([
            appBloc.database1.set('ServerList/$key', null),
            appBloc.database1.set('${StringHelper.schools}/$key', null),
          ]).then((value) {
            _resultComplater.complete(true);
          }).catchError((value) {
            log(value);
            _resultComplater.complete(false);
          });
        }).catchError((err) {
          log(err);
          _resultComplater.complete(false);
        });
        final _result = await _resultComplater.future;

        if (_result == true) {
          OverAlert.show(message: '$key Silindi');
        } else {
          OverAlert.show(type: AlertType.danger, message: 'Bir hata oldu');
        }

        await OverLoading.close();
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
