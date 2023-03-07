import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:widgetpackage/dropdown_search/dropdownsimplewidget.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../services/dataservice.dart';
import '../../model.dart';

class ExpansesLabelEditor extends StatefulWidget {
  @override
  _ExpansesLabelEditorState createState() => _ExpansesLabelEditorState();
}

class _ExpansesLabelEditorState extends State<ExpansesLabelEditor> {
  final _controller = TreeViewController<ExpansesLabelNode>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _initialRoot = AppVar.appBloc.schoolInfoForManagerService!.singleData!.expenseLabelRootNode;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _controller.toggleNodeExpandCollapse(_controller.elementAt('root') as ExpansesLabelNode));
  }

  Future<void> _save() async {
    if (_formKey.currentState!.checkAndSave()) {
      if (Fav.noConnection()) return;
      Map _newData = _controller.root.value.toJson();
      Map? _removedRootData = _newData['i'];
      if (_removedRootData == null || _removedRootData.keys.isEmpty) {
        return OverAlert.nothingFoundToSave();
      }
      setState(() {
        _isLoading = true;
      });
      await AccountingService.saveExpensesLabelSettings(_removedRootData).then((value) {
        OverAlert.saveSuc();
      }).catchError((_) {
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
      topBar: TopBar(leadingTitle: 'back'.translate),
      // topActions: TopActionsTitleWithChild(
      //   title: TopActionsTitle(title: 'labels'.translate),
      //   childHeight: 50,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.only(right: 16.0),
      //         child: OutlinedButton.icon(
      //           style: OutlinedButton.styleFrom(primary: Colors.green[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))),
      //           icon: Icon(Icons.add_circle),
      //           label: Text("add".translate),
      //           onPressed: () {
      //             _rootNode.add(LabelNode.create());
      //             setState(() {});
      //           },
      //         ),
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.only(right: 16.0),
      //         child: OutlinedButton.icon(
      //           style: OutlinedButton.styleFrom(primary: Colors.red[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))),
      //           icon: Icon(Icons.delete),
      //           label: Text("clear".translate),
      //           onPressed: () {
      //             _controller.root.clear();
      //             setState(() {});
      //           },
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: Body.child(
          maxWidth: 720,
          child: Form(
            key: _formKey,
            child: TreeView<ExpansesLabelNode>(
              initialItem: _initialRoot,
              controller: _controller,
              expansionBehavior: ExpansionBehavior.collapseOthersAndSnapToTop,
              expansionIndicator: ExpansionIndicator(
                //Bu hizayi istedigim gibi yapamadigim icin gorunmez yapildi ilerde builderdeki cizilen oku kaldirip yapabilirrsin
                expandIcon: SizedBox(),
                collapseIcon: SizedBox(),
              ),
              shrinkWrap: true,
              showRootNode: true,
              indentPadding: 32,
              builder: (context, level, item) => item.isRoot
                  ? Builder(builder: (context) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          item.children.isNotEmpty
                              ? Icons.arrow_drop_down_circle_sharp.icon.color(Fav.design.primary).onPressed(() {
                                  _controller.toggleNodeExpandCollapse(item);
                                }).make()
                              : SizedBox(width: 32),
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.green[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))),
                              icon: Icon(Icons.add_circle),
                              label: Text("add".translate),
                              onPressed: () {
                                item.add(ExpansesLabelNode.create());
                                setState(() {});
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))),
                              icon: Icon(Icons.delete),
                              label: Text("clear".translate),
                              onPressed: () {
                                _controller.root.clear();
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      );
                    })
                  : Card(
                      color: Fav.design.card.background,
                      child: ListTile(
                        leading: item.children.isNotEmpty
                            ? Icons.arrow_drop_down_circle_sharp.icon.color(Fav.design.primary).onPressed(() {
                                _controller.toggleNodeExpandCollapse(item);
                              }).make()
                            : SizedBox(width: 32),
                        title: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: AdvanceDropdown<int>(
                                iconData: Icons.palette,
                                padding: EdgeInsets.all(0),
                                items: Iterable.generate(35)
                                    .map((e) => DropdownItem<int>(
                                        value: e,
                                        child: Container(
                                          width: 30,
                                          height: 20,
                                          decoration: BoxDecoration(color: MyPalette.getColorFromCount(e), borderRadius: BorderRadius.circular(4)),
                                        )))
                                    .toList(),
                                initialValue: item.colorNo,
                                name: 'selectcolor'.translate,
                                onChanged: (value) {
                                  item.colorNo = value;
                                },
                                validatorRules: ValidatorRules(mustNumber: true, req: true, maxValue: 35, minValue: 0),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: MyTextFormField(
                                padding: Inset.h(16),
                                labelText: 'name'.translate,
                                onChanged: (value) {
                                  item.name = value;
                                },
                                initialValue: item.name,
                                validatorRules: ValidatorRules(req: true, minLength: 2),
                              ),
                            ),
                          ],
                        ),
                        dense: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => item.delete(),
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  item.add(ExpansesLabelNode.create());
                                });
                              },
                              icon: Icon(Icons.add_circle, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          )),
      bottomBar: BottomBar.saveButton(onPressed: _save, isLoading: _isLoading),
    );
  }
}
