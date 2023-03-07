import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

class QBankLight {
  QBankLight._();
  static Design get theme => Design(
      themeData: ThemeData(
        fontFamily: "SFUI",
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFBF7FF),
        primaryColor: const Color(0xff6665FF),
        dialogBackgroundColor: const Color(0xFFFBF7FF),
      ),
      primary: const Color(0xff6665FF),
      accent: const Color(0xfff2f2f2),
      primaryText: const Color(0xff1F314A),
      accentText: const Color(0xFF9A488A),
      disablePrimary: const Color(0xFFC5A8C0),
      brightness: Brightness.light,
      scaffold: ScaffoldDesign(
        background: const Color(0xFFFBF7FF),
        backgroundAsset: 'ekol',
        backgroundAssetOpacity: 0.8,
      ),
      snackBar: SnackBarDesign(
        background: const Color(0xFF61458F),
        dangerBackground: Colors.redAccent,
      ),
      progressIndicator: ProgressIndicatorDesign(
        indicator: const Color(0xFFFF6691),
      ),
      dropdown: DropdownDesign(
        border: const Color(0xFFFF6691),
        hint: const Color(0xFFC5A8C0),
        text: const Color(0xFF3B1736),
        canvas: const Color(0xFFFBF7FF),
      ),
      customColors1: [
        const Color(0xff61458F),
        const Color(0xffD2BCF7),
        const Color(0xff9C77DA),
      ],
      customColors2: [
        //color12345
        const Color(0xFF9C77DA),
        const Color(0xFFE9F4F3),
        Colors.tealAccent,
        const Color(0xFF9C77DA),
        Colors.transparent,
      ],
      bottomNavigationBar: BottomNavigationBarDesign(
        background: Colors.white,
        indicator: const Color(0xff1F314A).withAlpha(150),
        unSelected: const Color(0xff1F314A).withAlpha(150),
      ),
      appBar: AppBarDesign(
        background: const Color(0xFFFF6691),
        text: Colors.black,
      ),
      elevatedButton: ElevatedButtonDesign(
        background: const Color(0xff6665FF),
        variantBackground: const Color(0xFF61458F),
      ),
      textButton: TextButtonDesign(
        text: const Color(0xFF9A488A),
      ),
      textField: TextFieldDesign(
        border: const Color(0xFFFF6691),
        hint: const Color(0xFFC5A8C0),
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
      slidingSegment: SlidingSegmentDesign(background: const Color(0xFFFF6691)),
      selectableListItem: SelectableListItemDesign(
        unselectedText: const Color(0xFF3B1736),
        selected: const Color(0xFF00D4C9),
        unselected: Colors.white,
      ),
      switchDesign: SwitchDesign(
        color: const Color(0xFFFF6691),
        text: const Color(0xFF3B1736),
      ),
      checkBox: CheckBoxDesign(
        checked: const Color(0xFF61458F),
      ),
      emptyState: EmptyStateDesign(
        text: const Color(0xFF61458F),
        noRecordsAsset: 'loadingekol',
      ),
      card: CardDesign(
        background: const Color(0xFFFBF7FF),
        text: const Color(0xFF3B1736),
        variantText: const Color(0xFF3B1736), //todo,
        button: const Color(0xFFFF6691),
      ),
      listTile: ListTileDesign(
        title: const Color(0xFF9A488A),
        subTitle: const Color(0xFFC5A8C0),
      ),
      customDesign1: DesignSchema(
        //announcementHeader
        background: const Color(0xFF9C77DA),
        primaryText: Colors.white,
        shadow: const Color(0xFF9C77DA),
      ),
      customDesign2: DesignSchema(
          //announcementLList
          onPrimaryVariant: Colors.white, //appbartext
          primaryText: const Color(0xFF9A488A), //title
          background: Colors.white,
          onSecondaryVariant: const Color(0xFFFFE3E9), //hint
          secondaryText: const Color(0xFF3B1736).withAlpha(200) //todo, //content
          ),
      customDesign3: DesignSchema(
        ///Messagepage
        primary: const Color(0xFFE9F4F3),
        accent: const Color(0xFF9C77DA),
        onPrimary: const Color(0xFF3B1736),
        onAccent: Colors.white,
      ),
      customDesign4: DesignSchema(
        //ItemBG
        primary: const Color(0xFF9A488A),
        accent: const Color(0xFF61458F),
      ),
      others: {
        //todo bunada birsey bul
        'dateChangeWidgetTextColor': const Color(0xFF3B1736),
      });
}
