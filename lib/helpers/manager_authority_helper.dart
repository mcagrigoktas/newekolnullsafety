import 'package:mcg_extension/mcg_extension.dart';

import '../appbloc/appvar.dart';

class AuthorityHelper {
  AuthorityHelper._();

  static bool _checkAuthorityThiskey(String key, {bool warning = false}) {
    if (!AppVar.appBloc.hesapBilgileri.gtM) return false;
    if (AppVar.appBloc.hesapBilgileri.uid != 'Manager1' && !authorityList.contains(key)) {
      if (warning) {
        OverAlert.show(type: AlertType.danger, message: 'hasntauthority'.translate + ' ' + key.translate);
      }
      return false;
    }
    return true;
  }

// "yetki1": "Öğrenci, öğretmen ve sınıf listesini düzenleyebilir",
  static bool hasYetki1({bool warning = false}) => _checkAuthorityThiskey('yetki1', warning: warning);
// "yetki2": "Kurum ayarlarını düzenleyebilir.",
  static bool hasYetki2({bool warning = false}) => _checkAuthorityThiskey('yetki2', warning: warning);
//  "yetki3": "Muhasebe bilgilerini düzenleyebilir.",
  static bool hasYetki3({bool warning = false}) => _checkAuthorityThiskey('yetki3', warning: warning);
// "yetki4": "Öğretmen paylaşımlarına onay verebilir.",
  static bool hasYetki4({bool warning = false}) => _checkAuthorityThiskey('yetki4', warning: warning);
//  "yetki5": "Yemek listesini düzenleyebilir",
  static bool hasYetki5({bool warning = false}) => _checkAuthorityThiskey('yetki5', warning: warning);
// "Diğer kullanıcıların mesajlaşmalarını okuyabilir"
  static bool hasYetki6({bool warning = false}) => _checkAuthorityThiskey('yetki6', warning: warning);
  // "Rehberlik menusunu gorebilir"
  static bool hasYetki7({bool warning = false}) => _checkAuthorityThiskey('yetki7', warning: warning);
  // "Mesajlasma menusunu gorebilir"
  static bool hasYetki8({bool warning = false}) => _checkAuthorityThiskey('yetki8', warning: warning);
  // "e lesson ve appointment ders menulerini gorebilir"
  static bool hasYetki9({bool warning = false}) => _checkAuthorityThiskey('yetki9', warning: warning);
  // "Ödevleri, yoklamaları, birebir dersleri ve öğrenci portfolyosunu görebilir."
  static bool hasYetki10({bool warning = false}) => _checkAuthorityThiskey('yetki10', warning: warning);
  // "Saglık ıslemlerını ınceleyebılır
  static bool hasYetki11({bool warning = false}) => _checkAuthorityThiskey('yetki11', warning: warning);
  // "Ders programi ınceleyebılır
  static bool hasYetki12({bool warning = false}) => _checkAuthorityThiskey('yetki12', warning: warning);
  // "Deneme sinavi ınceleyebılır
  static bool hasYetki13({bool warning = false}) => _checkAuthorityThiskey('yetki13', warning: warning);

  static List<String> get authorityList => AppVar.appBloc.hesapBilgileri.authorityList;
}
