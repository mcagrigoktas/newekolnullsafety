import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

class QBankDark {
  QBankDark._();
  static Design get theme => Design(
      themeData: ThemeData(
        fontFamily: "SFUI",
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff2e3138),
        primaryColor: const Color(0xff6665FF),
        dialogBackgroundColor: const Color(0xff2e3138),
      ),
      primary: const Color(0xff6665FF),
      accent: const Color(0xff3D474F),
      primaryText: Colors.white,
      accentText: const Color(0xff6665FF),
      disablePrimary: const Color(0xFFC5A8C0),
      brightness: Brightness.dark,
      scaffold: ScaffoldDesign(
        background: const Color(0xff2e3138),
        backgroundAsset: 'ekol',
        backgroundAssetOpacity: 0.8,
      ),
      snackBar: SnackBarDesign(
        background: const Color(0xff6665FF),
        dangerBackground: Colors.redAccent,
      ),
      progressIndicator: ProgressIndicatorDesign(
        indicator: const Color(0xff6665FF),
      ),
      dropdown: DropdownDesign(
        border: const Color(0xff6665FF),
        hint: Colors.white.withAlpha(150),
        text: Colors.white,
        canvas: const Color(0xff24262A),
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
        const Color(0xff6665FF),
        Colors.transparent,
      ],
      bottomNavigationBar: BottomNavigationBarDesign(
        background: const Color(0xff24262A),
        indicator: const Color(0xff6665FF),
        unSelected: const Color(0xffffffff).withAlpha(100),
      ),
      appBar: AppBarDesign(
        background: const Color(0xff24262A),
        text: Colors.white,
      ),
      elevatedButton: ElevatedButtonDesign(
        background: const Color(0xff6665FF),
        variantBackground: const Color(0xff6665FF),
      ),
      textButton: TextButtonDesign(
        text: const Color(0xff6665FF),
      ),
      textField: TextFieldDesign(
        border: const Color(0xff6665FF),
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
        background: const Color(0xff6665FF),
      ),
      selectableListItem: SelectableListItemDesign(
        unselectedText: Colors.white,
        selected: const Color(0xff6665FF),
        unselected: const Color(0xff24262A),
      ),
      switchDesign: SwitchDesign(
        color: const Color(0xff6665FF),
        text: Colors.white,
      ),
      checkBox: CheckBoxDesign(
        checked: const Color(0xff6665FF),
      ),
      emptyState: EmptyStateDesign(
        text: Colors.white,
        noRecordsAsset: 'loadingekol',
      ),
      card: CardDesign(
        background: const Color(0xff24262A),
        text: const Color(0xFF3B1736),
        variantText: const Color(0xFF3B1736), //todo,
        button: const Color(0xFFFF6691),
      ),
      listTile: ListTileDesign(
        title: Colors.white,
        subTitle: Colors.white.withAlpha(200),
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
        primary: Colors.white,
        accent: const Color(0xff6665FF),
        onPrimary: const Color(0xff6665FF),
        onAccent: Colors.white,
      ),
      customDesign4: DesignSchema(
        //ItemBG
        primary: const Color(0xff6665FF),
        accent: const Color(0xFF61458F),
      ),
      others: {
        //todo bunada birsey bul
        'dateChangeWidgetTextColor': Colors.white,
      });
}
