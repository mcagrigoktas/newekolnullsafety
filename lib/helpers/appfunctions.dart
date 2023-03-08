import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../appbloc/appvar.dart';
import '../assets.dart';
import '../models/allmodel.dart';
import '../screens/managerscreens/othersettings/user_permission/user_permission.dart';

class StudentFunctions {
  StudentFunctions._();

  /// Ogrencinin ilgili oldugu tum siniflari getirir
  static List<Class> getClassList() => AppVar.appBloc.classService!.dataList.where((sinif) => AppVar.appBloc.hesapBilgileri.classKeyList.contains(sinif.key)).toList();

  ///Ogrencinin ilgili oldugu tum dersleri getirir
  static List<Lesson> getLessonList() => AppVar.appBloc.lessonService!.dataList.where((lesson) => getClassList().map((sinif) => sinif.key).contains(lesson.classKey)).toList();

//Ogrencinin gorebilelcegi tum ogretmen  listesi
  static List<String> listOfTeachersTheStudentCanSee() {
    final teacherKeyList = <String?>{};

    //Butun herkesi gorebilen ogretmenler
    AppVar.appBloc.teacherService!.dataList.forEach((teacher) {
      if (teacher.seeAllClass!) teacherKeyList.add(teacher.key);
    });
    //Dersine girdigi ogretmenler
    AppVar.appBloc.lessonService!.dataList.forEach((lesson) {
      if (AppVar.appBloc.hesapBilgileri.classKeyList.contains(lesson.classKey)) teacherKeyList.add(lesson.teacher);
    });
//Sinif ogretmenliklerine bakar
    AppVar.appBloc.classService!.dataList.where((sinif) => AppVar.appBloc.hesapBilgileri.classKeyList.contains(sinif.key)).forEach((sinif) {
      teacherKeyList.add(sinif.classTeacher);
      teacherKeyList.add(sinif.classTeacher2);
    });

    teacherKeyList.removeWhere((element) => element.safeLength < 1);
    return List<String>.from(teacherKeyList.toList());
  }

  //Ogrencinin rehber ogretmeni listesi
  static List<String> getGuidanceTecherList() {
    final teacherKeyList = <String?>{};

    AppVar.appBloc.classService!.dataList.where((sinif) => AppVar.appBloc.hesapBilgileri.classKeyList.contains(sinif.key)).forEach((sinif) {
      teacherKeyList.add(sinif.classTeacher);
      teacherKeyList.add(sinif.classTeacher2);
    });

    teacherKeyList.removeWhere((element) => element.safeLength < 1);
    return List<String>.from(teacherKeyList.toList());
  }
}

class TeacherFunctions {
  TeacherFunctions._();
  // Ogretmenin dersine girdigi sinfi listesi
  static List<Lesson> getLessonList() => AppVar.appBloc.lessonService!.dataList.where((lesson) => lesson.teacher == AppVar.appBloc.hesapBilgileri.uid).toList();

  //Ogretmenin rehber oldgu sinif listesi
  static List<Class> getGuidanceClassList() => AppVar.appBloc.classService!.dataList.where((sinif) => sinif.classTeacher == AppVar.appBloc.hesapBilgileri.uid).toList();

