part of '../dataservice.dart';

class PersonService {
  PersonService._();

  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static Database get _database11 => AppVar.appBloc.database1;
  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE
  //Okullarin person listesini ceker
  static Reference dbGetPersonLists() => Reference(_database11, 'Okullar/$_kurumId/Persons');

//! SETDATASERVICE
// Person Kaydeder
  static Future<void> savePerson(Person person) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/Persons/' + person.key!] = person.toJson(person.key!)..['lastUpdate'] = _realTime;

    return _database11.update(updates);
  }
}
