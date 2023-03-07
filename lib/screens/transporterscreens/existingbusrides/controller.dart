import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import 'model.dart';

class ExistingBusRideController extends ResponsivePageController<BusRideModel> {
  ExistingBusRideController(List<BusRideModel> itemList) : super(menuName: 'pastbusride') {
    this.itemList = itemList..sort((a, b) => int.tryParse(b.key.safeSubString(3, 8)!)! - int.tryParse(a.key.safeSubString(3, 8)!)!);
  }

  @override
  void onInit() {
    super.onInit();

    isPageLoading = false;
    makeFilter('');
  }
}
