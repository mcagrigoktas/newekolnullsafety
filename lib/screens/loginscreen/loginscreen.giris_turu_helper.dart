class LoginScreenGirisTuruHelper {
  LoginScreenGirisTuruHelper._();
  static String girisTuruKey(int? _girisTuru) {
    if (_girisTuru == 10) return "Managers";
    if (_girisTuru == 20) return "Teachers";
    if (_girisTuru == 30) return "Students";
    if (_girisTuru == 90) return "Transporters";
    throw ('Taninmayan giris turu');
  }
}
