part of '../dataservice.dart';

class StudentService {
  StudentService._();

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _database11 => AppVar.appBloc.database1;
  static Database get _databaseVersionss => AppVar.appBloc.databaseVersions;

  static dynamic get _realTime => databaseTime;

//! GETDATASERVICE

  // Öğrenci Listesi Referansı
  static Reference dbStudentListRef() => Reference(_database11, 'Okullar/$_kurumId/$_termKey/Students');

  // Tek bir ogrenci Referansı
  static Reference dbStudentRef(String key, String termKey) => Reference(_database11, 'Okullar/$_kurumId/$termKey/Students/$key');

//! SETDATASERVICE

  // Öğrenci Kaydeder
  static Future<void> saveStudent(Student student, String existingKey, {bool addBundle = false}) async {
    Map _studentCheckListValues = {};
    _studentCheckListValues["GirisTuru"] = 30;
    _studentCheckListValues["UID"] = existingKey;

    Map? _parent1CheckListValues;
    Map? _parent2CheckListValues;
    if (student.parentPassword1.safeLength >= 6 && student.parentPassword1 != student.password) {
      _parent1CheckListValues = {};
      _parent1CheckListValues["GirisTuru"] = 30;
      _parent1CheckListValues["UID"] = existingKey;
      _parent1CheckListValues["parentNo"] = 1;
    }
    if (student.parentPassword2.safeLength >= 6 && student.parentPassword2 != student.password && student.parentPassword2 != student.parentPassword1) {
      _parent2CheckListValues = {};
      _parent2CheckListValues["GirisTuru"] = 30;
      _parent2CheckListValues["UID"] = existingKey;
      _parent2CheckListValues["parentNo"] = 2;
    }

    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/Students/' + existingKey] = student.mapForSave(existingKey)..['lastUpdate'] = _realTime;
    updates['/Okullar/$_kurumId/CheckList/' + student.username! + student.password!] = _studentCheckListValues;
//? Veli 1 ve 2
    if (_parent1CheckListValues != null) {
      updates['/Okullar/$_kurumId/CheckList/' + student.username! + student.parentPassword1!] = _parent1CheckListValues;
    }
    if (_parent2CheckListValues != null) {
      updates['/Okullar/$_kurumId/CheckList/' + student.username! + student.parentPassword2!] = _parent2CheckListValues;
    }

    updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Students'] = _realTime;
    return _database11.update(updates).then((_) {
      _databaseVersionss.set('Okullar/$_kurumId/$_termKey/$existingKey/${VersionListEnum.userInfoChangeService}', _realTime);
      if (addBundle) {
        makeBundle();
      }
    });
  }

  // Öğrenci Import sirasindaKaydeder
  static Future<void> saveMultipleStudent(List<Student> itemList) async {
    final _checkListValuesSnap = await SignInOutService.checkAllCheckListValues();

    String _sameUsernameErrorText = '';
    if (_checkListValuesSnap?.value != null) {
      itemList.forEach((newStudent) {
        final _mewStudentUsernamePassword = newStudent.username! + newStudent.password!;
        (_checkListValuesSnap!.value as Map).entries.forEach((_userDataV) {
          final _userData = _userDataV.value as Map;
          final _usernamePassword = _userDataV.key;
          final _userGirisTuru = _userData['GirisTuru'];
          final _userGirisUID = _userData['UID'];

          if (_mewStudentUsernamePassword == _usernamePassword) {
            //! Burada parent faktoru degerlendirilmedi. Gerekebilir.
            if (_userGirisTuru == 30 && _userGirisUID == newStudent.key) {
              //Bisey Yapma
            } else {
              _sameUsernameErrorText += newStudent.name + '\n';
            }
          }
        });
      });
    }

    if (_sameUsernameErrorText.safeLength > 2) {
      final _message = 'sameUsernameErrorText'.translate + '\n' + _sameUsernameErrorText;
      OverAlert.show(message: _message, type: AlertType.danger, autoClose: false);
      throw (_message);
    }

    Map<String, dynamic> updates = {};

    itemList.forEach((student) {
      Map checkListValues = {};
      checkListValues["GirisTuru"] = 30;
      checkListValues["UID"] = student.key;

      Map? _parent1CheckListValues;
      Map? _parent2CheckListValues;
      if (student.parentPassword1.safeLength >= 6 && student.parentPassword1 != student.password) {
        _parent1CheckListValues = {};
        _parent1CheckListValues["GirisTuru"] = 30;
        _parent1CheckListValues["UID"] = student.key;
        _parent1CheckListValues["parentNo"] = 1;
      }
      if (student.parentPassword2.safeLength >= 6 && student.parentPassword2 != student.password && student.parentPassword2 != student.parentPassword1) {
        _parent2CheckListValues = {};
        _parent2CheckListValues["GirisTuru"] = 30;
        _parent2CheckListValues["UID"] = student.key;
        _parent2CheckListValues["parentNo"] = 2;
      }

      updates['/Okullar/$_kurumId/$_termKey/Students/' + student.key] = student.mapForSave(student.key)..['lastUpdate'] = _realTime;
      updates['/Okullar/$_kurumId/CheckList/' + student.username! + student.password!] = checkListValues;

      //? Veli 1 ve 2
      if (_parent1CheckListValues != null) {
        updates['/Okullar/$_kurumId/CheckList/' + student.username! + student.parentPassword1!] = _parent1CheckListValues;
      }
      if (_parent2CheckListValues != null) {
        updates['/Okullar/$_kurumId/CheckList/' + student.username! + student.parentPassword2!] = _parent2CheckListValues;
      }
    });

    updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Students'] = _realTime;

    return _database11.update(updates).then((value) {
      makeBundle();
    });
  }

// Öğrenci Siler
  static Future<void> deleteStudent(String existingKey, {bool recover = false}) async {
    Map<String, dynamic> updates = {};
    updates['/Okullar/$_kurumId/$_termKey/Students/' + existingKey + "/aktif"] = recover;
    updates['/Okullar/$_kurumId/$_termKey/Students/' + existingKey + "/lastUpdate"] = _realTime;
    updates['/Okullar/$_kurumId/SchoolData/Versions/$_termKey/Students'] = _realTime;
    return _database11.update(updates).then((_) {
      _databaseVersionss.set('Okullar/$_kurumId/$_termKey/$existingKey/${VersionListEnum.userInfoChangeService}', _realTime);
    });
  }

  static Future<void> makeBundle() async {
    if (!AppVar.appBloc.hesapBilgileri.gtM) return;
    return () {
      AppVar.appBloc.studentService?.makeBundle();
    }.delay(1500);
  }
}
