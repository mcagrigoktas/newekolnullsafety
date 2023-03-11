import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../appbloc/appvar.dart';
import '../../models/allmodel.dart';
import '../../screens/mesagging/messagehelper.dart';
import '../exporthelper.dart';
import '../numbertotext.dart';
import 'printhelper.dart';

class PrintAccounting {
  static Future<void> printStudentAccountingForTurkey(Student student, List<String> columnNames, PaymentModel paymentData) async {
    const tcLogoUrl = 'https://eokul.fra1.digitaloceanspaces.com/01asset/tclogo.png';

    final doc = pw.Document();
    var newColumnNames = List<String>.from(columnNames);
    newColumnNames[4] = 'date'.translate;
    newColumnNames.add('note'.translate);
    List<String> getRow(TaksitModel taksit) {
      double odenen = taksit.odemeler?.fold<double>(0.0, ((total, value) => total + value.miktar!)) ?? 0.0;
      return [
        taksit.name!,
        taksit.tarih!.dateFormat("d-MMM-yy"),
        taksit.tutar!.toStringAsFixed(2),
        odenen > 1 ? odenen.toStringAsFixed(2) : '_____',
        '_____',
        '_____',
      ];
    }

    List<List<String>> rows = [];
    rows.add(getRow(paymentData.pesinat!));

    if (paymentData.odemeTuru == 0) {
      rows.add(getRow(paymentData.pesinUcret!));
    } else {
      paymentData.taksitler!.forEach((taksit) {
        rows.add(getRow(taksit));
      });
    }

    var studentData = ExportHelper.setupStudentList(studentKey: student.key);
    Map studentMap = {};
    for (var i = 0; i < (studentData.first).length; i++) {
      if ([
        "studentno".translate,
        'namesurname'.translate,
        'username'.translate,
        'password'.translate,
        'classtype0'.translate,
        'genre'.translate,
        'tc'.translate,
        'starttime'.translate,
        "student".translate + " " + "phone".translate,
        'adress'.translate,
        'birthday'.translate,
        'bloodgenre'.translate,
        "father".translate + " " + "name2".translate,
        "father".translate + " " + "phone".translate,
        "father".translate + " " + "mail".translate,
        "father".translate + " " + "job".translate,
        "father".translate + " " + "birthday".translate,
        "mother".translate + " " + "name2".translate,
        "mother".translate + " " + "phone".translate,
        "mother".translate + " " + "mail".translate,
        "mother".translate + " " + "job".translate,
        "mother".translate + " " + "birthday".translate,
      ].contains(studentData.first[i])) studentMap[studentData.first[i]] = studentData.last[i];
    }
    // ignore: unused_local_variable
    final username = studentMap['username'.translate];
    final password = studentMap['password'.translate];
    final adress = studentMap['adress'.translate];
    // ignore: unused_local_variable
    final parentPassword = McgFunctions.mcgStringNumberKey(password)! + '-' + password;
    studentMap.remove('username'.translate);
    studentMap.remove('password'.translate);
    studentMap.remove('adress'.translate);
    await PrintHelper.printMultiplePagePdf([
      pw.Row(children: [
        pw.Image(pw.MemoryImage((await DownloadManager.downloadThenCache(url: tcLogoUrl))!.byteData), width: 40),
        pw.Expanded(
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Text('T.C.\nMİLLÎ EĞİTİM BAKANLIĞI\nÖZEL ÖĞRETİM KURUMLARI GENEL MÜDÜRLÜĞÜ\nÖĞRENCİ KAYIT SÖZLEŞMESİ', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('(ÖZEL OKULLAR)', textAlign: pw.TextAlign.center, style: const pw.TextStyle()),
        ])),
        pw.Image(
            pw.MemoryImage((await DownloadManager.downloadThenCache(
              url: tcLogoUrl,
            ))!
                .byteData),
            width: 40),
      ]),
      pw.SizedBox(height: 8),
      pw.Row(children: [
        pw.Text('Özel Okul Adı: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(AppVar.appBloc.schoolInfoService!.singleData!.name, style: const pw.TextStyle()),
      ]),
      pw.SizedBox(height: 8),
      PrintWidgetHelper.myTextContainer(color: PdfColors.grey, text: 'ÖĞRENCİNİN BİLGİLERİ', bold: true, padding: 4),
      ...[
        ['T.C. Kimlik No', student.tc],
        ['Adı ve Soyadı', student.name],
        [' Veli/Vasi Adı ve Soyadı', ''],
        ['Sınıfı', studentMap['classtype0'.translate]],
        ['Okula kayıt /nakil tarihi', ExportHelper.formatDate(student.startTime)],
        ['Ev adresi', adress],
      ]
          .map((e) => pw.Row(children: [
                pw.Expanded(child: PrintWidgetHelper.myBorderedContainer(padding: 4, text: e.first, height: 24, fontSize: 10), flex: 2),
                pw.Expanded(child: PrintWidgetHelper.myBorderedContainer(padding: 4, text: e.last, height: 24, bold: false, alignmentIsCenter: false, fontSize: 10), flex: 5),
              ]))
          .toList(),
      pw.SizedBox(height: 8),
      pw.Row(children: [
        pw.Expanded(
            child: pw.Column(children: [
          PrintWidgetHelper.myTextContainer(color: PdfColors.grey, text: 'ÖĞRENCİNİN ANNE BİLGİLERİ', bold: true, padding: 4),
          ...[
            ['T.C. Kimlik No', ''],
            ['Adı ve Soyadı', student.motherName ?? ''],
            ['Mesleği', student.motherJob ?? ''],
            ['Cep telefonu', student.motherPhone ?? ''],
            ['İş telefonu', ''],
            ['Ev adresi', ''],
            ['İş adresi', ''],
            ['E-Posta', student.motherMail ?? ''],
          ]
              .map((e) => pw.Row(children: [
                    pw.Expanded(child: PrintWidgetHelper.myBorderedContainer(padding: 4, text: e.first, height: 24, fontSize: 10), flex: 2),
                    pw.Expanded(child: PrintWidgetHelper.myBorderedContainer(padding: 4, text: e.last, height: 24, bold: false, alignmentIsCenter: false, fontSize: 10), flex: 5),
                  ]))
              .toList(),
        ])),
        pw.SizedBox(width: 8),
        pw.Expanded(
            child: pw.Column(children: [
          PrintWidgetHelper.myTextContainer(color: PdfColors.grey, text: 'ÖĞRENCİNİN BABA BİLGİLERİ', bold: true, padding: 4),
          ...[
            ['T.C. Kimlik No', ''],
            ['Adı ve Soyadı', student.fatherName ?? ''],
            ['Mesleği', student.fatherJob ?? ''],
            ['Cep telefonu', student.fatherPhone ?? ''],
            ['İş telefonu', ''],
            ['Ev adresi', ''],
            ['İş adresi', ''],
            ['E-Posta', student.fatherMail ?? ''],
          ]
              .map((e) => pw.Row(children: [
                    pw.Expanded(child: PrintWidgetHelper.myBorderedContainer(padding: 4, text: e.first, height: 24, fontSize: 10), flex: 2),
                    pw.Expanded(child: PrintWidgetHelper.myBorderedContainer(padding: 4, text: e.last, height: 24, bold: false, alignmentIsCenter: false, fontSize: 10), flex: 5),
                  ]))
              .toList(),
        ])),
      ]),
      pw.SizedBox(height: 8),
      PrintWidgetHelper.myTextContainer(color: PdfColors.grey, text: 'ÖĞRENCİNİN VASİ BİLGİLERİ  (VARSA)', bold: true, padding: 4),
      ...[
        ['T.C. Kimlik No', ''],
        ['Adı ve Soyadı', ''],
        ['Mesleği', ''],
        ['Cep telefonu', ''],
        ['Ev telefonu', ''],
        ['İş telefonu', ''],
        ['Ev adresi', ''],
        ['İş adresi', ''],
        ['E-Posta', ''],
      ]
          .map((e) => pw.Row(children: [
                pw.Expanded(child: PrintWidgetHelper.myBorderedContainer(padding: 4, text: e.first, height: 24, fontSize: 10), flex: 2),
                pw.Expanded(child: PrintWidgetHelper.myBorderedContainer(padding: 4, text: e.last, height: 24, bold: false, alignmentIsCenter: false, fontSize: 10), flex: 5),
              ]))
          .toList(),
      pw.Column(children: [
        pw.Container(height: 20, width: double.infinity, alignment: pw.Alignment.center, color: PdfColors.grey, child: pw.Text('mypaymentplan'.translate.toUpperCase(), style: pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 4),
        ...[
          ['dateofcontract'.translate, paymentData.sozlesmeTarihi!.dateFormat("d-MMM-yy")],
          ['startprice'.translate, paymentData.baslangicTutari!.toStringAsFixed(2)],
          if (paymentData.ekBaslangicTutari != null) ...paymentData.ekBaslangicTutari!.map((e) => [e.name, e.value!.toStringAsFixed(2)]),
          if (paymentData.indirimler != null) ...paymentData.indirimler!.map((e) => [e.name, '-' + e.oran.toString() + (e.type == 0 ? '%' : '')]),
          ['contractamount'.translate, paymentData.tutar!.toStringAsFixed(2)],
        ]
            .map<pw.Widget>(((e) => pw.Row(children: [
                  pw.Expanded(child: PrintWidgetHelper.myBorderedContainer(padding: 4, text: e.first as String, height: 24, fontSize: 10), flex: 2),
                  pw.Expanded(child: PrintWidgetHelper.myBorderedContainer(padding: 4, text: e.last as String, height: 24, bold: false, alignmentIsCenter: false, fontSize: 10), flex: 5),
                ])))
            .toList(),
        pw.SizedBox(height: 4),
        PrintWidgetHelper.makeTable(newColumnNames, rows),
      ]),
    ], doc: doc);
  }

  static Future<void> printStudentAccounting(Student student, List<String> columnNames, PaymentModel paymentData) async {
    final doc = pw.Document();
    var newColumnNames = List<String>.from(columnNames);
    newColumnNames[4] = 'date'.translate;
    newColumnNames.add('note'.translate);
    List<String> getRow(TaksitModel taksit) {
      double odenen = taksit.odemeler?.fold<double>(0.0, ((total, value) => total + value.miktar!)) ?? 0.0;
      return [
        taksit.name!,
        taksit.tarih!.dateFormat("d-MMM-yy"),
        taksit.tutar!.toStringAsFixed(2),
        odenen > 1 ? odenen.toStringAsFixed(2) : '_____',
        '_____',
        '_____',
      ];
    }

    List<List<String>> rows = [];
    rows.add(getRow(paymentData.pesinat!));

    if (paymentData.odemeTuru == 0) {
      rows.add(getRow(paymentData.pesinUcret!));
    } else {
      paymentData.taksitler!.forEach((taksit) {
        rows.add(getRow(taksit));
      });
    }

    var studentData = ExportHelper.setupStudentList(studentKey: student.key);
    Map studentMap = {};
    for (var i = 0; i < (studentData.first).length; i++) {
      if ([
        "studentno".translate,
        'namesurname'.translate,
        'username'.translate,
        'password'.translate,
        'classtype0'.translate,
        'genre'.translate,
        'tc'.translate,
        'starttime'.translate,
        "student".translate + " " + "phone".translate,
        'adress'.translate,
        'birthday'.translate,
        'bloodgenre'.translate,
        "father".translate + " " + "name2".translate,
        "father".translate + " " + "phone".translate,
        "father".translate + " " + "mail".translate,
        "father".translate + " " + "job".translate,
        "father".translate + " " + "birthday".translate,
        "mother".translate + " " + "name2".translate,
        "mother".translate + " " + "phone".translate,
        "mother".translate + " " + "mail".translate,
        "mother".translate + " " + "job".translate,
        "mother".translate + " " + "birthday".translate,
      ].contains(studentData.first[i])) studentMap[studentData.first[i]] = studentData.last[i];
    }
    final username = studentMap['username'.translate];
    final password = studentMap['password'.translate];
    final adress = studentMap['adress'.translate];
    final parentPassword = McgFunctions.mcgStringNumberKey(password)! + '-' + password;
    studentMap.remove('username'.translate);
    studentMap.remove('password'.translate);
    studentMap.remove('adress'.translate);
    await PrintHelper.printPdf(
      pw.Column(children: [
        pw.Row(children: [
          await EkolPrintHelper.schoolLogo(doc),
          pw.SizedBox(width: 16),
          EkolPrintHelper.schoolInfo(),
          pw.Spacer(),
          pw.Column(children: [
            pw.Text("studentno".translate + ': ' + student.no!, style: const pw.TextStyle(color: PdfColors.black)),
            pw.Text("starttime".translate + ': ' + ExportHelper.formatDate(student.startTime), style: const pw.TextStyle(color: PdfColors.black)),
          ])
        ]),
        pw.SizedBox(height: 8),
        pw.Container(height: 20, width: double.infinity, alignment: pw.Alignment.center, color: PdfColors.deepOrange, child: pw.Text('infos'.translate.toUpperCase(), style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 4),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
                child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
              for (var i = 0; i < studentMap.length; i++)
                if (i.isEven) PrintWidgetHelper.keyValueWidget(studentMap.entries.toList()[i].key, studentMap.entries.toList()[i].value),
            ])),
            pw.Expanded(
                child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
              for (var i = 0; i < studentMap.length; i++)
                if (i.isOdd) PrintWidgetHelper.keyValueWidget(studentMap.entries.toList()[i].key, studentMap.entries.toList()[i].value),
            ])),
          ],
        ),

        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: PrintWidgetHelper.keyValueColumnWidget('username'.translate, username)),
            pw.Expanded(child: PrintWidgetHelper.keyValueColumnWidget('password'.translate, password)),
            if (MessageHelper.isParentMessageActive()) pw.Expanded(child: PrintWidgetHelper.keyValueColumnWidget('parentpassword'.translate, parentPassword)),
            pw.Expanded(child: PrintWidgetHelper.keyValueColumnWidget('kurumid'.translate, AppVar.appBloc.hesapBilgileri.kurumID)),
          ],
        ),
        if (MessageHelper.isParentMessageActive()) pw.Text('parentmessagehint'.translate, textAlign: pw.TextAlign.center, style: const pw.TextStyle(color: PdfColors.black, fontSize: 8)),
        if (MessageHelper.isParentMessageActive()) pw.SizedBox(height: 8),
        PrintWidgetHelper.keyValueWidget('adress'.translate, adress, valueFlex: 3),
        pw.SizedBox(height: 16),
        pw.Container(height: 20, width: double.infinity, alignment: pw.Alignment.center, color: PdfColors.deepOrange, child: pw.Text('mypaymentplan'.translate.toUpperCase(), style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 4),
        pw.Row(children: [
          pw.Expanded(child: PrintWidgetHelper.keyValueWidget('dateofcontract'.translate, paymentData.sozlesmeTarihi!.dateFormat("d-MMM-yy"))),
          pw.Expanded(child: PrintWidgetHelper.keyValueWidget('startprice'.translate, paymentData.baslangicTutari!.toStringAsFixed(2))),
          if (paymentData.ekBaslangicTutari != null) ...paymentData.ekBaslangicTutari!.map((e) => pw.Expanded(child: PrintWidgetHelper.keyValueWidget(e.name, e.value!.toStringAsFixed(2)))),
          pw.Expanded(child: PrintWidgetHelper.keyValueWidget('contractamount'.translate, paymentData.tutar!.toStringAsFixed(2))),
        ]),

//          if ((data.indirimler?.length ?? 0) > 0)
//            Column(
//              children: data.indirimler
//                  .map(
//                    (indirim) => Padding(
//                  padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
//                  child: Row(
//                    mainAxisSize: MainAxisSize.min,
//                    children: <Widget>[
//                      Text(indirim.name + ': ', style: TextStyle(color: Fav.design.primaryText, fontWeight: FontWeight.bold, fontSize: 12)),
//                      Text('-' + indirim.oran.toString() + '%', style: TextStyle(color: Fav.design.primaryText, fontSize: 12)),
//                    ],
//                  ),
//                ),
//              )
//                  .toList(),
//            )

        pw.SizedBox(height: 4),
        PrintWidgetHelper.makeTable(newColumnNames, rows),
      ]),
      doc: doc,
    );
  }

  static Future<void> printMakbuz(BuildContext context, Student student, {faturaNo, required String paymentTypeKey, required String paymentName, tutar, int? date}) async {
    final _realPaymentName = AppVar.appBloc.schoolInfoService!.singleData!.paymentName(paymentTypeKey);

    final doc = pw.Document();

    var logo = await EkolPrintHelper.schoolLogo(doc);

    String? sinifText = AppVar.appBloc.classService!.dataListItem(student.class0 ?? '-')?.name;
    String sinifStudentNoText = (sinifText ?? '-') + ' / ' + (student.no ?? '-');

    pw.Widget makbuz = pw.Column(children: [
      pw.SizedBox(height: 16),
      pw.Container(
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue, width: 1)),
        child: pw.Row(children: [
          pw.Expanded(
              flex: 2,
              child: pw.Container(
                  decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))),
                  child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                    logo,
                    pw.SizedBox(width: 16),
                    pw.Text(AppVar.appBloc.schoolInfoService!.singleData!.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ]))),
          pw.Expanded(
              flex: 1,
              child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                pw.SizedBox(height: 4),
                pw.Text('makbuz'.translate),
                pw.SizedBox(height: 2),
                pw.Text('${'makbuzno'.translate}: $faturaNo'),
                pw.SizedBox(height: 2),
                pw.Text('${'date'.translate}: ${(date ?? DateTime.now().millisecondsSinceEpoch).dateFormat()}'),
                pw.SizedBox(height: 4),
              ])),
        ]),
      ),
      pw.SizedBox(height: 8),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        width: double.infinity,
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue, width: 1)),
        child: pw.Text('student'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue, width: 1), right: pw.BorderSide(color: PdfColors.blue, width: 1), left: pw.BorderSide(color: PdfColors.blue, width: 1))),
        child: pw.Row(children: [
          pw.Expanded(flex: 2, child: pw.Container(decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))), child: pw.Text('name'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
          pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(student.name))),
        ]),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue, width: 1), right: pw.BorderSide(color: PdfColors.blue, width: 1), left: pw.BorderSide(color: PdfColors.blue, width: 1))),
        child: pw.Row(children: [
          pw.Expanded(flex: 2, child: pw.Container(decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))), child: pw.Text('classtype0'.translate + ' / ' + 'studentno'.translate + ' :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
          pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(sinifStudentNoText))),
        ]),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue, width: 1), right: pw.BorderSide(color: PdfColors.blue, width: 1), left: pw.BorderSide(color: PdfColors.blue, width: 1))),
        child: pw.Row(children: [
          pw.Expanded(flex: 2, child: pw.Container(decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))), child: pw.Text('paymenttype'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
          pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(_realPaymentName.translate))),
        ]),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue, width: 1), right: pw.BorderSide(color: PdfColors.blue, width: 1), left: pw.BorderSide(color: PdfColors.blue, width: 1))),
        child: pw.Row(children: [
          pw.Expanded(flex: 2, child: pw.Container(decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))), child: pw.Text('taksitno'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
          pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(paymentName))),
        ]),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue, width: 1), right: pw.BorderSide(color: PdfColors.blue, width: 1), left: pw.BorderSide(color: PdfColors.blue, width: 1))),
        child: pw.Row(children: [
          pw.Expanded(flex: 2, child: pw.Container(decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))), child: pw.Text('paymentamount'.translate + ':', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)))),
          //todo para birimi ayarlanacak
          pw.Expanded(flex: 1, child: pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 16), child: pw.Text(tutar.toString() + '₺'))),
        ]),
      ),
      pw.SizedBox(height: 8),
      pw.Container(
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue, width: 1)),
        child: pw.Row(children: [
          pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 64,
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))),
                child: pw.Text('whopay'.translate + ':'),
              )),
          pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 64,
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))),
                child: pw.Text('name'.translate + ':'),
              )),
          pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 64,
                padding: const pw.EdgeInsets.all(8),
                decoration: const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(color: PdfColors.blue, width: 1))),
                child: pw.Text('signature'.translate + ':'),
              )),
        ]),
      ),
    ]);

    await PrintHelper.printPdf(
        pw.Column(children: [
          pw.Expanded(child: makbuz),
          pw.Expanded(child: makbuz),
        ]),
        doc: doc);
  }

  static Future<void> printAccountingVoucher(BuildContext context, Student? student, List<String> columnNames, PaymentModel paymentData) async {
    Map userData = {};
    GlobalKey<FormState> formKey = GlobalKey();
    bool cancel = false;
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Material(
              color: Colors.transparent,
              child: Form(
                key: formKey,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 750),
                      decoration: BoxDecoration(color: Fav.design.scaffold.background, borderRadius: BorderRadius.circular(32)),
                      padding: const EdgeInsets.all(32),
                      child: Group2Widget(
                        children: [
                          MyTextFormField(
                              labelText: 'vouchercompnyname'.translate,
                              validatorRules: ValidatorRules(),
                              initialValue: Fav.preferences.getString('vouchercompnyname') ?? AppVar.appBloc.schoolInfoService!.singleData!.name,
                              onSaved: (value) {
                                userData['vouchercompnyname'] = value;
                                Fav.preferences.setString('vouchercompnyname', value);
                              }),
                          MyTextFormField(
                              labelText: 'voucherno'.translate,
                              validatorRules: ValidatorRules(),
                              initialValue: '',
                              onSaved: (value) {
                                userData['voucherno'] = value.safeLength > 0 ? value : '-';
                              }),
                          MyTextFormField(
                              labelText: 'vouchername'.translate,
                              validatorRules: ValidatorRules(req: true, minLength: 4),
                              initialValue: student!.fatherName ?? '',
                              onSaved: (value) {
                                userData['vouchername'] = value;
                              }),
                          MyTextFormField(
                              labelText: 'tc'.translate,
                              validatorRules: ValidatorRules(),
                              initialValue: '',
                              onSaved: (value) {
                                userData['tc'] = value;
                              }),
                          MyTextFormField(
                              labelText: 'adress'.translate,
                              validatorRules: ValidatorRules(),
                              initialValue: student.adress ?? '',
                              onSaved: (value) {
                                userData['adress'] = value;
                              }),
                          MyTextFormField(
                              labelText: 'vouchertaxinfo'.translate,
                              validatorRules: ValidatorRules(),
                              initialValue: '',
                              onSaved: (value) {
                                userData['vouchertaxinfo'] = value;
                              }),
                          8.heightBox,
                          Text(
                            'voucherotherperson'.translate,
                            style: TextStyle(color: Fav.design.primaryText),
                          ),
                          8.heightBox,
                          MyTextFormField(
                              labelText: 'name'.translate,
                              validatorRules: ValidatorRules(),
                              initialValue: '',
                              onSaved: (value) {
                                userData['voucherotherperson'] = value;
                              }),
                          MyTextFormField(
                              labelText: 'tc'.translate,
                              validatorRules: ValidatorRules(),
                              initialValue: '',
                              onSaved: (value) {
                                userData['tc2'] = value;
                              }),
                          MyTextFormField(
                              labelText: 'vouchertaxinfo'.translate,
                              validatorRules: ValidatorRules(),
                              initialValue: '',
                              onSaved: (value) {
                                userData['vouchertaxinfo2'] = value;
                              }),
                          MyTextFormField(
                              labelText: 'term'.translate,
                              validatorRules: ValidatorRules(),
                              initialValue: AppVar.appBloc.schoolInfoService!.singleData!.activeTerm,
                              onSaved: (value) {
                                userData['term'] = value;
                              }),
                          AdvanceDropdown(
                              name: 'parabirimi'.translate,
                              validatorRules: ValidatorRules(),
                              items: [
                                DropdownItem(value: '₺', name: '₺'),
                                //     DropdownMenuItem(value: '\$', child: Text('\$', style: TextStyle(color:  Fav.design.primaryText))),
                              ],
                              onSaved: (value) {
                                userData['parabirimi'] = value;
                              }),
                          MyTextFormField(
                              labelText: 'courtname'.translate,
                              validatorRules: ValidatorRules(),
                              initialValue: Fav.preferences.getString('courtname', ''),
                              onSaved: (value) {
                                userData['courtname'] = value;
                                Fav.preferences.setString('courtname', value.toString());
                              }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MyRaisedButton(
                                text: 'cancel'.translate,
                                onPressed: () {
                                  cancel = true;
                                  Get.back();
                                },
                              ),
                              MyRaisedButton(
                                text: 'next'.translate,
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    formKey.currentState!.save();
                                    Get.back();
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (cancel) return;
    final doc = pw.Document();

    List<TaksitModel> taksitList = [];

    if (paymentData.odemeTuru == 0) {
      taksitList.add(paymentData.pesinUcret!);
    } else {
      paymentData.taksitler!.forEach((taksit) {
        taksitList.add(taksit);
      });
    }
    var logo = await EkolPrintHelper.schoolLogo(doc);
    await PrintHelper.printMultiplePagePdf(
      [
        ...taksitList.map((e) {
          return pw.Container(
              // color: PdfColor(0, 0, 0, 0.1).flatten(),
              padding: taksitList.indexOf(e).isEven ? const pw.EdgeInsets.only(bottom: 40) : const pw.EdgeInsets.only(top: 40),
              child: pw.Row(children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      logo,
                      pw.SizedBox(height: 64),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('voucherno'.translate + ': ${userData['voucherno']}', style: const pw.TextStyle(fontSize: 11)),
                          pw.Text('vouchertl'.translate + ': ${e.tutar!.toInt()}', style: const pw.TextStyle(fontSize: 11)),
                          pw.Text('vouchertl2'.translate + ': 0', style: const pw.TextStyle(fontSize: 11)),
                          pw.Text('vouchername'.translate + ': ${userData['vouchername']}', style: const pw.TextStyle(fontSize: 11)),
                          pw.Text('voucherexpiry'.translate + ': ${e.name}', style: const pw.TextStyle(fontSize: 11)),
                          pw.Text('date'.translate + ': ${e.tarih!.dateFormat("d-MM-yyyy")}', style: const pw.TextStyle(fontSize: 11)),
                        ],
                      ),
                      pw.SizedBox(height: 16),
                    ],
                  ),
                ),
                pw.Container(width: 1, height: 250, color: PdfColors.blue200, margin: const pw.EdgeInsets.all(8)),
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    children: [
                      pw.SizedBox(height: 16),
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                          children: <List<String>>[
                            ['voucherdate', e.tarih!.dateFormat("d-MM-yyyy")],
                            ['vouchertl3', '#${e.tutar!.toInt()}#${userData['parabirimi']}'],
                            ['vouchertl2', '0'],
                            ['voucherno', '${userData['voucherno']}'],
                          ]
                              .map((item) => pw.Column(
                                    children: [
                                      pw.Text(item[0].translate, style: const pw.TextStyle(fontSize: 11)),
                                      pw.Container(width: 70, height: 1, color: PdfColors.blue),
                                      pw.Text(item[1].translate, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                                    ],
                                  ))
                              .toList()),
                      pw.SizedBox(height: 16),
                      pw.Text(
                          'vounchertext'.argsTranslate({
                            'date': e.tarih!.dateFormat(),
                            'company': userData['vouchercompnyname'],
                            'amount': NumberToText.change(e.tutar!.toInt()),
                            'penny': '${0}',
                            'courtname': userData['courtname'],
                          }),
                          textAlign: pw.TextAlign.justify,
                          style: const pw.TextStyle(fontSize: 11)),
                      pw.SizedBox(height: 16),
                      pw.Container(
                          height: 160,
                          child: pw.LayoutBuilder(builder: (_, constratints) {
                            return pw.Stack(children: [
                              pw.Align(
                                  alignment: pw.Alignment.topLeft,
                                  child: pw.Padding(
                                      padding: pw.EdgeInsets.only(top: 28),
                                      child: pw.Transform.rotateBox(
                                        angle: math.pi / 2,
                                        child: pw.Text('voucherlegand1'.translate, style: const pw.TextStyle(fontSize: 11)),
                                      ))),
                              pw.Positioned(
                                  left: 26,
                                  top: 0,
                                  bottom: 0,
                                  right: constratints!.maxWidth / 2,
                                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                                    pw.Text('name'.translate + ': ${userData['vouchername']}', style: const pw.TextStyle(fontSize: 11)),
                                    pw.Text('adress'.translate + ': ', style: const pw.TextStyle(fontSize: 11)),
                                    pw.Text(userData['adress'], style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.normal)),
                                    pw.Text('tc'.translate + ': ${userData['tc']}', style: const pw.TextStyle(fontSize: 11)),
                                    pw.Text('vouchertaxinfo'.translate + ': ${userData['vouchertaxinfo']}', style: const pw.TextStyle(fontSize: 11)),
                                    pw.Text('voucherotherperson'.translate + ': ${userData['voucherotherperson']}', style: const pw.TextStyle(fontSize: 11)),
                                    pw.Text('tc'.translate + ': ${userData['tc2']}', style: const pw.TextStyle(fontSize: 11)),
                                    pw.Text('vouchertaxinfo'.translate + ': ${userData['vouchertaxinfo2']}', style: const pw.TextStyle(fontSize: 11)),
                                  ])),
                              pw.Align(
                                  alignment: pw.Alignment.topLeft,
                                  child: pw.Padding(
                                      padding: pw.EdgeInsets.only(top: 28, left: constratints.maxWidth / 2),
                                      child: pw.Transform.rotateBox(
                                        angle: math.pi / 2,
                                        child: pw.Text('voucherlegand1'.translate, style: const pw.TextStyle(fontSize: 11)),
                                      ))),
                              pw.Positioned(
                                  left: constratints.maxWidth / 2 + 26,
                                  top: 0,
                                  bottom: 0,
                                  right: 0,
                                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                                    pw.Text('tc'.translate + ': ${student!.tc}', style: const pw.TextStyle(fontSize: 11)),
                                    pw.Text('name'.translate + ': ${student.name}', style: const pw.TextStyle(fontSize: 11)),
                                    pw.Text('phone'.translate + ': ${student.studentPhone}', style: const pw.TextStyle(fontSize: 11)),
                                    pw.Text('term'.translate + ': ${userData['term']}', style: const pw.TextStyle(fontSize: 11)),
                                    pw.Text('date'.translate + ': ${DateTime.now().dateFormat("d-MMM-yyyy")}', style: const pw.TextStyle(fontSize: 11)),
                                    pw.SizedBox(height: 16),
                                    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly, children: [
                                      pw.Expanded(child: pw.Text('signature'.translate, style: const pw.TextStyle(fontSize: 11))),
                                      pw.Expanded(child: pw.Text('signature'.translate, style: const pw.TextStyle(fontSize: 11))),
                                    ])
                                  ]))
                            ]);
                          }))
                    ],
                  ),
                ),
              ]));
        }).toList()
      ],
      doc: doc,
    );
  }

  // static void printShowPayments(List<List<String>> data) {
  //   final doc = pw.Document();
  //   PrintHelper.printMultiplePagePdf(
  //     [
  //       PrintWidgetHelper.myTextContainer(text: 'showpayments'.translate),
  //       PrintWidgetHelper.makeTable(
  //         data.first,
  //         data.sublist(1),
  //       )
  //     ],
  //     doc: doc,
  //   );
  // }

  // static void printPastStatistics(List<List<String>> data) {
  //   final doc = pw.Document();
  //   PrintHelper.printMultiplePagePdf([
  //     PrintWidgetHelper.myTextContainer(text: 'accountingstatitictype0'.translate),
  //     PrintWidgetHelper.makeTable(
  //       data.first,
  //       data.sublist(1),
  //     )
  //   ], doc: doc);
  // }

  // static void printMonthlyStatistics(List<List<String>> data) {
  //   final doc = pw.Document();
  //   PrintHelper.printMultiplePagePdf(
  //     [
  //       PrintWidgetHelper.myTextContainer(text: 'accountingstatitictype1'.translate),
  //       PrintWidgetHelper.makeTable(
  //         data.first,
  //         data.sublist(1),
  //       )
  //     ],
  //     doc: doc,
  //   );
  // }
}
