import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

class EkolDark {
  EkolDark._();
  static Design get theme => Design(
      themeData: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff2e3138),
        primaryColor: const Color(0xff3D9AEF),
        dialogBackgroundColor: const Color(0xff2e3138),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.resolveWith((state) => state.contains(MaterialState.hovered) ? Colors.grey : Fav.design.primaryText.withAlpha(10)),
          thickness: MaterialStateProperty.resolveWith((state) => state.contains(MaterialState.hovered) ? 8 : 5),
        ),
      ),
      layoutStyle: 0,
      primary: const Color(0xff3D9AEF),
      accent: const Color(0xff3D474F),
      primaryText: Colors.white,
      accentText: const Color(0xff3D9AEF),
      disablePrimary: const Color(0xFFC5A8C0),
      brightness: Brightness.dark,
      scaffold: ScaffoldDesign(
        background: const Color(0xff2e3138),
        backgroundAsset: 'ekol',
        backgroundAssetOpacity: 0.25,
        accentBackground: const Color(0xff1E1E1E),
      ),
      snackBar: SnackBarDesign(
        background: const Color(0xff3D9AEF),
        dangerBackground: Colors.redAccent,
      ),
      progressIndicator: ProgressIndicatorDesign(
        indicator: const Color(0xff3D9AEF),
      ),
      dropdown: DropdownDesign(
        border: const Color(0xff3D9AEF),
        hint: Colors.white.withAlpha(150),
        text: Colors.white,
        canvas: const Color(0xff24262A),
      ),
      customColors1: [
        const Color(0xff3D9AEF).withAlpha(150),
        const Color(0xff3D9AEF).withAlpha(230),
        const Color(0xff3D9AEF).withAlpha(180),
      ],
      customColors2: [
        //color12345
        const Color(0xFF9C77DA),
        const Color(0xFFE9F4F3),
        const Color(0xFF00D4C9),
        const Color(0xff3D9AEF),
        Colors.transparent,
      ],
      bottomNavigationBar: BottomNavigationBarDesign(
        background: const Color(0xff414149).withAlpha(235),
        indicator: const Color(0xff3D9AEF),
        unSelected: const Color(0xffffffff).withAlpha(100),
      ),
      appBar: AppBarDesign(
        background: const Color(0xff24262A),
        text: Colors.white,
      ),
      elevatedButton: ElevatedButtonDesign(
        background: const Color(0xff3D9AEF),
        variantBackground: const Color(0xff3D9AEF),
      ),
      textButton: TextButtonDesign(
        text: const Color(0xff3D9AEF),
      ),
      textField: TextFieldDesign(
        border: const Color(0xff3D9AEF),
        hint: Colors.white.withAlpha(150),
        text: Colors.white,
      ),
      sheet: SheetDesign(
        headerText: Colors.white,
        itemText: Colors.white,
        background: Color(0xff262627),
        card: Color(0xff363636),
        contentText: Colors.white,
      ),
      chip: ChipDesign(
        background: Colors.amber,
        text: const Color(0xFF3B1736),
      ),
      slidingSegment: SlidingSegmentDesign(
        background: const Color(0xff3D9AEF),
      ),
      selectableListItem: SelectableListItemDesign(
        unselectedText: Colors.white,
        selected: const Color(0xff3D9AEF),
        unselected: const Color(0xff24262A),
      ),
      switchDesign: SwitchDesign(
        color: const Color(0xff3D9AEF),
        text: Colors.white,
      ),
      checkBox: CheckBoxDesign(
        checked: const Color(0xff3D9AEF),
      ),
      emptyState: EmptyStateDesign(
        text: Colors.white,
        noRecordsAsset: 'loadingekol',
      ),
      card: CardDesign(
        background: const Color(0xff24262A),
        text: Colors.white,
        variantText: Colors.white,
        button: const Color(0xff3D9AEF),
      ),
      listTile: ListTileDesign(
        title: Colors.white,
        subTitle: Colors.white.withAlpha(200),
      ),
      customDesign1: DesignSchema(
        //announcementHeader
        background: const Color(0xff24262A),
        primaryText: Colors.white,
        shadow: const Color(0xff24262A),
        secondaryText: Colors.white.withAlpha(150),
      ),
      customDesign2: DesignSchema(
          //announcementLList
          onPrimaryVariant: const Color(0xff3D9AEF), //appbartext
          primaryText: Colors.white,
          background: const Color(0xff24262A),
          onSecondaryVariant: Colors.white.withAlpha(150), //hint
          secondaryText: Colors.white.withAlpha(200)),
      customDesign3: DesignSchema(
        ///Messagepage
        primary: Color(0xff404040),
        accent: const Color(0xff3D9AEF),
        onPrimary: const Color(0xff3D9AEF),
        onAccent: Colors.white,
      ),
      customDesign4: DesignSchema(
        //ItemBG
        primary: const Color(0xff3D9AEF),
        accent: const Color(0xFF61458F),
      ),
      customDesign5: DesignSchema(
        //Bottom navigation barFloating Button
        primary: const Color(0xff2E80ED),
        accent: const Color(0xFF4AB5F0),
        shadow: Colors.grey.shade600,
      ),
      others: {
        //todo bunada birsey bul
        'dateChangeWidgetTextColor': Colors.white,

        ///new
        'widget.primaryText': Colors.white,
        'widget.secondaryText': Colors.white.withAlpha(180),
        'widget.primaryBackground': const Color(0xff15151D).withOpacity(0.6),
        'widget.pageBackground': const Color(0xff2e3138).withOpacity(0.97),
        "scaffold.background": const Color(0xff2e3138),
        "appbar.background": const Color(0xff2e3138).withOpacity(0.12),
        "textfield.enableborder": const Color(0xffd9d9d9),
        "textfield.spread": Colors.grey.withAlpha(50),
      });
}
