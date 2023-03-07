import '../../../../appbloc/appvar.dart';

class BroadcastStarterModel {
  dynamic lastUpdate;

  int? state;

  BroadcastStarterModel({this.lastUpdate});

  BroadcastStarterModel.fromJson(Map snapshot) {
    lastUpdate = snapshot['lastUpdate'];
    state = snapshot['state'];
  }

  Map<String, dynamic> mapForSave() {
    return {
      'lastUpdate': lastUpdate,
      'state': state,
    };
  }

  bool get active => state == 1 && AppVar.appBloc.realTime - lastUpdate < const Duration(hours: 2).inMilliseconds;
}
