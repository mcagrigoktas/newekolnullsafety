import 'package:geolocator/geolocator.dart';
import 'package:mcg_extension/mcg_extension.dart';

class LocationHelper {
  LocationHelper._();

//? Burda androidde background mesaj izni verilmesi lazim. Bu izin verildiginde market sayfalarinda girilmesi gereken istekler olacak.
  static const isBackroundServiceEnabled = false;

  static Future<bool> isGranted() async {
    if ((await _hasPermission()) == false) {
      OverAlert.show(message: 'locationpermissionerr'.translate, type: AlertType.info);
      return false;
    }

    if ((await _isServiceEnabled()) == false) {
      OverAlert.show(message: 'locationservice'.translate, type: AlertType.info);
      return false;
    }

    return true;
  }

  static Future<bool> _isServiceEnabled() async {
    bool _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return _serviceEnabled;
  }

  static Future<bool> _hasPermission() async {
    if (isBackroundServiceEnabled) {
      var _permissionGranted = await PermissionManager.location(showAlert: false);
      if (_permissionGranted) return true;
    }
    var _permissionGranted2 = await PermissionManager.locationWhenInUse();
    if (_permissionGranted2) return true;
    return false;
  }
}
