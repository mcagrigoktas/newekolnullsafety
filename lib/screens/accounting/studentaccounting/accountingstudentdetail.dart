// import 'dart:async';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';
// import 'package:mypackage/mywidgets.dart';
// import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

// import '../../../appbloc/appvar.dart';
// import '../../../flavors/mainhelper.dart';
// import '../../../services/dataservice.dart';
// import '../accountingnotes.dart';
// import 'widgets/newpaymentplanwidget.dart';
// import 'widgets/paymentplanwidget.dart';
// import 'widgets/singlepaymentwidget.dart';

// class AccountingStudentDetail extends StatefulWidget {
//   final String islemYapilacakKey;
//   final GlobalKey<FormState> formKey;
//   final Function resetPage;
//   AccountingStudentDetail({this.islemYapilacakKey, this.formKey, this.resetPage});

//   @override
//   AccountingStudentDetailState createState() {
//     return AccountingStudentDetailState();
//   }
// }

// class AccountingStudentDetailState extends State<AccountingStudentDetail> with SingleTickerProviderStateMixin {
  
//   }

 

  

//   @override
//   Widget build(BuildContext context) {
   

//     return Form(
//       key: widget.formKey,
//       child: (widget.islemYapilacakKey == null)
//           ? EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST)
//           : Container(
//               key: globalKey,
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Column(
//                 children: <Widget>[_buildPaymentTypesWidget(), Expanded(key: ValueKey(widget.islemYapilacakKey), child: _childMenuWidget)],
//               )),
//     );
//   }
// }
