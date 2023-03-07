import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../appbloc/appvar.dart';
import '../../../flavors/mainhelper.dart';
import '../../../helpers/print_and_export_helper.dart';
import '../../../localization/usefully_words.dart';
import '../../../models/allmodel.dart';
import '../../../models/notification.dart';
import '../../../services/dataservice.dart';

class PastStatistics extends StatefulWidget {
  PastStatistics();

  @override
  _PastStatisticsState createState() => _PastStatisticsState();
}

class PastData {
  final String? name;
  final String? paymentName;
  final double? tutar;
  final String? studentKey;
  final int? tarih;

  String get tarihText => tarih!.dateFormat("d-MMM-yyyy");
  PastData({this.name, this.paymentName, this.tutar, this.studentKey, this.tarih});
}

class _PastStatisticsState extends State<PastStatistics> {
  String _paymentTypeKey = 'all';
  Map? _data;
  bool _isLoading = true;
  final List<PastData> _pastData = [];
  List<PastData> _filteredPastData = [];
  @override
  void initState() {
    if (DateTime.now().millisecondsSinceEpoch - Fav.readSeasonCache<int>('readaccountingstatisticstime', 0)! < const Duration(minutes: 10).inMilliseconds && Fav.readSeasonCache<Map>('readlastaccountingstatistics', {}) != null) {
      _data = Fav.readSeasonCache<Map>('readlastaccountingstatistics', {});
      _getPastData();
      _isLoading = false;
    } else {
      AccountingService.dbAllStudentAccountingData().once().then((snap) {
        setState(() {
          _data = snap!.value;
          _getPastData();
          _isLoading = false;
          Fav.writeSeasonCache('readaccountingstatisticstime', DateTime.now().millisecondsSinceEpoch);
          Fav.writeSeasonCache('readlastaccountingstatistics', _data);
        });
      });
    }
    super.initState();
  }

  void _makeFilter() {
    if (_paymentTypeKey == 'all') {
      _filteredPastData = _pastData;
    } else {
      _filteredPastData = _pastData.where((element) => (element.paymentName == _paymentTypeKey)).toList();
    }
  }

  final List<MultipleInAppNotificationItem> _notificationList = [];
  bool _notificationSended = false;

