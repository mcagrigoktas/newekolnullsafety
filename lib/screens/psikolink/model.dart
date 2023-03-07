// import '../../appbloc/appvar.dart';
// import '../../helpers/appfunctions.dart';

// class PikolinkHelper {
//   PikolinkHelper._();
//   static Map<String, dynamic> getPsikolinkUserModelFromEcollUserModel() {
//     return PsikoLinkUserModel(
//       displayName: AppVar.appBloc.hesapBilgileri.name,
//       email: AppVar.appBloc.hesapBilgileri.kurumID + '_' + AppVar.appBloc.hesapBilgileri.uid + "@psikolink.com",
//       schoolKey: "ecoll" + AppVar.appBloc.hesapBilgileri.kurumID,
//       // todo schoolKey 'ecoll' ile başlamalı
//       key: "ecoll" + AppVar.appBloc.hesapBilgileri.kurumID + '_' + AppVar.appBloc.hesapBilgileri.uid,
//       createdAt: 1629724649205,
//       updatedAt: 1629724649205,
//     ).toMap();
//   }

//   static Map<String, dynamic> getPsikolinkSchoolModelFromEcollSchoolModel() {
//     return PsikolinkSchoolModel(
//       name: AppVar.appBloc.schoolInfoService.singleData.name,
//       key: "ecoll" + AppVar.appBloc.hesapBilgileri.kurumID,
//       authCategories: authCategories.keys.toList(),
//       eduLevel: AppVar.appBloc.hesapBilgileri.isEkid ? 'ana' : 'lise',
//       createdAt: 1629724649205,
//       updatedAt: 1629724649205,
//     ).toMap();
//   }

//   static final Map<String, String> eduLevel = {
//     "ana": "eduLevel.anaokulu",
//     "ilk": "eduLevel.ilk",
//     "orta": "eduLevel.orta",
//     "lise": "eduLevel.lise",
//   };
//   static final Map<String, String> authCategories = {
//     "supervizyon": "authCategories.supervizyon",
//     "test": "authCategories.test",
//     ...libCategories,
//   };

//   static final Map<String, String> libCategories = {
//     "bulten": "libCategories.bulten",
//     "sesliBulten": "Sesli Bültenler",
//     "afis": "libCategories.afis",
//     "sunum": "libCategories.sunum",
//     "pano": "libCategories.pano",
//     "grupRehberligi": "libCategories.grupRehberligi",
//     "video": "libCategories.video",
//   };

//   static List getStudentListForPsikolink() {
//     return AppFunctions2.getStudentListForTeacherAndManager().map((student) => PsikolinkStudentModel(no: student.no, sinifi: AppVar.appBloc.classService.dataListItem(student.class0)?.name ?? '-', subesi: '', name: student.name)).map((e) => e.toMap()).toList();
//   }
// }

// class PsikoLinkUserModel {
//   /// Kullancı Adı
//   String displayName;

//   /// Kullanıcı mail adresi
//   String email;

//   /// Okul id'si
//   String schoolKey;

//   /// Psikolink admini ise true tutar. Diğerlerinde false'tur.
//   bool isAdmin;

//   /// Kullanıcı okul yetkilisi ise true tutar.
//   bool isManager;

//   /// Kullanıcı öğretmen ise true tutar.
//   bool isTeacher;

//   /// Kullanıcı psikolog ise true tutar.
//   bool isPsychologist;

//   bool isDeleted;
//   String key;
//   int createdAt;
//   int updatedAt;

//   PsikoLinkUserModel({
//     this.displayName,
//     this.email,
//     this.schoolKey,
//     this.isAdmin = false,
//     this.isManager = false,
//     this.isTeacher = true,
//     this.isPsychologist = false,
//     this.isDeleted = false,
//     this.key,
//     this.createdAt,
//     this.updatedAt,
//   });

//   get isAdminOrManager => isAdmin || isManager;

