import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../flavors/dbconfigs/other/init_helpers.dart';

class ErrorLog extends StatefulWidget {
  ErrorLog();

  @override
  _ErrorLogState createState() => _ErrorLogState();
}

class ErrorModel {
  String? error;
  String? platform;
  String? time;
  String? key;

  ErrorModel();
}

Map errorMap = {};

class _ErrorLogState extends State<ErrorLog> {
  bool isLoading = true;
  Map? data;
  List<ErrorModel> list = [];

  Future<void> fetchData() async {
    final _firebaseDatabaseApp = await FirebaseInitHelper.getErrorApp();

    isLoading = true;
    setState(() {});
    await Database(app: _firebaseDatabaseApp).once('ekolerrors', limitToLast: 30).then((snap) {
      data = snap!.value;
      list.clear();

      data!.forEach((date, dateAllError) {
        isLoading = false;
        (dateAllError['errors'] as Map).forEach((key, value) {
          if (value is! Map) {
            list.add(ErrorModel()
              ..time = date.toString()
              ..error = value.toString()
              ..key = key);
          } else if (value['applicationParameters'] != null) {
            list.add(ErrorModel()
              ..time = date.toString()
              ..error = value['e'].toString()
              ..platform = value['p'].toString()
              ..key = key);
          }
        });
      });
      errorMap.clear();
      list.forEach((item) {
        final errkey = item.error.safeSubString(0, 200);
        log(errkey);
        List<ErrorModel> errorList = errorMap[errkey] ?? [];
        errorList.add(item);
        errorMap[errkey] = errorList;
      });

      setState(() {
        isLoading = false;
        list = list.reversed.toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // bununla error loglari silebilirsin   database.set(null);
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    var entries = errorMap.entries.toList();

    return AppScaffold(
      topBar: TopBar(leadingTitle: 'back'.translate),
      topActions: TopActionsTitle(title: 'Error Log'),
      body: isLoading
          ? Body.circularProgressIndicator()
          : Body.listviewBuilder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                List<ErrorModel> errors = entries.toList()[index].value;

                return Column(
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        var sure = await Over.sure();
                        if (sure != true) return;

                        final _firebaseDatabaseApp = await FirebaseInitHelper.getErrorApp();
                        List<Future> future = errors.map((item) => Database(app: _firebaseDatabaseApp).set('ekolerrors/${item.time}/errors/${item.key}', null)).toList();

                        Future.wait(future).then((_) {
                          fetchData();
                        }).unawaited;
                      },
                    ),
                    ...errors
                        .map(
                          (item) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              item.time,
                              item.platform,
                            ]
                                .map((e) => Text(
                                      e ?? '',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ))
                                .toList(),
                          ),
                        )
                        .toList(),
                    8.heightBox,
                    Text(
                      entries.toList()[index].key,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                    ),
                    8.heightBox,
                    ExpansionTile(
                      title: const Text('Detay'),
                      children: <Widget>[
                        Text(
                          errors.first.error!,
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                );
              }),
    );
  }
}
