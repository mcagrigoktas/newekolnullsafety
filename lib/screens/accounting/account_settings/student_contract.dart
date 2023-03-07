//? bu sayfa iyi bir rich text editor gelene kadar pasife alindi save kismi ve bir cok kisiim guzel calisiyor
// import 'package:flutter/material.dart';
// import 'package:html_editor_enhanced/html_editor.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/mywidgets.dart';
// import 'package:widgetpackage/widgetpackage.dart';

// import '../../../appbloc/appvar.dart';
// import '../../../services/setdataservice.dart';
// import 'richtextprint.dart';

// class StudentContractEditor extends StatefulWidget {
//   StudentContractEditor({Key key}) : super(key: key);
//   @override
//   _StudentContractEditorState createState() => _StudentContractEditorState();
// }

// class _StudentContractEditorState extends State<StudentContractEditor> {
//   bool _isLoading = false;
//   HtmlEditorController controller = HtmlEditorController(processInputHtml: false, processNewLineAsBr: true, processOutputHtml: false);

//   Future<void> _save() async {
//     final _text = await controller.getText();
//     await SetDataService.saveStudentContractTemplate(_text).then((value) {
//       OverAlert.saveSuc();
//       _isLoading = false;
//       setState(() {});
//     }).catchError((err) {
//       OverAlert.saveErr();
//       _isLoading = false;
//       setState(() {});
//     });
//   }

//   @override
//   void initState() {
//     controller = HtmlEditorController(processInputHtml: false, processNewLineAsBr: true, processOutputHtml: false);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//             child: RichTextEditor(
//           controller: controller,
//           initialText: AppVar.appBloc.schoolInfoForManagerService.singleData.studentContractTemplate ?? '',
//         )),
//         Column(
//           children: [
//             if (isDebugMode)
//               MyRaisedButton(
//                   onPressed: () async {
//                     log(await controller.getText());
//                   },
//                   text: 'text'),
//             Expanded(
//               child: Scroller(
//                 child: Column(
//                   children: [
//                     Card(
//                       color: Fav.design.primary,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           'addtwoline'.translate.text.color(Colors.white).bold.make(),
//                           Text('Enter', style: TextStyle(color: Colors.white)),
//                         ],
//                       ).p8,
//                     ),
//                     Card(
//                       color: Fav.design.primary,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           'addoneline'.translate.text.color(Colors.white).bold.make(),
//                           Text('Shift + Enter', style: TextStyle(color: Colors.white)),
//                         ],
//                       ).p8,
//                     ),
//                     ...<List<String>>[
//                       [
//                         'date',
//                         '{{date}}',
//                       ],
//                       [
//                         'parentname',
//                         '{{parentName}}',
//                       ],
//                     ]
//                         .map((e) => Card(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   e.first.translate.text.color(Fav.design.primary).bold.make(),
//                                   SelectableText(
//                                     e.last,
//                                     style: TextStyle(color: Fav.design.primaryText),
//                                   ),
//                                 ],
//                               ).p8,
//                             ))
//                         .toList()
//                   ],
//                 ),
//               ),
//             ),
//             8.heightBox,
//             MyProgressButton(
//                 isLoading: false,
//                 onPressed: () async {
//                   RichTextPrint(await controller.getText());
//                 },
//                 label: 'example'.translate),
//             MyProgressButton(isLoading: _isLoading, onPressed: _save, label: Words.save),
//           ],
//         ).p16
//       ],
//     );
//   }
// }
