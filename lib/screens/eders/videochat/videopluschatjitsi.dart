// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';

// import '../../../models/allmodel.dart';
// import '../livebroadcast/live_area/layouts/livelessonmenutoolbarekol.dart';
// import '../livebroadcast/livebroadcasthelper.dart';

// class VideoPlusChat extends StatelessWidget {
//   final String channelName;
//   final String studentKey;
//   final bool spyVisible;
//   VideoPlusChat({this.channelName, this.spyVisible = false, this.studentKey});
//   @override
//   Widget build(BuildContext context) {
//     return LiveLessonMenuLayout(
//       item: LiveBroadcastModel()
//         ..targetList = [studentKey]
//         ..broadcastLink = LiveBroadCastHelper.getJitsiDomain()
//         ..channelName = 'ch' + channelName + channelName

//         ///ogrencinin kamera ve sesi giriste acik olabilmesi  icin lesson name  e bakiyor
//         ..lessonName = 'videolesson'.translate
//         ..livebroadcasturltype = 5,
//     );
//   }
// }
