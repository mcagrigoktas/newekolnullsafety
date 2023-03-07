// import 'package:flutter/material.dart';
// import 'package:mcg_extension/mcg_extension.dart';

// class Ekid {
//   Ekid._();
//   static Design get theme => Design(
//       fontFamily: "EKID",
//       primary: const Color(0xFFFF6691),
//       accent: const Color(0xfff2f2f2),
//       primaryText: const Color(0xFF3B1736),
//       accentText: const Color(0xFF9A488A),
//       disablePrimary: const Color(0xFFC5A8C0),
//       brightness: Brightness.light,
//       scaffold: ScaffoldDesign(
//         background: const Color(0xFFFBF7FF),
//         backgroundAsset: 'ekid',
//         backgroundAssetOpacity: 0.04,
//         accentBackground: const Color(0xffF8F9FD),
//       ),
//       snackBar: SnackBarDesign(
//         background: const Color(0xFF61458F),
//         dangerBackground: Colors.redAccent,
//       ),
//       progressIndicator: ProgressIndicatorDesign(
//         indicator: const Color(0xFFFF6691),
//       ),
//       dropdown: DropdownDesign(
//         border: const Color(0xFFFF6691),
//         hint: const Color(0xFFC5A8C0),
//         text: const Color(0xFF3B1736),
//         canvas: const Color(0xFFFBF7FF),
//       ),
//       customColors1: [
//         const Color(0xff61458F),
//         const Color(0xffD2BCF7),
//         const Color(0xff9C77DA),
//       ],
//       customColors2: [
//         //color12345
//         const Color(0xFF9C77DA),
//         const Color(0xFFE9F4F3),
//         const Color(0xFF00D4C9),
//         const Color(0xFF9C77DA),
//         Colors.transparent,
//       ],
//       bottomNavigationBar: BottomNavigationBarDesign(
//         background: Color(0xFFFfffff).withAlpha(230),
//         indicator: const Color(0xFFFF6691),
//         unSelected: Colors.black,
//       ),
//       // bottomNavigationBar: BottomNavigationBarDesign(
//       //   background: Color(0xffF6F8FA),
//       //   indicator: const Color(0xFFFF6691),
//       //   unSelected: const Color(0xFFC5A8C0),
//       // ),
//       appBar: AppBarDesign(
//         background: const Color(0xffF4F3FA),
//         text: Colors.black,
//         // background: const Color(0xFFFF6691),
//         // text: Colors.white,
//       ),
//       elevatedButton: ElevatedButtonDesign(
//         background: const Color(0xFF9A488A),
//         variantBackground: const Color(0xFF61458F),
//       ),
//       textButton: TextButtonDesign(
//         text: const Color(0xFF9A488A),
//       ),
//       textField: TextFieldDesign(
//         border: const Color(0xFFFF6691),
//         hint: const Color(0xFFC5A8C0),
//         text: const Color(0xFF3B1736),
//       ),
//       sheet: SheetDesign(
//         headerText: const Color(0xff6665FF),
//         itemText: Colors.black,
//       ),
//       chip: ChipDesign(
//         background: Colors.amber,
//         text: const Color(0xFF3B1736),
//       ),
//       slidingSegment: SlidingSegmentDesign(
//         background: const Color(0xFFFF6691),
//       ),
//       selectableListItem: SelectableListItemDesign(
//         unselectedText: const Color(0xFF3B1736),
//         selected: const Color(0xFF00D4C9),
//         unselected: Colors.white,
//       ),
//       switchDesign: SwitchDesign(
//         color: const Color(0xFFFF6691),
//         text: const Color(0xFF3B1736),
//       ),
//       checkBox: CheckBoxDesign(
//         checked: const Color(0xFF61458F),
//       ),
//       emptyState: EmptyStateDesign(
//         text: const Color(0xFF61458F),
//         noRecordsAsset: 'loadingekid',
//       ),
//       card: CardDesign(
//         background: const Color(0xFFFBF7FF),
//         text: const Color(0xFF3B1736),
//         variantText: const Color(0xFF3B1736), //todo,
//         button: const Color(0xFFFF6691),
//       ),
//       listTile: ListTileDesign(
//         title: const Color(0xFF9A488A),
//         subTitle: const Color(0xFFC5A8C0),
//       ),
//       customDesign1: DesignSchema(
//         //announcementHeader
//         background: const Color(0xFF9C77DA),
//         primaryText: Colors.white,
//         shadow: const Color(0xFF9C77DA),
//       ),
//       customDesign2: DesignSchema(
//           //announcementLList
//           onPrimaryVariant: Colors.white, //appbartext
//           primaryText: const Color(0xFF9A488A), //title
//           background: Colors.white,
//           onSecondaryVariant: const Color(0xFFFFE3E9), //hint
//           secondaryText: const Color(0xFF3B1736).withAlpha(200) //todo, //content
//           ),
//       customDesign3: DesignSchema(
//         ///Messagepage
//         primary: const Color(0xFFE9F4F3),
//         accent: const Color(0xFF9C77DA),
//         onPrimary: const Color(0xFF3B1736),
//         onAccent: Colors.white,
//       ),
//       customDesign4: DesignSchema(
//         //ItemBG
//         primary: const Color(0xFF9A488A),
//         accent: const Color(0xFF61458F),
//       ),
//       customDesign5: DesignSchema(
//         //Floating Button
//         accent: const Color(0xFFFF878B),
//         primary: const Color(0xFFFF6691),

//         shadow: Colors.grey.shade600.withOpacity(0.5),
//       ),
//       others: {
//         //todo bunada birsey bul
//         'dateChangeWidgetTextColor': const Color(0xFF3B1736),

//         ///new
//         'widget.primaryText': const Color(0xff254375),
//         'widget.secondaryText': const Color(0xff929AAB),
//         'widget.primaryBackground': Colors.white70,
//         'widget.pageBackground': const Color(0xffeeeeee).withOpacity(0.97),
//         "scaffold.background": Colors.white,
//         "appbar.background": Colors.white10,
//         "textfield.enableborder": const Color(0xffd9d9d9),
//         "textfield.spread": Colors.grey.withAlpha(50),
//       });
// }
