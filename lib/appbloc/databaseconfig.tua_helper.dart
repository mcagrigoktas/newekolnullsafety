import 'package:mcg_extension/mcg_extension.dart';

import 'databaseconfig.model_helper.dart';

class DatabaseTuaHelper {
  DatabaseTuaHelper._();
  static DataBaseConfigModel getConfig() {
    return DataBaseConfigModel(
      //?Real time database
      rtdb1: 'https://tuaacademy-33045-default-rtdb.asia-southeast1.firebasedatabase.app',
      rtdb2: 'https://tua2.asia-southeast1.firebasedatabase.app',
      rtdb3: 'https://tua3.asia-southeast1.firebasedatabase.app',
      rtdbAccounting: 'https://tuaaccounting.asia-southeast1.firebasedatabase.app',
      rtdbLessonProgram: 'https://tualessonprogram.asia-southeast1.firebasedatabase.app',
      rtdbLogs: 'https://tualogs.asia-southeast1.firebasedatabase.app',
      rtdbVersions: 'https://tuaversions.asia-southeast1.firebasedatabase.app',
      rtdbSB: 'https://tuasb.asia-southeast1.firebasedatabase.app/',

      //? Storage
      storageMainBucket: 'gs://tuaacademy-33045.appspot.com',
      questionBankBucket: 'gs://tuaacademy-sb',
      questionBankUrlPrefix: 'https://firebasestorage.googleapis.com/v0/b/tuaacademy-33045.appspot.com/o',
      firebaseStorageUrlPrefix: null,

      //? Auth
      privateKey: null,
      serviceAccountEmail: null,

      //? Noification
      vapidKey: null,

      //? Question Bank
      draftBooksUrl: "https://elseifsorubankasi.firebaseio.com",

      //? MutluCell Config
      mutluCellUsername: null,
      mutluCellPassword: null,
      mutluCellOriginator: null,

      //?Superadmin
      superAdminUserName: 'alcm1HPueamngi.o3o3sprdi@m'.unMix,
      superAdminPassword: 'Z7Yta15e6Au22'.unMix,
      superUserModels: [
        SuperUserInfo(username: 'mshptacdyegPuaae'.unMix, password: '227Yatacdm15F13uaaey'.unMix, saver: Saver.elseif, authorityList: [
          SuperUserAuthority.developer,
        ]),
      ],
    );
  }
}
