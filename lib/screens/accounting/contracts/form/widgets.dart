import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../controller.dart';
import '../helper.dart';

class ContractName extends StatelessWidget {
  const ContractName({required this.controller});

  final ContractsController controller;

  @override
  Widget build(BuildContext context) {
    return MyTextFormField(
      onSaved: (text) {
        controller.itemData!.name = text;
      },
      initialValue: controller.itemData!.name,
      labelText: 'contractname'.translate,
      iconData: Icons.person_pin,
      validatorRules: ValidatorRules(req: true, minLength: 3),
    );
  }
}

class ContractExp extends StatelessWidget {
  const ContractExp({
    required this.controller,
  });

  final ContractsController controller;

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

  final ContractsController controller;
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
                    controller.newContracTotal.value = controller.itemData!.installaments.fold<double>(0.0, (p, e) => p + (e.amount ?? 0.0));
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

class ContractAmount extends StatelessWidget {
  const ContractAmount({
    required this.controller,
  });

  final ContractsController controller;

  @override
  Widget build(BuildContext context) {
    return MyTextFormField(
      textAlign: TextAlign.end,
      onChanged: (text) {
        controller.itemData!.contractAmount = double.tryParse(text);
      },
      onSaved: (text) {
        controller.itemData!.contractAmount = double.tryParse(text);
      },
      initialValue: controller.itemData!.contractAmount!.toStringAsFixed(2),
      labelText: 'contractamount'.translate,
      iconData: Icons.money,
      validatorRules: ValidatorRules(mustNumber: true, req: true, minValue: 1),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}

class ContractDuration extends StatelessWidget {
  const ContractDuration({
    required this.controller,
  });

  final ContractsController controller;

  @override
  Widget build(BuildContext context) {
    return MyTextFormField(
      onSaved: (text) {
        controller.itemData!.duration = text;
      },
      initialValue: (controller.itemData!.duration ?? 1).toString(),
      labelText: 'duration'.translate,
      iconData: Icons.hourglass_bottom,
      validatorRules: ValidatorRules(),
      keyboardType: const TextInputType.numberWithOptions(),
    );
  }
}

class StartDate extends StatelessWidget {
  const StartDate({
    required this.controller,
  });

  final ContractsController controller;

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

  final ContractsController controller;

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

class Label extends StatelessWidget {
  const Label({
    required this.controller,
  });

  final ContractsController controller;

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
            await ContractHelper.openLabelSettingsDialog();
            controller.formKey = GlobalKey<FormState>();
            controller.update();
          },
        ).p4,
      ),
      items: AppVar.appBloc.schoolInfoForManagerService!.singleData!
          .contractLabelInfoList()
          .map((e) => DropdownItem<String>(
              value: e.key,
              name: e.value,
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
