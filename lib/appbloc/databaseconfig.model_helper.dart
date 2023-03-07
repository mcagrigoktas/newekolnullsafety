import 'package:mcg_extension/mcg_extension.dart';

class DataBaseConfigModel {
  //? RealTimeDatabaseConfigs
  final String? rtdb1;
  final String? rtdb2;
  final String? rtdb3;
  final String? rtdbAccounting;
  final String? rtdbLessonProgram;
  final String? rtdbLogs;
  final String? rtdbVersions;
  final String? rtdbSB;

  //? Storage
  final String? storageMainBucket;
  final String? firebaseStorageUrlPrefix;
  final String? questionBankBucket;
  final String? questionBankUrlPrefix;

  //? Auth
  final String? privateKey;
  final String? serviceAccountEmail;

  //? Notification
  final String? vapidKey;

  //? QuestionBank
  final String? draftBooksUrl;

  //? Mutlucell
  final String? mutluCellUsername;
  final String? mutluCellPassword;
  final String? mutluCellOriginator;

  //? SuperUsers
  final List<SuperUserInfo>? superUserModels;
  final String? superAdminUserName;
  final String? superAdminPassword;

  //? DemoInfo
  final Map<String, Map<String, Map<String, String>>>? demoInfo;

  DataBaseConfigModel({
    this.rtdb1,
    this.rtdb2,
    this.rtdb3,
    this.rtdbAccounting,
    this.rtdbLessonProgram,
    this.rtdbLogs,
    this.rtdbSB,
    this.rtdbVersions,
    this.storageMainBucket,
    this.questionBankBucket,
    this.questionBankUrlPrefix,
    this.firebaseStorageUrlPrefix,
    this.privateKey,
    this.serviceAccountEmail,
    this.vapidKey,
    this.draftBooksUrl,
    this.mutluCellOriginator,
    this.mutluCellPassword,
    this.mutluCellUsername,
    this.superUserModels,
    this.superAdminUserName,
    this.superAdminPassword,
    this.demoInfo,
  });
}

class SuperUserInfo {
  final String? username;
  final String? password;
  final Saver saver;
  final List<SuperUserAuthority> authorityList;

  const SuperUserInfo({required this.username, required this.password, required this.saver, this.authorityList = const []});

  bool get isDeveloper => authorityList.contains(SuperUserAuthority.developer);

  bool get hasRegisterChool => isDeveloper || authorityList.contains(SuperUserAuthority.registerSchool);
  bool get hasSuperManagerRegister => isDeveloper || authorityList.contains(SuperUserAuthority.superManagerRegister);
  bool get hasChangeSchoolInfo => isDeveloper || authorityList.contains(SuperUserAuthority.changeSchoolInfo);
  bool get hasAddEvaulationData => isDeveloper || authorityList.contains(SuperUserAuthority.addEvaulationData);
  bool get hasChangeLogPost => isDeveloper || authorityList.contains(SuperUserAuthority.changeLogPost);
}

enum SuperUserAuthority {
  developer,
  registerSchool,
  changeSchoolInfo,
  superManagerRegister,
  addEvaulationData,
  changeLogPost,
}

@Note('Eklenen birsey degistirilemez')
enum Saver {
  elseif,
  smat,
  usa,
  germany,
  spain,
  france,
}
