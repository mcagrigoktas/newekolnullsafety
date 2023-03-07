import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:mcg_extension/mcg_extension.dart';

import '../appconfig.dart';
import 'aci.dart' as aci;
import 'datatac.dart' as datatac;
import 'datatacekid.dart' as datatacekid;
import 'elseif.dart' as elseif;
import 'elseifekid.dart' as elseifekid;
import 'generally.dart' as generally;
import 'golbasi.dart' as golbasi;
import 'muradiye.dart' as muradiye;
import 'qbank.dart' as qbank;
import 'smatqbank.dart' as smatqbank;
import 'speedsis.dart' as speedsis;
import 'taktikbende.dart' as taktikbende;
import 'tarea.dart' as tarea;
import 'teknokent.dart' as teknokent;
import 'tua.dart' as tua;

class DefaultFirebaseOptionsForFlavor {
  static FirebaseOptions get currentFlavor {
    final _appConfig = Get.find<AppConfig>();

    //* Golden
    if (_appConfig.flavorType == FlavorType.elseif) return elseif.DefaultFirebaseOptions.currentPlatform;
    if (_appConfig.flavorType == FlavorType.elseifekid) return elseifekid.DefaultFirebaseOptions.currentPlatform;

    //* SpeedSis
    if (_appConfig.flavorType == FlavorType.speedsis) return speedsis.DefaultFirebaseOptions.currentPlatform;

    // //*Nigeria
    if (_appConfig.flavorType == FlavorType.datatac) return datatac.DefaultFirebaseOptions.currentPlatform;
    if (_appConfig.flavorType == FlavorType.datatacekid) return datatacekid.DefaultFirebaseOptions.currentPlatform;

    // //*TurkeySchool
    if (_appConfig.flavorType == FlavorType.aci) return aci.DefaultFirebaseOptions.currentPlatform;
    if (_appConfig.flavorType == FlavorType.golbasi) return golbasi.DefaultFirebaseOptions.currentPlatform;
    if (_appConfig.flavorType == FlavorType.muradiye) return muradiye.DefaultFirebaseOptions.currentPlatform;
    if (_appConfig.flavorType == FlavorType.teknokent) return teknokent.DefaultFirebaseOptions.currentPlatform;
    if (_appConfig.flavorType == FlavorType.taktikbende) return taktikbende.DefaultFirebaseOptions.currentPlatform;
    if (_appConfig.flavorType == FlavorType.acilim) return generally.DefaultFirebaseOptions.currentPlatform;

    //*
    if (_appConfig.flavorType == FlavorType.tua) return tua.DefaultFirebaseOptions.currentPlatform;

    // //* QBank
    if (_appConfig.flavorType == FlavorType.qbank) return qbank.DefaultFirebaseOptions.currentPlatform;
    if (_appConfig.flavorType == FlavorType.smatqbank) return smatqbank.DefaultFirebaseOptions.currentPlatform;
    if (_appConfig.flavorType == FlavorType.tarea) return tarea.DefaultFirebaseOptions.currentPlatform;

    throw UnsupportedError(
      'Unsupported Flavor Type',
    );
  }
}

extension FirebaseOptionsExtension on FirebaseOptions {
  String get urlText {
    return 'apiKey=$apiKey&appId=$appId&messagingSenderId=$messagingSenderId&projectId=$projectId&authDomain=$authDomain&measurementId=$measurementId';
  }
}
