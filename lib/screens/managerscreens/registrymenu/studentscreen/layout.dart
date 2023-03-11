import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:mypackage/srcwidgets/myresponsivescaffold.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../../appbloc/appvar.dart';
import '../../../../helpers/exporthelper.dart';
import '../../../../helpers/manager_authority_helper.dart';
import '../../../../helpers/print/printhelper.dart';
import '../../../../helpers/print/registrymenuprint.dart';
import '../../../../localization/usefully_words.dart';
import '../../../importpages/importpagemain.dart';
import '../../../main/menu_list_helper.dart';
import '../copy_another_term_helper.dart';
import 'controller.dart';
import 'helper.dart';
import 'student.dart';

class StudentList extends StatelessWidget {
  final Student? initialItem;
  final Map? preRegistrationData;
  StudentList({this.initialItem, this.preRegistrationData});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StudentListController>(
        init: StudentListController(initialItem: initialItem, preRegistrationData: preRegistrationData),
        builder: (controller) {
          final Widget _newButton = AddIcon(onPressed: controller.clickNewItem);

          //  Icons.add.icon.color(Fav.design.appBar.text).onPressed(controller.clickNewItem).make();
          final Widget _middle = (controller.newItem != null
                  ? 'new'.translate
                  : controller.selectedItem != null
                      ? controller.selectedItem!.name
                      : 'studentlist'.translate)
              .text
              .bold
              .color(Fav.design.primary)
              .maxLines(1)
              .fontSize(18)
              .autoSize
              .make();

          final Widget _sendSmsButton = MyPopupMenuButton(
              toolTip: 'sendusername1'.translate,
              child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(MdiIcons.share, color: Fav.design.appBar.text)),
              onSelected: (value) {
                if (value == 1) {
                  controller.sendSMS();
                } else if (value == 2) {
                  EkolPrintHelper.printUsername(controller.selectedItem!);
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(child: Text('sendusername1'.translate, style: TextStyle(color: Fav.design.primaryText)), value: 1),
                  PopupMenuItem(child: Text('printusername1'.translate, style: TextStyle(color: Fav.design.primaryText)), value: 2),
                ];
              });

          final Widget _exportItems = MyPopupMenuButton(
            itemBuilder: (context) {
              return <PopupMenuEntry>[
                PopupMenuItem(value: 3, child: Text('copyanotherterm'.translate)),
                PopupMenuItem(value: 0, child: Text('fromexcell'.translate)),
                if (kIsWeb) PopupMenuItem(value: 1, child: Text('exportexcell'.translate)),
                PopupMenuItem(value: 2, child: Text(Words.print)),
              ];
            },
            child: MoreIcon(),
            onSelected: (value) async {
              if (value == 0) {
                Fav.to(ImportPageMain(menuNo: 10)).unawaited;
              } else if (value == 1) {
                var classKey = await OverPage.openChoosebleListViewFromMap(data: (AppVar.appBloc.classService!.dataList.fold<Map>({'all': 'all'.translate}, (p, e) => p..[e.key] = e.name)), title: 'chooseclass'.translate);
                if (classKey == null) return;
                ExportHelper.exportStudentList(classKey: classKey);
              } else if (value == 2) {
                RegistryMenuPrint.printStudentList(context).unawaited;
              } else if (value == 3) {
                CopyFromAnotherTermHelper.copyStudent().unawaited;
              }
            },
          );
          final _topBar = controller.newItem != null
              ? RTopBar.sameAll(leadingIcon: Icons.clear_rounded, leadingTitle: 'cancelnewentry'.translate, backButtonPressed: controller.cancelNewEntry, middle: _middle)
              : RTopBar(
                  mainLeadingTitle: 'menu1'.translate,
                  leadingTitleMainEqualBoth: true,
                  detailLeadingTitle: 'studentlist'.translate,
                  detailBackButtonPressed: controller.detailBackButtonPressed,
                  detailTrailingActions: AppVar.appBloc.hesapBilgileri.gtM ? [if (controller.selectedItem != null) _sendSmsButton, _exportItems, _newButton] : null,
                  mainTrailingActions: AppVar.appBloc.hesapBilgileri.gtM ? [_exportItems, _newButton] : null,
                  bothTrailingActions: AppVar.appBloc.hesapBilgileri.gtM ? [if (controller.selectedItem != null) _sendSmsButton, _exportItems, _newButton] : null,
                  mainMiddle: _middle,
                  detailMiddle: _middle,
                  bothMiddle: _middle,
                );
          Body? _leftBody;
          Body? _rightBody;
          if (controller.isPageLoading) {
            _leftBody = Body.child(child: MyProgressIndicator(isCentered: true));
          } else if (controller.newItem == null && controller.itemList.isEmpty) {
            _leftBody = Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.NORECORDSWITHPLUS));
          } else {
            _leftBody = controller.newItem != null
                ? null
                : Body.listviewBuilder(
                    pageStorageKey: AppVar.appBloc.hesapBilgileri.kurumID + 'studentlist',
                    listviewFirstWidget: Column(
                      children: [
                        MySearchBar(
                          onChanged: (text) {
                            controller.makeFilter(text);
                            controller.update();
                          },
                          resultCount: controller.filteredItemList.length,
                          initialText: controller.filteredText,
                        ).px4,
                        AdvanceDropdown<String?>(
                          padding: Inset(4),
                          items: [
                            DropdownItem(
                              name: 'chooseclass'.translate,
                              value: null,
                            ),
                            ...(AppVar.appBloc.classService!.dataList
                                  ..removeWhere((element) {
                                    if (AppVar.appBloc.hesapBilgileri.gtM) return false;
                                    if (AppVar.appBloc.hesapBilgileri.gtT) return !controller.teacherClassList!.contains(element.key);

                                    return true;
                                  }))
                                .map((sinif) => DropdownItem(
                                      name: sinif.name,
                                      value: sinif.key,
                                    ))
                                .toList(),
                            DropdownItem(
                              name: 'noclassstudent'.translate,
                              value: 'noclass',
                            ),
                          ],
                          onChanged: (value) {
                            controller.filteredClassKey = value;
                            controller.makeFilter(controller.filteredText);
                            controller.update();
                          },
                          initialValue: controller.filteredClassKey,
                        ),
                      ],
                    ),
                    itemCount: controller.filteredItemList.length,
                    itemBuilder: (context, index) => MyCupertinoListTile(
                      title: controller.filteredItemList[index].name,
                      onTap: () {
                        controller.selectPerson(controller.filteredItemList[index]);
                      },
                      isSelected: controller.filteredItemList[index].key == controller.itemData?.key,
                      imgUrl: controller.filteredItemList[index].imgUrl,
                    ),
                  );

            _rightBody = controller.itemData == null
                ? Body.child(child: EmptyState(emptyStateWidget: EmptyStateWidget.CHOOSELIST))
                : Body.child(
                    maxWidth: 720,
                    withKeyboardCloserGesture: true,
                    child: Form(
                      key: controller.formKey,
                      child: FormStack(
                        children: [
                          FormStackItem(
                            name: 'studentinfo'.translate,
                            child: Scroller(
                              child: AbsorbPointer(
                                absorbing: !AppVar.appBloc.hesapBilgileri.gtM,
                                child: AnimatedGroupWidget(
                                  children: [
                                    MyTextFormField(
                                      initialValue: controller.itemData!.name,
                                      labelText: "namesurname".translate,
                                      iconData: MdiIcons.account,
                                      validatorRules: ValidatorRules(req: true, minLength: 6),
                                      onSaved: (value) {
                                        controller.itemData!.name = value;
                                      },
                                    ),
                                    if (AppVar.appBloc.hesapBilgileri.gtM)
                                      MyTextFormFieldWithCounter(
                                        controller: controller.tcController,
                                        // initialValue: _data.tc,
                                        labelText: "tc".translate,
                                        iconData: MdiIcons.card,
                                        iconColor: Colors.deepOrangeAccent,
                                        validatorRules: ValidatorRules(noGap: true),
                                        onSaved: (value) {
                                          controller.itemData!.tc = value;
                                        },
                                      ),
                                    if (AppVar.appBloc.hesapBilgileri.gtM)
                                      MyTextFormField(
                                        controller: controller.usernameController,
                                        //  initialValue: _data.username,
                                        hintText: "sixcharacter".translate,
                                        labelText: "username".translate,
                                        iconData: MdiIcons.at,
                                        validatorRules: ValidatorRules(req: true, minLength: 6, noGap: true, firebaseSafe: true),
                                        onSaved: (value) {
                                          controller.itemData!.username = value;
                                        },
                                      ),
                                    if (AppVar.appBloc.hesapBilgileri.gtM)
                                      IgnorePointer(
                                        ignoring: controller.isPasswordMustHide,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: MyTextFormField(
                                                    obscureText: controller.isPasswordMustHide,
                                                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                                                    controller: controller.passwordController,
                                                    hintText: "sixcharacter".translate,
                                                    labelText: "password".translate,
                                                    iconData: MdiIcons.key,
                                                    validatorRules: ValidatorRules(req: true, minLength: 6, noGap: true, firebaseSafe: true),
                                                    onSaved: (value) {
                                                      controller.itemData!.password = value.trim();
                                                    },
                                                  ),
                                                ),
                                                IconButton(
                                                  tooltip: 'autopasswordhint'.translate,
                                                  icon: const Icon(MdiIcons.calculator),
                                                  color: Fav.design.primary,
                                                  onPressed: controller.autoPasswords,
                                                ),
                                                8.widthBox
                                              ],
                                            ),
                                            // if (MessageHelper.isParentMessageActive() && Get.find<RemoteControlValues>().userCanChangePassword == false)
                                            //   Padding(
                                            //     padding: const EdgeInsets.only(left: 32.0),
                                            //     child: Obx(() => Text(
                                            //           'parentpassword'.translate + ': ' + controller.parentPassword.value,
                                            //           style: TextStyle(color: Fav.design.primaryText, fontSize: 10),
                                            //         )),
                                            //   ),
                                          ],
                                        ),
                                      ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MyTextFormField(
                                            controller: controller.schoolNoController,
                                            // initialValue: controller.itemData.no,
                                            labelText: "studentno".translate,
                                            iconData: MdiIcons.counter,
                                            validatorRules: ValidatorRules(
                                              req: true,
                                              noGap: true,
                                              minLength: AppVar.appBloc.hesapBilgileri.isEkolOrUni ? 1 : 0,
                                            ),
                                            onSaved: (value) {
                                              controller.itemData!.no = value;
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'autostudentnohint'.translate,
                                          icon: const Icon(MdiIcons.autoFix),
                                          color: Fav.design.primaryText,
                                          onPressed: controller.autoSchoolNo,
                                        ),
                                        8.widthBox
                                      ],
                                    ),
                                    AdvanceDropdown<String?>(
                                      initialValue: controller.itemData!.class0,
                                      name: "classtype0".translate,
                                      iconData: MdiIcons.humanMaleBoard,
                                      items: controller.classDropDownList,
                                      onSaved: (value) {
                                        controller.itemData!.class0 = value;
                                      },
                                      onChanged: (value) {
                                        controller.classKeyForAutoScoolNo = value;
                                      },
                                    ),
                                    if (controller.etudClassDropDownList != null)
                                      AdvanceDropdown<String?>(
                                        initialValue: controller.itemData!.groupList['t1'],
                                        name: "classtype1".translate,
                                        iconData: MdiIcons.humanMaleBoard,
                                        items: controller.etudClassDropDownList!,
                                        onSaved: (value) {
                                          controller.itemData!.groupList['t1'] = value;
                                        },
                                      ),
                                    if (MenuList.hasTimeTable())
                                      ...AppVar.appBloc.schoolInfoService!.singleData!.filteredClassType!.entries.map((item) {
                                        return AdvanceDropdown<String?>(
                                          initialValue: controller.itemData!.groupList[item.key], //todo
                                          name: item.value,
                                          iconData: MdiIcons.humanMaleBoard,
                                          items: AppVar.appBloc.classService!.dataList.where((sinif) => sinif.classType == int.tryParse(item.key.replaceAll('t', ''))).map((sinif) {
                                            return DropdownItem<String?>(value: sinif.key, name: sinif.name);
                                          }).toList()
                                            ..insert(0, DropdownItem<String?>(value: null, name: "secimyapilmamis".translate)),
                                          onSaved: (value) {
                                            controller.itemData!.groupList[item.key] = value;
                                          },
                                        ); //todo
                                      }).toList(),
                                    AdvanceDropdown<bool>(
                                      initialValue: controller.itemData!.genre,
                                      name: "genre".translate,
                                      iconData: MdiIcons.genderMaleFemale,
                                      items: [
                                        DropdownItem(name: "genre1".translate, value: false),
                                        DropdownItem(name: "genre2".translate, value: true),
                                      ],
                                      onSaved: (value) {
                                        controller.itemData!.genre = value;
                                      },
                                    ),
                                    MyDatePicker(
                                      initialValue: controller.itemData!.birthday,
                                      title: "birthday".translate,
                                      firstYear: 1985,
                                      lastYear: 2025,
                                      onSaved: (value) {
                                        controller.itemData!.birthday = value;
                                      },
                                    ),
                                    if (AppVar.appBloc.hesapBilgileri.isEkolOrUni)
                                      MyTextFormField(
                                        initialValue: controller.itemData!.studentPhone,
                                        labelText: "student".translate + " " + "phone".translate,
                                        iconData: MdiIcons.phone,
                                        validatorRules: ValidatorRules(phoneNumber: true, noGap: true),
                                        keyboardType: TextInputType.phone,
                                        onSaved: (value) {
                                          controller.itemData!.studentPhone = value;
                                        },
                                      ),
                                    ...StudentDataExtra.widgetList(controller.itemData),
                                    if (controller.transporterDropDownList != null)
                                      AdvanceDropdown<String?>(
                                        initialValue: controller.itemData!.transporter,
                                        name: "transporter".translate,
                                        iconData: MdiIcons.bus,
                                        items: controller.transporterDropDownList!,
                                        onSaved: (value) {
                                          controller.itemData!.transporter = value;
                                        },
                                      ),
                                    MyDatePicker(
                                      initialValue: controller.itemData!.startTime,
                                      title: "starttime".translate,
                                      firstYear: 2012,
                                      lastYear: 2025,
                                      onSaved: (value) {
                                        controller.itemData!.startTime = value;
                                      },
                                    ),
                                    if (AppVar.appBloc.hesapBilgileri.gtM)
                                      MyTextFormField(
                                        initialValue: controller.itemData!.adress,
                                        maxLines: null,
                                        hintText: "...".translate,
                                        labelText: "adres".translate,
                                        iconData: MdiIcons.mapMarker,
                                        onSaved: (value) {
                                          controller.itemData!.adress = value;
                                        },
                                      ),
                                    MyTextFormField(
                                      initialValue: controller.itemData!.explanation,
                                      maxLines: null,
                                      hintText: "...".translate,
                                      labelText: "aciklama".translate,
                                      iconData: MdiIcons.information,
                                      onSaved: (value) {
                                        controller.itemData!.explanation = value;
                                      },
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: MyPhotoUploadWidget(
                                        saveLocation: AppVar.appBloc.hesapBilgileri.kurumID + '/' + AppVar.appBloc.hesapBilgileri.termKey + '/' + "UserProfileImages",
                                        initialValue: controller.itemData!.imgUrl,
                                        avatarImage: true,
                                        onSaved: (value) {
                                          controller.itemData!.imgUrl = value;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          FormStackItem(
                            name: 'parentinfo'.translate,
                            child: AbsorbPointer(
                              absorbing: !AppVar.appBloc.hesapBilgileri.gtM,
                              child: Scroller(
                                child: Column(
                                  children: [
                                    Group2Widget(
                                      children: [
                                        MyTextFormField(
                                          initialValue: controller.itemData!.fatherName,
                                          labelText: "father".translate + " " + "name2".translate,
                                          iconData: MdiIcons.account,
                                          onSaved: (value) {
                                            controller.itemData!.fatherName = value;
                                          },
                                        ),
                                        if (AppVar.appBloc.hesapBilgileri.gtM)
                                          MyTextFormField(
                                            initialValue: controller.itemData!.fatherPhone,
                                            labelText: "father".translate + " " + "phone".translate,
                                            iconData: MdiIcons.phone,
                                            validatorRules: ValidatorRules(phoneNumber: true, noGap: true),
                                            keyboardType: TextInputType.phone,
                                            onSaved: (value) {
                                              controller.itemData!.fatherPhone = value;
                                            },
                                          ),
                                        MyTextFormField(
                                          initialValue: controller.itemData!.fatherJob,
                                          labelText: "father".translate + " " + "job".translate,
                                          iconData: MdiIcons.accountStar,
                                          onSaved: (value) {
                                            controller.itemData!.fatherJob = value;
                                          },
                                        ),
                                        MyDatePicker(
                                          initialValue: controller.itemData!.fatherBirthday,
                                          title: "father".translate + " " + "birthday".translate,
                                          firstYear: 1950,
                                          lastYear: 2025,
                                          onSaved: (value) {
                                            controller.itemData!.fatherBirthday = value;
                                          },
                                        ),
                                        if (AppVar.appBloc.hesapBilgileri.gtM)
                                          MyTextFormField(
                                            initialValue: controller.itemData!.fatherMail,
                                            labelText: "father".translate + " " + "mail".translate,
                                            iconData: MdiIcons.at,
                                            onSaved: (value) {
                                              controller.itemData!.fatherMail = value.trim();
                                            },
                                          ),
                                      ],
                                    ),
                                    Group2Widget(
                                      children: [
                                        MyTextFormField(
                                          initialValue: controller.itemData!.motherName,
                                          labelText: "mother".translate + " " + "name2".translate,
                                          iconData: MdiIcons.account,
                                          onSaved: (value) {
                                            controller.itemData!.motherName = value;
                                          },
                                        ),
                                        if (AppVar.appBloc.hesapBilgileri.gtM)
                                          MyTextFormField(
                                            initialValue: controller.itemData!.motherPhone,
                                            labelText: "mother".translate + " " + "phone".translate,
                                            iconData: MdiIcons.phone,
                                            validatorRules: ValidatorRules(phoneNumber: true, noGap: true),
                                            keyboardType: TextInputType.phone,
                                            onSaved: (value) {
                                              controller.itemData!.motherPhone = value;
                                            },
                                          ),
                                        MyTextFormField(
                                          initialValue: controller.itemData!.motherJob,
                                          labelText: "mother".translate + " " + "job".translate,
                                          iconData: MdiIcons.accountStar,
                                          onSaved: (value) {
                                            controller.itemData!.motherJob = value;
                                          },
                                        ),
                                        MyDatePicker(
                                          initialValue: controller.itemData!.motherBirthday,
                                          title: "mother".translate + " " + "birthday".translate,
                                          firstYear: 1950,
                                          lastYear: 2025,
                                          onSaved: (value) {
                                            controller.itemData!.motherBirthday = value;
                                          },
                                        ),
                                        if (AppVar.appBloc.hesapBilgileri.gtM)
                                          MyTextFormField(
                                            initialValue: controller.itemData!.motherMail,
                                            labelText: "mother".translate + " " + "mail".translate,
                                            iconData: MdiIcons.at,
                                            onSaved: (value) {
                                              controller.itemData!.motherMail = value.trim();
                                            },
                                          ),
                                      ],
                                    ),
                                    Group2Widget(
                                      children: [
                                        AdvanceDropdown<int?>(
                                          initialValue: controller.itemData!.parentState,
                                          name: "parentState".translate,
                                          iconData: MdiIcons.bus,
                                          items: [
                                            DropdownItem(child: '-'.text.make(), value: null),
                                            ...Iterable.generate(5, (e) => e)
                                                .map(
                                                  (e) => DropdownItem(name: 'parentState${e + 1}'.translate, value: e + 1),
                                                )
                                                .toList(),
                                          ],
                                          onSaved: (value) {
                                            controller.itemData!.parentState = value;
                                          },
                                          onChanged: (value) {
                                            controller.itemData!.parentState = value;
                                            controller.update();
                                          },
                                        ),
                                        if (AppVar.appBloc.hesapBilgileri.gtM && !AppVar.appBloc.hesapBilgileri.isEkid)
                                          IgnorePointer(
                                            ignoring: controller.isParent1PasswordMustHide,
                                            child: MyTextFormField(
                                              obscureText: controller.isParent1PasswordMustHide,
                                              initialValue: controller.itemData!.parentPassword1,
                                              hintText: "sixcharacter".translate,
                                              labelText: "parentpassword".translate + ' ' + (controller.itemData!.parentState == 2 ? '(${"mother".translate})' : ''),
                                              iconData: MdiIcons.key,
                                              validatorRules: ValidatorRules(),
                                              onSaved: (value) {
                                                controller.itemData!.parentPassword1 = value.trim();
                                              },
                                            ),
                                          ),
                                        if (AppVar.appBloc.hesapBilgileri.gtM && controller.itemData!.parentState == 2)
                                          IgnorePointer(
                                            ignoring: controller.isParent2PasswordMustHide,
                                            child: MyTextFormField(
                                              obscureText: controller.isParent2PasswordMustHide,
                                              initialValue: controller.itemData!.parentPassword2,
                                              hintText: "sixcharacter".translate,
                                              labelText: (AppVar.appBloc.hesapBilgileri.isEkid ? ('2. ' + 'password'.translate) : "parentpassword".translate) + ' (${"father".translate})',
                                              iconData: MdiIcons.key,
                                              validatorRules: ValidatorRules(),
                                              onSaved: (value) {
                                                controller.itemData!.parentPassword2 = value.trim();
                                              },
                                            ),
                                          )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          FormStackItem(
                            name: 'healthinfo'.translate,
                            child: AbsorbPointer(
                              absorbing: !AppVar.appBloc.hesapBilgileri.gtM,
                              child: Group2Widget(
                                children: [
                                  MyTextFormField(
                                    maxLines: null,
                                    initialValue: controller.itemData!.allergy,
                                    labelText: "allergy".translate,
                                    iconData: MdiIcons.pill,
                                    onSaved: (value) {
                                      controller.itemData!.allergy = value;
                                    },
                                  ),
                                  AdvanceDropdown<String>(
                                    initialValue: controller.itemData!.blood ?? "?",
                                    name: "bloodgenre".translate,
                                    iconData: MdiIcons.bloodBag,
                                    items: ['?', "0+", "0-", "A+", "A-", "B+", "B-", "AB+", "AB-"].map((e) => DropdownItem(name: e, value: e)).toList(),
                                    onSaved: (value) {
                                      controller.itemData!.blood = value;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
          }

          RBottomBar? _bottomBar;
          if (AppVar.appBloc.hesapBilgileri.gtM && controller.itemData != null && (controller.visibleScreen == VisibleScreen.detail)) {
            Widget _bottomChild = Row(
              children: [
                if (controller.selectedItem != null)
                  MyPopupMenuButton(
                    itemBuilder: (context) {
                      return <PopupMenuEntry>[
                        PopupMenuItem(value: 0, child: Text(Words.delete)),
                        // const PopupMenuDivider(),
                        // PopupMenuItem(value: 1, child: Text('copyotherterm'.translate)),
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
                        var sure = await Over.sure(message: controller.selectedItem!.name + '\n' + 'deleterecorderr'.translate);
                        if (sure == true) await controller.delete();
                      }
                      // else if (value == 1) {
                      //   await controller.copy();
                      // }
                    },
                  ),
                const Spacer(),
                if (AuthorityHelper.hasYetki3() && context.screenWidth > 600)
                  MyMiniRaisedButton(
                    onPressed: () {
                      if (!controller.isSaving) {
                        controller.save(goAccounting: true);
                      }
                    },
                    text: "saveandgoaccounting".translate,
                  ),
                8.widthBox,
                MyProgressButton(
                  onPressed: () {
                    controller.save();
                  },
                  label: Words.save,
                  isLoading: controller.isSaving,
                ),
                16.widthBox,
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
