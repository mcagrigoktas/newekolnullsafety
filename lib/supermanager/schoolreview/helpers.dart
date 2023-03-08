import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:turkish/turkish.dart';

import '../../appbloc/appvar.dart';
import '../../models/allmodel.dart';

class SuperManagerHelpers {
  SuperManagerHelpers._();

  static Future<Map?> getSchoolInfoMap(String? kurumId) async {
    Map? schoolInfoMap = Fav.readSeasonCache('${kurumId}SchoolInfo');
    if (schoolInfoMap == null) {
      schoolInfoMap = (await AppVar.appBloc.database1.once('Okullar/$kurumId/SchoolData/Info'))?.value;
      Fav.writeSeasonCache('${kurumId}SchoolInfo', schoolInfoMap);
    }
    return schoolInfoMap;
  }
}

class SuperManagerMiniFetchers {
  SuperManagerMiniFetchers._();

  static MiniFetcher<Manager> managerMiniFetchers(String? kurumId, {Function(Map)? getValueAfter, Function(Map)? getValueAfterOnlyDatabaseQuery}) {
    return MiniFetcher<Manager>('${kurumId}Managers', FetchType.ONCE,
        multipleData: true,
        queryRef: Reference(AppVar.appBloc.database1, 'Okullar/$kurumId/Managers'),
        jsonParse: (key, value) => Manager.fromJson(value, key),
        removeFunction: (a) => a.name == null,
        sortFunction: (Manager a, Manager b) {
          return turkish.comparator(a.name!.toLowerCase(), b.name!.toLowerCase());
        },
        lastUpdateKey: 'lastUpdate',
        filterDeletedData: true,
        getValueAfterOnlyDatabaseQuery: getValueAfterOnlyDatabaseQuery,
        getValueAfter: getValueAfter);
  }

  static MiniFetcher<Teacher> teacherMiniFetchers(String? kurumId, String? termKey, {Function(Map)? getValueAfter, Function(Map)? getValueAfterOnlyDatabaseQuery}) {
    return MiniFetcher<Teacher>("$kurumId${termKey}Teachers", FetchType.ONCE,
        queryRef: Reference(AppVar.appBloc.database1, 'Okullar/$kurumId/$termKey/Teachers'),
        jsonParse: (key, value) => Teacher.fromJson(value, key),
        removeFunction: (a) => !a.isReliable,
        sortFunction: (Teacher a, Teacher b) {
          return turkish.comparator(a.name.toLowerCase(), b.name.toLowerCase());
        },
        multipleData: true,
        lastUpdateKey: 'lastUpdate',
        filterDeletedData: true,
        getValueAfterOnlyDatabaseQuery: getValueAfterOnlyDatabaseQuery,
        getValueAfter: getValueAfter);
  }

  static MiniFetcher<Student> studentMiniFetchers(String? kurumId, String? termKey, {Function(Map)? getValueAfter, Function(Map)? getValueAfterOnlyDatabaseQuery}) {
    return MiniFetcher<Student>("$kurumId${termKey}Students", FetchType.ONCE,
        queryRef: Reference(AppVar.appBloc.database1, 'Okullar/$kurumId/$termKey/Students'),
        jsonParse: (key, value) => Student.fromJson(value, key),
        removeFunction: (a) => !a.isReliable,
        sortFunction: (Student a, Student b) {
          return turkish.comparator(a.name.toLowerCase(), b.name.toLowerCase());
        },
        multipleData: true,
        lastUpdateKey: 'lastUpdate',
        filterDeletedData: true,
        getValueAfterOnlyDatabaseQuery: getValueAfterOnlyDatabaseQuery,
        getValueAfter: getValueAfter);
  }

  static MiniFetcher<Class> classMiniFetchers(String? kurumId, String? termKey, {Function(Map)? getValueAfter, Function(Map)? getValueAfterOnlyDatabaseQuery}) {
    return MiniFetcher<Class>("$kurumId${termKey}Classes", FetchType.ONCE,
        queryRef: Reference(AppVar.appBloc.database1, 'Okullar/$kurumId/$termKey/Classes'),
        jsonParse: (key, value) => Class.fromJson(value, key),
        removeFunction: (a) => a.name == null,
        sortFunction: (Class a, Class b) {
          return turkish.comparator(a.name!.toLowerCase(), b.name!.toLowerCase());
        },
        multipleData: true,
        lastUpdateKey: 'lastUpdate',
        filterDeletedData: true,
        getValueAfterOnlyDatabaseQuery: getValueAfterOnlyDatabaseQuery,
        getValueAfter: getValueAfter);
  }

  static MiniFetcher<Lesson> lessonMiniFetchers(String? kurumId, String termKey, {Function(Map)? getValueAfter, Function(Map)? getValueAfterOnlyDatabaseQuery}) {
    return MiniFetcher<Lesson>("$kurumId${termKey}Lessons", FetchType.ONCE,
        queryRef: Reference(AppVar.appBloc.database1, 'Okullar/$kurumId/$termKey/Lessons'),
        jsonParse: (key, value) => Lesson.fromJson(value, key),
        removeFunction: (a) => a.name == null,
        sortFunction: (Lesson a, Lesson b) {
          return turkish.comparator(a.name!.toLowerCase(), b.name!.toLowerCase());
        },
        multipleData: true,
        lastUpdateKey: 'lastUpdate',
        filterDeletedData: true,
        getValueAfterOnlyDatabaseQuery: getValueAfterOnlyDatabaseQuery,
        getValueAfter: getValueAfter);
  }
}
