import 'package:mcg_extension/mcg_extension.dart';

import 'databaseconfig.model_helper.dart';

class DatabaseEkolHelper {
  DatabaseEkolHelper._();
  static DataBaseConfigModel getConfig() {
    return DataBaseConfigModel(
        //?Real time database
        rtdb1: 'https://class-724.firebaseio.com',
        rtdb2: 'https://elseifekol2.firebaseio.com',
        rtdb3: 'https://elseifekol3.firebaseio.com',
        rtdbAccounting: 'https://elseifekolaccounting.firebaseio.com',
        rtdbLessonProgram: 'https://elseifekollessonprogram.firebaseio.com',
        rtdbLogs: 'https://elseifekollogs.firebaseio.com',
        rtdbVersions: 'https://elseifekolversions.firebaseio.com',
        rtdbSB: 'https://sbekol.firebaseio.com',

        //? Storage
        storageMainBucket: 'gs://class-724.appspot.com',
        questionBankBucket: 'gs://sorubankasi',
        questionBankUrlPrefix: 'https://firebasestorage.googleapis.com/v0/b/sorubankasi/o',
        firebaseStorageUrlPrefix: 'https://firebasestorage.googleapis.com/v0/b/class-724.appspot.com/o',

        //? Auth
        privateKey: "-----BEGIN PRIVATE KEY-----\n" +
            "wgkgAoBQ78fY7VFfZ5IEgBDNgqkGwBQFACKgSAEAIACjYAF37EdFMIvIAABkhi90AEASBg".unMix! +
            "\n" +
            "9vUt16remT+IuQXnQDZtBDGPeKH0lfVKD+I/Q3QfLWo1ex/2/SrJ0rk3VvfOMRPbD04t7J".unMix! +
            "\n" +
            "p2nVDyzk8b9HSYxL7XHpHp1L0ASIC8FX3ytYiuyYMB1C4eJYEBUuCVvM1MwBe+sNdv1jaS".unMix! +
            "\n" +
            "iwSC+8otqyrhzkYHjMTMx3Ym1pNv0uaM9VNd+YFYeZK75xmQaXgRauwgsTExmmiKSuZfeQ".unMix! +
            "\n" +
            "PGMw6WLql5St3Zf0gyeJ65UQFxfbz6bHGXRA7j0kSyYzu66gfHHp8N8OmLp0qZFw\nh1HNZNuP5WAAZ+spC9o7HLxhpUMdqcKIIC0YEVDd7TmW+WVDKKF/2ps4/302NEoT\n+hz4mMQjAgMBAAECggEAHFUBJ3Pcca/PKMXwcjbqgrQA6Rc/b4NsQ+xFcRdyrjmQ\nTdbqIKA05zuAW2h2srh3/0+xRlbTgHqMwv2wcWgZuVX2Yc4nqYA6Ju/8cZ3zYFet\nxGimIRmMGIc5K1D8DdwY3kYWf5tEdvSVmwzQsFhUEy2fQVCRYr4dEUBRsplxmW61\nJBX71yGDK13+xEcOXS9BB0oMiecKzRa45dv/ilCCOdwPiyrprum8XOb/lsZBpIr0\nZjiPpi2tIwnFYbCn/gOEYlxyZkqazeI76zndCm/FJZR1G9nrGwL5LdUwpz803RA3\nqK9EKdIrCjE2PeuZd9HATbAkMLQoNokpVS7iQTAtOQKBgQDuOsbVahK1XWGQnOs6\n4xxTDGTjNBkKQ0Ki+yz9p7JXgWQsFNqmG8T4hh/fr52U2eSIwads4KL7TtGGh+uB\nSmh+6kLfFwwtxKg6LfPWf+myksFxmCA8xZS8PWayQ6xJMsKsJWdvsjeTXOxv3wUk\ndpTTZJguFlOP/+RydHr+rmzSVQKBgQDJjXGDFVAqZV+JEqAtA/eLY3dyXICJuTXd\n4rygneSHwnFovQNnyZqyhP9auC9wgYT3HZCQRjO1Uiv5YgbM7Glg6cf12HCi2FYc\n/tR32wgzIkjmr0N1Z5wBSsV3DTpWZISCf3h92+G8AxHTpSrBO3LL8K7tV43G0Z01\nY54hNcHklwKBgQCktuz9aC7xSVSJCYY3HApcfYhP85iQmPq895Ae/dD4YdViCTU4\nfqDM+OeW4LTC03kI+WSKijMGMXP7YYT6yvi/L7f2yde42W07dMRQffaWapPnt7gq\nbK4vDQExpkq7/aXOIrqG5yE3+ZrcqsXCdV7nXnk9/F/gg5xvaowUBYPmVQKBgQCD\nzv9b9VU+1JrcvpSHu99ohbz4yiu5ZaknmX84Hun0KqIWF/4hIsQLWVTRlEBZ+Cnn\nnasL3w0z2DAv3/6Ih1cG7Pw697f5lzcBsVlrpI9BOXupeRbJsd9hLO/kQn9TPls2\nKHy4+lIurWc8HPjP87vISXdseeSbEDwaTTJ9j3VkswKBgGn6Pg/KMk0w/Pqb/IHY\nEW7K1VPwArcW41IrbePloTbHbwxdl6WD4Pcy1NSxC0vIqysNpDlmd6gNOzQ9cdxf\nthsOrZtRT4h7tZBb9eh0Er5p7G+kjqrUtsIj8rY9GO7b6TuAwcXdKFf5ZYURsKgh\ndJ+pMIXK54dvqGuBTjD3qcaG\n-----END PRIVATE KEY-----\n",
        serviceAccountEmail: "4imgevcacutcmNxMieaeamnd-wy@ls-2.a.sriecon.osCtfrbs-diskqsxcas7".unMix,

        //? Noification
        vapidKey: 'BLrmOIyrrMczZlbAXjCaqgY8q3rL641KSCK6KPi71qcqtGH9i1mKC99gjL779cAZv1z7Bc4rOYt6msMNSmWIukE',

        //? Question Bank
        draftBooksUrl: "https://elseifsorubankasi.firebaseio.com",

        //? MutluCell Config
        mutluCellUsername: 'smRCLodniiiCcPglebl'.unMix,
        mutluCellPassword: '499FMg80.zfFt048'.unMix,
        mutluCellOriginator: '79NAc05542FGS98053'.unMix,

        //? Super Users
        superUserModels: [
          ///elseif
          SuperUserInfo(username: 'HT2cgiopXar1'.unMix, password: 'oEH975LGS864'.unMix, saver: Saver.elseif, authorityList: [
            SuperUserAuthority.developer,
          ]),
          SuperUserInfo(username: 'Q3cbkr7d2Yei1'.unMix, password: 'kxk539HP3539'.unMix, saver: Saver.elseif, authorityList: [
            SuperUserAuthority.addEvaulationData,
            SuperUserAuthority.changeSchoolInfo,
            SuperUserAuthority.registerSchool,
            SuperUserAuthority.superManagerRegister,
          ]),
          SuperUserInfo(username: '4jNtguufRurl'.unMix, password: 'Mpk123LCX242'.unMix, saver: Saver.elseif, authorityList: [
            SuperUserAuthority.addEvaulationData,
            SuperUserAuthority.changeSchoolInfo,
            SuperUserAuthority.registerSchool,
            SuperUserAuthority.superManagerRegister,
          ]),
          SuperUserInfo(username: 'qLkkbaY66ur1'.unMix, password: 'C44k21ARZ1k2'.unMix, saver: Saver.elseif, authorityList: [
            SuperUserAuthority.addEvaulationData,
            SuperUserAuthority.changeSchoolInfo,
            SuperUserAuthority.registerSchool,
            SuperUserAuthority.superManagerRegister,
          ]),
          SuperUserInfo(username: 'WYTpkzpP4aie'.unMix, password: 'yur354S8S453'.unMix, saver: Saver.elseif, authorityList: [
            SuperUserAuthority.addEvaulationData,
            SuperUserAuthority.changeSchoolInfo,
            SuperUserAuthority.registerSchool,
            SuperUserAuthority.superManagerRegister,
            SuperUserAuthority.changeLogPost,
          ]),

          ///smat
          SuperUserInfo(username: 'aEg354F37433'.unMix, password: 'PCi132zoi231'.unMix, saver: Saver.smat, authorityList: [
            SuperUserAuthority.addEvaulationData,
            SuperUserAuthority.changeSchoolInfo,
            SuperUserAuthority.registerSchool,
            SuperUserAuthority.superManagerRegister,
          ]),
          SuperUserInfo(username: 'fP2464yis553'.unMix, password: 'P9d232FY9234'.unMix, saver: Saver.smat, authorityList: [
            SuperUserAuthority.addEvaulationData,
            SuperUserAuthority.superManagerRegister,
          ]),

          ///USA
          SuperUserInfo(username: 'ryX45wMfR1qe'.unMix, password: 'a2n108A1U999'.unMix, saver: Saver.usa, authorityList: [
            SuperUserAuthority.addEvaulationData,
            SuperUserAuthority.changeSchoolInfo,
            SuperUserAuthority.registerSchool,
            SuperUserAuthority.superManagerRegister,
          ]),

          ///Spain
          SuperUserInfo(username: 'wCig1471mga5'.unMix, password: 'FLB245cdN466'.unMix, saver: Saver.spain, authorityList: [
            SuperUserAuthority.addEvaulationData,
            SuperUserAuthority.changeSchoolInfo,
            SuperUserAuthority.registerSchool,
            SuperUserAuthority.superManagerRegister,
          ]),

          ///Germany
          SuperUserInfo(username: 'nCU71uq9q8yt'.unMix, password: 'UpE440QXm698'.unMix, saver: Saver.germany, authorityList: [
            SuperUserAuthority.addEvaulationData,
            SuperUserAuthority.changeSchoolInfo,
            SuperUserAuthority.registerSchool,
            SuperUserAuthority.superManagerRegister,
          ]),

          ///French
          SuperUserInfo(username: 'Fj1ee4ktGt58'.unMix, password: 'wpA692Cgy994'.unMix, saver: Saver.france, authorityList: [
            SuperUserAuthority.addEvaulationData,
            SuperUserAuthority.changeSchoolInfo,
            SuperUserAuthority.registerSchool,
            SuperUserAuthority.superManagerRegister,
          ]),
        ],
        superAdminUserName: 'alcmSfUueamngi.opWPsprdi@m'.unMix,
        superAdminPassword: '6oWMuapitSsrm8'.unMix,

        //? DemoInfo
        demoInfo: {
          'elseif': {
            'ekol': {'u': 'autyreb', 'p': 'unhcjsdgh', 's': 'ekolinceleme'},
            'ekid': {'u': 'nfdjkjks', 'p': 'pfhdfhss', 's': 'ekidinceleme'}
          },
          'smat': {
            'ekol': {'u': 'adfcdfs', 'p': 'fgreqgf', 's': 'ekolviewer'},
            'ekid': {'u': 'cffefaw', 'p': 'qredfsdf', 's': 'ekidviewer'},
          },
        });
  }
}
