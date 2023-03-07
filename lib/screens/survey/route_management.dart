import 'package:mcg_extension/mcg_extension.dart';

import '../../models/allmodel.dart';
import 'fillsurvey.dart' deferred as fill_survey;
import 'surveylist.dart' deferred as survey_list;

class SurveyMainRoutes {
  SurveyMainRoutes._();

  static Future<void>? goSurveyList() async {
    OverLoading.show();
    await survey_list.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(survey_list.SurveyList());
  }

  static Future<void>? goSurveyFillPage(Announcement? announcement) async {
    OverLoading.show();
    await fill_survey.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(fill_survey.SurveyFillPage(announcement: announcement));
  }
}
