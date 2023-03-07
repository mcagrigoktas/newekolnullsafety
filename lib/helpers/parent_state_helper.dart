import 'package:mcg_extension/mcg_extension.dart';

import '../appbloc/appvar.dart';
import 'stringhelper.dart';

/// Ogrencinin anne baba ayri ise parent state 2

class ParentStateHelper {
  ParentStateHelper._();
  static String userTopBarNamePrefix() {
    String _result = '';
    if (AppVar.appBloc.hesapBilgileri.gtMT) return _result;

    if (AppVar.appBloc.hesapBilgileri.isEkid) {
      if (AppVar.appBloc.hesapBilgileri.parentState == 2) {
        if (AppVar.appBloc.hesapBilgileri.parentNo == 2) {
          _result += ' (${"father".translate})';
        } else {
          _result += ' (${"mother".translate})';
        }
      }
    } else {
      if (AppVar.appBloc.hesapBilgileri.parentState == 2 && AppVar.appBloc.hesapBilgileri.isParent) {
        if (AppVar.appBloc.hesapBilgileri.parentNo == 2) {
          _result += ' (${"father".translate})';
        } else {
          _result += ' (${"mother".translate})';
        }
      }
    }

    return _result;
  }

  static void addTokenValuesForParents(Map<String, dynamic> updates, String? _kurumId, String? _termKey, String? _uid, realTime, String deviceName, String token) {
    if (AppVar.appBloc.hesapBilgileri.isEkid) {
      if (AppVar.appBloc.hesapBilgileri.parentState != 2 || AppVar.appBloc.hesapBilgileri.parentNo == 1) {
        final parentUidkey = '40-G-' + _uid!;
        updates['/${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TSM/$parentUidkey/lastUpdate'] = realTime;
        updates['/${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TSM/$parentUidkey/tl/$token'] = deviceName;
      }
      if (AppVar.appBloc.hesapBilgileri.parentNo == 2) {
        final parentUidkey = '42-G-' + _uid!;
        updates['/${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TSM/$parentUidkey/lastUpdate'] = realTime;
        updates['/${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TSM/$parentUidkey/tl/$token'] = deviceName;
      }
    } else {
      if (AppVar.appBloc.hesapBilgileri.isParent == false) return;
      if (AppVar.appBloc.hesapBilgileri.parentState != 2 || AppVar.appBloc.hesapBilgileri.parentNo == 1) {
        final parentUidkey = '40-G-' + _uid!;
        updates['/${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TSM/$parentUidkey/lastUpdate'] = realTime;
        updates['/${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TSM/$parentUidkey/tl/$token'] = deviceName;
      }
      if (AppVar.appBloc.hesapBilgileri.parentNo == 2) {
        final parentUidkey = '42-G-' + _uid!;
        updates['/${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TSM/$parentUidkey/lastUpdate'] = realTime;
        updates['/${StringHelper.schools}/$_kurumId/$_termKey/Tokens2/TSM/$parentUidkey/tl/$token'] = deviceName;
      }
    }
  }
}