  /// Herhangi bir ogretmenin gorebilecegi sinif listesini gonderir.
  /// Ekid icin Ogretmen1 ve Ogretmen 2 si oldugu sinif yada o sinifa ait herhangi bir dersin ogretmeni oldugu sinifi gonderir
  /// Ekol icin herhangi bir inifin rehber ogretmeni ise yada o sinifa ait herhangi bir dersin ogretmeni oldugu sinifi gonderir
  /// Hem ekid hem ekl icin ogretmen butun siifnlari gorebilsin secili olursa gosterir
  static List<String> getTeacherClassList() {
    //Ekid ile ekol arasinda su anlik pek bir fark yok gibi ama yinede ayri yazildi
    List<String> classList = [];

    //Ogretmeni oldugu siniflaria bakiliyor
    if (AppVar.appBloc.hesapBilgileri.isEkid) {
      AppVar.appBloc.classService!.dataList.forEach((sinif) {
        if (AppVar.appBloc.hesapBilgileri.teacherSeeAllClass == true) {
          classList.add(sinif.key!);
        } else if (sinif.classTeacher == AppVar.appBloc.hesapBilgileri.uid || sinif.classTeacher2 == AppVar.appBloc.hesapBilgileri.uid) {
          classList.add(sinif.key!);
        }
      });
      if (AppVar.appBloc.hesapBilgileri.teacherSeeAllClass == true) {
        return classList;
      }
      //Dersine girdigi siniflara bakiliyor
      AppVar.appBloc.lessonService!.dataList.forEach((lesson) {
        if (lesson.teacher == AppVar.appBloc.hesapBilgileri.uid && !classList.contains(lesson.classKey)) {
          classList.addIfNotNull(lesson.classKey);
        }
      });
    } else {
      //Ogretmeni oldugu siniflaria bakiliyor
      AppVar.appBloc.classService!.dataList.forEach((sinif) {
        if (AppVar.appBloc.hesapBilgileri.teacherSeeAllClass == true) {
          classList.add(sinif.key!);
        } else if (sinif.classTeacher == AppVar.appBloc.hesapBilgileri.uid || sinif.classTeacher2 == AppVar.appBloc.hesapBilgileri.uid) {
          classList.add(sinif.key!);
        }
      });
      if (AppVar.appBloc.hesapBilgileri.teacherSeeAllClass == true) {
        return classList;
      }
      //Dersine girdigi siniflara bakiliyor
      AppVar.appBloc.lessonService!.dataList.forEach((lesson) {
        if (lesson.teacher == AppVar.appBloc.hesapBilgileri.uid && !classList.contains(lesson.classKey)) {
          classList.addIfNotNull(lesson.classKey);
        }
      });
    }
    return classList;
  }

  ///Yukaridakinden tek farki sonucu Key olarak degil class olarak gondermesi
  /// Herhangi bir ogretmenin gorebilecegi sinif listesini gonderir.
  /// Ekid icin Ogretmen1 ve Ogretmen 2 si oldugu sinif yada o sinifa ait herhangi bir dersin ogretmeni oldugu sinifi gonderir
  /// Ekol icin herhangi bir inifin rehber ogretmeni ise yada o sinifa ait herhangi bir dersin ogretmeni oldugu sinifi gonderir
  /// Hem ekid hem ekl icin ogretmen butun siifnlari gorebilsin secili olursa gosterir
  static List<Class> getTeacherClassList2() {
    final classList = getTeacherClassList().map((e) => AppVar.appBloc.classService!.dataListItem(e)).toList();
    return List<Class>.from(classList..removeWhere((element) => element.toString() == 'null'));
  }

  ///Herhangi bir ogretmenin gorebilecegi tum ogrenci listesini gosterir. Butun ihtimalleri degerlendirir
  static List<Student> getAllStudentList() {
    if (AppVar.appBloc.hesapBilgileri.teacherSeeAllClass == true) return AppVar.appBloc.studentService!.dataList;
    List<String?> _teacherClassList = TeacherFunctions.getTeacherClassList();
    final _studentList = AppVar.appBloc.studentService!.dataList.where((student) {
      if (_teacherClassList.any((item) => student.classKeyList.contains(item))) return true;
      return false;
    }).toList();
    return _studentList;
  }
}

class ManagerFunctions {
  ManagerFunctions._();
}

class AppFunctions2 {
  AppFunctions2._();

  /// Herhangi bir ogretmen yada idarecinin gorebilecegi ogrenci listesini dondurur
  static List<Student> getStudentListForTeacherAndManager() {
    if (AppVar.appBloc.hesapBilgileri.gtM) return AppVar.appBloc.studentService!.dataList;
    if (AppVar.appBloc.hesapBilgileri.gtT) return TeacherFunctions.getAllStudentList();
    return [];
  }

