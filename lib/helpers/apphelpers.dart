import 'package:mcg_extension/mcg_extension.dart';

class AppHelpers {
  AppHelpers._();

  static String passwordToParentPassword(String password) {
    if (password.length < 4) return '';
    return McgFunctions.mcgStringNumberKey(password)! + '-$password';
  }
}