//   get isTeacherOrManager => isTeacher || isManager;

//   Map<String, dynamic> toMap() {
//     return {
//       'displayName': displayName,
//       'email': email,
//       'schoolKey': schoolKey,
//       'isAdmin': isAdmin,
//       'isManager': isManager,
//       'isPsychologist': isPsychologist,
//       'isTeacher': isTeacher,
//       'isDeleted': isDeleted,
//       'key': key,
//       'createdAt': createdAt,
//       'updatedAt': updatedAt,
//     };
//   }

//   factory PsikoLinkUserModel.fromMap(Map map) {
//     return PsikoLinkUserModel(
//       displayName: map['displayName'] as String,
//       email: map['email'] as String,
//       schoolKey: map['schoolKey'] as String,
//       isAdmin: map['isAdmin'] ?? false,
//       isManager: map['isManager'] ?? false,
//       isTeacher: map['isTeacher'] ?? true,
//       isPsychologist: map['isPsychologist'] ?? false,
//       isDeleted: map['isDeleted'] ?? false,
//       key: map['key'] as String,
//       createdAt: map['createdAt'] as int,
//       updatedAt: map['updatedAt'] as int,
//     );
//   }
// }

// class PsikolinkSchoolModel {
//   /// Okul Adını tutar
//   String name;

//   /// Okul seviyesi, anaokulu, ilkokul...
//   /// utils/list_helper/eduLevel içindeki listeki key değer tutar.
//   /// ör: anaokulu için ana
//   String eduLevel;

//   /// Okul aboneliklerini tutar: bülten, afiş...
//   /// utils/list_helper/authCategories içindeki keylerden oluşan bir liste tutar.
//   /// Ör: Eğer okulun bülten aboneleği varsa [bulten] tutar.
//   List<String> authCategories;

//   bool isDeleted;
//   String key;
//   int createdAt;
//   int updatedAt;

//   PsikolinkSchoolModel({
//     this.name,
//     this.eduLevel,
//     this.isDeleted = false,
//     this.authCategories = const <String>[],
//     this.key,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory PsikolinkSchoolModel.fromMap(Map map) {
//     return PsikolinkSchoolModel(
//       name: map['name'] as String,
//       eduLevel: map['eduLevel'] ?? "orta",
//       isDeleted: map['isDeleted'] ?? false,
//       authCategories: List.from((map['authCategories'] as List).map((e) => e.toString())),
//       key: map['key'] as String,
//       createdAt: map['createdAt'] as int,
//       updatedAt: map['updatedAt'] as int,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     // ignore: unnecessary_cast
//     return {
//       'name': name,
//       'eduLevel': eduLevel,
//       'isDeleted': isDeleted,
//       'authCategories': authCategories,
//       'key': key,
//       'createdAt': createdAt,
//       'updatedAt': updatedAt,
//     } as Map<String, dynamic>;
//   }

//   Map<String, dynamic> toMapAuthCategories() {
//     // ignore: unnecessary_cast
//     return {
//       'authCategories': authCategories,
//       'updatedAt': updatedAt,
//     } as Map<String, dynamic>;
//   }
// }

// class PsikolinkStudentModel {
//   String no;
//   String sinifi;
//   String subesi;
//   String name;

//   PsikolinkStudentModel({
//     this.no = "",
//     this.sinifi = "",
//     this.subesi = "",
//     this.name,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'no': no,
//       'sinifi': sinifi,
//       'subesi': subesi,
//       'name': name,
//     };
//   }

//   factory PsikolinkStudentModel.fromMap(Map<String, dynamic> map) {
//     return PsikolinkStudentModel(
//       no: map['no'] as String,
//       sinifi: map['sinifi'] as String,
//       subesi: map['subesi'] as String,
//       name: map['name'] as String,
//     );
//   }

//   String get sinifiVeSubesi => sinifi + "-" + subesi;
// }
