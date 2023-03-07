import 'package:mcg_extension/mcg_extension.dart';

import '../../appbloc/appvar.dart';

class DeleteSocialNetworkData {
  DeleteSocialNetworkData._();
  static Future<void> delete() async {
    int deletetCount = 0;
    final Map _serverListMap = (await AppVar.appBloc.database1.once('ServerList'))!.value;
    List<String> _serverList = _serverListMap.entries.fold<List<String>>(<String>[], (p, e) => p..add(e.key));
    // for (var i = 0; i < _serverList.length; i++) {
    //   await 10.wait;
    //   print('$i: ' + _serverList[i]);
    // }
    // print(_serverList.length);
    // print(_serverList.indexOf('marmaraanadolu'));
    // print('AllServerList: $_serverList');

    // return;

    for (var i = 0; i < _serverList.length; i++) {
      final _serverId = _serverList[i];
      log('$i: ' + _serverId);
      final Map _termListMap = (await AppVar.appBloc.database1.once('Okullar/$_serverId/SchoolData/Terms'))!.value;
      List<String> _termList = _termListMap.entries.fold<List<String>>(<String>[], (p, e) => p..add(e.key));

      for (var j = 0; j < _termList.length; j++) {
        final _term = _termList[j];
        final Map? _studetnListMap = (await AppVar.appBloc.database1.once('Okullar/$_serverId/$_term/Students'))?.value;
        if (_studetnListMap == null) continue;
        List<String> _studentList = _studetnListMap.entries.fold<List<String>>(<String>[], (p, e) => p..add(e.key));
        for (var s = 0; s < _studentList.length; s++) {
          Map<String, dynamic> updatesSocial = {};

          final _student = _studentList[s];
          final Map? _socialItemsMap = (await AppVar.appBloc.database2.once(
            'Okullar/$_serverId/$_term/SocialNetwork/$_student',
            orderByChild: 'timeStamp',
            endAt: DateTime.now().subtract(Duration(days: 365)).millisecondsSinceEpoch,
          ))
              ?.value;
          List<String> _mustDeletedSocialItemsKeyList = _socialItemsMap?.entries.fold<List<String>>(<String>[], (p, e) => p..add(e.key)) ?? [];
          for (var t = 0; t < _mustDeletedSocialItemsKeyList.length; t++) {
            final _itemKey = _mustDeletedSocialItemsKeyList[t];
            updatesSocial['Okullar/$_serverId/$_term/SocialNetwork/$_student/$_itemKey'] = null;
          }
          final Map? _socialVideoItemsMap = (await AppVar.appBloc.database2.once(
            'Okullar/$_serverId/$_term/Video/$_student',
            orderByChild: 'timeStamp',
            endAt: DateTime.now().subtract(Duration(days: 365)).millisecondsSinceEpoch,
          ))
              ?.value;
          List<String> _mustDeletedSocialVideoItemsKeyList = _socialVideoItemsMap?.entries.fold<List<String>>(<String>[], (p, e) => p..add(e.key)) ?? [];
          for (var t = 0; t < _mustDeletedSocialVideoItemsKeyList.length; t++) {
            final _itemKey = _mustDeletedSocialVideoItemsKeyList[t];
            updatesSocial['Okullar/$_serverId/$_term/Video/$_student/$_itemKey'] = null;
          }
          deletetCount += updatesSocial.length;
          if (updatesSocial.isNotEmpty) await AppVar.appBloc.database2.update(updatesSocial);
        }
      }
      log('DeleteCount $deletetCount');
      log(_serverId + ' BITTI');
    }
  }
}
