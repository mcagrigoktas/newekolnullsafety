import 'package:mcg_extension/mcg_extension.dart';

import '../../../../models/lesson.dart';
import '../../../../models/models.dart';
import 'layouts/livelessonmenutoolbarekol.dart';

class DeferredLiveAreaStarter {
  DeferredLiveAreaStarter._();
  static Future<void>? startGetTo({
    LiveBroadcastModel? item,
    LiveLessonType? liveLessonType,
    Lesson? lesson,
  }) {
    return Fav.to(LiveLessonMenuLayout(
      item: item,
      liveLessonType: liveLessonType,
      lesson: lesson,
    ));
  }

  static Future<void>? startGetOff({
    LiveBroadcastModel? item,
    LiveLessonType? liveLessonType,
    Lesson? lesson,
  }) {
    return Get.off(() => LiveLessonMenuLayout(
          item: item,
          liveLessonType: liveLessonType,
          lesson: lesson,
        ));
  }
}
