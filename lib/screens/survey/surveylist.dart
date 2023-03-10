import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../appbloc/appvar.dart';
import '../../services/dataservice.dart';
import 'makesurvey.dart';
import 'surveyresults.dart';

class SurveyList extends StatefulWidget {
  @override
  _SurveyListState createState() => _SurveyListState();
}

class _SurveyListState extends State<SurveyList> {
  StreamSubscription? streamSubscription;
  List<Snap> surveyValue = [];
  bool isLoading = true;

  @override
  void initState() {
    /// todo Buraya minifetcher yaz. baska lazimsa ara  yaz
    streamSubscription = SurveyService.dbSurveyList().onValue().listen((event) {
      if (event?.value == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      surveyValue.clear();
      (event!.value as Map).forEach((key, value) {
        if (value['aktif'] != false) surveyValue.add(Snap(key, value));
      });
      surveyValue.sort((a, b) => b.key.compareTo(a.key));

      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        topBar: TopBar(
          leadingTitle: 'menu1'.translate,
          trailingActions: <Widget>[
            AddIcon(
              onPressed: () {
                Fav.to(SurveyEdit());
              },
            ),
          ],
        ),
        topActions: TopActionsTitle(
          title: 'surveylist'.translate,
        ),
        body: isLoading
            ? Body.circularProgressIndicator()
            : Body.listviewBuilder(
                itemCount: surveyValue.length,
                itemBuilder: (context, index) {
                  var snap = surveyValue[index];
                  if (AppVar.appBloc.hesapBilgileri.gtT && snap.value['prepared'] != AppVar.appBloc.hesapBilgileri.uid) return const SizedBox();

                  return Card(
                    color: Fav.design.card.background,
                    child: ListTile(
                      title: Text(snap.value['title'], style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold)),
                      trailing: Icon(Icons.chevron_right, color: Fav.design.primaryText),
                      onTap: () {
                        Fav.to(SurveyDataList(surveyKey: snap.key));
                      },
                    ),
                  );
                },
              ));
  }
}
