import 'package:hive/hive.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:turkish/turkish.dart';

import '../adminpages/screens/evaulationadmin/exams/model.dart';
import '../adminpages/screens/evaulationadmin/examtypes/model.dart';
import '../adminpages/screens/evaulationadmin/opticformtypes/model.dart';
import '../flavors/mainhelper.dart';
import '../screens/managerscreens/registrymenu/personslist/model.dart';
import '../services/dataservice.dart';
import 'appvar.dart';

//? Basinda bu isaret olanlara bakarak yeni fetcher ekleyeceginde ekleme yapman gerekenleri gorebilirsin
enum MiniFetcherKeys {
  allSchoolExams,
  allGlobalExams,
  allExamType,
  schoolExamTypes,
  allOpticformType,
  schoolOpticformTypes,

  //* Okul hesabindaki idareci icin person listesini tutmak icin
  schoolPersons
}

class MiniFetchers {
  MiniFetchers._();

  static MiniFetcher getFetcher(MiniFetcherKeys miniFetcherKey) {
    if (Get.isRegistered<MiniFetcher>(tag: _boxKey(miniFetcherKey))) return Get.find<MiniFetcher>(tag: _boxKey(miniFetcherKey));
    return _registerMiniFetcher(miniFetcherKey);
  }

  static Future<void> unregisterAllFetcher() async {
    for (var fetcher in MiniFetcherKeys.values) {
      if (Get.isRegistered<MiniFetcher>(tag: _boxKey(fetcher))) {
        await Get.find<MiniFetcher>(tag: _boxKey(fetcher)).dispose();
        await Get.delete<MiniFetcher>(tag: _boxKey(fetcher), force: true);
      }
    }
  }

  static Future<bool> clearDataAllFetcher() async {
    for (var fetcherkey in MiniFetcherKeys.values) {
      Box box = await Get.openSafeBox(_boxKey(fetcherkey) + AppConst.miniFetcherBoxVersion.toString());
      await box.clear();
    }
    return true;
  }

//?
  static MiniFetcher _registerMiniFetcher(MiniFetcherKeys miniFetcherKeys) {
    if (miniFetcherKeys == MiniFetcherKeys.allExamType) return _registerAllExamType(miniFetcherKeys);
    if (miniFetcherKeys == MiniFetcherKeys.schoolExamTypes) return _registerSchoollExamTypes(miniFetcherKeys);
    if (miniFetcherKeys == MiniFetcherKeys.allOpticformType) return _registerallOpticformType(miniFetcherKeys);
    if (miniFetcherKeys == MiniFetcherKeys.schoolOpticformTypes) return _registerSchoolOpticformType(miniFetcherKeys);
    if (miniFetcherKeys == MiniFetcherKeys.allSchoolExams) return _registerAllSchoolExams(miniFetcherKeys);
    if (miniFetcherKeys == MiniFetcherKeys.allGlobalExams) return _registerAllGlobalExams(miniFetcherKeys);
    if (miniFetcherKeys == MiniFetcherKeys.schoolPersons) return _registerSchoolPerson(miniFetcherKeys);

    throw ('Boyle bir fetcher yok');
    //  return null;
  }

//?
  static String _boxKey(MiniFetcherKeys miniFetcherKeys) {
    Map boxKeyList = {
      MiniFetcherKeys.allExamType: 'allEkolExamType',
      MiniFetcherKeys.allOpticformType: 'allEkolOpticformType',
      MiniFetcherKeys.allGlobalExams: 'allEkolExams',
      MiniFetcherKeys.allSchoolExams: '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}allExams',
      MiniFetcherKeys.schoolExamTypes: '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}examTypes',
      MiniFetcherKeys.schoolOpticformTypes: '${AppVar.appBloc.hesapBilgileri.kurumID}${AppVar.appBloc.hesapBilgileri.termKey}opticFormTypes',
      MiniFetcherKeys.schoolPersons: '${AppVar.appBloc.hesapBilgileri.kurumID}personList',
    };
    return boxKeyList[miniFetcherKeys];
  }

  static MiniFetcher _registerAllExamType(MiniFetcherKeys miniFetcherKey) {
    Get.put<MiniFetcher>(
        MiniFetcher<ExamType>(
          _boxKey(miniFetcherKey),
          FetchType.LISTEN,
          multipleData: true,
          jsonParse: (key, value) => ExamType.fromJson(value, key),
          lastUpdateKey: 'lastUpdate',
          sortFunction: (ExamType i1, ExamType i2) => i2.name!.compareTo(i1.name!),
          removeFunction: (a) => a.name == null,
          queryRef: ExamService.dbGetAllExamType(),
          filterDeletedData: true,
        ),
        tag: _boxKey(miniFetcherKey),
        permanent: true);
    return Get.find<MiniFetcher>(tag: _boxKey(miniFetcherKey));
  }

