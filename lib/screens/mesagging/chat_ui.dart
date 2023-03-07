import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

import '../../helpers/glassicons.dart';

class ChatUi extends StatefulWidget {
  final Widget? trailing;
  final String? title;
  final Widget? largeTitleActions;
  final Widget? body;
  final Widget? bottom;
  final ScrollController? scrollController;
  ChatUi({this.trailing, this.title, this.body, this.scrollController, this.largeTitleActions, this.bottom});

  @override
  State<ChatUi> createState() => _ChatUiState();
}

class _ChatUiState extends State<ChatUi> {
  bool largeTitleVisible = true;
  @override
  void initState() {
    widget.scrollController?.addListener(() {
      setState(() {
        largeTitleVisible = widget.scrollController!.offset < 1;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Fav.design.scaffold.background,
      body: Stack(
        children: [
          Positioned(left: 0, right: 0, top: 0, bottom: 0, child: widget.body!),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Fav.design.others['appbar.background']!.withAlpha(215),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: Get.back,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icons.arrow_back_ios_new_rounded.icon.color(Fav.design.appBar.text).padding(2).make(),
                                  'messages'.translate.text.color(Fav.design.appBar.text).make(),
                                ],
                              ),
                            ).p4,
                          ),
                          Expanded(
                            child: Align(alignment: Alignment.center, child: widget.title.text.color(GlassIcons.messagesIcon.color!).bold.autoSize.fontSize(18).maxLines(1).make()),
                          ),
                          if (widget.trailing != null) Expanded(child: Align(alignment: Alignment.topRight, child: widget.trailing)) else const Spacer(),
                        ],
                      ).paddingOnly(top: context.screenTopPadding, left: context.screenLeftPadding, right: context.screenRightPadding),
                      if (widget.largeTitleActions != null)
                        AnimatedSwitcher(
                            duration: const Duration(milliseconds: 222),
                            transitionBuilder: (child, animation) {
                              return SizeTransition(sizeFactor: animation, child: child);
                            },
                            child: !largeTitleVisible ? const SizedBox() : widget.largeTitleActions),
                      Container(
                        color: Fav.design.primaryText.withAlpha(15),
                        height: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Fav.design.others['appbar.background']!.withAlpha(215),
                  child: SafeArea(top: false, child: Align(alignment: Alignment.center, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: widget.bottom))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