  void _getPastData() {
    _notificationList.clear();
    _data!.forEach((studentKey, allPaymentList) {
      var student = AppVar.appBloc.studentService!.dataList.singleWhereOrNull((student) => student.key == studentKey);

      ///todo silinmis  ogrenciye ait faturalainda gozukmesini istyiorasn  burayi ac
      //  if (student == null) student = Student()..name =  'erasedstudent');
      if (allPaymentList['PaymentPlans'] != null && student != null) {
        (allPaymentList['PaymentPlans'] as Map).forEach((paymentName, paymentValues) {
          if (paymentName == 'custompayment') {
            (paymentValues as Map).forEach((paymentKey, paymentValue) {
              TaksitModel payment = TaksitModel.fromJson(paymentValue);
              final double odennenTutar = (payment.odemeler?.fold<double>(0.0, ((t, v) => t + v.miktar!)) ?? 0);
              if (payment.aktif != false && odennenTutar < payment.tutar! && payment.tarih! < DateTime.now().millisecondsSinceEpoch - 43200000) {
                _pastData.add(PastData(
                  name: student.name,
                  studentKey: studentKey,
                  paymentName: payment.name,
                  tutar: (payment.tutar! - odennenTutar).toDouble(),
                  tarih: payment.tarih,
                ));
                final _message = 'accountingnoificationwarning'.argsTranslate({'date': payment.tarih!.dateFormat("d-MMM-yyyy"), 'amount': (payment.tutar! - odennenTutar).toStringAsFixed(2)}) + ' (' + payment.name! + ')';

                final _existingItemThisStudent = _notificationList.firstWhereOrNull((element) => element.uid == studentKey);
                if (_existingItemThisStudent == null) {
                  final _notification = InAppNotification(title: student.name, content: _message, key: 'SA_${payment.tarih!.dateFormat("d-MM-yyyy")}', type: NotificationType.payment, pageName: PageName.sA)..forParentOtherMenu = true;
                  _notificationList.add(MultipleInAppNotificationItem(uid: studentKey, notification: _notification));
                } else {
                  _notificationList.remove(_existingItemThisStudent);
                  final existingMessage = _existingItemThisStudent.notification.content!;
                  final _notification = InAppNotification(title: student.name, content: existingMessage + '\n' + _message, key: 'SA_${payment.tarih!.dateFormat("d-MM-yyyy")}', type: NotificationType.payment, pageName: PageName.sA)..forParentOtherMenu = true;
                  _notificationList.add(MultipleInAppNotificationItem(uid: studentKey, notification: _notification));
                }
              }
            });
          } else {
            var _realPaymentName = AppVar.appBloc.schoolInfoService!.singleData!.paymentName(paymentName);

            PaymentModel _payments = PaymentModel.fromJson(paymentValues);

            if (_payments.aktif != false) {
              final List<TaksitModel?> paymentList = [];
              if (_payments.pesinUcret != null) {
                paymentList.add(_payments.pesinUcret);
              }
              if (_payments.pesinat != null) {
                paymentList.add(_payments.pesinat);
              }
              if (_payments.taksitler != null) {
                paymentList.addAll(_payments.taksitler!);
              }

              paymentList.forEach((payment) {
                if ((payment!.tutar ?? 0) != 0) {
                  final double odennenTutar = (payment.odemeler?.fold<double>(0, ((t, v) => t + v.miktar!)) ?? 0);
                  if (payment.aktif != false && odennenTutar < payment.tutar! && payment.tarih! < DateTime.now().millisecondsSinceEpoch - 43200000) {
                    _pastData.add(PastData(
                      name: student.name,
                      studentKey: studentKey,
                      paymentName: _realPaymentName,
                      tutar: (payment.tutar! - odennenTutar).toDouble(),
                      tarih: payment.tarih,
                    ));

                    final _message = 'accountingnoificationwarning'.argsTranslate({'date': payment.tarih!.dateFormat("d-MMM-yyyy"), 'amount': (payment.tutar! - odennenTutar).toStringAsFixed(2)}) + ' (' + _realPaymentName! + ')';

                    final _existingItemThisStudent = _notificationList.singleWhereOrNull((element) => element.uid == studentKey);
                    if (_existingItemThisStudent == null) {
                      final _notification = InAppNotification(title: student.name, content: _message, key: 'SA_${payment.tarih!.dateFormat("d-MM-yyyy")}', type: NotificationType.payment, pageName: PageName.sA)..forParentOtherMenu = true;
                      _notificationList.add(MultipleInAppNotificationItem(uid: studentKey, notification: _notification));
                    } else {
                      _notificationList.remove(_existingItemThisStudent);
                      final existingMessage = _existingItemThisStudent.notification.content!;
                      final _notification = InAppNotification(title: student.name, content: existingMessage + '\n' + _message, key: 'SA_${payment.tarih!.dateFormat("d-MM-yyyy")}', type: NotificationType.payment, pageName: PageName.sA)..forParentOtherMenu = true;
                      _notificationList.add(MultipleInAppNotificationItem(uid: studentKey, notification: _notification));
                    }
                  }
                }
              });
            }
          }
        });
      }
    });
    _makeFilter();
  }

  PrintAndExportModel _prepareExportData({bool forExcel = false}) {
    return PrintAndExportModel(columnNames: [
      'name'.translate,
      'paymenttype'.translate,
      'date'.translate,
      'unpaid'.translate,
    ], rows: _filteredPastData.map<List<dynamic>>((e) => [e.name, e.paymentName, e.tarihText, forExcel ? e.tutar : e.tutar.toString()]).toList());
  }

