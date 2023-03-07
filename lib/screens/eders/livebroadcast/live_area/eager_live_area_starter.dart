import 'package:mcg_extension/mcg_extension.dart';

import '../../../../models/lesson.dart';
import '../../../../models/models.dart';
import '../livebroadcasthelper.dart';
import 'deferred_live_area_starter.dart' deferred as eager;
import 'layouts/livelessonmenutoolbarekol.dart';

class LiveAreaStarter {
  LiveAreaStarter._();
  static Future<void>? startGetTo({
    LiveBroadcastModel? item,
    LiveLessonType? liveLessonType,
    Lesson? lesson,
  }) async {
    await eager.loadLibrary();
    return eager.DeferredLiveAreaStarter.startGetTo(item: item, lesson: lesson, liveLessonType: liveLessonType);
  }

  static Future<void>? startGetOff({
    LiveBroadcastModel? item,
    LiveLessonType? liveLessonType,
    Lesson? lesson,
  }) async {
    await eager.loadLibrary();
    return eager.DeferredLiveAreaStarter.startGetOff(item: item, lesson: lesson, liveLessonType: liveLessonType);
  }

  static Future<void>? startVideoChat({
    required String channelName,
    String? studentKey,
    bool? spyVisible,
  }) async {
    await eager.loadLibrary();
    return eager.DeferredLiveAreaStarter.startGetTo(
      item: LiveBroadcastModel()
        ..targetList = studentKey == null ? null : [studentKey]
        ..broadcastLink = LiveBroadCastHelper.getJitsiDomain()
        ..channelName = 'ch' + channelName + channelName

        ///ogrencinin kamera ve sesi giriste acik olabilmesi  icin lesson name  e bakiyor
        ..lessonName = 'videolesson'.translate
        ..livebroadcasturltype = 5,
    );
  }
}
