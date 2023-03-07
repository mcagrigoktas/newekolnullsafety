part of '../dataservice.dart';

class MedicineService {
  MedicineService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID!;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey!;
  static dynamic get _realTime => databaseTime;
  static Database get _database11 => AppVar.appBloc.database1;
  static Database get _database33 => AppVar.appBloc.database3;

//! GETDATASERVICE

//Ilac girisi yapilan  profilleri ceker
  static Reference dbMedicineProfilessRef() => Reference(_database33, 'Okullar/$_kurumId/$_termKey/HealthCare/Profiles');

//! SETDATASERVICE

//Veli ilac Ekler
  static Future<void> addMedicineProfile(medicineData) => _database33.push('Okullar/$_kurumId/$_termKey/HealthCare/Profiles', medicineData).then((_) {
        _database11.set('Okullar/$_kurumId/SchoolData/Versions/$_termKey/MedicineProfiles', _realTime);
      });

  //Eklenen ilac silinir
  static Future<void> deleteMedicineProfile(medicineKey) {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/HealthCare/Profiles/$medicineKey/aktif'] = false;
    updates['/Okullar/$_kurumId/$_termKey/HealthCare/Profiles/$medicineKey/timeStamp'] = _realTime;

    return _database33.update(updates).then((_) {
      _database11.set('Okullar/$_kurumId/SchoolData/Versions/$_termKey/MedicineProfiles', _realTime);
    });
  }

  //ilacin verildigini ogretmen kaydeder
  static Future<void> gaveMedicine(String profileKey, String date) {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/HealthCare/Profiles/$profileKey/medicineReport/$date'] = true;
    updates['/Okullar/$_kurumId/$_termKey/HealthCare/Profiles/$profileKey/timeStamp'] = _realTime;
    return _database33.update(updates).then((_) {
      _database11.set('Okullar/$_kurumId/SchoolData/Versions/$_termKey/MedicineProfiles', _realTime);
    });
  }
}