  //Herhangi bir keyin fotografini bulur
  static String? whatIsProfileImgUrl(String? key, {bool exceptStudent = false, bool onlyStudent = false}) {
    String? imgUrl;
    if (key == AppVar.appBloc.hesapBilgileri.uid) return AppVar.appBloc.hesapBilgileri.imgUrl;

    if (!exceptStudent) {
      imgUrl = AppVar.appBloc.studentService?.dataListItem(key!)?.imgUrl;
      if (imgUrl != null) return imgUrl;
    }
    if (!onlyStudent) {
      imgUrl = AppVar.appBloc.managerService?.dataListItem(key!)?.imgUrl;
      if (imgUrl != null) return imgUrl;

      imgUrl = AppVar.appBloc.teacherService?.dataListItem(key!)?.imgUrl;
      if (imgUrl != null) return imgUrl;
    }

    return null;
  }

  //Herhangi bir keyin ismini bulur
  static String? whatIsThisName(String? key, {bool exceptStudent = false, bool onlyStudent = false}) {
    String? name;
    if (!exceptStudent) {
      name = AppVar.appBloc.studentService?.dataListItem(key!)?.name;
      if (name != null) return name;
    }
    if (!onlyStudent) {
      name = AppVar.appBloc.managerService?.dataListItem(key!)?.name;
      if (name != null) return name;

      name = AppVar.appBloc.teacherService?.dataListItem(key!)?.name;
      if (name != null) return name;
    }

    return null;
  }

  // Ogretmen ve velinin mesajlasmasi icin saatin uygun olup olmadigini kontrol eder.
  static bool isHourPermission() {
    if (AppVar.appBloc.hesapBilgileri.gtM) return true;

    DateTime lastTime = DateTime.fromMillisecondsSinceEpoch(AppVar.appBloc.realTime);
    final startTime = UserPermissionList.bannedClockStartTime();
    final endTime = UserPermissionList.bannedClockEndTime();

    if (lastTime.hour < startTime || endTime - 1 < lastTime.hour) {
      FocusScope.of(Get.context!).requestFocus(FocusNode());
      OverBottomSheet.show(
        BottomSheetPanel.child(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Assets.images.iconclockPNG,
                width: 64,
                height: 64,
              ),
              16.widthBox,
              Expanded(child: 'hourblockwarning'.argTranslate('$startTime:00-$endTime:00').text.center.color(Fav.design.primaryText).make()),
            ],
          ).p16,
        ),
      );

      return false;
    } else {
      return true;
    }
  }

//? Icerisinde sinif listesi kisi listesi alluser keyi bulunan key listesinden bunla ilgili kullanicilarin key listesini dondurur
  static List<String> targetListToUidList(List<String?> targetList, {bool allUserKeyMeanAllStudent = false}) {
    final List<String> _uidList = [];

    AppVar.appBloc.studentService!.dataList.forEach((student) {
      if (targetList.any((element) => <String?>['alluser', student.key, ...student.classKeyList].contains(element))) {
        _uidList.add(student.key);
      }
    });

    AppVar.appBloc.managerService!.dataList.forEach((manager) {
      if (targetList.any((element) => <String?>[
            if (allUserKeyMeanAllStudent == false) 'alluser',
            manager.key,
          ].contains(element))) {
        _uidList.add(manager.key!);
      }
    });
    AppVar.appBloc.teacherService!.dataList.forEach((teacher) {
      if (targetList.any((element) => <String?>[
            if (allUserKeyMeanAllStudent == false) 'alluser',
            teacher.key,
          ].contains(element))) {
        _uidList.add(teacher.key!);
      }
    });

    return _uidList;
  }

  static List<String> getStudenKeytListThisClass(String classKey) {
    return AppVar.appBloc.studentService!.dataList.where((element) => element.classKeyList.contains(classKey)).map((e) => e.key).toList();
  }
}

