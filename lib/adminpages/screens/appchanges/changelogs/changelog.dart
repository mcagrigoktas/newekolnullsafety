import 'package:flutter/cupertino.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../appbloc/databaseconfig.dart';
import '../../../../constant_settings.dart';
import 'controller.dart';
import 'model.dart';
import 'post_item.dart';

class ChangeLogPage extends StatelessWidget {
  ChangeLogPage();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangelogController>(
        init: ChangelogController(),
        builder: (controller) {
          return AppScaffold(
              topBar: TopBar(leadingTitle: 'menu1'.translate),
              topActions: TopActionsTitleWithChild(
                  title: TopActionsTitle(title: 'changelog'.translate),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoSlidingSegmentedControl<ChangeLogPostType>(
                            groupValue: controller.menuType,
                            children: {
                              ChangeLogPostType.changelog: 'changelog'.translate.text.make(),
                              ChangeLogPostType.fix: 'fixes'.translate.text.make(),
                            },
                            onValueChanged: (value) {
                              controller.menuType = value!;
                              controller.makeFilter();
                              controller.update();
                            },
                          ),
                        ],
                      ),
                    ],
                  )),
              body: (controller.isPageLoading)
                  ? Body.circularProgressIndicator()
                  : Body.listviewBuilder(
                      padding: Inset.b(context.screenBottomPadding),
                      maxWidth: 960,
                      itemCount: controller.filteredPostList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final _item = controller.filteredPostList[index];
                        return PostItemWidget(
                          isFirst: index == 0,
                          isLast: index == controller.filteredPostList.length - 1,
                          key: ObjectKey(_item),
                          item: _item,
                          index: index,
                        );
                      },
                    ));
        });
  }
}

class ChangelogController extends BaseController {
  String? changeLogData; //'changelogempty'.translate;

  List<ChangeLogPostItem> _postList = [];
  @override
  void onInit() {
    super.onInit();
    isPageLoading = true;
    _fetchData();
  }

  ChangeLogPostType menuType = ChangeLogPostType.changelog;
  List<ChangeLogPostItem> filteredPostList = [];
  void makeFilter() {
    filteredPostList = _postList
        .where((element) => element.appTarget == ChangeLogAppTarget.all || (AppVar.appBloc.hesapBilgileri.isEkid && element.appTarget == ChangeLogAppTarget.ekid) || (AppVar.appBloc.hesapBilgileri.isEkol && element.appTarget == ChangeLogAppTarget.ekol))
        .where((element) => element.targetLang == 'lang'.translate)
        .where((element) => element.postype == menuType)
        .toList();
    filteredPostList.sort((a, b) => b.timeStamp! - a.timeStamp!);
  }

  Future<void> _fetchData() async {
    final _kExpireTime = isDebugAccount ? Duration(seconds: 5) : Duration(hours: 1);
    final _data = await (DownloadManager.downloadFreshCachedData(DatabaseStarter.databaseConfig.firebaseStorageUrlPrefix! + '/Changelogs%2FMedia%2Fchangelogsbundle.txt?alt=media', _kExpireTime));
    final _unzippedMapData = DataZip.jsonDataFromZip(_data!.byteData);
    _postList = _unzippedMapData.entries.map((e) => ChangeLogPostItem.fromJson(e.value, e.key)).toList();
    isPageLoading = false;
    makeFilter();
    update();
  }
}
