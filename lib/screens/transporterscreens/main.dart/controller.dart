import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../../../flavors/appentry/ekolsplashscreen.dart';
import '../../../services/dataservice.dart';
import '../existingbusrides/model.dart';
import '../route_management.dart';

class TransporterMainController extends GetxController {
  @override
  void onInit() {
    _setupSplashScreen();
    super.onInit();
  }

  //? Splash Screen Baslangic
  bool logoGosterilecek = true;
  Future<void> _setupSplashScreen() async {
    if (!logoGosterilecek) return;

    const int duration = 2666;

    final current = SplashScreen(duration: duration);

    await 10.wait;

    Get.dialog(current, useSafeArea: false, barrierColor: Colors.transparent, barrierDismissible: false).unawaited;
    await 1000.wait;
    logoGosterilecek = false;
    update();
    await (duration - 1000).wait;
    if (Get.isDialogOpen!) Get.back();
  }
//? Splash Screen Bitis

  Future<void> startBusRide(int _seferNo) async {
    await TransportingMainRoutes.goBusRideScreen(_seferNo);
  }

  MiniFetcher<BusRideModel>? existingBusRides;

  Future<void> showExistingBusRide() async {
    if (existingBusRides == null) {
      OverLoading.show();
      existingBusRides = MiniFetcher<BusRideModel>(
        AppVar.appBloc.hesapBilgileri.kurumID! + AppVar.appBloc.hesapBilgileri.termKey! + AppVar.appBloc.hesapBilgileri.uid! + 'ServiceRollCallList',
        FetchType.LISTEN,
        multipleData: true,
        lastUpdateKey: 'lastUpdate',
        queryRef: TransportService.dbAllServiceDataATransporter(AppVar.appBloc.hesapBilgileri.uid!),
        jsonParse: (key, value) => BusRideModel(transporterUid: AppVar.appBloc.hesapBilgileri.uid, name: value['time'], key: key, data: value),
      );
      await 2000.wait;
      await OverLoading.close();
    }
    if (existingBusRides!.dataList.isNotEmpty) {
      await TransportingMainRoutes.goExistingBusridesScreen(existingBusRides!.dataList);
    } else {
      'norecords'.showAlert(AlertType.danger);
    }
  }
}
