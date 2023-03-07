import 'package:mcg_extension/mcg_extension.dart';

import 'exams/examdefine.dart' deferred as exam_define;
import 'helper.dart';

class EvaulationMainRoutes {
  EvaulationMainRoutes._();

  static Future<void>? goExamDefinePage(EvaulationUserType girisTuru) async {
    OverLoading.show();
    await exam_define.loadLibrary();
    await OverLoading.close();
    return Fav.guardTo(exam_define.ExamDefine(girisTuru));
  }
}
