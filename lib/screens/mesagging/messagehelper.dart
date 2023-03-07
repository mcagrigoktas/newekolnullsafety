import '../../appbloc/appvar.dart';

class MessageHelper {
  MessageHelper._();

  /// Sanirsam velilere ogrencinin goremeyecegi mesaj yada odeme gibi seyler icin
  /// bu bazi yerlerde ekidse degilse seklinde kullanilmis
  static bool isParentMessageActive() {
    if (!AppVar.appBloc.hesapBilgileri.isEkolOrUni) return false;
    return true;
  }
}
