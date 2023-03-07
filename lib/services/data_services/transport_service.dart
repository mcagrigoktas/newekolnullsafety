part of '../dataservice.dart';

class TransportService {
  TransportService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _database11 => AppVar.appBloc.database1;
  static Database get _databaseLogss => AppVar.appBloc.databaseLogs;

  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE

  // Araç Listesi Referansı
  static Reference dbTransportListRef() => Reference(_database11, 'Okullar/$_kurumId/$_termKey/Transporters');

  // Tek bir arac Referansı
  static Reference dbTransportRef(String key, String termKey) => Reference(_database11, 'Okullar/$_kurumId/$termKey/Transporters/$key');

  //Servisciler icin tum servis datalari referansi
  static Reference dbAllServiceDataATransporter(String? uid) => Reference(_databaseLogss, '${StringHelper.schools}/$_kurumId/$_termKey/ServiceLogs/ServiceBasedRC/$uid');

//! SETDATASERVICE

  // Servis Aracı Kaydeder
  static Future<void> saveMultipleTransport(List<Transporter?> transporterList) async {
    Map<String, dynamic> _updates = {};

    transporterList.forEach((transporter) {
      Map checkListValues = {};
      checkListValues["GirisTuru"] = 90;
      checkListValues["UID"] = transporter!.key;

      _updates['/Okullar/$_kurumId/$_termKey/Transporters/' + transporter.key!] = transporter.mapForSave(transporter.key!)..['lastUpdate'] = _realTime;
      _updates['/Okullar/$_kurumId/CheckList/' + transporter.username! + transporter.password!] = checkListValues;
    });

    _updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Transporters'] = _realTime;
    return _database11.update(_updates).then((value) {
      makeBundle();
    });
  }

  static Future<void> sendTransporterRollCall(String dateKey, String transporterUid, Map data) {
    Map<String, dynamic> updates = {};

    data['lastUpdate'] = databaseTime;
    data['uid'] = AppVar.appBloc.hesapBilgileri.uid;
    updates['/${StringHelper.schools}/$_kurumId/$_termKey/ServiceLogs/TimeBasedRC/${dateKey + transporterUid}'] = data;
    updates['/${StringHelper.schools}/$_kurumId/$_termKey/ServiceLogs/ServiceBasedRC/$transporterUid/$dateKey'] = data;
    return _databaseLogss.update(updates);
  }

  static Future<void> makeBundle() async {
    if (!AppVar.appBloc.hesapBilgileri.gtM) return;
    return () {
      AppVar.appBloc.transporterService?.makeBundle();
    }.delay(1500);
  }
}