class AppFunctions {
  /// Herhangi bir ogretmenin rehberlik sinifini gonderir.
  /// Ekid icin Ogretmen1 ve Ogretmen 2 si oldugu sinif
  /// Ekol icin herhangi bir inifin rehber ogretmeni ise
  List<String> getGuidanceClassList() {
    //Ekid ile ekol arasinda su anlik pek bir fark yok gibi ama yinede ayri yazildi
    List<String> classList = [];

    //Ogretmeni oldugu siniflaria bakiliyor
    if (AppVar.appBloc.hesapBilgileri.isEkid) {
      AppVar.appBloc.classService!.dataList.forEach((sinif) {
        if (sinif.classTeacher == AppVar.appBloc.hesapBilgileri.uid || sinif.classTeacher2 == AppVar.appBloc.hesapBilgileri.uid) {
          classList.add(sinif.key!);
        }
      });
    } else {
      //Ogretmeni oldugu siniflaria bakiliyor
      AppVar.appBloc.classService!.dataList.forEach((sinif) {
        if (sinif.classTeacher == AppVar.appBloc.hesapBilgileri.uid || sinif.classTeacher2 == AppVar.appBloc.hesapBilgileri.uid) {
          classList.add(sinif.key!);
        }
      });
    }
    return classList;
  }

  /// Sadece ogrenci hesabina ait bir metot. Herhangi bir ogrenci ogretmeni gorebilirmi
  /// Ekid ile ekol arasinda bir fark yok
  bool isStudentVisibleTeacher(Teacher teacher) {
    if (teacher.seeAllClass == true) return true;

    //ogretmen dersine giriyor mu
    if (AppVar.appBloc.lessonService!.dataList.any((lesson) => lesson.teacher == teacher.key && AppVar.appBloc.hesapBilgileri.classKeyList.contains(lesson.classKey))) return true;

    //ogretmen sinif ogretmenimi
    if (whomStudentClassTeacher(AppVar.appBloc.hesapBilgileri.uid).contains(teacher.key)) return true;

    return false;
  }

//ogrencinin sinif ogretmeni kimler
  List<String> whomStudentClassTeacher(String studentKey) {
    if (AppVar.appBloc.hesapBilgileri.isEkolOrUni) {
      List<String?> classList;
      if (AppVar.appBloc.hesapBilgileri.gtS) {
        classList = AppVar.appBloc.hesapBilgileri.classKeyList;
      } else {
        Student? ogrenci = AppVar.appBloc.studentService!.dataListItem(studentKey);
        if (ogrenci == null) return [];
        classList = ogrenci.classKeyList;
      }
      if (classList.isEmpty) return [];

      return AppVar.appBloc.classService!.dataList.where((sinif) => classList.contains(sinif.key!)).map((sinif) => (sinif.classTeacher ?? '')).toList()..removeWhere((teacherKey) => teacherKey == '');
    } else if (AppVar.appBloc.hesapBilgileri.isEkid) {
      List<String> list = [];

      String sinifKey;

      if (AppVar.appBloc.hesapBilgileri.gtS) {
        sinifKey = (AppVar.appBloc.hesapBilgileri.class0 ?? "");
      } else {
        Student? student = AppVar.appBloc.studentService!.dataListItem(studentKey);
        if (student == null) return list;

        sinifKey = student.class0 ?? "";
      }

      if (sinifKey.length < 3) {
        return [];
      }
      Class? sinif = AppVar.appBloc.classService!.dataListItem(sinifKey);
      if (sinif == null) return [];

      list.addIfNotNull(sinif.classTeacher);
      list.addIfNotNull(sinif.classTeacher2);

      return list;
    }
    return [];
  }

  //Herhangi bir keyin silinmisler arasindada ismini bulur
  ///additionalItem Silinmis oldugu nasil belirtilsin isme ekler
  String? whatIsThisErasedItem(String key, {String additionalItem = ''}) {
    String? name;
    name = AppVar.appBloc.studentService?.dataListItem(key, lookDeletedData: true)?.name;
    if (name != null) return name + additionalItem;

    name = AppVar.appBloc.managerService?.dataListItem(key, lookDeletedData: true)?.name;
    if (name != null) return name + additionalItem;

    name = AppVar.appBloc.teacherService?.dataListItem(key, lookDeletedData: true)?.name;
    if (name != null) return name + additionalItem;

    return null;
  }

  //Herhangi bir keyin ismini bulur
  String? classKeyToName(String key) {
    return AppVar.appBloc.classService?.dataListItem(key)?.name;
  }
}
