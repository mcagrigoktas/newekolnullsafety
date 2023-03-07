import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import '../../../../models/schoolinfo.dart';
import '../../../../services/dataservice.dart';

class BranchesPage extends StatefulWidget {
  final String? previousMenuName;
  BranchesPage({this.previousMenuName});

  @override
  State<BranchesPage> createState() => _BranchesPageState();
}

class _BranchesPageState extends State<BranchesPage> {
  final List<String> _itemList = AppVar.appBloc.schoolInfoService!.singleData!.branchList;
  final _scrollController = ScrollController();
  bool _isLoading = false;

  Future<void> _save() async {
    _itemList.removeWhere((element) => element.safeLength < 2);
    if (_itemList.length > 1) {
      if (Fav.noConnection()) return;
      FocusScope.of(Get.context!).requestFocus(FocusNode());
      setState(() {
        _isLoading = true;
      });

      await SchoolDataService.saveBranchNames(_itemList).then((value) {
        OverAlert.saveSuc();
      }).catchError((err) {
        OverAlert.saveErr();
      });
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: (widget.previousMenuName ?? '').translate),
      topActions: TopActionsTitle(title: "branchlist".translate),
      body: Body.listviewBuilder(
        withKeyboardCloserGesture: true,
        itemCount: _itemList.length,
        maxWidth: 640,
        scrollController: _scrollController,
        itemBuilder: (c, index) {
          return Row(
            children: [
              Expanded(
                child: MyTextField(
                  hintText: 'branch'.translate,
                  initialValue: _itemList[index],
                  onChanged: (value) {
                    _itemList[index] = value;
                  },
                ),
              ),
              if (!defaultBranches.map((e) => e.translate).contains(_itemList[index]))
                CupertinoIcons.clear_circled_solid.icon
                    .color(Colors.redAccent)
                    .onPressed(() {
                      setState(() {
                        _itemList.removeAt(index);
                      });
                    })
                    .make()
                    .pr8
            ],
          );
        },
      ),
      bottomBar: BottomBar(
          child: Row(
        children: [
          MyRaisedButton(
                  onPressed: () async {
                    setState(() {
                      _itemList.add('');
                    });
                    await 100.wait;
                    await _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: 100.milliseconds, curve: Curves.easeIn);
                  },
                  text: 'add'.translate)
              .pl16,
          Spacer(),
          MyProgressButton(
            onPressed: _save,
            label: Words.save,
            isLoading: _isLoading,
          ).pr16,
        ],
      )),
    );
  }
}

// class CaseNames extends StatefulWidget {
//   CaseNames({Key key}) : super(key: key);

//   @override
//   _CaseNamesState createState() => _CaseNamesState();
// }

// class _CaseNamesState extends State<CaseNames> {
//   List<String> data = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
//   void _save() {
//     if (_formKey.currentState.validate()) {
//       _formKey.currentState.save();
//       setState(() {
//         isLoading = true;
//       });

//       SetDataService.saveAccountingCaseNames(data).then((value) {
//         OverAlert.saveSuc();
//         setState(() {
//           isLoading = false;
//         });
//       }).catchError((err) => OverAlert.saveErr());
//     } else {
//       Alert.fillRequired();
//     }
//   }

//   final GlobalKey<FormState> _formKey = GlobalKey();
//   bool isLoading = false;
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           ...Iterable.generate(9)
//               .map((e) => MyTextFormField(
//                     labelText: '${e + 1}',
//                     onSaved: (value) {
//                       data[e] = value;
//                     },
//                     validatorRules: ValidatorRules(required: true, minLength: 1),
//                     initialValue: AppVar.appBloc.schoolInfoService.singleData.caseName(e + 1),
//                   ))
//               .toList(),
//           MyProgressButton(
//             isLoading: isLoading,
//             onPressed: _save,
//             label: Words.save,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class PaymentNames extends StatefulWidget {
//   PaymentNames({Key key}) : super(key: key);

//   @override
//   _PaymentNamesState createState() => _PaymentNamesState();
// }

// class _PaymentNamesState extends State<PaymentNames> {
//   final Map _data = {};
//   void _save() {
//     if (_formKey.currentState.validate()) {
//       _formKey.currentState.save();
//       setState(() {
//         _isLoading = true;
//       });

//       SetDataService.saveAccountingPaymentNames(_data).then((value) {
//         OverAlert.saveSuc();
//         setState(() {
//           _isLoading = false;
//         });
//       }).catchError((err) => OverAlert.saveErr());
//     } else {
//       Alert.fillRequired();
//     }
//   }

//   final GlobalKey<FormState> _formKey = GlobalKey();
//   bool _isLoading = false;
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           ...Iterable.generate(5)
//               .map((e) => MyTextFormField(
//                     labelText: '${e + 1}',
//                     onSaved: (value) {
//                       _data['paymenttype${e + 1}'] = value;
//                     },
//                     validatorRules: ValidatorRules(required: true, minLength: 5),
//                     initialValue: AppVar.appBloc.schoolInfoService.singleData.paymentName('paymenttype${e + 1}'),
//                   ))
//               .toList(),
//           MyProgressButton(
//             isLoading: _isLoading,
//             onPressed: _save,
//             label: Words.save,
//           ),
//         ],
//       ),
//     );
//   }
// }
