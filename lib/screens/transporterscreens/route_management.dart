import 'package:mcg_extension/mcg_extension.dart';

import 'busride/layout.dart' deferred as bus_ride;
import 'existingbusrides/layout.dart' deferred as existing_busrides;
import 'existingbusrides/model.dart';
import 'service_locations/layout.dart' deferred as service_locations;
import 'student_screen_transporter_info/layout.dart' deferred as student_screen_transporter_info;
import 'transportlist/layout.dart' deferred as transporter_list;
import 'transportlist/transporter.dart';

class TransportingMainRoutes {
  TransportingMainRoutes._();

  static Future<void>? goTransporterList() async {
    OverLoading.show();
    await transporter_list.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(transporter_list.TransporterList());
  }

  static Future<void>? goStudentScreenTransporterInfo() async {
    OverLoading.show();
    await student_screen_transporter_info.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(student_screen_transporter_info.StudentScreenTransporterInfo());
  }

  static Future<void>? goServiceLocationScreen({List<Transporter>? transporterList}) async {
    OverLoading.show();
    await service_locations.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(service_locations.ServiceLocationsScreen(
      transporterList: transporterList,
    ));
  }

  static Future<void>? goExistingBusridesScreen(List<BusRideModel> itemList) async {
    OverLoading.show();
    await existing_busrides.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(existing_busrides.ExistingBusRides(itemList));
  }

  static Future<void>? goBusRideScreen(int seferNo) async {
    OverLoading.show();
    await bus_ride.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(bus_ride.BusRide(seferNo));
  }
}
