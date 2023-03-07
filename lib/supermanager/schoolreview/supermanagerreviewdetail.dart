import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../models/allmodel.dart';
import '../../screens/loginscreen/loginscreen.dart';
import '../../screens/managerscreens/othersettings/usegeinfo.dart';
import '../../services/dataservice.dart';
import 'helpers.dart';

class SuperManagerReviewDetail extends StatefulWidget {
  final String? islemYapilacakKey;
  final GlobalKey<FormState>? formKey;
  final Function? resetPage;
  SuperManagerReviewDetail({this.islemYapilacakKey, this.formKey, this.resetPage, key}) : super(key: key);

  @override
  SuperManagerReviewDetailState createState() {
    return SuperManagerReviewDetailState();
  }
}

class SuperManagerReviewDetailState extends State<SuperManagerReviewDetail> with SingleTickerProviderStateMixin {
  String? activeTerm;
  bool isLoading = true;
  String? termKey;
  Widget? reviewWidget;
  String? schoolType;

  Map? usegeInfo;

  void goSchoolAccount() {
    if (Fav.noConnection()) return;

    UserInfoService.dbGetUserInfo(widget.islemYapilacakKey, 'Managers', 'Manager1', '').once().then((snap) {
      if (snap!.value == null) {
        OverAlert.show(type: AlertType.danger, message: 'anerror'.translate);
      }
      Manager manager = Manager.fromJson(snap.value, 'Manager1');
      Fav.to(EkolSignInPage(
        username: manager.username,
        password: manager.password,
        serverId: widget.islemYapilacakKey,
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  MiniFetcher<Manager>? managerFetcher;
  MiniFetcher<Teacher>? teacherFetcher;
  MiniFetcher<Student>? studentFetcher;
  MiniFetcher<Class>? classFetcher;
  Future<void> fetchData() async {
    if (widget.islemYapilacakKey != null) {
      Map? schoolInfoMap = await SuperManagerHelpers.getSchoolInfoMap(widget.islemYapilacakKey);

      if (schoolInfoMap == null) {
        OverAlert.show(message: 'kurumiderror'.argTranslate(widget.islemYapilacakKey!));
        return;
      }
      // Map schoolInfoMap = Fav.readSeasonCache('${widget.islemYapilacakKey}SchoolInfo');
      // if (schoolInfoMap == null) {
      //   schoolInfoMap = (await AppVar.appBloc.database11.once('${StringHelper.schools}/${widget.islemYapilacakKey}/SchoolData/Info')).value;
      //   Fav.writeSeasonCache('${widget.islemYapilacakKey}SchoolInfo', schoolInfoMap);
      // }

      termKey = schoolInfoMap['activeTerm'];
      schoolType = schoolInfoMap['schoolType'];

      managerFetcher = SuperManagerMiniFetchers.managerMiniFetchers(widget.islemYapilacakKey, getValueAfter: (_) => setState(() {}));
      teacherFetcher = SuperManagerMiniFetchers.teacherMiniFetchers(widget.islemYapilacakKey, termKey, getValueAfter: (_) => setState(() {}));
      studentFetcher = SuperManagerMiniFetchers.studentMiniFetchers(widget.islemYapilacakKey, termKey, getValueAfter: (_) => setState(() {}));
      classFetcher = SuperManagerMiniFetchers.classMiniFetchers(widget.islemYapilacakKey, termKey, getValueAfter: (_) => setState(() {}));

      Map? usageInfoMap = Fav.readSeasonCache('${widget.islemYapilacakKey}UsageInfo');
      if (usageInfoMap == null) {
        usageInfoMap = (await UserInfoService.dbUsageInfo(widget.islemYapilacakKey, termKey).once())?.value;
        Fav.writeSeasonCache('${widget.islemYapilacakKey}UsageInfo', usageInfoMap);
      }

      usegeInfo = usageInfoMap ?? {};
      await 100.wait;
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.islemYapilacakKey == null) {
      return EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST);
    }
    if (isLoading) {
      return MyProgressIndicator(
        isCentered: true,
        text: 'supermanagerwaithint'.translate,
        padding: const EdgeInsets.all(16),
      );
    }

    return MyForm(
      formKey: widget.formKey!,
      child: CupertinoTabWidget(
        tabs: [
          TabMenu(
              name: "registrymenu".translate,
              widget: SingleChildScrollView(
                  child: AnimatedGroupWidget(
                children: <Widget>[
                  StatisticWidget(
                    name: 'manager'.translate,
                    bgColor: Colors.amber,
                    count: managerFetcher?.dataList.length ?? 0,
                  ),
                  StatisticWidget(
                    name: 'student'.translate,
                    bgColor: Colors.green,
                    count: studentFetcher?.dataList.length ?? 0,
                  ),
                  StatisticWidget(
                    name: 'teacher'.translate,
                    bgColor: Colors.deepOrange,
                    count: teacherFetcher?.dataList.length ?? 0,
                  ),
                  StatisticWidget(
                    name: 'class'.translate,
                    bgColor: Colors.indigoAccent,
                    count: classFetcher?.dataList.length ?? 0,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: MyRaisedButton(
                        text: 'checkschooldata'.translate,
                        onPressed: goSchoolAccount,
                        iconData: Icons.chevron_right,
                      ),
                    ),
                  ),
                ],
              )),
              value: 0),
          TabMenu(
              name: "usageinfo".translate,
              widget: UsageInfo(
                hasScaffold: false,
                data: usegeInfo,
                studentList: studentFetcher?.dataList ?? [],
                teacherList: teacherFetcher?.dataList ?? [],
                managerList: managerFetcher?.dataList ?? [],
                schoolType: schoolType,
              ),
              value: 1),
        ],
      ),
    );
  }
}

class StatisticWidget extends StatelessWidget {
  final int? count;
  final String? name;
  final Color? bgColor;
  StatisticWidget({this.name, this.count, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: bgColor, boxShadow: [BoxShadow(color: bgColor!)]),
      child: Column(
        children: <Widget>[
          Container(
            decoration: const ShapeDecoration(
              shape: StadiumBorder(),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(12),
            child: Text(
              count.toString(),
              style: TextStyle(color: bgColor, fontWeight: FontWeight.bold, fontSize: 32),
            ),
          ),
          16.heightBox,
          Text(name!, style: const TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }
}
