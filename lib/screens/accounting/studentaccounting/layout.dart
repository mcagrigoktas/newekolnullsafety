import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../flavors/mainhelper.dart';
import 'controller.dart';
import 'widgets/accountingnotes.dart';
import 'widgets/newpaymentplanwidget.dart';
import 'widgets/paymentplanwidget.dart';
import 'widgets/singlepaymentwidget.dart';

class StudentAccounting extends StatelessWidget {
  final String? selectedKey;
  StudentAccounting({this.selectedKey});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StudentAccountingController>(
        init: StudentAccountingController(initialItem: selectedKey),
        builder: (controller) {
          //todo burada daha farkli detaylar yazabilir misin bak
          final Widget _middle = (controller.selectedStudent != null ? controller.selectedStudent!.name : '').text.bold.color(Fav.design.primary).maxLines(1).fontSize(18).autoSize.make();

          final Widget _otherItems = QudsPopupButton(
              backgroundColor: Fav.design.scaffold.background,
              child: Icons.more_vert_sharp.icon.color(Fav.design.appBar.text).make(),
              itemBuilder: (context) {
                return [
                  QudsPopupMenuItem(
                      trailing: !controller.showErasedStudent ? Icons.check_box_outline_blank.icon.color(Fav.design.primaryText).make() : Icons.check_box_outlined.icon.color(Fav.design.primaryText).make(),
                      title: 'showerasedstudent'.translate.text.make(),
                      onPressed: () {
                        controller.showErasedStudent = !controller.showErasedStudent;
                        controller.makeFilter(controller.filteredText);
                        controller.update();
                      })
                ];
              });
          final _topBar = RTopBar(
            mainLeadingTitle: 'menu1'.translate,
            leadingTitleMainEqualBoth: true,
            detailLeadingTitle: 'studentlist'.translate,
            detailBackButtonPressed: controller.detailBackButtonPressed,
            detailTrailingActions: [],
            mainTrailingActions: [_otherItems],
            bothTrailingActions: [_otherItems],
            mainMiddle: _middle,
            detailMiddle: _middle,
            bothMiddle: _middle,
          );
          Body _leftBody;
          Body? _rightBody;
          if (controller.isPageLoading) {
            _leftBody = Body.child(child: MyProgressIndicator(isCentered: true));
          } else {
            _leftBody = Body.listviewBuilder(
              pageStorageKey: AppVar.appBloc.hesapBilgileri.kurumID + 'studentList',
              listviewFirstWidget: MySearchBar(
                onChanged: (text) {
                  controller.makeFilter(text);
                  controller.update();
                },
                resultCount: controller.filteredItemList.length,
                initialText: controller.filteredText,
              ).p4,
              itemCount: controller.filteredItemList.length,
              itemBuilder: (context, index) => MyCupertinoListTile(
                title: controller.filteredItemList[index].name,
                onTap: () async {
                  await controller.selectItem(controller.filteredItemList[index]);
                },
                isSelected: controller.filteredItemList[index].key == controller.selectedStudent?.key,
                imgUrl: controller.filteredItemList[index].imgUrl,
              ),
            );

            if (controller.selectedStudent == null) {
              _rightBody = Body.child(child: Center(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST)));
            } else if (controller.isLoading) {
              _rightBody = Body.circularProgressIndicator();
            } else {
              Widget _childMenuWidget;
              if (controller.paymentTypeKey == 'custompayment') {
                _childMenuWidget = SinglePaymentWidget(
                  paymentTypeKey: controller.paymentTypeKey!,
                  studentKey: controller.selectedStudent!.key,
                  data: (controller.data['PaymentPlans'] ?? {})[controller.paymentTypeKey],
                );
              } else if ((controller.data['PaymentPlans']?.containsKey(controller.paymentTypeKey) ?? false) && (controller.data['PaymentPlans'][controller.paymentTypeKey]['aktif'] ?? true)) {
                _childMenuWidget = PaymentPlanWidget(
                  paymentTypeKey: controller.paymentTypeKey!,
                  studentKey: controller.selectedStudent!.key,
                  data: controller.data['PaymentPlans'][controller.paymentTypeKey],
                );
              } else if (controller.makeNewPlan) {
                _childMenuWidget = NewPaymentPlanWidget(
                  paymentTypeKey: controller.paymentTypeKey!,
                  studentKey: controller.selectedStudent!.key,
                );
              } else {
                _childMenuWidget = _buildEmptyPaymenPlanWidgets();
              }

              _rightBody = Body.child(
                  withKeyboardCloserGesture: true,
                  child: Form(
                    key: controller.formKey,
                    child: Container(
                        key: controller.globalKey,
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0),
                        child: Column(
                          children: <Widget>[_buildPaymentTypesWidget(), Expanded(key: ValueKey(controller.selectedStudent!.key), child: _childMenuWidget)],
                        )),
                  ));
            }
          }

          return AppResponsiveScaffold(
            topBar: _topBar,
            leftBody: _leftBody,
            rightBody: _rightBody,
            visibleScreen: controller.visibleScreen,
          );
        });
  }

  Widget _buildPaymentTypesWidget() {
    final controller = Get.find<StudentAccountingController>();
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AdvanceDropdown<String>(
              items: AppConst.accountingType
                  .map((paymentType) => DropdownItem(
                        name: AppVar.appBloc.schoolInfoService!.singleData!.paymentName(paymentType),
                        value: paymentType,
                      ))
                  .toList(),
              onChanged: (value) {
                controller.globalKey = GlobalKey();
                Fav.preferences.setString('paymentTypeKey', value);
                controller.paymentTypeKey = value;
                controller.makeNewPlan = false;
                controller.update();
              },
              initialValue: controller.paymentTypeKey,
              padding: const EdgeInsets.only(bottom: 0.0, left: 4, right: 4, top: 0),
            ),
          ),
          16.widthBox,
          SizedBox(
            height: 28,
            child: MyRaisedButton(
              elevation: 0,
              color: CupertinoColors.tertiarySystemFill,
              textColor: Fav.design.primaryText,
              text: 'accountingmote'.translate,
              iconData: Icons.note_add,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              onPressed: () {
                OverBottomSheet.show(BottomSheetPanel.child(child: AccountingNote(controller.selectedStudent!.key)));
              },
            ),
          ),
        ],
      ),
    );
  }

  // Eger ogrenciye ait odeme plani yoksa
  Widget _buildEmptyPaymenPlanWidgets() {
    return Column(
      children: <Widget>[
        EmptyState(text: 'nopaymentplan'.translate),
        MyRaisedButton(
          text: 'makenewplan'.translate,
          onPressed: () {
            final controller = Get.find<StudentAccountingController>();
            controller.makeNewPlan = true;
            controller.update();
          },
        ),
      ],
    );
  }
}
