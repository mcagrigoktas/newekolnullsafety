import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../localization/usefully_words.dart';
import 'controller.dart';
import 'model.dart';

class PersonsList extends StatelessWidget {
  PersonsList();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonsListController>(
        init: PersonsListController(),
        builder: (controller) {
          final Widget _newButton = Tooltip(
            message: 'personlisthint1'.translate,
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
            textStyle: TextStyle(fontSize: 14, color: Colors.white),
            child: AddIcon(onPressed: controller.clickNewPerson),
          );
          final Widget _middle = (controller.newPerson != null
                  ? 'new'.translate
                  : controller.selectedPerson != null
                      ? controller.selectedPerson!.name
                      : 'personlist'.translate)
              .text
              .bold
              .color(Fav.design.primary)
              .maxLines(1)
              .fontSize(18)
              .autoSize
              .make();

          final _topBar = controller.newPerson != null
              ? RTopBar.sameAll(leadingIcon: Icons.clear_rounded, leadingTitle: 'cancelnewentry'.translate, backButtonPressed: controller.cancelNewEntry, middle: _middle)
              : RTopBar(
                  mainLeadingTitle: 'menu1'.translate,
                  leadingTitleMainEqualBoth: true,
                  detailLeadingTitle: 'personlist'.translate,
                  detailBackButtonPressed: controller.detailBackButtonPressed,
                  detailTrailingActions: [_newButton],
                  mainTrailingActions: [_newButton],
                  bothTrailingActions: [_newButton],
                  mainMiddle: _middle,
                  detailMiddle: _middle,
                  bothMiddle: _middle,
                );
          Body? _leftBody;
          Body? _rightBody;
          if (controller.isPageLoading) {
            _leftBody = Body.child(child: MyProgressIndicator(isCentered: true));
          } else if (controller.newPerson == null && controller.itemList.isEmpty) {
            _leftBody = Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDSWITHPLUS));
          } else {
            _leftBody = controller.newPerson != null
                ? null
                : Body.listviewBuilder(
                    listviewFirstWidget: MySearchBar(
                      onChanged: (text) {
                        controller.makeFilter(text);
                        controller.update();
                      },
                      resultCount: controller.filteredItemList.length,
                    ).p4,
                    pageStorageKey: AppVar.appBloc.hesapBilgileri.kurumID + 'personList',
                    itemCount: controller.filteredItemList.length,
                    itemBuilder: (context, index) => MyCupertinoListTile(
                      title: controller.filteredItemList[index].name,
                      onTap: () {
                        // OverAlert.show(message: 'Bu deneme mesajidir', title: 'Heyy', type: AlertType.successful,autoClose:false);
                        controller.selectPerson(controller.filteredItemList[index]);
                      },
                      imgUrl: controller.filteredItemList[index].imgUrl,
                      isSelected: controller.filteredItemList[index].key == controller.personData?.key,
                    ),
                  );

            _rightBody = controller.personData == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : Body.singleChildScrollView(
                    maxWidth: 720,
                    withKeyboardCloserGesture: true,
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          AnimatedGroupWidget(
                            children: [
                              MyTextFormField(
                                initialValue: controller.personData!.name,
                                labelText: "name".translate,
                                iconData: MdiIcons.account,
                                validatorRules: ValidatorRules(req: true, minLength: 5),
                                onSaved: (value) {
                                  controller.personData!.name = value;
                                },
                              ),
                              MyMultiSelect(
                                  iconData: Icons.category,
                                  context: context,
                                  items: [
                                    MyMultiSelectItem(PersonCategory.employee.name, 'employee2'.translate),
                                    MyMultiSelectItem(PersonCategory.supplier.name, 'supplier'.translate),
                                  ],
                                  initialValue: controller.personData!.categories?.map((e) => e.name).toList() ?? [],
                                  onSaved: (value) {
                                    controller.personData!.categories = J.jEnumList(value, PersonCategory.values, []);
                                  },
                                  onChanged: (value) {
                                    controller.personData!.categories = J.jEnumList(value, PersonCategory.values, []);
                                    controller.update();
                                  },
                                  name: 'missions'.translate,
                                  title: 'missions'.translate),
                              MyTextFormField(
                                initialValue: controller.personData!.tc,
                                labelText: "tc".translate,
                                iconData: MdiIcons.card,
                                validatorRules: ValidatorRules(noGap: true),
                                onSaved: (value) {
                                  controller.personData!.tc = value;
                                },
                                counter: true,
                              ),
                              MyTextFormField(
                                initialValue: controller.personData!.tel1,
                                labelText: "phone".translate + ' :1',
                                iconData: MdiIcons.phone,
                                validatorRules: ValidatorRules(phoneNumber: true, noGap: true),
                                keyboardType: TextInputType.phone,
                                onSaved: (value) {
                                  controller.personData!.tel1 = value;
                                },
                              ),
                              MyTextFormField(
                                initialValue: controller.personData!.tel2,
                                labelText: "phone".translate + ' :2',
                                iconData: MdiIcons.phone,
                                validatorRules: ValidatorRules(phoneNumber: true, noGap: true),
                                keyboardType: TextInputType.phone,
                                onSaved: (value) {
                                  controller.personData!.tel2 = value;
                                },
                              ),
                              MyTextFormField(
                                initialValue: controller.personData!.mail,
                                labelText: "mail".translate,
                                iconData: MdiIcons.at,
                                onSaved: (value) {
                                  controller.personData!.mail = value.trim();
                                },
                              ),
                              MyTextFormField(
                                initialValue: controller.personData!.adres,
                                maxLines: null,
                                hintText: "...".translate,
                                labelText: "adres".translate,
                                iconData: MdiIcons.mapMarker,
                                onSaved: (value) {
                                  controller.personData!.adres = value;
                                },
                              ),
                              MyTextFormField(
                                initialValue: controller.personData!.exp,
                                maxLines: null,
                                hintText: "...".translate,
                                labelText: "aciklama".translate,
                                iconData: MdiIcons.information,
                                onSaved: (value) {
                                  controller.personData!.exp = value;
                                },
                              ),
                            ],
                          ),
                          if (controller.personData!.categories?.contains(PersonCategory.supplier) == true)
                            Container(
                              padding: Inset(8),
                              decoration: BoxDecoration(color: Colors.green.withAlpha(15), borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                children: [
                                  'contactinfo'.translate.text.color(Fav.design.primary).fontSize(20).bold.make(),
                                  AnimatedGroupWidget(
                                    children: [
                                      MyTextFormField(
                                        initialValue: controller.personData!.contactName,
                                        labelText: "name".translate,
                                        iconData: MdiIcons.account,
                                        validatorRules: ValidatorRules(),
                                        onSaved: (value) {
                                          controller.personData!.contactName = value;
                                        },
                                      ),
                                      MyTextFormField(
                                        initialValue: controller.personData!.contactTel,
                                        labelText: "phone".translate,
                                        iconData: MdiIcons.phone,
                                        validatorRules: ValidatorRules(phoneNumber: true, noGap: true),
                                        keyboardType: TextInputType.phone,
                                        onSaved: (value) {
                                          controller.personData!.contactTel = value;
                                        },
                                      ),
                                      MyTextFormField(
                                        initialValue: controller.personData!.contactExp,
                                        maxLines: null,
                                        hintText: "...".translate,
                                        labelText: "aciklama".translate,
                                        iconData: MdiIcons.information,
                                        onSaved: (value) {
                                          controller.personData!.contactExp = value;
                                        },
                                      ),
                                      MyTextFormField(
                                        initialValue: controller.personData!.contactMail,
                                        labelText: "mail".translate,
                                        iconData: MdiIcons.at,
                                        onSaved: (value) {
                                          controller.personData!.contactMail = value.trim();
                                        },
                                      ),
                                      MyTextFormField(
                                        initialValue: controller.personData!.customerNumber,
                                        labelText: "customerNumber".translate,
                                        iconData: MdiIcons.account,
                                        validatorRules: ValidatorRules(),
                                        onSaved: (value) {
                                          controller.personData!.customerNumber = value;
                                        },
                                      ),
                                      MyTextFormField(
                                        initialValue: controller.personData!.taxNumber,
                                        labelText: "taxNumber".translate,
                                        iconData: MdiIcons.account,
                                        validatorRules: ValidatorRules(),
                                        onSaved: (value) {
                                          controller.personData!.taxNumber = value;
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          Align(
                            child: MyPhotoUploadWidget(
                              avatarImage: true,
                              saveLocation: AppVar.appBloc.hesapBilgileri.kurumID + '/' + AppVar.appBloc.hesapBilgileri.termKey + '/' + "UserProfileImages",
                              initialValue: controller.personData!.imgUrl,
                              onSaved: (value) {
                                controller.personData!.imgUrl = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ));
          }

          RBottomBar? _bottomBar;
          if (controller.personData != null && (controller.visibleScreen == VisibleScreen.detail)) {
            Widget _bottomChild = Row(
              children: [
                if (controller.selectedPerson != null)
                  MyPopupMenuButton(
                    itemBuilder: (context) {
                      return <PopupMenuEntry>[
                        PopupMenuItem(
                          value: 0,
                          child: Text(Words.delete),
                        ),
                      ];
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Fav.design.primaryText.withAlpha(10)),
                      child: Icon(Icons.more_vert, color: Fav.design.primaryText.withAlpha(180)),
                    ),
                    onSelected: (value) async {
                      if (value == 0) {
                        var sure = await Over.sure();
                        if (sure == true) await controller.save(delete: true);
                      }
                    },
                  ),
                const Spacer(),
                MyProgressButton(
                  onPressed: controller.save,
                  label: Words.save,
                  isLoading: controller.isSaving,
                ).pr16
              ],
            );
            _bottomBar = RBottomBar(
              bothChild: _bottomChild,
              detailChild: _bottomChild,
            );
          }

          return AppResponsiveScaffold(
            topBar: _topBar,
            leftBody: _leftBody,
            rightBody: _rightBody,
            visibleScreen: controller.visibleScreen,
            bottomBar: _bottomBar,
          );
        });
  }
}
