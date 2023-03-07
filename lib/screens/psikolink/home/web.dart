// import 'dart:async';
// import 'dart:convert';
// import 'dart:html';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';

// import '../model.dart';

// class PsikolinkHome extends StatefulWidget {
//   PsikolinkHome();

//   @override
//   State<PsikolinkHome> createState() => _PsikolinkHomeState();
// }

// class _PsikolinkHomeState extends State<PsikolinkHome> {
//   String key;
//   Completer<IFrameElement> _iFrame;
//   @override
//   void initState() {
//     _iFrame = Completer();
//     key = 4.makeKey;

//     final _iframeElement = IFrameElement()
//       ..width = '100%'
//       ..height = '100%'
//       ..src = 'https://psikolink.web.app'
//       ..style.border = 'none';

// // ignore: undefined_prefixed_name
//     ui.platformViewRegistry.registerViewFactory('webview' + key, (int viewId) {
//       window.onMessage.listen(
//         (event) {
//           final Map<String, dynamic> data = Map<String, dynamic>.from(event.data);

//           if (data.containsKey('Ready')) {
//             if (!_iFrame.isCompleted) {
//               _iFrame.complete(_iframeElement);
//             }
//           }
//         },
//       );
//       return _iframeElement;
//     });

//     postMessage();

//     super.initState();
//   }

//   Future<void> postMessage() async {
//     final _iframe = await _iFrame.future;

//     final _postData = {
//       'brightness': Fav.design.brightness.name,
//       'ecollPsikolinkIntegrated': true,

//       '_ecollSchoolModelString': PikolinkHelper.getPsikolinkSchoolModelFromEcollSchoolModel(),
//       '_ecollUserModelString': PikolinkHelper.getPsikolinkUserModelFromEcollUserModel(),
//       //  '_ecollStudentList': PikolinkHelper.getStudentListForPsikolink(),
//     };
//     // PlatformFunctions.callFunctions('setPled', [json.encode(_postData)]);
//     _iframe.contentWindow.postMessage(json.encode(_postData), '*');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return HtmlElementView(viewType: 'webview' + key);
//   }
// }
