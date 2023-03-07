import '../../../../appbloc/appvar.dart';
import '../../../models/models.dart';
import '../../../qbankbloc/getdataservice.dart';

class PurchaseHelper {
  Future<void> reloadBooks() async {
    return QBGetDataService.getBookPurchasedList(AppVar.qbankBloc.databaseSBB, AppVar.qbankBloc.hesapBilgileri.uid).once().then((snapshot) {
      List<PurchasedBookData> list = [];
      if (snapshot?.value != null) {
        (snapshot!.value as Map).forEach((key, value) {
          list.add(PurchasedBookData.fromJson(value));
        });
      }
      list.removeWhere((item) => item.status != 10);
      AppVar.qbankBloc.hesapBilgileri.purchasedList = list;
      //  Fav.preferences.setString("qbankHesapBilgileri", AppVar.qbankBloc.hesapBilgileri.toString());
      AppVar.qbankBloc.hesapBilgileri.savePreferences();
    });
  }
}