  static MiniFetcher _registerSchoollExamTypes(MiniFetcherKeys miniFetcherKey) {
    Get.put<MiniFetcher>(
        MiniFetcher<ExamType>(
          _boxKey(miniFetcherKey),
          FetchType.LISTEN,
          multipleData: true,
          jsonParse: (key, value) => ExamType.fromJson(value, key),
          lastUpdateKey: 'lastUpdate',
          sortFunction: (ExamType i1, ExamType i2) => i2.name!.compareTo(i1.name!),
          removeFunction: (a) => a.name == null,
          queryRef: ExamService.dbGetSchoolExamTypes(),
          filterDeletedData: true,
        ),
        tag: _boxKey(miniFetcherKey),
        permanent: true);
    return Get.find<MiniFetcher>(tag: _boxKey(miniFetcherKey));
  }

  static MiniFetcher _registerallOpticformType(MiniFetcherKeys miniFetcherKey) {
    Get.put<MiniFetcher>(
        MiniFetcher<OpticFormModel>(
          _boxKey(miniFetcherKey),
          FetchType.LISTEN,
          multipleData: true,
          jsonParse: (key, value) => OpticFormModel.fromJson(value),
          lastUpdateKey: 'lastUpdate',
          sortFunction: (OpticFormModel i1, OpticFormModel i2) => i2.name!.compareTo(i1.name!),
          removeFunction: (a) => a.name == null,
          queryRef: ExamService.dbGetAdminOpticFormType(),
          filterDeletedData: true,
        ),
        tag: _boxKey(miniFetcherKey),
        permanent: true);
    return Get.find<MiniFetcher>(tag: _boxKey(miniFetcherKey));
  }

  static MiniFetcher _registerSchoolOpticformType(MiniFetcherKeys miniFetcherKey) {
    Get.put<MiniFetcher>(
        MiniFetcher<OpticFormModel>(
          _boxKey(miniFetcherKey),
          FetchType.LISTEN,
          multipleData: true,
          jsonParse: (key, value) => OpticFormModel.fromJson(value),
          lastUpdateKey: 'lastUpdate',
          sortFunction: (OpticFormModel i1, OpticFormModel i2) => i2.name!.compareTo(i1.name!),
          removeFunction: (a) => a.name == null,
          queryRef: ExamService.dbGetSchoollOpticFormType(),
          filterDeletedData: true,
        ),
        tag: _boxKey(miniFetcherKey),
        permanent: true);
    return Get.find<MiniFetcher>(tag: _boxKey(miniFetcherKey));
  }

  static MiniFetcher _registerAllSchoolExams(MiniFetcherKeys miniFetcherKey) {
    Get.put<MiniFetcher>(
        MiniFetcher<Exam>(
          _boxKey(miniFetcherKey),
          FetchType.LISTEN,
          multipleData: true,
          jsonParse: (key, value) => Exam.fromJson(value, key),
          lastUpdateKey: 'lastUpdate',
          sortFunction: (Exam i1, Exam i2) => i2.lastUpdate.compareTo(i1.lastUpdate),
          removeFunction: (a) => a.name == null || a.userType == null || a.savedBy == null || a.kurumIdList == null,
          queryRef: ExamService.dbGetSchoolExams(),
          filterDeletedData: true,
        ),
        tag: _boxKey(miniFetcherKey),
        permanent: true);
    return Get.find<MiniFetcher>(tag: _boxKey(miniFetcherKey));
  }

  static MiniFetcher _registerAllGlobalExams(MiniFetcherKeys miniFetcherKey) {
    Get.put<MiniFetcher>(
        MiniFetcher<Exam>(_boxKey(miniFetcherKey), FetchType.LISTEN,
            multipleData: true,
            jsonParse: (key, value) => Exam.fromJson(value, key),
            lastUpdateKey: 'lastUpdate',
            sortFunction: (Exam i1, Exam i2) => i2.name!.compareTo(i1.name!),
            removeFunction: (a) => a.name == null || a.userType == null || a.savedBy == null || a.kurumIdList == null,
            queryRef: ExamService.dbGetGlobalExams(),
            filterDeletedData: true,
            minLastUpdateTime: DateTime.now().subtract(Duration(days: 365)).millisecondsSinceEpoch),
        tag: _boxKey(miniFetcherKey),
        permanent: true);
    return Get.find<MiniFetcher>(tag: _boxKey(miniFetcherKey));
  }

  static MiniFetcher _registerSchoolPerson(MiniFetcherKeys miniFetcherKey) {
    Get.put<MiniFetcher>(
        MiniFetcher<Person>(
          _boxKey(miniFetcherKey),
          FetchType.LISTEN,
          multipleData: true,
          jsonParse: (key, value) => Person.fromJson(value, key),
          lastUpdateKey: 'lastUpdate',
          sortFunction: (Person a, Person b) {
            return 'lang'.translate == 'tr' ? turkish.comparator(a.name!.toLowerCase(), b.name!.toLowerCase()) : (a.name!.toLowerCase()).compareTo(b.name!.toLowerCase());

            // return i2.name.compareTo(i1.name);
          },
          removeFunction: (a) => a.name == null,
          queryRef: PersonService.dbGetPersonLists(),
          filterDeletedData: true,
        ),
        tag: _boxKey(miniFetcherKey),
        permanent: true);
    return Get.find<MiniFetcher>(tag: _boxKey(miniFetcherKey));
  }
}
