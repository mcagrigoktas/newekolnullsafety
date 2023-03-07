import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:widgetpackage/widgetpackage.dart';

import '../../../assets.dart';
import '../../../helpers/glassicons.dart';

class MyCustomPainter extends CustomPainter {
  MyCustomPainter({this.insetRadius = 38});

  final double insetRadius;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path()..moveTo(0, 12);

    double insetCurveBeginnningX = size.width / 2 - insetRadius;
    double insetCurveEndX = size.width / 2 + insetRadius;
    double transitionToInsetCurveWidth = size.width * .05;
    path.quadraticBezierTo(size.width * 0.20, 0, insetCurveBeginnningX - transitionToInsetCurveWidth, 0);
    path.quadraticBezierTo(insetCurveBeginnningX, 0, insetCurveBeginnningX, insetRadius / 2);

    path.arcToPoint(Offset(insetCurveEndX, insetRadius / 2), radius: Radius.circular(10.0), clockwise: false);

    path.quadraticBezierTo(insetCurveEndX, 0, insetCurveEndX + transitionToInsetCurveWidth, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 12);
    path.lineTo(size.width, size.height + 56);
    path.lineTo(0, size.height + 56);

    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Fav.design.customDesign5.shadow
          ..strokeWidth = 0.4);
    //canvas.drawShadow(path, _shadowColor, 5.0, false);
  }

  @override
  bool shouldRepaint(oldDelegate) => false;
}

class MyCustomClipper extends CustomClipper<Path> {
  double insetRadius;
  MyCustomClipper({this.insetRadius = 38});
  @override
  Path getClip(Size size) {
    Path path = Path()..moveTo(0, 12);

    double insetCurveBeginnningX = size.width / 2 - insetRadius;
    double insetCurveEndX = size.width / 2 + insetRadius;
    double transitionToInsetCurveWidth = size.width * .05;
    path.quadraticBezierTo(size.width * 0.20, 0, insetCurveBeginnningX - transitionToInsetCurveWidth, 0);
    path.quadraticBezierTo(insetCurveBeginnningX, 0, insetCurveBeginnningX, insetRadius / 2);

    path.arcToPoint(Offset(insetCurveEndX, insetRadius / 2), radius: Radius.circular(10.0), clockwise: false);

    path.quadraticBezierTo(insetCurveEndX, 0, insetCurveEndX + transitionToInsetCurveWidth, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 12);
    path.lineTo(size.width, size.height + 56);
    path.lineTo(0, size.height + 56);
    return path;
  }

  @override
  bool shouldReclip(MyCustomClipper oldClipper) => false;
}

class QBankCurvedBottomNavBarButton extends StatelessWidget {
  const QBankCurvedBottomNavBarButton({
    Key? key,
    this.imgAsset,
    this.imgAsset2,
    this.selectedColor,
    this.icon,
    this.icon2,
    required this.selected,
    required this.onPressed,
    this.name,
  }) : super(key: key);
  final String? imgAsset;
  final String? imgAsset2;
  final IconData? icon;
  final IconData? icon2;
  final bool selected;
  final Function() onPressed;
  final Color? selectedColor;
  final String? name;

  @override
  Widget build(BuildContext context) {
    if (imgAsset != null) {
      return InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
              child: AnimatedSwitcher(
                duration: 333.milliseconds,
                child: SizedBox(
                  key: ValueKey(imgAsset! + selected.toString()),
                  height: 28,
                  width: 28,
                  child: !selected ? (imgAsset2!.endsWith('svg') ? SvgPicture.asset(imgAsset2!) : Image.asset(imgAsset2!)) : (imgAsset!.endsWith('svg') ? SvgPicture.asset(imgAsset!) : Image.asset(imgAsset!)),
                ),
              ),
            ),
            if (name == null) 8.heightBox,
            if (name != null)
              AnimatedDefaultTextStyle(
                duration: 333.milliseconds,
                style: TextStyle(
                  color: selected ? selectedColor : Fav.design.bottomNavigationBar.unSelected,
                  fontFamily: Theme.of(context).textTheme.bodyText2!.fontFamily,
                  fontSize: 9.5,
                ),
                child: Text(
                  name!,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    }
    return QudsAnimatedCombinedIconsButton(
      startIcon: icon!,
      endIcon: icon2!,
      duration: 333.milliseconds,
      startIconColor: selectedColor ?? Fav.design.bottomNavigationBar.indicator,
      endIconColor: Fav.design.bottomNavigationBar.unSelected,
      showStartIcon: selected,
      onPressed: onPressed,
      withRotation: false,
    );
  }
}

class EkolCurvedBottomNavBarButton extends StatelessWidget {
  const EkolCurvedBottomNavBarButton({
    Key? key,
    this.imgAsset,
    this.selectedColor,
    required this.icon,
    required this.icon2,
    required this.selected,
    required this.onPressed,
    this.name,
  }) : super(key: key);
  final String? imgAsset;
  final IconData icon;
  final IconData icon2;
  final bool selected;
  final Function() onPressed;
  final Color? selectedColor;
  final String? name;

