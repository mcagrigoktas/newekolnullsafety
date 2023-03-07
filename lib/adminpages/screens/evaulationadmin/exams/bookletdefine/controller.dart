import 'package:flutter/cupertino.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../examtypes/model.dart';
import '../../helper.dart';
import '../model.dart';
import 'model.dart';

class OnlineFormController extends GetxController {
  BookLetModel? model;
  ExamType? examType;
  EvaulationUserType userType;
  Exam? exam;
  int seisonNo;
  OnlineFormController(this.model, this.examType, this.userType, this.exam, this.seisonNo);

  GlobalKey<FormState> formKey = GlobalKey();

  @override
  void onInit() {
    model ??= BookLetModel()
      ..exambookletlocation = Exambookletlocation.pdf
      ..isOnlyMainBooklet = true
      ..lessonBookLetFiles = {};

    super.onInit();
  }

  void saveItem() {
    if (formKey.currentState!.checkAndSave()) {
      exam!.bookLetsData!['seison$seisonNo'] = model;
      Get.back(result: true);
    }
  }
}
