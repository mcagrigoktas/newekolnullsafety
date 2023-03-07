import 'package:get/get.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../adminpages/screens/supermanagerpages/models.dart';
import '../models/accountdata.dart';

class SuperManagerController extends GetxController {
  HesapBilgileri hesapBilgileri;
  List<SuperManagerSchoolInfoModel>? serverList;
  Map<String, MiniFetcher> schoolsDatas = {};

  SuperManagerController(this.serverList, this.hesapBilgileri) {
    // this.serverList = serverList.map((item) => SuperManagerSchoolInfoModel(schoolName: item['schoolName'], serverId: item['serverId'])).toList();
  }

  @override
  void onInit() {
    _init();
    super.onInit();
  }

  @override
  Future<void> onClose() async {
    super.onClose();
  }

  void _init() {}
}
