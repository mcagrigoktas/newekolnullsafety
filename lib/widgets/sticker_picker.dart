// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../models/allmodel.dart';

class LogoPicker extends StatelessWidget {
  final List<String> itemNames;
  String? initialValue;
  final IconData? iconData;
  final Color? color;
  final String? name;
  final Function(String?)? onSaved;
  final Function(String)? onChanged;
  final EdgeInsets? padding;
  LogoPicker({this.onSaved, required this.itemNames, this.iconData, this.color, this.name, this.initialValue, this.onChanged, this.padding});

  Future<void> showPicker(BuildContext context, state) async {
    var value = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(32),
              child: Wrap(
                runSpacing: 16,
                alignment: WrapAlignment.center,
                spacing: 16,
                children: itemNames.map((item) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, item);
                      },
                      child: Chip(
                        padding: const EdgeInsets.all(8),
                        label: MyCachedImage(
                          width: 24.0,
                          height: 24.0,
                          imgUrl: DailyReport(iconName: item).iconUrl,
                        ),
                        backgroundColor: Fav.design.chip.background,
                      ));
                }).toList(),
              )),
        );
      },
    );
    if (value != null) {
      state.didChange(value);
      if (onChanged != null) {
        onChanged!(value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!itemNames.any((item) => item == initialValue)) {
      initialValue = itemNames.first;
    }

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return GestureDetector(
            onTap: () {
              showPicker(context, state);
            },
            child: InputDecorator(
              decoration: InputDecoration(
                isDense: false,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                helperText: name,
                icon: iconData == null ? null : Icon(iconData, color: color),
                labelStyle: TextStyle(color: Fav.design.dropdown.hint),
                contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 6.0),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Fav.design.dropdown.border)),
              ),
              child: MyCachedImage(
                width: 32.0,
                height: 32.0,
                imgUrl: DailyReport(iconName: itemNames.singleWhere((item) => item == state.value)).iconUrl,
              ),
            ),
          );
        },
        onSaved: onSaved,
        initialValue: initialValue ?? itemNames.first,
      ),
    );
  }
}
