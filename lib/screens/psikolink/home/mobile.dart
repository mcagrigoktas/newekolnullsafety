// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:mcg_extension/mcg_extension.dart';

// import '../model.dart';

// class PsikolinkHome extends StatefulWidget {
//   PsikolinkHome();

//   @override
//   _PsikolinkHomeState createState() => _PsikolinkHomeState();
// }

// class _PsikolinkHomeState extends State<PsikolinkHome> {
//   String key = 5.makeKey;
//   InAppWebViewController mobileWebview;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   Future<void> init() async {
//     mobileWebview.addJavaScriptHandler(
//         handlerName: 'message',
//         callback: (msg) async {
//           //  final Map message = json.decode(msg[0]);
//         });

//     final _postData = {
//       'brightness': Fav.design.brightness.name,
//       'ecollPsikolinkIntegrated': true,
//       '_ecollSchoolModelString': PikolinkHelper.getPsikolinkSchoolModelFromEcollSchoolModel(),
//       '_ecollUserModelString': PikolinkHelper.getPsikolinkUserModelFromEcollUserModel(),
//       // '_ecollStudentList': PikolinkHelper.getStudentListForPsikolink(),
//     };
//     // mobileWebview.log(await mobileWebview.getHtml());
//     log('hhh');

//     final _data = json.encode(_postData);
//     // await mobileWebview.evaluateJavascript(source: "setPled(" + _data + ");");
//     await mobileWebview.evaluateJavascript(source: """
// pled = JSON.stringify($_data);
// console.log(pled);
//     """);
//     log('ooo');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return KeyedSubtree(
//       key: Key('JitsiMobileWebview$key'),
//       child: InAppWebView(
//         initialUrlRequest: URLRequest(url: Uri.parse('https://psikolink.web.app')),

//         initialOptions: InAppWebViewGroupOptions(
//           android: AndroidInAppWebViewOptions(
//             useHybridComposition: true,
//             allowFileAccess: true,
//           ),
//           ios: IOSInAppWebViewOptions(
//             allowsInlineMediaPlayback: true,
//             allowsPictureInPictureMediaPlayback: false,
//             allowsAirPlayForMediaPlayback: false,
//           ),
//           crossPlatform: isAndroid
//               ? InAppWebViewOptions(
//                   preferredContentMode: UserPreferredContentMode.MOBILE,
//                   mediaPlaybackRequiresUserGesture: false,
//                   cacheEnabled: kReleaseMode,
//                   supportZoom: false,
//                 )
//               : InAppWebViewOptions(
//                   preferredContentMode: UserPreferredContentMode.MOBILE,
//                   mediaPlaybackRequiresUserGesture: false,
//                   cacheEnabled: kReleaseMode,
//                   supportZoom: false,
//                   applicationNameForUserAgent: isIOS ? 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.2 Safari/605.1.15' : '',
//                   userAgent: isIOS ? 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.2 Safari/605.1.15' : '',
//                 ),
//         ), //aa

//         onConsoleMessage: (controller, message) {
//           log(message.message);
//         },
//         onWebViewCreated: (InAppWebViewController webviewContoller) {
//           mobileWebview = webviewContoller;
//         },
//         onLoadStart: (_, __) {},
//         onLoadStop: (_, __) {
//           init();
//         },

//         onProgressChanged: (InAppWebViewController controller, int progress) async {},
//         androidOnPermissionRequest: (InAppWebViewController controller, String origin, List<String> resources) async {
//           return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
//         },
//       ),
//     );
//   }
// }
