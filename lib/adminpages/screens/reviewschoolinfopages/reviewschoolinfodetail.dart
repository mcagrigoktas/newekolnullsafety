import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../appbloc/databaseconfig.model_helper.dart';
import '../../../helpers/stringhelper.dart';
import '../../../models/allmodel.dart';
import '../../../screens/loginscreen/loginscreen.dart';
import '../../../services/dataservice.dart';

class ReviewSchoolInfoDetail extends StatefulWidget {
  final String? islemYapilacakKey;
  final GlobalKey<FormState>? formKey;
  final Function? resetPage;

  ReviewSchoolInfoDetail({this.islemYapilacakKey, this.formKey, this.resetPage, key}) : super(key: key);

  @override
  ReviewSchoolInfoDetailState createState() {
    return ReviewSchoolInfoDetailState();
  }
}

class ReviewSchoolInfoDetailState extends State<ReviewSchoolInfoDetail> {
  String? activeTerm;
  // bool isLoading = true;
  bool isLoading2 = false;

  @override
  void initState() {
    super.initState();

    if (widget.islemYapilacakKey != null) {
      AppVar.appBloc.database1.once('${StringHelper.schools}/${widget.islemYapilacakKey}/SchoolData/Info/activeTerm').then((snap) {
        activeTerm = snap!.value;
        reviewData();
      });
    }
  }

  List<Widget> reviewWidget = [];

  void reviewData() {
    if (activeTerm == null) return;

    if (Fav.noConnection()) return;

    setState(() {
      reviewWidget.clear();
      isLoading2 = true;
    });
    Future.wait([
      AppVar.appBloc.database1.once('${StringHelper.schools}/${widget.islemYapilacakKey}/$activeTerm/Students', orderByChild: 'aktif', equalTo: true),
      AppVar.appBloc.database1.once('${StringHelper.schools}/${widget.islemYapilacakKey}/$activeTerm/Teachers', orderByChild: 'aktif', equalTo: true),
      AppVar.appBloc.database1.once('${StringHelper.schools}/${widget.islemYapilacakKey}/$activeTerm/Classes', orderByChild: 'aktif', equalTo: true),
    ]).then((results) {
      setState(() {
        reviewWidget.add(StatisticWidget(name: 'Student: ', bgColor: Colors.amber, count: (results[0]?.value ?? {}).length ?? 0));
        reviewWidget.add(StatisticWidget(name: 'Teacher: ', bgColor: Colors.redAccent, count: (results[1]?.value ?? {}).length ?? 0));
        reviewWidget.add(StatisticWidget(name: 'Class: ', bgColor: Colors.greenAccent, count: (results[2]?.value ?? {}).length ?? 0));
        isLoading2 = false;
      });
    });
  }

  void goSchoolAccount() {
    if (Fav.noConnection()) return;

    UserInfoService.dbGetUserInfo(widget.islemYapilacakKey!, 'Managers', 'Manager1', '').once().then((snap) {
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
  Widget build(BuildContext context) {
    if (widget.islemYapilacakKey == null) {
      return EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST);
    }
    if (isLoading2) {
      return MyProgressIndicator(isCentered: true);
    }

    return MyForm(
      formKey: widget.formKey!,
      child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: <Widget>[
              8.heightBox,
              Group2Widget(
                children: reviewWidget,
              ),
              if (Get.find<SuperUserInfo>().isDeveloper)
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
    );
  }
}

class StatisticWidget extends StatelessWidget {
  final int count;
  final String name;
  final Color bgColor;
  StatisticWidget({required this.name, required this.count, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: bgColor, boxShadow: [BoxShadow(color: bgColor)]),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            child: Text(
              count.toString(),
              style: TextStyle(color: bgColor, fontWeight: FontWeight.bold, fontSize: 32),
            ),
            backgroundColor: Colors.white,
            radius: 32,
          ),
          16.heightBox,
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
