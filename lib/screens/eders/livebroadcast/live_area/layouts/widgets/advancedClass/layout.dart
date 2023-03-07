import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../../../../appbloc/appvar.dart';
import 'controller.dart';

class AdvancedClassMain extends StatelessWidget {
  AdvancedClassMain();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvancedClassController>(builder: (controller) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            child: Row(
              children: [
                'live'.translate.text.fontSize(18).make(),
                const Spacer(),
                if (AppVar.appBloc.hesapBilgileri.imgUrl.safeLength > 2) CircleAvatar(backgroundImage: CacheHelper.imageProvider(imgUrl: AppVar.appBloc.hesapBilgileri.imgUrl!), radius: 16),
              ],
            ),
          ),
          Expanded(
            child: controller.layoutType == 1 ? Layout1() : Layout2(),
          ),
        ],
      );
    });
  }
}

class Layout2 extends StatelessWidget {
  Layout2();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdvancedClassController>();

    return Center(
      child: SingleChildScrollView(
        child: LayoutBuilder(builder: (context, constraints) {
          if (controller.bigWidgetKey != null && controller.participantHolders[controller.bigWidgetKey!] != null) {
            return PointerInterceptor(
              child: GestureDetector(
                onTap: () {
                  controller.bigWidgetKey = null;
                  controller.update();
                },
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: constraints.maxWidth - 32,
                      height: (constraints.maxWidth - 32) * 9 / 16,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Fav.design.primaryText.withAlpha(100)), color: Fav.design.scaffold.background),
                      child: controller.participantHolders[controller.bigWidgetKey!]!.widget,
                    ),
                    Positioned(
                      bottom: 2,
                      right: 8,
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: NameWidget(
                            name: (controller.participantHolders[controller.bigWidgetKey!]!.model?.name ?? ''),
                          )),
                    ),
                  ],
                ).paddingAll(16),
              ),
            );
          }

          final typeIsBig = controller.participantHolders.entries.length > 23;
          final double _participantWidth = min((constraints.maxWidth - (typeIsBig ? 14 : 10) * controller.padding) / (typeIsBig ? 7 : 5), 180.0);

          final _participantHeight = _participantWidth / 16 * 9;
          final _bigParticipantWidth = _participantWidth * 3 + 6 * controller.padding;
          final _bigParticipantHeight = _bigParticipantWidth / 16 * 9;

          List<Widget> participantWidgetList = [
            ...controller.participantHolders.entries.where((element) => !element.value.isScreenShare! && !element.value.isLocal! && !element.value.isHost!).map((e) {
              if (controller.bigWidgetKey == e.value.webUid) return const SizedBox();

              return ParticipantWidget(
                width: _participantWidth,
                height: _participantHeight,
                holder: e.value,
                padding: controller.padding,
              );
            }).toList(),
            for (var t = 0; t < 13 - controller.participantHolders.entries.length; t++)
              EmptyParticipant(
                width: _participantWidth,
                height: _participantHeight,
                padding: controller.padding,
              ),
          ];
          final int participantWidgetListLength = participantWidgetList.length;
          return Row(
            children: [
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  children: [
                    for (var i = 0; i < participantWidgetListLength; i = i + 2)
                      if (i < 6 || i > 11) participantWidgetList[i],
                  ],
                ),
              ),
              controller.padding.widthBox,
              SizedBox(
                width: _bigParticipantWidth,
                child: Column(
                  children: [
                    Row(
                      children: [
                        participantWidgetList[6],
                        participantWidgetList[7],
                        participantWidgetList[8],
                      ],
                    ),
                    HostArea(width: _bigParticipantWidth, height: _bigParticipantHeight, padding: controller.padding),
                    ScreenShareArea(width: _bigParticipantWidth, height: _bigParticipantHeight, padding: controller.padding),
                    LocalArea(width: _bigParticipantWidth, height: _bigParticipantHeight, padding: controller.padding),
                    Row(
                      children: [
                        if (participantWidgetListLength > 9) participantWidgetList[9],
                        if (participantWidgetListLength > 10) participantWidgetList[10],
                        if (participantWidgetListLength > 11) participantWidgetList[11],
                      ],
                    ),
                  ],
                ),
              ),
              controller.padding.widthBox,
              Expanded(
                child: Wrap(
                  children: [
                    for (var i = 1; i < participantWidgetListLength; i = i + 2)
                      if (i < 6 || i > 11) participantWidgetList[i],
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    ).p4;
  }
}

class Layout1 extends StatelessWidget {
  Layout1();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdvancedClassController>();
    return Center(
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Card(
          margin: EdgeInsets.zero,
          color: Fav.design.card.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: BigWidget()),
              Column(
                children: [
                  LocalArea(width: controller.participantWidth, height: controller.participantHeigth, padding: controller.padding),
                  ScreenShareArea(width: controller.participantWidth, height: controller.participantHeigth, padding: controller.padding),
                  HostArea(width: controller.participantWidth, height: controller.participantHeigth, padding: controller.padding),
                  Expanded(child: Layout1ParticipantArea()),
                ],
              ).p8,
            ],
          ),
        ).p16,
      ),
    );
  }
}

class HostArea extends StatelessWidget {
  final double? width;
  final double? height;
  final double? padding;
  HostArea({this.width, this.height, this.padding});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdvancedClassController>();
    Holder? holder = controller.participantHolders.entries.firstWhereOrNull((element) => element.value.isHost == true)?.value;
    if (holder == null) return const SizedBox();
    if (controller.bigWidgetKey == holder.webUid) return const SizedBox();

