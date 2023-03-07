import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../helpers/manager_authority_helper.dart';
import '../../localization/usefully_words.dart';
import '../../services/dataservice.dart';

class EatUrl extends StatefulWidget {
  @override
  _EatUrlState createState() => _EatUrlState();
}

class _EatUrlState extends State<EatUrl> {
  TextEditingController controller = TextEditingController();
  bool isLoading = false;

  void save() {
    if (Fav.noConnection()) return;
    if (controller.text.length < 6) return;

    setState(() {
      isLoading = true;
    });
    EatService.saveEatData(controller.text).then((_) {
      Get.back();
      OverAlert.saveSuc();
      setState(() {
        isLoading = false;
      });
    }).catchError((_) {
      setState(() {
        isLoading = false;
      });
      OverAlert.saveErr();
    });
  }

  @override
  void initState() {
    controller.value = TextEditingValue(text: AppVar.appBloc.schoolInfoService!.singleData!.eatMenuUrl!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: AppVar.appBloc.schoolInfoService!.stream,
        builder: (context, snapshot) {
          Widget? _bottomBar;
          if (AppVar.appBloc.hesapBilgileri.gtM && AuthorityHelper.hasYetki5(warning: false)) {
            _bottomBar = Row(
              children: <Widget>[
                Expanded(
                    child: MyTextField(
                  controller: controller,
                  labelText: 'link'.translate,
                )),
                MyProgressButton(
                  isLoading: isLoading,
                  label: Words.save,
                  onPressed: save,
                ).px16
              ],
            );
          }
          var _current = AppVar.appBloc.schoolInfoService!.singleData!.eatMenuUrl!.length > 6
              ? Padding(
                  key: ValueKey(AppVar.appBloc.schoolInfoService!.singleData!.eatMenuUrl),
                  padding: EdgeInsets.zero,
                  child: WebViewScaffold(
                    appBarTitle: "eatlist".translate,
                    url: AppVar.appBloc.schoolInfoService!.singleData!.eatMenuUrl.startsWithHttp ? AppVar.appBloc.schoolInfoService!.singleData!.eatMenuUrl! : 'https://' + AppVar.appBloc.schoolInfoService!.singleData!.eatMenuUrl!,
                    bottomWidget: _bottomBar,
                  ),
                )
              : AppScaffold(topBar: TopBar(), body: Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDS)));

          return _current;
        });
  }
}
