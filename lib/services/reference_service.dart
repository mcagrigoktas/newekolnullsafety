import 'package:mcg_extension/mcg_extension.dart';

import '../appbloc/appvar.dart';

class ReferenceService {
  ReferenceService._();

  //
  static String publicEducationListRef() => 'AllSchool/CommonData/PublicEducationList';
  static String privateEducationListRef() => 'AllSchool/CommonData/EducationList';

  //

  static String get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  //static String? get _uid => AppVar.appBloc.hesapBilgileri.uid;
  static String get _termKey => AppVar.appBloc.hesapBilgileri.termKey;

  static String userContractCollectionRef() => 'Okullar/$_kurumId/Accounting/$_termKey/UserContracts';
  static String salesContractCollectionRef() => 'Okullar/$_kurumId/Accounting/$_termKey/SalesContracts';
  static String singleDocListCollectionRef() => 'Okullar/$_kurumId/SingleDocs/$_termKey/SingleDocList';
  static String accountLogRef() => 'Okullar/$_kurumId/Accounting/$_termKey/AccountLog';
  static String expensesCollectionRef() => 'Okullar/$_kurumId/Accounting/$_termKey/Expenses';
  static String socialReference() => 'Okullar/$_kurumId/Data/$_termKey/Social';

  static String schoolGroupCollectionRef() => 'ForAdmin/SchoolGroups/Package';

//* gelen keyin ilk harfini kesip o isimle biten doc ismi gonderir.
//* mesele 10 farkli doc olusturup gelen datalari o 10 doca gore rasgele isminin bas harfine gore dagitir
  static String getDocName(String key, [int docCount = 10]) {
    return '/Doc' + (keyCharacters.indexOf(key.firstXcharacter(1)!) % docCount).toString();
  }

  //SimpleP2P haftalik datasi
  static String simpleP2PWeekData() => 'Okullar/$_kurumId/Data/$_termKey/P2PWeeklyData';
}
