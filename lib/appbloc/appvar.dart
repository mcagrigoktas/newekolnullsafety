import 'package:get/get.dart';

import '../flavors/appconfig.dart';
import '../qbank/qbankbloc/qbankbloc.dart';
import '../qbank/testpage/controller/questionpagecontroller.dart';
import 'appbloc.dart';

class AppVar {
  AppVar._();
  static AppBloc get appBloc => Get.find<AppBloc>();
  static AppConfig get appConfig => Get.find<AppConfig>();
  static QuestionPageController get questionPageController => Get.find<QuestionPageController>();
  //static TabController homeTabController;
 // static Map<String, int> homeTabList = {};
  static QbankAppBloc get qbankBloc => Get.find<QbankAppBloc>();
}
