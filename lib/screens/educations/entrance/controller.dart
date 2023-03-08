import 'dart:async';

import 'package:mcg_extension/mcg_extension.dart';

import '../../../appbloc/appvar.dart';
import '../model.dart';

class EducationListEntranceController extends GetxController {
  late StreamSubscription _pageRefresher;
  final List<Education> itemList = [];
  Set<String> classLevelList = {};
  String? classLevel;
  @override
  void onInit() {
    if (AppVar.appBloc.hesapBilgileri.gtS) {
      classLevel = AppVar.appBloc.classService!.dataList.singleWhereOrNull((sinif) => sinif.key == AppVar.appBloc.hesapBilgileri.class0)?.classLevel;
    } else {
      AppVar.appBloc.educationService!.dataList<Education>().forEach((element) {
        classLevelList.addAll(element.classLevelList ?? []);
      });
      classLevelList = (classLevelList.toList()..sort()).toSet();
      classLevel ??= classLevelList.isNotEmpty ? classLevelList.first : null;
    }

    filterItemList();
    _pageRefresher = AppVar.appBloc.educationService!.stream.listen((event) {
      filterItemList();
    });
    _deleteFavoritesNonExistItems();

    super.onInit();
  }

  @override
  void onClose() {
    _pageRefresher.cancel();
    super.onClose();
  }

  List<Education> get _getAllEducationData => AppVar.appBloc.educationService!.dataList<Education>().where((element) => element.serverIdList!.any((element) => AppVar.appBloc.hesapBilgileri.genelMudurlukEducationList.contains(element))).toList();

  void _deleteFavoritesNonExistItems() {
    final _favoritesItems = Fav.preferences.getLimitedStringList(AppVar.appBloc.hesapBilgileri.kurumID + AppVar.appBloc.hesapBilgileri.uid + 'favoritesEducationItems', [])!;
    final _allEducationItems = _getAllEducationData;
    _favoritesItems.forEach((_favKey) {
      final _item = _allEducationItems.firstWhereOrNull((element) => element.key == _favKey);
      if (_item == null) {
        Fav.preferences.removeThisStringInStringList(AppVar.appBloc.hesapBilgileri.kurumID + AppVar.appBloc.hesapBilgileri.uid + 'favoritesEducationItems', _favKey);
      }
    });
  }

  void filterItemList() {
    itemList.clear();

    _getAllEducationData.forEach((element) {
      if (element.classLevelList?.contains(classLevel) == true) {
        itemList.add(element);
      }
    });

    // itemList.forEach((element) {
    //   log(element.toJson());
    // });
  }
}
