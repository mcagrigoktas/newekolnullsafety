import 'package:mcg_extension/mcg_extension.dart';

import '../flavors/appconfig.dart';
import '../models/models.dart';
import 'databaseconfig.ekol_helper.dart';
import 'databaseconfig.model_helper.dart';
import 'databaseconfig.tua_helper.dart';

class DatabaseStarter {
  DatabaseStarter._();

  static DataBaseConfigModel? _configModel;
  static DataBaseConfigModel get databaseConfig {
    if (_configModel != null) return _configModel!;
    if (Get.find<AppConfig>().databaseVersion == 0) {
      _configModel = DatabaseEkolHelper.getConfig();
    } else if (Get.find<AppConfig>().databaseVersion == 2) {
      _configModel = DatabaseTuaHelper.getConfig();
    } else {
      throw (Exception('Database versioyonu bulunamadi'));
    }
    return _configModel!;
  }

  @TODO('Burayi enum seklinde ayarla')
  static Map<String, MarketData> marketLinks = {
    'speedsis': MarketData('SpeedSIS', 'elseif.page.link/SpeedSIS', 'elseif.page.link/SpeedSIS', 'elseif', 'speedsis.com'),
    'aci': MarketData('Açı', 'elseif.page.link/aci', 'elseif.page.link/aciios', 'elseif', 'acidijitalokul.com'),
    'acilim': MarketData('Açılım Dijital', 'elseif.page.link/adan', 'elseif.page.link/adIos', 'elseif', 'acilimdijital.com'),
    'taktikbende': MarketData('Taktik Bende', '', '', 'elseif', ''),
    'datatac': MarketData('Smat Collage', 'elseif.page.link/SMat', 'elseif.page.link/Smat', 'smat', ''),
    'datatacekid': MarketData('Smat', 'elseif.page.link/SmatKid', 'elseif.page.link/Smatkid', 'smat', ''),
    'elseif': MarketData('E-coll', 'elseif.page.link/EColl', 'elseif.page.link/Ecoll', 'elseif', 'eokul.dev'), //ecollmobile.com
    'elseifekid': MarketData('Ekid+', 'elseif.page.link/EKid', 'elseif.page.link/Ekid', 'elseif', 'ekidmobile.com'),
    'golbasi': MarketData('Gölbaşı Belediyesi', 'play.google.com/store/apps/details?id=com.elseif.golbasiekol', '----', 'yok', ''),
    'muradiye': MarketData('Muradiye', 'elseif.page.link/TRP2', 'elseif.page.link/KML1', 'elseif', ''),
    'teknokent': MarketData('Teknokent Koleji', 'elseif.page.link/TEch', 'elseif.page.link/Tech', 'elseif', 'teknokentmobil.com'),
  };
}
