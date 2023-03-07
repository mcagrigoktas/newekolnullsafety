// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/mywidgets.dart';

// import '../../../helpers/glassicons.dart';
// import 'z_mainwidget.dart';

// class FernusWidget extends MainWidget {
//   FernusWidget() : super([12, 6, 4], [0, 0, 0]);

//   @override
//   Widget build(BuildContext context) {
//     return WidgetContainer(
//       closedWidget: Container(
//         decoration: BoxDecoration(
//             color: Fav.design.others['widget.primaryBackground'],
//             // gradient: Colors.white.hueGradient,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(color: const Color(0xff2C2E60).withOpacity(0.01), blurRadius: 2, spreadRadius: 2, offset: const Offset(0, 0)),
//             ]),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Image.asset(
//               GlassIcons.medicine.imgUrl!,
//               width: 32,
//             ),
//             8.widthBox,
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   'Fernus'.translate.text.color(GlassIcons.medicine.color!).fontSize(18).bold.make(),
//                 ],
//               ),
//             ),
//           ],
//         ).p16,
//       ),
//       openWidget: Fernus(),
//       borderRadius: 16,
//     );
//   }
// }

// class Fernus extends StatefulWidget {
//   Fernus();
//   @override
//   _FernusState createState() => _FernusState();
// }

// class _FernusState extends State<Fernus> {
//   final _apiKey = 'http://vektorelvideo.aciyayinlari.com.tr/api/api.php';

//   bool _isLoading = false;
//   String? _currentNode = '-1';
//   Map? _currentMap = {};
//   final List<Map?> _previousMapList = [];

//   Future<void> _fetcData() async {
//     if (Fav.noConnection()) return;
//     setState(() {
//       _isLoading = true;
//     });
//     var uri = Uri.parse(_apiKey);
//     final requestBody = {'action': 'get-node', 'node': _currentNode!};
//     var request = http.MultipartRequest('POST', uri)..fields.addAll(requestBody);
//     var response = await request.send();
//     final respStr = await response.stream.bytesToString();
//     final data = jsonDecode(respStr);
//     if (_currentMap!.isNotEmpty) {
//       _previousMapList.add(_currentMap);
//     }
//     _currentMap = data;

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> _goTest(String? testId, String name) async {
//     if (Fav.noConnection()) return;
//     setState(() {
//       _isLoading = true;
//     });
//     var uri = Uri.parse(_apiKey);
//     final requestBody = {'action': 'get-source', 'source': testId!};
//     var request = http.MultipartRequest('POST', uri)..fields.addAll(requestBody);
//     var response = await request.send();
//     final respStr = await response.stream.bytesToString();
//     final data = jsonDecode(respStr);

//     setState(() {
//       _isLoading = false;
//     });
//     await Fav.to(FernusTest(data, name));
//   }

//   @override
//   void initState() {
//     _fetcData();

//     super.initState();
//   }

//   List? get nodes => _currentMap!['nodes'];

//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       topBar: TopBar(
//           leadingTitle: 'menu1'.translate,
//           backButtonPressed: () {
//             if (_previousMapList.isEmpty) {
//               Get.back();
//             } else {
//               setState(() {
//                 _currentMap = _previousMapList.last;
//                 _previousMapList.removeLast();
//               });
//             }
//           }),
//       topActions: TopActionsTitle(title: 'Fernus'),
//       body: _isLoading || _currentMap == null || nodes == null
//           ? Body.child(child: MyProgressIndicator())
//           : Body.listviewBuilder(
//               itemBuilder: (context, index) {
//                 return MyCupertinoListTile(
//                   onTap: () {
//                     if ((nodes![index] as Map)['is_questions']) {
//                       _goTest((nodes![index] as Map)['id'], (((nodes![index] as Map)['nm'] ?? 'yok') as String));
//                     } else {
//                       _currentNode = (nodes![index] as Map)['id'];
//                       _fetcData();
//                     }
//                   },
//                   title: (((nodes![index] as Map)['nm'] ?? 'yok') as String),
//                 );
//               },
//               itemCount: nodes!.length,
//             ),
//     );
//   }
// }

// class FernusTest extends StatelessWidget {
//   final Map? data;
//   final String name;
//   FernusTest(this.data, this.name);

//   List? get nodes => data!['contents'];
//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       topBar: TopBar(leadingTitle: 'Test Listesi'),
//       topActions: data!['answers'] == null
//           ? TopActionsTitle(
//               title: name,
//             )
//           : TopActionsTitleWithChild(
//               title: TopActionsTitle(
//                 title: name,
//               ),
//               child: Center(
//                   child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: (data!['answers'] as String?)!.characters.map((e) {
//                           return e.text.color(Colors.white).make().p2.circleBackground(background: Colors.greenAccent).p2;
//                         }).toList(),
//                       )))),
//       body: Body.listviewBuilder(
//           itemCount: nodes!.length,
//           itemBuilder: (context, index) {
//             return MyCupertinoListTile(
//               title: '${index + 1}',
//               onTap: () {
//                 if (((nodes![index] as Map)['solved'] as String?).safeLength > 6) {
//                   Fav.to(MyVideoPlay(
//                     cacheVideo: false,
//                     url: (nodes![index] as Map)['solved'],
//                     isActiveDownloadButton: false,
//                   ));
//                 } else {
//                   OverAlert.show(message: 'Link hatali', type: AlertType.danger);
//                 }
//               },
//             );
//           }),
//     );
//   }
// }
// //{type: video, image: https://vektorelvideo.aciyayinlari.com.tr/, subjects: [], id: 33676, diff: , answer: X, solved: http://vektorelvideo.aciyayinlari.com.tr/uploads/assets/solution_files/6087ebd404b49.mp4, name: soru, order_number: 2}