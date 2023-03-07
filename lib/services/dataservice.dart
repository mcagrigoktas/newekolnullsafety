import 'package:firebase_database/firebase_database.dart';
import 'package:mcg_database/firestore/firestore.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../helpers/stringhelper.dart';
import '../../models/allmodel.dart';
import '../../models/enums.dart';
import '../../screens/managerscreens/registrymenu/personslist/model.dart';
import '../../screens/p2p/freestyle/model.dart';
import '../../screens/portfolio/model.dart';
import '../adminpages/screens/appchanges/changelogs/model.dart';
import '../adminpages/screens/evaulationadmin/answerkeyspage/earning_list_define/model.dart';
import '../appbloc/appvar.dart';
import '../helpers/appfunctions.dart';
import '../helpers/parent_state_helper.dart';
import '../models/notification.dart';
import '../screens/guiding/caserecords/model.dart';
import '../screens/managerscreens/othersettings/user_permission/user_permission.dart';
import '../screens/managerscreens/schoolsettings/models/mutlu_cell.dart';
import '../screens/p2p/simple/edit_p2p_draft/model.dart';
import '../screens/p2p/simple/reserve_p2p/model.dart';
import '../screens/rollcall/model.dart';
import '../screens/timetable/homework/homework_check_helper.dart';
import '../screens/timetable/modelshw.dart';
import 'pushnotificationservice.dart';
import 'reference_service.dart';

part 'data_services/accounting_service.dart';
part 'data_services/announcement_service.dart';
part 'data_services/caserecord_service.dart';
part 'data_services/changelog_service.dart';
part 'data_services/class_service.dart';
part 'data_services/dailyreport_service.dart';
part 'data_services/eat_service.dart';
part 'data_services/exam_service.dart';
part 'data_services/homework_service.dart';
part 'data_services/in_app_notification_service.dart';
part 'data_services/lesson_service.dart';
part 'data_services/livebroadcast_service.dart';
part 'data_services/manager_service.dart';
part 'data_services/medicine_service.dart';
part 'data_services/message_service.dart';
part 'data_services/p2p_service.dart';
part 'data_services/person_service.dart';
part 'data_services/portfolio_service.dart';
part 'data_services/preregister_service.dart';
part 'data_services/program_service.dart';
part 'data_services/randomdata_service.dart';
part 'data_services/rollcall_service.dart';
part 'data_services/school_data_service.dart';
part 'data_services/signinout_service.dart';
part 'data_services/social_service.dart';
part 'data_services/sticker_service.dart';
part 'data_services/student_service.dart';
part 'data_services/survey_service.dart';
part 'data_services/teacher_service.dart';
part 'data_services/transport_service.dart';
part 'data_services/user_info_service.dart';
part 'data_services/videochat_service.dart';

class LogHelper {
  LogHelper._();
  static String? get _kurumId => AppVar.appBloc.hesapBilgileri.kurumID;
  static String? get _termKey => AppVar.appBloc.hesapBilgileri.termKey;
  static Database get _databaseLogss => AppVar.appBloc.databaseLogs;
  //Log kayitlari transaction

  static void addLog(String menuname, String? senderKey, [int? count]) {
    _databaseLogss.runTransaction('${StringHelper.schools}/$_kurumId/$_termKey/UsageLogs/${'m:' + DateTime.now().month.toString()}/$menuname/$senderKey', (count ?? 1));
  }
}
