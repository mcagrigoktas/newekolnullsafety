import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

class EkolMaterialLightTheme {
  EkolMaterialLightTheme._();
  static Design get theme => Design(
      themeData: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xffECEBF3),
        primaryColor: const Color(0xffF55959),
        dialogBackgroundColor: const Color(0xFFF6F6F6),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.resolveWith((state) => state.contains(MaterialState.hovered) ? Colors.grey : Fav.design.primaryText.withAlpha(10)),
          thickness: MaterialStateProperty.resolveWith((state) => state.contains(MaterialState.hovered) ? 8 : 5),
        ),
      ),
      layoutStyle: 0,
      primary: const Color(0xffF55959),
      accent: const Color(0xfff2f2f2),
      primaryText: const Color(0xFF3B1736),
      accentText: const Color(0xFF9A488A),
      disablePrimary: Colors.grey,
      brightness: Brightness.light,
      scaffold: ScaffoldDesign(
        background: const Color(0xFFF6F6F6),
        backgroundAsset: 'ekol',
        backgroundAssetOpacity: 0.04,
        accentBackground: const Color(0xffF8F9FD),
      ),
      snackBar: SnackBarDesign(
        background: const Color(0xFF61458F),
        dangerBackground: Colors.redAccent,
      ),
      progressIndicator: ProgressIndicatorDesign(indicator: const Color(0xffF55959)),
      dropdown: DropdownDesign(
        border: const Color(0xffFFA001),
        hint: Colors.grey,
        text: const Color(0xFF3B1736),
        canvas: const Color(0xFFFBF7FF),
      ),
      customColors1: [
        //hookColors
        Colors.black.withAlpha(100),
        const Color(0xffF55959).withAlpha(220),
        const Color(0xffF55959).withAlpha(160),
      ],
      customColors2: [
        //color12345
        const Color(0xFF9C77DA),
        const Color(0xFFE9F4F3),
        const Color(0xFF00D4C9),
        const Color(0xFF9C77DA),
        Colors.transparent,
      ],
      bottomNavigationBar: BottomNavigationBarDesign(
        background: Color(0xFFFfffff).withAlpha(230),
        indicator: const Color(0xffF55959),
        unSelected: Color(0xFF5A5A5A),
      ),
      appBar: AppBarDesign(
        background: const Color(0xffF4F3FA),
        text: Colors.black,
      ),
      elevatedButton: ElevatedButtonDesign(
        background: const Color(0xffF55959),
        variantBackground: const Color(0xffF55959),
      ),
      textButton: TextButtonDesign(
        text: const Color(0xffF55959),
      ),
      textField: TextFieldDesign(
        border: const Color(0xffFFA001),
        hint: Colors.grey,
        text: const Color(0xFF3B1736),
      ),
      sheet: SheetDesign(
        headerText: const Color(0xff6665FF),
        itemText: Colors.black,
        background: Color(0xffffffff),
        card: Color(0xffeeeeee),
        contentText: Colors.black,
      ),
      chip: ChipDesign(
        background: Colors.amber,
        text: const Color(0xFF3B1736),
      ),
      slidingSegment: SlidingSegmentDesign(
        background: const Color(0xffF55959),
      ),
      selectableListItem: SelectableListItemDesign(
        unselectedText: const Color(0xFF3B1736),
        selected: const Color(0xFF00D4C9),
        unselected: Colors.white,
      ),
      switchDesign: SwitchDesign(
        color: const Color(0xffF55959),
        text: const Color(0xFF3B1736),
      ),
      checkBox: CheckBoxDesign(
        checked: const Color(0xffFFA001),
      ),
      emptyState: EmptyStateDesign(
        text: const Color(0xFF3B1736),
        noRecordsAsset: 'norecords',
      ),
      card: CardDesign(
        background: Colors.white,
        text: Colors.black,
        variantText: Colors.grey,
        button: const Color(0xffFFA001),
      ),
      listTile: ListTileDesign(
        title: Colors.black,
        subTitle: Colors.grey,
      ),
      customDesign1: DesignSchema(
        //announcementHeader
        background: const Color(0xffF55959),
        primaryText: Colors.white,
        shadow: Colors.grey,
        secondaryText: Colors.white,
      ),
      customDesign2: DesignSchema(
        //announcementLList
        onPrimaryVariant: const Color(0xffF55959), //appbartext
        primaryText: Colors.black,
        background: const Color(0xffFAF9FD),
        onSecondaryVariant: Colors.white, //hint
        secondaryText: const Color(0xff505050), //content
      ),
      customDesign3: DesignSchema(
        ///Messagepage
        primary: Colors.white,
        accent: const Color(0xFF9C77DA),
        onPrimary: const Color(0xFF3B1736),
        onAccent: Colors.white,
      ),
      customDesign4: DesignSchema(
        primary: const Color(0xFF9A488A),
        accent: const Color(0xFF61458F),
      ),
      customDesign5: DesignSchema(
        //Floating Button
        primary: const Color(0xffF55959),
        accent: const Color(0xffF55959).hue15,
        shadow: Colors.grey.shade600.withOpacity(0.5),
      ),
      others: {
        //todo bunada birsey bul
        'dateChangeWidgetTextColor': const Color(0xFF3B1736),

        ///new
        'widget.primaryText': const Color(0xff254375),
        'widget.secondaryText': const Color(0xff929AAB),
        'widget.primaryBackground': Colors.white70,
        'widget.pageBackground': const Color(0xffeeeeee).withOpacity(0.97),
        "scaffold.background": Colors.white,
        "appbar.background": Colors.white10,
        "textfield.enableborder": const Color(0xffd9d9d9),
        "textfield.spread": Colors.grey.withAlpha(50),
      });
}
