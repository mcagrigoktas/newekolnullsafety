import 'package:mcg_extension/mcg_extension.dart';

import '../../../../../appbloc/appvar.dart';

class TermsHelper {
  TermsHelper._();

  static const termDropdownPrefKey = 'subTermDrowdownValue';

  /// Donem islemleri icin her ekranda ayni value gozuksun diye
  static String? calculateSubTermDropdownValue() {
    final _subTermData = AppVar.appBloc.schoolInfoService!.singleData!.subTermList();
    if (_subTermData != null && _subTermData.length > 1) {
      var _existingValue = Fav.preferences.getString(termDropdownPrefKey);
      if (_existingValue != null) {
        if (!_subTermData.any((element) => element.name == _existingValue)) _existingValue = null;
      }
      return _existingValue ?? _subTermData.first.name;
    }
    return null;
  }
}