    String hostName = 'Host';
    return PointerInterceptor(
      child: GestureDetector(
        onTap: () {
          controller.bigWidgetKey = holder.webUid;
          controller.update();
        },
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            children: [
              holder.widget!,
              Positioned(
                bottom: 2,
                right: 8,
                child: ConstrainedBox(constraints: BoxConstraints(maxWidth: width! * 3 / 4), child: NameWidget(name: hostName)),
              ),
            ],
          ),
        ).paddingAll(padding!),
      ),
    );
  }
}

class LocalArea extends StatelessWidget {
  final double? width;
  final double? height;
  final double? padding;
  LocalArea({this.width, this.height, this.padding});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdvancedClassController>();

    if (controller.bigWidgetKey == controller.ownKey) return const SizedBox();
    Widget? current = controller.participantHolders.entries.firstWhereOrNull((element) => element.value.isLocal == true)?.value.widget;
    if (current == null) return const SizedBox();
    current = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Fav.design.primary.withAlpha(100)),
      child: GestureDetector(
        onTap: () {
          controller.bigWidgetKey = controller.ownKey;
          controller.update();
        },
        child: PointerInterceptor(
          child: Stack(
            children: [
              current,
              Positioned(
                bottom: 2,
                right: 8,
                child: ConstrainedBox(constraints: BoxConstraints(maxWidth: width! * 3 / 4), child: NameWidget(name: AppVar.appBloc.hesapBilgileri.name)),
              ),
            ],
          ),
        ),
      ),
    ).paddingAll(padding!);

    return current;
  }
}

class ScreenShareArea extends StatelessWidget {
  final double? width;
  final double? height;
  final double? padding;
  ScreenShareArea({this.width, this.height, this.padding});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdvancedClassController>();
    if (controller.bigWidgetKey == 'ScreenShare') return const SizedBox();
    Widget? current = controller.participantHolders.entries.firstWhereOrNull((element) => element.value.isScreenShare == true)?.value.widget;
    if (current == null) return const SizedBox();

    return PointerInterceptor(
      child: GestureDetector(
        onTap: () {
          controller.bigWidgetKey = 'ScreenShare';
          controller.update();
        },
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            children: [
              current,
              Positioned(
                bottom: 2,
                right: 8,
                child: ConstrainedBox(constraints: BoxConstraints(maxWidth: width! * 3 / 4), child: NameWidget(name: 'screenshare'.translate)),
              ),
            ],
          ),
        ).paddingAll(controller.padding),
      ),
    );
  }
}

class Layout1ParticipantArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdvancedClassController>();
    return SingleChildScrollView(
      child: Column(
        children: [
          ...controller.participantHolders.entries.where((element) => !element.value.isScreenShare! && !element.value.isLocal! && !element.value.isHost!).map((e) {
            if (controller.bigWidgetKey == e.value.webUid) return const SizedBox();

            return ParticipantWidget(
              width: controller.participantWidth,
              height: controller.participantHeigth,
              holder: e.value,
              padding: controller.padding,
            ).pb4;
          }).toList(),
          for (var t = 0; t < 7 - controller.participantHolders.entries.length; t++)
            EmptyParticipant(
              width: controller.participantWidth,
              height: controller.participantHeigth,
              padding: 0,
            ).pb4,
        ],
      ),
    );
  }
}

class ParticipantWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final Holder? holder;
  final double? padding;
  ParticipantWidget({this.width, this.height, this.holder, this.padding});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdvancedClassController>();
    return PointerInterceptor(
      child: GestureDetector(
        onTap: () {
          controller.bigWidgetKey = holder!.webUid;
          controller.update();
        },
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              width: width,
              height: height,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Fav.design.primaryText.withAlpha(100)), color: Fav.design.scaffold.background),
              child: holder!.widget,
            ),
            Positioned(
              bottom: 2,
              right: 8,
              child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: width! / 2),
                  child: NameWidget(
                    name: holder!.model!.name,
                  )),
            ),
          ],
        ).paddingAll(padding!),
      ),
    );
  }
}

class EmptyParticipant extends StatelessWidget {
  final double? width;
  final double? height;
  final double? padding;
  EmptyParticipant({this.width, this.height, this.padding});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        alignment: Alignment.center,
        width: width,
        height: height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Fav.design.primaryText.withAlpha(30)), color: Fav.design.scaffold.background),
        child: Icon(
          Icons.person_pin,
          color: Fav.design.primaryText.withAlpha(180),
        ),
      ).paddingAll(padding!),
    );
  }
}

class BigWidget extends StatelessWidget {
  BigWidget();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdvancedClassController>();
    if (controller.bigWidgetKey == 'ScreenShare') {
      //todo ekran paylasim en boy oraninu ayarla
      // p.info('zoom = screenshare');
      // return Container(
      //   //   alignment: Alignment.center,
      //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      //   child: FittedBox(fit: BoxFit.contain, child: zoomedView),
      // ).paddingAll(padding);
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: controller.bigWidgetKey == null
          ? const SizedBox()
          : controller.participantHolders[controller.bigWidgetKey!] == null
              ? const SizedBox()
              : controller.participantHolders[controller.bigWidgetKey!]!.widget,
    ).paddingAll(controller.padding);
  }
}

class NameWidget extends StatelessWidget {
  final String? name;
  NameWidget({this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(radius: 12, backgroundColor: Colors.white60, child: Icons.fullscreen.icon.size(12).padding(0).color(Colors.black).make()),
        4.widthBox,
        if (name.safeLength > 0) Flexible(child: name.text.fontSize(9).maxLines(2).color(Colors.black).make().stadium(background: Colors.white60)),
      ],
    ).p4;
  }
}
