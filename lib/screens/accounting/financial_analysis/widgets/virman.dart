import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../account_settings/case_names.dart';
import '../controller.dart';
import '../model.dart';

class VirmanPage extends StatelessWidget {
  VirmanPage();
  @override
  Widget build(BuildContext context) {
    final _controller = Get.find<FinancialAnalysisController>();
    return AppScaffold(
      topBar: TopBar(
          leadingTitle: 'financialanalysis'.translate,
          backButtonPressed: () {
            _controller.virmanPageType = null;
            _controller.update();
          }),
      topActions: TopActionsTitle(title: 'vmenu${_controller.virmanPageType == VirmanType.onlyEnter ? 1 : 2}'.translate),
      body: Body.singleChildScrollView(
          maxWidth: 600,
          child: MyForm(
            formKey: _controller.virmanFormKey,
            child: SingleChildScrollView(
              child: AnimatedColumnWidget(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: AdvanceDropdown(
                          items: Iterable.generate(maxCaseNumber + 1).map((i) => DropdownItem(value: i, name: i == 0 ? 'casenumber'.translate : AppVar.appBloc.schoolInfoService!.singleData!.caseName(i))).toList(),
                          onChanged: (dynamic value) {
                            _controller.virmanItemForSave!.enteringCase = value;
                          },
                          onSaved: (dynamic value) {
                            _controller.virmanItemForSave!.enteringCase = value;
                          },
                          validatorRules: ValidatorRules(req: true, minValue: 1, mustNumber: true),
                          initialValue: _controller.virmanItemForSave!.enteringCase,
                          name: 'casenumber'.translate,
                        ),
                      ),
                      if (_controller.virmanPageType == VirmanType.change) Icons.arrow_right_alt_sharp.icon.color(Colors.green).make().circleBackground(background: Colors.green.withAlpha(20)),
                      if (_controller.virmanPageType == VirmanType.change)
                        Expanded(
                          child: AdvanceDropdown(
                            items: Iterable.generate(maxCaseNumber + 1).map((i) => DropdownItem(value: i, name: i == 0 ? 'casenumber'.translate : AppVar.appBloc.schoolInfoService!.singleData!.caseName(i))).toList(),
                            onChanged: (dynamic value) {
                              _controller.virmanItemForSave!.sendingCase = value;
                            },
                            onSaved: (dynamic value) {
                              _controller.virmanItemForSave!.sendingCase = value;
                            },
                            validatorRules: ValidatorRules(req: true, minValue: 1, mustNumber: true),
                            initialValue: _controller.virmanItemForSave!.sendingCase,
                            name: 'casenumber'.translate,
                          ),
                        ),
                    ],
                  ),
                  MyTextFormField(
                    iconData: Icons.attach_money_rounded,
                    textAlign: TextAlign.end,
                    validatorRules: ValidatorRules(req: true, mustNumber: true, minLength: 1, minValue: _controller.virmanPageType == VirmanType.change ? 0 : -100000000),
                    onSaved: (value) {
                      _controller.virmanItemForSave!.enteringAmount = double.tryParse(value!);
                    },
                    labelText: ''.translate,
                    initialValue: _controller.virmanItemForSave!.enteringAmount!.toStringAsFixed(2),
                  ),
                  MyDatePicker(
                      onSaved: (value) {
                        _controller.virmanItemForSave!.date = value;
                      },
                      title: 'date'.translate,
                      initialValue: _controller.virmanItemForSave!.date),
                  MyTextFormField(
                    labelText: "aciklama".translate,
                    iconData: Icons.content_paste_sharp,
                    validatorRules: ValidatorRules(),
                    onSaved: (value) {
                      _controller.virmanItemForSave!.exp = value;
                    },
                    maxLines: null,
                    initialValue: _controller.virmanItemForSave!.exp,
                  ),
                ],
              ),
            ),
          )),
      bottomBar: BottomBar.saveButton(onPressed: _controller.saveVirman, isLoading: _controller.isVirmanSaving),
    );
  }
}
