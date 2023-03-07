import '../../appbloc/appvar.dart';
import '../../models/allmodel.dart';

class SocialFunctions {
  List<String> targetListToContactList({List<String>? targetList, String? senderKey, allManagers = true, allTeachers = true}) {
    List<String> contactList = [];

    //Ogrenciler ekleniyor
    contactList = AppVar.appBloc.studentService!.dataList.where((student) {
      if (targetList!.contains("alluser")) {
        return true;
      }
      if (targetList.any((item) => [...student.classKeyList, student.key].contains(item))) {
        return true;
      }
      return false;
    }).map((student) {
      return student.key!;
    }).toList();

//idareciler ekleniyor
    AppVar.appBloc.managerService!.dataList.forEach((manager) {
      contactList.add(manager.key!);
    });
//herkesle paylasilmissa tum ogretmenler ekleniyor
    AppVar.appBloc.teacherService!.dataList.forEach((teacher) {
      if (targetList!.contains("alluser")) {
        contactList.add(teacher.key!);
      }
    });
// sinif ogretmenleri ekleniyor
    if (AppVar.appBloc.hesapBilgileri.isEkid) {
      List<Class> sinifListesi = AppVar.appBloc.classService!.dataList.where((sinif) => targetList!.contains(sinif.key)).toList();
      sinifListesi.forEach((sinif) {
        if (sinif.classTeacher != null && !contactList.contains(sinif.classTeacher)) {
          contactList.add(sinif.classTeacher!);
        }
        if (sinif.classTeacher2 != null && !contactList.contains(sinif.classTeacher2)) {
          contactList.add(sinif.classTeacher2!);
        }
      });
    }

    //Gonderen kisi ekleniyor
    if (!contactList.contains(senderKey)) {
      contactList.add(senderKey!);
    }

    return contactList;
  }
}
