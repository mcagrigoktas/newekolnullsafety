import 'dart:async';

import 'package:mcg_extension/mcg_extension.dart';

import '../../../../services/dataservice.dart';

class UserPermissionPageController extends BaseController {
  final Map data = {};

  Future<void> submit() async {
    if (Fav.noConnection()) return;
    if (formKey.currentState!.checkAndSave()) {
      if (data['startTime'] >= data['endTime']) {
        OverAlert.show(message: 'incompatiblehour'.translate, type: AlertType.danger);
        return;
      }

      startLoading();
      await SchoolDataService.savePermissions(data).then((a) {
        OverAlert.saveSuc();
      }).catchError((error) {
        OverAlert.saveErr();
      });
      stopLoading();
    }
  }
}
