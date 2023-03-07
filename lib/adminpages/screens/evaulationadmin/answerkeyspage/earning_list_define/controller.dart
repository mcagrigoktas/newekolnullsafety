import 'package:mcg_database/mcg_database.dart';
import 'package:mypackage/srcpages/reponsive_page/controller.dart';

import '../../../../../services/dataservice.dart';
import '../../helper.dart';
import 'model.dart';

class EarningListController extends ResponsivePageController<EarningItem> {
  EvaulationUserType girisTuru;
  String? genelMudurlukKurumId;
  MiniFetcher<EarningItem>? earningListFetcher;
  EarningListController(this.earningListFetcher, this.girisTuru, this.genelMudurlukKurumId)
      : super(
          menuName: 'earninglistdefine',
          listViewPageStorageKey: 'earninglistdefine',
          saveFunction: (item) async {
            if (girisTuru == EvaulationUserType.school) {
              await ExamService.saveSchoollEarningItem(item);
            } else {
              await ExamService.saveGlobalEarningItem(item, genelMudurlukKurumId);
            }
          },
          deleteFunction: (item) async {
            item.aktif = false;
            if (girisTuru == EvaulationUserType.school) {
              await ExamService.saveSchoollEarningItem(item);
            } else {
              await ExamService.saveGlobalEarningItem(item, genelMudurlukKurumId);
            }
          },
          createNewClassFunction: () => EarningItem.create(),
        );

  @override
  void onInit() {
    super.onInit();

    refreshSubscription = earningListFetcher!.stream.listen((event) {
      itemList = earningListFetcher!.dataList;
      makeFilter(filteredText);
      isPageLoading = false;
      update();
    });
  }
}
