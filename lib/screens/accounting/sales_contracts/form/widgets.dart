import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../controller.dart';
import '../helper.dart';

class ContractName extends StatelessWidget {
  const ContractName({required this.controller});

  final SalesContractsController controller;

  @override
  Widget build(BuildContext context) {
    return MyTextFormField(
      onSaved: (text) {
        controller.itemData!.name = text;
      },
      onChanged: (text) {
        controller.itemData!.name = text;
      },
      initialValue: controller.itemData!.name,
      labelText: 'contractname'.translate,
      iconData: Icons.app_registration_outlined,
      validatorRules: ValidatorRules(req: true, minLength: 3),
    );
  }
}

class SalesContractPersonWidget extends StatelessWidget {
  const SalesContractPersonWidget({required this.controller});

  final SalesContractsController controller;

  @override
  Widget build(BuildContext context) {
    return AdvanceDropdown<String>(
      name: 'person'.translate,
      onSaved: (value) {
        controller.itemData!.personKey = value;
      },
      onChanged: (value) {
        controller.itemData!.personKey = value;
      },
      initialValue: controller.itemData!.personKey,
      iconData: Icons.person_pin,
      items: controller.personList.map((e) => DropdownItem(name: e.name, value: e.key)).toList(),
    );
  }
}

class StartDate extends StatelessWidget {
  const StartDate({
    required this.controller,
  });

  final SalesContractsController controller;

  @override
  Widget build(BuildContext context) {
    return MyDatePicker(
        onSaved: (value) {
          controller.itemData!.startDate = value;
        },
        title: 'dateofcontract'.translate,
        initialValue: controller.itemData!.startDate ?? DateTime.now().millisecondsSinceEpoch);
  }
}

class ContractFinishTime extends StatelessWidget {
  const ContractFinishTime({
    required this.controller,
  });

  final SalesContractsController controller;

  @override
  Widget build(BuildContext context) {
    return MyDatePicker(
        onSaved: (value) {
          controller.itemData!.endDate = value;
        },
        title: 'finishtime'.translate,
        initialValue: controller.itemData!.endDate ?? DateTime.now().add(Duration(days: 365)).millisecondsSinceEpoch);
  }
}

class ContractExp extends StatelessWidget {
  const ContractExp({
    required this.controller,
  });

  final SalesContractsController controller;

  @override
  Widget build(BuildContext context) {
    return MyTextFormField(
      labelText: 'aciklama'.translate,
      validatorRules: ValidatorRules(),
      iconData: Icons.note,
      maxLines: null,
      initialValue: controller.itemData!.exp,
      onSaved: (value) => controller.itemData!.exp = value,
      onChanged: (value) => controller.itemData!.exp = value,
    );
  }
}

class InstallamentCount extends StatelessWidget {
  const InstallamentCount({required this.controller, this.useCalculateWidget = true});

  final SalesContractsController controller;
  final bool useCalculateWidget;

  @override
  Widget build(BuildContext context) {
    return AdvanceDropdown<int>(
      searchbarEnableLength: 1000,
      trailingWidget: useCalculateWidget
          ? Tooltip(
              message: 'calculateinstallaments'.translate,
              child: Icons.calculate.icon
                  .color(Fav.design.primary)
                  .onPressed(() {
                    controller.itemData!.calculateInstallaments();
                    controller.newContracAmountTotal.value = controller.itemData!.installaments.fold<double>(0.0, (p, e) => p + (e.amount ?? 0.0));
                    controller.update();
                  })
                  .padding(4)
                  .make())
          : null,
      name: 'installmentnumber'.translate,
      onChanged: (value) {
        controller.itemData!.setupInstallaments(value);
        controller.update();
      },
      items: Iterable.generate(20).map((e) => DropdownItem<int>(name: '${e + 1}', value: e + 1)).toList(),
      initialValue: controller.itemData!.installaments.length,
    );
  }
}

class Label extends StatelessWidget {
  const Label({
    required this.controller,
  });

  final SalesContractsController controller;

  @override
  Widget build(BuildContext context) {
    return AdvanceDropdown<String>(
      name: 'label'.translate,
      iconData: Icons.label,
      extraWidget: Align(
        alignment: Alignment.topRight,
        child: MyMiniRaisedButton(
          text: 'edit'.translate,
          onPressed: () async {
            Get.back();
            await SalesContractHelper.openLabelSettingsDialog();
            controller.formKey = GlobalKey<FormState>();
            controller.update();
          },
        ).p4,
      ),
      items: AppVar.appBloc.schoolInfoForManagerService!.singleData!
          .salesContractLabelInfoList()
          .map((e) => DropdownItem<String>(
              value: e.key,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 14,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MyPalette.getBaseColor(int.tryParse(e.key.replaceAll('c', ''))!)),
                  ),
                  8.widthBox,
                  e.value.text.make()
                ],
              )))
          .toList(),
      initialValue: controller.itemData!.label,
      onSaved: (value) {
        controller.itemData!.label = value;
      },
    );
  }
}