  @override
  Widget build(BuildContext context) {
    if (imgAsset != null) {
      return InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
              child: AnimatedSwitcher(
                duration: 333.milliseconds,
                child: SizedBox(
                  key: ValueKey(imgAsset! + selected.toString()),
                  height: 28,
                  width: 28,
                  child: !selected
                      ? icon.icon.padding(0).color(Fav.design.bottomNavigationBar.unSelected).make()
                      : imgAsset!.endsWith('svg')
                          ? SvgPicture.asset(imgAsset!)
                          : Image.asset(imgAsset!),
                ),
              ),
            ),
            if (name == null) 8.heightBox,
            if (name != null)
              AnimatedDefaultTextStyle(
                duration: 333.milliseconds,
                style: TextStyle(
                  color: selected ? selectedColor : Fav.design.bottomNavigationBar.unSelected,
                  fontFamily: Theme.of(context).textTheme.bodyText2!.fontFamily,
                  fontSize: 9.5,
                ),
                child: Text(
                  name!,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    }
    return QudsAnimatedCombinedIconsButton(
      startIcon: icon,
      endIcon: icon2,
      duration: 333.milliseconds,
      startIconColor: selectedColor ?? Fav.design.bottomNavigationBar.indicator,
      endIconColor: Fav.design.bottomNavigationBar.unSelected,
      showStartIcon: selected,
      onPressed: onPressed,
      withRotation: false,
    );
  }
}

class EkolCurverBotomNavigationFAB extends StatelessWidget {
  const EkolCurverBotomNavigationFAB({
    Key? key,
    required this.selected,
    required this.onPressed,
  }) : super(key: key);

  final bool selected;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    if (2 > 1) {
      return FloatingActionButton(
          child: AnimatedContainer(
            duration: 200.milliseconds,
            width: 60,
            height: 60,
            decoration: selected
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      Fav.design.customDesign5.accent,
                      Fav.design.customDesign5.primary,
                    ]))
                : BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 0.2, color: Fav.design.customDesign5.shadow),
                    gradient: RadialGradient(colors: [
                      Fav.design.bottomNavigationBar.background.withOpacity(1.0),
                      Fav.design.bottomNavigationBar.background.withOpacity(1.0),
                    ]),
                    // color: Fav.design.bottomNavigationBar.background.withOpacity(1.0),
                  ),
            child: selected ? MdiIcons.widgets.icon.color(Colors.white).make() : MdiIcons.widgetsOutline.icon.color(Fav.design.bottomNavigationBar.unSelected).make(),
          ),
          elevation: 5,
          onPressed: onPressed);
    }

    final imgAsset = GlassIcons.apps.imgUrl!;
    const icon = MdiIcons.widgetsOutline;
    return FloatingActionButton(
      onPressed: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 0.2, color: Fav.design.customDesign5.shadow),
          color: Fav.design.bottomNavigationBar.background.withOpacity(1.0),
        ),
        child: AnimatedSwitcher(
          duration: 333.milliseconds,
          child: SizedBox(
            key: ValueKey(imgAsset + selected.toString()),
            height: 28,
            width: 28,
            child: !selected
                ? icon.icon.padding(0).color(Fav.design.bottomNavigationBar.unSelected).make()
                : imgAsset.endsWith('svg')
                    ? SvgPicture.asset(imgAsset)
                    : Image.asset(imgAsset),
          ),
        ),
      ),
    );
  }
}

class QBankCurverBotomNavigationFAB extends StatelessWidget {
  //? Text yapmak istersen bookstore.translate i koyabilirsin
  const QBankCurverBotomNavigationFAB({
    Key? key,
    required this.selected,
    required this.onPressed,
  }) : super(key: key);

  final bool selected;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    // if (2 > 1) {
    //   return FloatingActionButton(
    //       child: AnimatedContainer(
    //         duration: 200.milliseconds,
    //         width: 60,
    //         height: 60,
    //         decoration: selected
    //             ? BoxDecoration(
    //                 shape: BoxShape.circle,
    //                 gradient: RadialGradient(colors: [
    //                   Fav.design.customDesign5.accent,
    //                   Fav.design.customDesign5.primary,
    //                 ]))
    //             : BoxDecoration(
    //                 shape: BoxShape.circle,
    //                 border: Border.all(width: 0.2, color: Fav.design.customDesign5.shadow),
    //                 gradient: RadialGradient(colors: [
    //                   Fav.design.bottomNavigationBar.background.withOpacity(1.0),
    //                   Fav.design.bottomNavigationBar.background.withOpacity(1.0),
    //                 ]),
    //                 // color: Fav.design.bottomNavigationBar.background.withOpacity(1.0),
    //               ),
    //         child: selected ? MdiIcons.widgets.icon.color(Colors.white).make() : MdiIcons.widgetsOutline.icon.color(Fav.design.bottomNavigationBar.unSelected).make(),
    //       ),
    //       elevation: 5,
    //       onPressed: onPressed);
    // }

    final imgAsset = Assets.images.homePNG;
    const icon = MdiIcons.widgetsOutline;
    return FloatingActionButton(
      onPressed: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 0.2, color: Fav.design.customDesign5.shadow),
          color: Fav.design.bottomNavigationBar.background.withOpacity(1.0),
        ),
        child: AnimatedSwitcher(
          duration: 333.milliseconds,
          child: SizedBox(
            key: ValueKey(imgAsset + selected.toString()),
            height: 28,
            width: 28,
            child: !selected
                ? icon.icon.padding(0).color(Fav.design.bottomNavigationBar.unSelected).make()
                : imgAsset.endsWith('svg')
                    ? SvgPicture.asset(imgAsset)
                    : Image.asset(imgAsset),
          ),
        ),
      ),
    );
  }
}
