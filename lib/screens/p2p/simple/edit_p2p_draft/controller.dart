import 'package:mcg_extension/mcg_extension.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../services/dataservice.dart';
import 'layout.helper.dart';
import 'model.dart';

class P2PEditLayoutController extends BaseController {
  String teacherDropdownValue = 'school';

  late SimpleP2pDraft schoolDraftData;

  @override
  void onInit() {
    schoolDraftData = AppVar.appBloc.simpleP2PDraftService?.singleData ?? SimpleP2pDraft.fromJson({});
    super.onInit();
  }

  Future<void> addItemsForSchoolDraft() async {
    final _result = await P2PEditSchoolHelper.add();
    if (_result != null) schoolDraftData.addSchoolP2pDraftItems(_result);
    update();
  }

  Future<void> save() async {
    if (Fav.noConnection()) return;
    startLoading();
    await P2PService.saveSimpleP2PSchoolDraft(schoolDraftData.toJson()).then((_) => OverAlert.saveSuc()).catchError((_) => OverAlert.saveErr());
    stopLoading();
  }
}