  @override
  Widget build(BuildContext context) {
    final _topBar = TopBar(leadingTitle: 'menu1'.translate);

    if (_isLoading) {
      return AppScaffold(topBar: _topBar, topActions: TopActionsTitle(title: 'accountingstatitictype0'.translate), body: Body.child(child: MyProgressIndicator(isCentered: true)));
    }

    final _topActions = TopActionsTitleWithChild(
        title: TopActionsTitle(title: 'accountingstatitictype0'.translate),
        child: AdvanceDropdown(
          name: 'paymenttype'.translate,
          items: AppConst.accountingType.map((paymentType) {
            final _realPaymentName = AppVar.appBloc.schoolInfoService!.singleData!.paymentName(paymentType);
            return DropdownItem(name: _realPaymentName, value: _realPaymentName);
          }).toList()
            ..add(DropdownItem(name: 'all'.translate, value: 'all')),
          onChanged: (dynamic value) {
            setState(() {
              _paymentTypeKey = value;
              _makeFilter();
            });
          },
          initialValue: _paymentTypeKey,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ));

    final _body = Body.listviewBuilder(
      itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
              color: index.isOdd ? (Fav.design.others["scaffold.background"] ?? Fav.design.scaffold.background).withAlpha(150) : Fav.design.scaffold.accentBackground.withAlpha(150), border: index != 0 ? Border(top: BorderSide(color: Fav.design.primaryText.withAlpha(30), width: 1)) : null),
          child: StatisticsTile(pastData: _filteredPastData[index])),
      itemCount: _filteredPastData.length,
      maxWidth: 800,
    );
    final _bottomBar = BottomBar(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!_notificationSended)
          MyMiniRaisedButton(
            onPressed: () async {
              final _sure = await Over.sure();
              if (_sure != true) return;
              OverLoading.show();
              await InAppNotificationService.sendMultipleInAppNotification(_notificationList, notificationTag: PageName.sA.name)!.then((value) {
                OverAlert.show(message: 'sendnotificationsuc'.translate + ' (' + 'piece'.argTranslate(_notificationList.length.toString()) + ')', autoClose: false);
              });
              await OverLoading.close();
              setState(() {
                _notificationSended = true;
              });
            },
            text: 'batchnotification'.translate,
          ),
        16.widthBox,
        MyMiniRaisedButton(
          text: Words.print,
          onPressed: () {
            PrintAndExportHelper.printPdf(data: _prepareExportData(forExcel: false), pdfHeaderName: 'accountingstatitictype0'.translate);
          },
          iconData: Icons.print,
        ),
        16.widthBox,
        MyMiniRaisedButton(
          text: 'exportexcell'.translate,
          onPressed: () {
            PrintAndExportHelper.exportToExcel(data: _prepareExportData(forExcel: true), excelName: 'accountingstatitictype0'.translate);
          },
          iconData: Icons.print,
        ),
        16.widthBox,
      ],
    ));

    return AppScaffold(
      topBar: _topBar,
      topActions: _topActions,
      body: _body,
      bottomBar: _bottomBar,
    );
  }
}

class StatisticsTile extends StatelessWidget {
  final PastData? pastData;

  StatisticsTile({this.pastData});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(
          pastData!.name!,
          style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          pastData!.paymentName! + ' ${pastData!.tarihText}',
          style: TextStyle(color: Fav.design.primaryText, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              pastData!.tutar!.toStringAsFixed(2),
              style: TextStyle(color: Fav.design.accentText),
            ),
            8.widthBox,
            IconButton(
              icon: Icon(
                Icons.send,
                color: Fav.design.primaryText,
              ),
              onPressed: () async {
                final _message = 'accountingnoificationwarning'.argsTranslate({'date': pastData!.tarihText, 'amount': pastData!.tutar!.toStringAsFixed(2)}) + ' (' + pastData!.paymentName! + ')';
                final _sure = await Over.sure(message: _message);
                if (_sure != true) return;
                final _notification = InAppNotification(title: pastData!.name, content: _message, key: 'SA_${pastData!.tarihText.removeNonEnglishCharacter}', type: NotificationType.payment)
                  ..forParentOtherMenu = true
                  ..pageName = PageName.sA;
                OverLoading.show();
                await InAppNotificationService.sendInAppNotification(_notification, pastData!.studentKey!, notificationTag: PageName.sA.name).then((value) {
                  OverAlert.show(title: 'sendnotificationsuc'.translate + ' - ' + pastData!.name!, message: _message, autoClose: false);
                });
                await OverLoading.close();
              },
            )
          ],
        ));
  }
}
