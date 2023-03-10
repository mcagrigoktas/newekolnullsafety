import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:syncfusion_flutter_core/localizations.dart';

abstract class SfGlobalLocalizations implements SfLocalizations {
  /// Created an constructor of SfGlobalLocalizations class.
  const SfGlobalLocalizations({
    required String localeName,
  }) : _localeName = localeName;
  // ignore: unused_field
  final String _localeName;
  //ignore: public_member_api_docs
  static const LocalizationsDelegate<SfLocalizations> delegate = _SfLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> delegates = <LocalizationsDelegate<dynamic>>[
    SfGlobalLocalizations.delegate,
  ];
}

class _SfLocalizationsDelegate extends LocalizationsDelegate<SfLocalizations> {
  const _SfLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['tr', 'en', 'ru', 'az', 'de'].contains(locale.languageCode);

  static final Map<Locale, Future<SfLocalizations>> _loadedTranslations = <Locale, Future<SfLocalizations>>{};

  @override
  Future<SfLocalizations> load(Locale locale) {
    assert(isSupported(locale));
    return _loadedTranslations.putIfAbsent(locale, () {
      final String localeName = intl.Intl.canonicalizedLocale(locale.toString());
      assert(
        locale.toString() == localeName,
        'Flutter does not support the non-standard locale form $locale (which '
        'might be $localeName',
      );

      return SynchronousFuture<SfLocalizations>(getSyncfusionTranslation(
        locale,
      ));
    });
  }

  @override
  bool shouldReload(_SfLocalizationsDelegate old) => false;

  @override
  String toString() => 'SfGlobalLocalizations.delegate(5 locales)';
}

//?https://github.com/syncfusion/flutter-widgets/blob/master/packages/syncfusion_localizations/lib/src/l10n/generated_syncfusion_localizations.dart
// Bu adresten yenilerini alabilirsin
SfGlobalLocalizations getSyncfusionTranslation(Locale locale) {
  if (locale.languageCode == 'tr') {
    return const SfLocalizationsTr();
  }
  if (locale.languageCode == 'en') {
    return const SfLocalizationsEn();
  }
  if (locale.languageCode == 'ru') {
    return const SfLocalizationsRu();
  }
  if (locale.languageCode == 'az') {
    return const SfLocalizationsAz();
  }
  if (locale.languageCode == 'de') {
    return const SfLocalizationsDe();
  }
  return const SfLocalizationsEn();
}

/// The translations for Turkish (`tr`).
class SfLocalizationsTr extends SfGlobalLocalizations {
  /// Creating an argument constructor of SfLocalizationsTr class
  const SfLocalizationsTr({
    String localeName = 'tr',
  }) : super(
          localeName: localeName,
        );

  @override
  String get afterDataGridFilteringLabel => r'Sonras??nda';

  @override
  String get afterOrEqualDataGridFilteringLabel => r'Sonra veya E??it';

  @override
  String get allDayLabel => r'T??m g??n';

  @override
  String get allowedViewDayLabel => r'G??n';

  @override
  String get allowedViewMonthLabel => r'Ay';

  @override
  String get allowedViewScheduleLabel => r'Takvim';

  @override
  String get allowedViewTimelineDayLabel => r'Zaman ??izelgesi G??n??';

  @override
  String get allowedViewTimelineMonthLabel => r'Zaman ??izelgesi Ay??';

  @override
  String get allowedViewTimelineWeekLabel => r'Zaman ??izelgesi Haftas??';

  @override
  String get allowedViewTimelineWorkWeekLabel => r'Zaman ??izelgesi ??al????ma Haftas??';

  @override
  String get allowedViewWeekLabel => r'Hafta';

  @override
  String get allowedViewWorkWeekLabel => r'??al????ma haftas??';

  @override
  String get andDataGridFilteringLabel => r'Ve';

  @override
  String get beforeDataGridFilteringLabel => r'??nce veya E??it';

  @override
  String get beforeOrEqualDataGridFilteringLabel => r'??nceki';

  @override
  String get beginsWithDataGridFilteringLabel => r'??le ba??lar';

  @override
  String get cancelDataGridFilteringLabel => r'??ptal';

  // @override
  // String get clearFilterFromDataGridFilteringLabel => r'Filtreyi Temizle';

  @override
  String get containsDataGridFilteringLabel => r'i??erir';

  @override
  String get dateFiltersDataGridFilteringLabel => r'Tarih Filtreleri';

  @override
  String get daySpanCountLabel => r'G??n';

  @override
  String get dhualhiLabel => r'Zilhicce';

  @override
  String get dhualqiLabel => r'Zil Qi' "'" r'dah';

  @override
  String get doesNotBeginWithDataGridFilteringLabel => r'ile Ba??lam??yor';

  @override
  String get doesNotContainDataGridFilteringLabel => r'????ermiyor';

  @override
  String get doesNotEndWithDataGridFilteringLabel => r'ile bitmez';

  @override
  String get doesNotEqualDataGridFilteringLabel => r'E??it de??il';

  @override
  String get emptyDataGridFilteringLabel => r'Bo??';

  @override
  String get endsWithDataGridFilteringLabel => r'ile biter';

  @override
  String get equalsDataGridFilteringLabel => r'e??ittir';

  @override
  String get greaterThanDataGridFilteringLabel => r'B??y??kt??r';

  @override
  String get greaterThanOrEqualDataGridFilteringLabel => r'B??y??k veya E??it';

  @override
  String get jumada1Label => r'Cumada el-evvel';

  @override
  String get jumada2Label => r'Jumada al-thani';

  @override
  String get lessThanDataGridFilteringLabel => r'Daha az';

  @override
  String get lessThanOrEqualDataGridFilteringLabel => r'Az veya e??it';

  @override
  String get muharramLabel => r'Muharrem';

  @override
  String get noEventsCalendarLabel => r'Olay yok';

  @override
  String get noMatchesDataGridFilteringLabel => r'E??le??me yok';

  @override
  String get noSelectedDateCalendarLabel => r'Se??ili tarih yok';

  @override
  String get notEmptyDataGridFilteringLabel => r'Bo?? de??il';

  @override
  String get notNullDataGridFilteringLabel => r'Ge??ersiz de??il';

  @override
  String get nullDataGridFilteringLabel => r'H??k??ms??z';

  @override
  String get numberFiltersDataGridFilteringLabel => r'Say?? Filtreleri';

  @override
  String get ofDataPagerLabel => r'ile ilgili';

  @override
  String get okDataGridFilteringLabel => r'TAMAM';

  @override
  String get orDataGridFilteringLabel => r'Veya';

  @override
  String get pagesDataPagerLabel => r'sayfalar';

  @override
  String get passwordDialogContentLabel => r'Bu PDF dosyas??n?? a??mak i??in ??ifreyi girin';

  @override
  String get passwordDialogHeaderTextLabel => r'??ifre korumal??';

  @override
  String get passwordDialogHintTextLabel => r'Parolan?? Gir';

  @override
  String get passwordDialogInvalidPasswordLabel => r'ge??ersiz ??ifre';

  @override
  String get pdfBookmarksLabel => r'Yer imleri';

  @override
  String get pdfEnterPageNumberLabel => r'Sayfa numaras??n?? girin';

  @override
  String get pdfGoToPageLabel => r'Sayfaya git';

  @override
  String get pdfHyperlinkContentLabel => r'Sayfay?? a??mak ister misin?';

  @override
  String get pdfHyperlinkDialogCancelLabel => r'??PTAL ET';

  @override
  String get pdfHyperlinkDialogOpenLabel => r'A??IK';

  @override
  String get pdfHyperlinkLabel => r'Web Sayfas??n?? A??';

  @override
  String get pdfInvalidPageNumberLabel => r'L??tfen ge??erli bir numara girin';

  @override
  String get pdfNoBookmarksLabel => r'Yer i??areti bulunamad??';

  @override
  String get pdfPaginationDialogCancelLabel => r'??PTAL ETMEK';

  @override
  String get pdfPaginationDialogOkLabel => r'Tamam';

  @override
  String get pdfPasswordDialogCancelLabel => r'??PTAL ETMEK';

  @override
  String get pdfPasswordDialogOpenLabel => r'A??IK';

  @override
  String get pdfScrollStatusOfLabel => r'ile ilgili';

  @override
  String get rabi1Label => r'Rebi??levvel';

  @override
  String get rabi2Label => r'Rabi' "'" r' al-thani';

  @override
  String get rajabLabel => r'Recep';

  @override
  String get ramadanLabel => r'Ramazan';

  @override
  String get rowsPerPageDataPagerLabel => r'Sayfa ba????na sat??r say??s??';

  @override
  String get safarLabel => r'Safar';

  @override
  String get searchDataGridFilteringLabel => r'Arama';

  @override
  String get selectAllDataGridFilteringLabel => r'Hepsini se??';

  @override
  String get series => r'Seri';

  @override
  String get shaabanLabel => r'??aban';

  @override
  String get shawwalLabel => r'??evval';

  @override
  String get shortDhualhiLabel => r'Z??l-H';

  @override
  String get shortDhualqiLabel => r'Zil-Q';

  @override
  String get shortJumada1Label => r'Jum. i';

  @override
  String get shortJumada2Label => r'Jum. II';

  @override
  String get shortMuharramLabel => r'M??h.';

  @override
  String get shortRabi1Label => r'Rabi. i';

  @override
  String get shortRabi2Label => r'Rabi. II';

  @override
  String get shortRajabLabel => r'Raj.';

  @override
  String get shortRamadanLabel => r'Veri deposu.';

  @override
  String get shortSafarLabel => r'Saf.';

  @override
  String get shortShaabanLabel => r'Sha.';

  @override
  String get shortShawwalLabel => r'Shaw.';

  @override
  String get showRowsWhereDataGridFilteringLabel => r'Sat??rlar?? g??ster nerede';

  @override
  String get sortAToZDataGridFilteringLabel => r'A' "'" r'dan Z' "'" r'ye S??rala';

  @override
  String get sortAndFilterDataGridFilteringLabel => r'S??rala ve Filtrele';

  @override
  String get sortLargestToSmallestDataGridFilteringLabel => r'En B??y??kten En K????????e S??rala';

  @override
  String get sortNewestToOldestDataGridFilteringLabel => r'En Yeniden En Eskiye S??rala';

  @override
  String get sortOldestToNewestDataGridFilteringLabel => r'Eskiden En Yeniye S??rala';

  @override
  String get sortSmallestToLargestDataGridFilteringLabel => r'En K??????kten En B??y????e S??rala';

  @override
  String get sortZToADataGridFilteringLabel => r'Z' "'" r'den A' "'" r'ya S??rala';

  @override
  String get textFiltersDataGridFilteringLabel => r'Metin Filtreleri';

  @override
  String get todayLabel => r'Bug??n';

  @override
  String get weeknumberLabel => r'Hafta';

  @override
  String get clearFilterDataGridFilteringLabel => r'Temiz filtre';

  @override
  String get fromDataGridFilteringLabel => r'??tibaren';
}

// The translations for English (`en`).
class SfLocalizationsEn extends SfGlobalLocalizations {
  /// Creating an argument constructor of SfLocalizationsEn class
  const SfLocalizationsEn({
    String localeName = 'en',
  }) : super(
          localeName: localeName,
        );

  @override
  String get afterDataGridFilteringLabel => r'After';

  @override
  String get afterOrEqualDataGridFilteringLabel => r'After Or Equal';

  @override
  String get allDayLabel => r'All Day';

  @override
  String get allowedViewDayLabel => r'Day';

  @override
  String get allowedViewMonthLabel => r'Month';

  @override
  String get allowedViewScheduleLabel => r'Schedule';

  @override
  String get allowedViewTimelineDayLabel => r'Timeline Day';

  @override
  String get allowedViewTimelineMonthLabel => r'Timeline Month';

  @override
  String get allowedViewTimelineWeekLabel => r'Timeline Week';

  @override
  String get allowedViewTimelineWorkWeekLabel => r'Timeline Work Week';

  @override
  String get allowedViewWeekLabel => r'Week';

  @override
  String get allowedViewWorkWeekLabel => r'Work Week';

  @override
  String get andDataGridFilteringLabel => r'And';

  @override
  String get beforeDataGridFilteringLabel => r'Before Or Equal';

  @override
  String get beforeOrEqualDataGridFilteringLabel => r'Before';

  @override
  String get beginsWithDataGridFilteringLabel => r'Begins With';

  @override
  String get cancelDataGridFilteringLabel => r'Cancel';

  // @override
  // String get clearFilterFromDataGridFilteringLabel => r'Clear Filter From';

  @override
  String get containsDataGridFilteringLabel => r'Contains';

  @override
  String get dateFiltersDataGridFilteringLabel => r'Date Filters';

  @override
  String get daySpanCountLabel => r'Day';

  @override
  String get dhualhiLabel => r'Dhu al-Hijjah';

  @override
  String get dhualqiLabel => r'Dhu al-Qi' "'" r'dah';

  @override
  String get doesNotBeginWithDataGridFilteringLabel => r'Does Not Begin With';

  @override
  String get doesNotContainDataGridFilteringLabel => r'Does Not Contain';

  @override
  String get doesNotEndWithDataGridFilteringLabel => r'Does Not End With';

  @override
  String get doesNotEqualDataGridFilteringLabel => r'Does Not Equal';

  @override
  String get emptyDataGridFilteringLabel => r'Empty';

  @override
  String get endsWithDataGridFilteringLabel => r'Ends With';

  @override
  String get equalsDataGridFilteringLabel => r'Equals';

  @override
  String get greaterThanDataGridFilteringLabel => r'Greater Than';

  @override
  String get greaterThanOrEqualDataGridFilteringLabel => r'Greater Than Or Equal';

  @override
  String get jumada1Label => r'Jumada al-awwal';

  @override
  String get jumada2Label => r'Jumada al-thani';

  @override
  String get lessThanDataGridFilteringLabel => r'Less Than';

  @override
  String get lessThanOrEqualDataGridFilteringLabel => r'Less Than Or Equal';

  @override
  String get muharramLabel => r'Muharram';

  @override
  String get noEventsCalendarLabel => r'No events';

  @override
  String get noMatchesDataGridFilteringLabel => r'No matches';

  @override
  String get noSelectedDateCalendarLabel => r'No selected date';

  @override
  String get notEmptyDataGridFilteringLabel => r'Not Empty';

  @override
  String get notNullDataGridFilteringLabel => r'Not Null';

  @override
  String get nullDataGridFilteringLabel => r'Null';

  @override
  String get numberFiltersDataGridFilteringLabel => r'Number Filters';

  @override
  String get ofDataPagerLabel => r'of';

  @override
  String get okDataGridFilteringLabel => r'OK';

  @override
  String get orDataGridFilteringLabel => r'Or';

  @override
  String get pagesDataPagerLabel => r'pages';

  @override
  String get passwordDialogContentLabel => r'Enter the password to open this PDF file';

  @override
  String get passwordDialogHeaderTextLabel => r'Password Protected';

  @override
  String get passwordDialogHintTextLabel => r'Enter Password';

  @override
  String get passwordDialogInvalidPasswordLabel => r'Invalid Password';

  @override
  String get pdfBookmarksLabel => r'Bookmarks';

  @override
  String get pdfEnterPageNumberLabel => r'Enter page number';

  @override
  String get pdfGoToPageLabel => r'Go to page';

  @override
  String get pdfHyperlinkContentLabel => r'Do you want to open the page at';

  @override
  String get pdfHyperlinkDialogCancelLabel => r'CANCEL';

  @override
  String get pdfHyperlinkDialogOpenLabel => r'OPEN';

  @override
  String get pdfHyperlinkLabel => r'Open Web Page';

  @override
  String get pdfInvalidPageNumberLabel => r'Please enter a valid number';

  @override
  String get pdfNoBookmarksLabel => r'No bookmarks found';

  @override
  String get pdfPaginationDialogCancelLabel => r'CANCEL';

  @override
  String get pdfPaginationDialogOkLabel => r'OK';

  @override
  String get pdfPasswordDialogCancelLabel => r'CANCEL';

  @override
  String get pdfPasswordDialogOpenLabel => r'OPEN';

  @override
  String get pdfScrollStatusOfLabel => r'of';

  @override
  String get rabi1Label => r'Rabi' "'" r' al-awwal';

  @override
  String get rabi2Label => r'Rabi' "'" r' al-thani';

  @override
  String get rajabLabel => r'Rajab';

  @override
  String get ramadanLabel => r'Ramadan';

  @override
  String get rowsPerPageDataPagerLabel => r'Rows per page';

  @override
  String get safarLabel => r'Safar';

  @override
  String get searchDataGridFilteringLabel => r'Search';

  @override
  String get selectAllDataGridFilteringLabel => r'Select All';

  @override
  String get series => r'Series';

  @override
  String get shaabanLabel => r'Sha' "'" r'aban';

  @override
  String get shawwalLabel => r'Shawwal';

  @override
  String get shortDhualhiLabel => r'Dhu' "'" r'l-H';

  @override
  String get shortDhualqiLabel => r'Dhu' "'" r'l-Q';

  @override
  String get shortJumada1Label => r'Jum. I';

  @override
  String get shortJumada2Label => r'Jum. II';

  @override
  String get shortMuharramLabel => r'Muh.';

  @override
  String get shortRabi1Label => r'Rabi. I';

  @override
  String get shortRabi2Label => r'Rabi. II';

  @override
  String get shortRajabLabel => r'Raj.';

  @override
  String get shortRamadanLabel => r'Ram.';

  @override
  String get shortSafarLabel => r'Saf.';

  @override
  String get shortShaabanLabel => r'Sha.';

  @override
  String get shortShawwalLabel => r'Shaw.';

  @override
  String get showRowsWhereDataGridFilteringLabel => r'Show rows where';

  @override
  String get sortAToZDataGridFilteringLabel => r'Sort A To Z';

  @override
  String get sortAndFilterDataGridFilteringLabel => r'Sort and Filter';

  @override
  String get sortLargestToSmallestDataGridFilteringLabel => r'Sort Largest To Smallest';

  @override
  String get sortNewestToOldestDataGridFilteringLabel => r'Sort Newest To Oldest';

  @override
  String get sortOldestToNewestDataGridFilteringLabel => r'Sort Oldest To Newest';

  @override
  String get sortSmallestToLargestDataGridFilteringLabel => r'Sort Smallest To Largest';

  @override
  String get sortZToADataGridFilteringLabel => r'Sort Z To A';

  @override
  String get textFiltersDataGridFilteringLabel => r'Text Filters';

  @override
  String get todayLabel => r'Today';

  @override
  String get weeknumberLabel => r'Week';

  @override
  String get clearFilterDataGridFilteringLabel => r'Clear Filter';

  @override
  String get fromDataGridFilteringLabel => r'From';
}

/// The translations for Russian (`ru`).
class SfLocalizationsRu extends SfGlobalLocalizations {
  /// Creating an argument constructor of SfLocalizationsRu class
  const SfLocalizationsRu({
    String localeName = 'ru',
  }) : super(
          localeName: localeName,
        );

  @override
  String get afterDataGridFilteringLabel => r'??????????';

  @override
  String get afterOrEqualDataGridFilteringLabel => r'?????????? ?????? ??????????';

  @override
  String get allDayLabel => r'???????? ????????';

  @override
  String get allowedViewDayLabel => r'????????';

  @override
  String get allowedViewMonthLabel => r'??????????';

  @override
  String get allowedViewScheduleLabel => r'????????????????????';

  @override
  String get allowedViewTimelineDayLabel => r'????????';

  @override
  String get allowedViewTimelineMonthLabel => r'??????????';

  @override
  String get allowedViewTimelineWeekLabel => r'???????????? ?????????????????? ??????????';

  @override
  String get allowedViewTimelineWorkWeekLabel => r'?????????????? ????????????';

  @override
  String get allowedViewWeekLabel => r'????????????';

  @override
  String get allowedViewWorkWeekLabel => r'?????????????? ????????????';

  @override
  String get andDataGridFilteringLabel => r'?? ??????????';

  @override
  String get beforeDataGridFilteringLabel => r'???????????? ?????? ??????????';

  @override
  String get beforeOrEqualDataGridFilteringLabel => r'????';

  @override
  String get beginsWithDataGridFilteringLabel => r'???????????????????? ??';

  @override
  String get cancelDataGridFilteringLabel => r'????????????';

  // @override
  // String get clearFilterFromDataGridFilteringLabel => r'???????????????? ???????????? ????';

  @override
  String get containsDataGridFilteringLabel => r'????????????????';

  @override
  String get dateFiltersDataGridFilteringLabel => r'?????????????? ????????';

  @override
  String get daySpanCountLabel => r'????????';

  @override
  String get dhualhiLabel => r'???? ??????-??????????';

  @override
  String get dhualqiLabel => r'???? ??????-????????';

  @override
  String get doesNotBeginWithDataGridFilteringLabel => r'???? ???????????????????? ??';

  @override
  String get doesNotContainDataGridFilteringLabel => r'???? ????????????????';

  @override
  String get doesNotEndWithDataGridFilteringLabel => r'???? ?????????????????????????? ??';

  @override
  String get doesNotEqualDataGridFilteringLabel => r'???? ??????????';

  @override
  String get emptyDataGridFilteringLabel => r'????????????';

  @override
  String get endsWithDataGridFilteringLabel => r'?????????????????????????? ??';

  @override
  String get equalsDataGridFilteringLabel => r'??????????';

  @override
  String get greaterThanDataGridFilteringLabel => r'?????????? ??????';

  @override
  String get greaterThanOrEqualDataGridFilteringLabel => r'???????????? ?????? ??????????';

  @override
  String get jumada1Label => r'?????????????? ??????-????????????';

  @override
  String get jumada2Label => r'?????????????? ??????-????????';

  @override
  String get lessThanDataGridFilteringLabel => r'????????????, ??????';

  @override
  String get lessThanOrEqualDataGridFilteringLabel => r'???????????? ?????? ??????????';

  @override
  String get muharramLabel => r'????????????????';

  @override
  String get noEventsCalendarLabel => r'?????? ??????????????';

  @override
  String get noMatchesDataGridFilteringLabel => r'?????? ????????????????????';

  @override
  String get noSelectedDateCalendarLabel => r'???????? ???? ??????????????';

  @override
  String get notEmptyDataGridFilteringLabel => r'???? ????????????';

  @override
  String get notNullDataGridFilteringLabel => r'??????????????????';

  @override
  String get nullDataGridFilteringLabel => r'??????????????';

  @override
  String get numberFiltersDataGridFilteringLabel => r'???????????????? ??????????????';

  @override
  String get ofDataPagerLabel => r'????';

  @override
  String get okDataGridFilteringLabel => r'????????????';

  @override
  String get orDataGridFilteringLabel => r'?????? ????';

  @override
  String get pagesDataPagerLabel => r'????????????????';

  @override
  String get passwordDialogContentLabel => r'?????????????? ????????????, ?????????? ?????????????? ???????? ???????? PDF';

  @override
  String get passwordDialogHeaderTextLabel => r'???????????? ??????????????';

  @override
  String get passwordDialogHintTextLabel => r'?????????????? ????????????';

  @override
  String get passwordDialogInvalidPasswordLabel => r'???????????????????????? ????????????';

  @override
  String get pdfBookmarksLabel => r'????????????????';

  @override
  String get pdfEnterPageNumberLabel => r'?????????????? ?????????? ????????????????';

  @override
  String get pdfGoToPageLabel => r'?????????????? ???? ????????????????';

  @override
  String get pdfHyperlinkContentLabel => r'???? ???????????? ?????????????? ???????????????? ??';

  @override
  String get pdfHyperlinkDialogCancelLabel => r'????????????';

  @override
  String get pdfHyperlinkDialogOpenLabel => r'????????????????';

  @override
  String get pdfHyperlinkLabel => r'?????????????? ??????-????????????????';

  @override
  String get pdfInvalidPageNumberLabel => r'???????????????????? ?????????????? ???????????????????? ??????????';

  @override
  String get pdfNoBookmarksLabel => r'???????????????? ???? ??????????????';

  @override
  String get pdfPaginationDialogCancelLabel => r'????????????????';

  @override
  String get pdfPaginationDialogOkLabel => r'Ok';

  @override
  String get pdfPasswordDialogCancelLabel => r'????????????????';

  @override
  String get pdfPasswordDialogOpenLabel => r'????????????????';

  @override
  String get pdfScrollStatusOfLabel => r'????';

  @override
  String get rabi1Label => r'???????? ??????-????????????';

  @override
  String get rabi2Label => r'???????? ??????-????????';

  @override
  String get rajabLabel => r'????????????';

  @override
  String get ramadanLabel => r'??????????????';

  @override
  String get rowsPerPageDataPagerLabel => r'?????????? ???? ????????????????';

  @override
  String get safarLabel => r'??????????';

  @override
  String get searchDataGridFilteringLabel => r'??????????';

  @override
  String get selectAllDataGridFilteringLabel => r'?????????????? ??????';

  @override
  String get series => r'??????';

  @override
  String get shaabanLabel => r'????????????';

  @override
  String get shawwalLabel => r'??????????????';

  @override
  String get shortDhualhiLabel => r'????????-??';

  @override
  String get shortDhualqiLabel => r'????????-??????';

  @override
  String get shortJumada1Label => r'????????. ??';

  @override
  String get shortJumada2Label => r'????????. II';

  @override
  String get shortMuharramLabel => r'??????.';

  @override
  String get shortRabi1Label => r'????????. ??';

  @override
  String get shortRabi2Label => r'????????. II';

  @override
  String get shortRajabLabel => r'????????.';

  @override
  String get shortRamadanLabel => r'??????.';

  @override
  String get shortSafarLabel => r'??????.';

  @override
  String get shortShaabanLabel => r'????.';

  @override
  String get shortShawwalLabel => r'??????.';

  @override
  String get showRowsWhereDataGridFilteringLabel => r'???????????????? ????????????, ??????';

  @override
  String get sortAToZDataGridFilteringLabel => r'?????????????????????? ???? ?? ???? ??';

  @override
  String get sortAndFilterDataGridFilteringLabel => r'???????????????????? ?? ????????????????????';

  @override
  String get sortLargestToSmallestDataGridFilteringLabel => r'?????????????????????? ???? ???????????????? ?? ????????????????';

  @override
  String get sortNewestToOldestDataGridFilteringLabel => r'?????????????????????? ???? ?????????? ?? ????????????';

  @override
  String get sortOldestToNewestDataGridFilteringLabel => r'?????????????????????? ???? ???????????? ?? ??????????';

  @override
  String get sortSmallestToLargestDataGridFilteringLabel => r'?????????????????????? ???? ???????????????? ?? ????????????????';

  @override
  String get sortZToADataGridFilteringLabel => r'?????????????????????? ???? ?? ???? ??';

  @override
  String get textFiltersDataGridFilteringLabel => r'?????????????????? ??????????????';

  @override
  String get todayLabel => r'??????????????';

  @override
  String get weeknumberLabel => r'????????????';

  @override
  String get clearFilterDataGridFilteringLabel => r'???????????????? ????????????';

  @override
  String get fromDataGridFilteringLabel => r'????';
}

/// The translations for Azerbaijani (`az`).
class SfLocalizationsAz extends SfGlobalLocalizations {
  /// Creating an argument constructor of SfLocalizationsAz class
  const SfLocalizationsAz({
    String localeName = 'az',
  }) : super(
          localeName: localeName,
        );

  @override
  String get afterDataGridFilteringLabel => r'sonra';

  @override
  String get afterOrEqualDataGridFilteringLabel => r'Sonra V?? ya B??rab??r';

  @override
  String get allDayLabel => r'B??t??n g??n';

  @override
  String get allowedViewDayLabel => r'G??n';

  @override
  String get allowedViewMonthLabel => r'ay';

  @override
  String get allowedViewScheduleLabel => r'C??dv??l';

  @override
  String get allowedViewTimelineDayLabel => r'Zaman qrafiki g??n??';

  @override
  String get allowedViewTimelineMonthLabel => r'Zaman qrafiki ay??';

  @override
  String get allowedViewTimelineWeekLabel => r'Timeline H??ft??si';

  @override
  String get allowedViewTimelineWorkWeekLabel => r'Timeline ???? H??ft??si';

  @override
  String get allowedViewWeekLabel => r'H??ft??';

  @override
  String get allowedViewWorkWeekLabel => r'???? h??ft??si';

  @override
  String get andDataGridFilteringLabel => r'V??';

  @override
  String get beforeDataGridFilteringLabel => r'??vv??l V?? ya B??rab??r';

  @override
  String get beforeOrEqualDataGridFilteringLabel => r'??vv??l';

  @override
  String get beginsWithDataGridFilteringLabel => r'il?? ba??lay??r';

  @override
  String get cancelDataGridFilteringLabel => r'L????v et';

  // @override
  // String get clearFilterFromDataGridFilteringLabel => r'Filtri Sil';

  @override
  String get containsDataGridFilteringLabel => r'ehtiva edir';

  @override
  String get dateFiltersDataGridFilteringLabel => r'Tarix Filtrl??ri';

  @override
  String get daySpanCountLabel => r'G??n';

  @override
  String get dhualhiLabel => r'Zilhicc??';

  @override
  String get dhualqiLabel => r'Zilqid??';

  @override
  String get doesNotBeginWithDataGridFilteringLabel => r'??l?? Ba??lamaz';

  @override
  String get doesNotContainDataGridFilteringLabel => r'T??rkibind?? Yoxdur';

  @override
  String get doesNotEndWithDataGridFilteringLabel => r'??l?? Bitmir';

  @override
  String get doesNotEqualDataGridFilteringLabel => r'B??rab??r Deyil';

  @override
  String get emptyDataGridFilteringLabel => r'Bo??';

  @override
  String get endsWithDataGridFilteringLabel => r'il?? bitir';

  @override
  String get equalsDataGridFilteringLabel => r'B??rab??rdir';

  @override
  String get greaterThanDataGridFilteringLabel => r'B??y??k';

  @override
  String get greaterThanOrEqualDataGridFilteringLabel => r'B??y??k V?? ya B??rab??r';

  @override
  String get jumada1Label => r'C??m?? ??l-??vv??l';

  @override
  String get jumada2Label => r'C??m??d?? ??l-sani';

  @override
  String get lessThanDataGridFilteringLabel => r'Daha az';

  @override
  String get lessThanOrEqualDataGridFilteringLabel => r'Az V?? ya B??rab??r';

  @override
  String get muharramLabel => r'M??h??rr??m';

  @override
  String get noEventsCalendarLabel => r'T??dbir yoxdur';

  @override
  String get noMatchesDataGridFilteringLabel => r'Uy??unluq yoxdur';

  @override
  String get noSelectedDateCalendarLabel => r'Se??ilmi?? tarix yoxdur';

  @override
  String get notEmptyDataGridFilteringLabel => r'Bo?? deyil';

  @override
  String get notNullDataGridFilteringLabel => r'Null deyil';

  @override
  String get nullDataGridFilteringLabel => r'S??f??r';

  @override
  String get numberFiltersDataGridFilteringLabel => r'N??mr?? Filtrl??ri';

  @override
  String get ofDataPagerLabel => r'of';

  @override
  String get okDataGridFilteringLabel => r'tamam';

  @override
  String get orDataGridFilteringLabel => r'V?? ya';

  @override
  String get pagesDataPagerLabel => r's??hif??l??r';

  @override
  String get passwordDialogContentLabel => r'Bu PDF fayl??n?? a??maq ??????n parolu daxil edin';

  @override
  String get passwordDialogHeaderTextLabel => r'Parol Qorunur';

  @override
  String get passwordDialogHintTextLabel => r'Parol daxil edin';

  @override
  String get passwordDialogInvalidPasswordLabel => r'etibars??z ??ifr??';

  @override
  String get pdfBookmarksLabel => r'??lf??cinl??r';

  @override
  String get pdfEnterPageNumberLabel => r'S??hif?? n??mr??sini daxil edin';

  @override
  String get pdfGoToPageLabel => r'S??hif??y?? daxil ol';

  @override
  String get pdfHyperlinkContentLabel => r'??nvan??nda s??hif??ni a??maq ist??yirsiniz';

  @override
  String get pdfHyperlinkDialogCancelLabel => r'L????V ED??N';

  @override
  String get pdfHyperlinkDialogOpenLabel => r'A??IQ';

  @override
  String get pdfHyperlinkLabel => r'Veb s??hif??ni a????n';

  @override
  String get pdfInvalidPageNumberLabel => r'Etibarl?? n??mr?? daxil edin';

  @override
  String get pdfNoBookmarksLabel => r'??lf??cin tap??lmad??';

  @override
  String get pdfPaginationDialogCancelLabel => r'L????V ED??N';

  @override
  String get pdfPaginationDialogOkLabel => r'tamam';

  @override
  String get pdfPasswordDialogCancelLabel => r'L????V ED??N';

  @override
  String get pdfPasswordDialogOpenLabel => r'A??IQ';

  @override
  String get pdfScrollStatusOfLabel => r'of';

  @override
  String get rabi1Label => r'R??biul-??vv??l';

  @override
  String get rabi2Label => r'R??bi ??l-sani';

  @override
  String get rajabLabel => r'R??c??b';

  @override
  String get ramadanLabel => r'Ramazan';

  @override
  String get rowsPerPageDataPagerLabel => r'S??hif?? ba????na sat??rlar';

  @override
  String get safarLabel => r'S??f??r';

  @override
  String get searchDataGridFilteringLabel => r'Axtar';

  @override
  String get selectAllDataGridFilteringLabel => r'Ham??s??n?? se??';

  @override
  String get series => r'Serial';

  @override
  String get shaabanLabel => r'??aban';

  @override
  String get shawwalLabel => r'????vval';

  @override
  String get shortDhualhiLabel => r'Z??l-H';

  @override
  String get shortDhualqiLabel => r'Z??l-Q';

  @override
  String get shortJumada1Label => r'C??m??. I';

  @override
  String get shortJumada2Label => r'C??m??. II';

  @override
  String get shortMuharramLabel => r'Muh.';

  @override
  String get shortRabi1Label => r'R??bi. I';

  @override
  String get shortRabi2Label => r'R??bi. II';

  @override
  String get shortRajabLabel => r'Raj.';

  @override
  String get shortRamadanLabel => r'Ram.';

  @override
  String get shortSafarLabel => r'Saf.';

  @override
  String get shortShaabanLabel => r'??a.';

  @override
  String get shortShawwalLabel => r'??ou.';

  @override
  String get showRowsWhereDataGridFilteringLabel => r'S??tirl??ri harada g??st??rin';

  @override
  String get sortAToZDataGridFilteringLabel => r'A-dan Z-y?? ??e??idl??yin';

  @override
  String get sortAndFilterDataGridFilteringLabel => r'??e??idl??yin v?? Filtr edin';

  @override
  String get sortLargestToSmallestDataGridFilteringLabel => r'??n b??y??kd??n ki??iy?? ??e??idl??yin';

  @override
  String get sortNewestToOldestDataGridFilteringLabel => r'??n yenid??n k??hn??y?? ??e??idl??yin';

  @override
  String get sortOldestToNewestDataGridFilteringLabel => r'??n k??hn??d??n ??n yeniy?? ??e??idl??yin';

  @override
  String get sortSmallestToLargestDataGridFilteringLabel => r'??n ki??ikd??n b??y??y?? ??e??idl??yin';

  @override
  String get sortZToADataGridFilteringLabel => r'Z-d??n A s??ralay??n';

  @override
  String get textFiltersDataGridFilteringLabel => r'M??tn Filtrl??ri';

  @override
  String get todayLabel => r'Bu g??n';

  @override
  String get weeknumberLabel => r'H??ft??';

  @override
  String get clearFilterDataGridFilteringLabel => r'Filtri t??mizl??yin';

  @override
  String get fromDataGridFilteringLabel => r'From';
}

/// The translations for German (`de`).
class SfLocalizationsDe extends SfGlobalLocalizations {
  /// Creating an argument constructor of SfLocalizationsDe class
  const SfLocalizationsDe({
    String localeName = 'de',
  }) : super(
          localeName: localeName,
        );

  @override
  String get afterDataGridFilteringLabel => r'Nach';

  @override
  String get afterOrEqualDataGridFilteringLabel => r'Nach oder gleich';

  @override
  String get allDayLabel => r'Den ganzen Tag';

  @override
  String get allowedViewDayLabel => r'Tag';

  @override
  String get allowedViewMonthLabel => r'Monat';

  @override
  String get allowedViewScheduleLabel => r'Zeitplan';

  @override
  String get allowedViewTimelineDayLabel => r'Zeitleiste Tag';

  @override
  String get allowedViewTimelineMonthLabel => r'Zeitachse Monat';

  @override
  String get allowedViewTimelineWeekLabel => r'Zeitleiste Woche';

  @override
  String get allowedViewTimelineWorkWeekLabel => r'Zeitleiste Arbeitswoche';

  @override
  String get allowedViewWeekLabel => r'Woche';

  @override
  String get allowedViewWorkWeekLabel => r'Arbeitswoche';

  @override
  String get andDataGridFilteringLabel => r'Und';

  @override
  String get beforeDataGridFilteringLabel => r'Vor oder gleich';

  @override
  String get beforeOrEqualDataGridFilteringLabel => r'Vor';

  @override
  String get beginsWithDataGridFilteringLabel => r'Beginnt mit';

  @override
  String get cancelDataGridFilteringLabel => r'Absagen';

  // @override
  // String get clearFilterFromDataGridFilteringLabel => r'Filter l??schen von';

  @override
  String get containsDataGridFilteringLabel => r'Enth??lt';

  @override
  String get dateFiltersDataGridFilteringLabel => r'Datumsfilter';

  @override
  String get daySpanCountLabel => r'Tag';

  @override
  String get dhualhiLabel => r'Dhu al-Hijjah';

  @override
  String get dhualqiLabel => r'Dhu al-Qidah';

  @override
  String get doesNotBeginWithDataGridFilteringLabel => r'Beginnt nicht mit';

  @override
  String get doesNotContainDataGridFilteringLabel => r'Beinhaltet nicht';

  @override
  String get doesNotEndWithDataGridFilteringLabel => r'Endet nicht mit';

  @override
  String get doesNotEqualDataGridFilteringLabel => r'Ist nicht gleich';

  @override
  String get emptyDataGridFilteringLabel => r'Leer';

  @override
  String get endsWithDataGridFilteringLabel => r'Endet mit';

  @override
  String get equalsDataGridFilteringLabel => r'Gleich';

  @override
  String get greaterThanDataGridFilteringLabel => r'Gr????er als';

  @override
  String get greaterThanOrEqualDataGridFilteringLabel => r'Gr????er als oder gleich';

  @override
  String get jumada1Label => r'Jumada al-awwal';

  @override
  String get jumada2Label => r'Jumada al-thani';

  @override
  String get lessThanDataGridFilteringLabel => r'Weniger als';

  @override
  String get lessThanOrEqualDataGridFilteringLabel => r'Weniger als oder gleich';

  @override
  String get muharramLabel => r'Muharram';

  @override
  String get noEventsCalendarLabel => r'Keine Ereignisse';

  @override
  String get noMatchesDataGridFilteringLabel => r'Keine Treffer';

  @override
  String get noSelectedDateCalendarLabel => r'Kein ausgew??hltes Datum';

  @override
  String get notEmptyDataGridFilteringLabel => r'Nicht leer';

  @override
  String get notNullDataGridFilteringLabel => r'Nicht null';

  @override
  String get nullDataGridFilteringLabel => r'Null';

  @override
  String get numberFiltersDataGridFilteringLabel => r'Zahlenfilter';

  @override
  String get ofDataPagerLabel => r'von';

  @override
  String get okDataGridFilteringLabel => r'OK';

  @override
  String get orDataGridFilteringLabel => r'Oder';

  @override
  String get pagesDataPagerLabel => r'Seiten';

  @override
  String get passwordDialogContentLabel => r'Geben Sie das Passwort ein, um diese PDF-Datei zu ??ffnen';

  @override
  String get passwordDialogHeaderTextLabel => r'Passwortgesch??tzt';

  @override
  String get passwordDialogHintTextLabel => r'Passwort eingeben';

  @override
  String get passwordDialogInvalidPasswordLabel => r'Ung??ltiges Passwort';

  @override
  String get pdfBookmarksLabel => r'Lesezeichen';

  @override
  String get pdfEnterPageNumberLabel => r'Seitenzahl eingeben';

  @override
  String get pdfGoToPageLabel => r'Gehen Sie zur Seite';

  @override
  String get pdfHyperlinkContentLabel => r'M??chten Sie die Seite ??ffnen unter';

  @override
  String get pdfHyperlinkDialogCancelLabel => r'ABBRECHEN';

  @override
  String get pdfHyperlinkDialogOpenLabel => r'OFFEN';

  @override
  String get pdfHyperlinkLabel => r'Webseite ??ffnen';

  @override
  String get pdfInvalidPageNumberLabel => r'Bitte geben Sie eine g??ltige Nummer ein';

  @override
  String get pdfNoBookmarksLabel => r'Keine Lesezeichen gefunden';

  @override
  String get pdfPaginationDialogCancelLabel => r'ABBRECHEN';

  @override
  String get pdfPaginationDialogOkLabel => r'OK';

  @override
  String get pdfPasswordDialogCancelLabel => r'ABBRECHEN';

  @override
  String get pdfPasswordDialogOpenLabel => r'OFFEN';

  @override
  String get pdfScrollStatusOfLabel => r'von';

  @override
  String get rabi1Label => r'Rabi' "'" r' al-awwal';

  @override
  String get rabi2Label => r'Rabi' "'" r' al-thani';

  @override
  String get rajabLabel => r'Rajab';

  @override
  String get ramadanLabel => r'Ramadan';

  @override
  String get rowsPerPageDataPagerLabel => r'Zeilen pro Seite';

  @override
  String get safarLabel => r'Safar';

  @override
  String get searchDataGridFilteringLabel => r'Suche';

  @override
  String get selectAllDataGridFilteringLabel => r'W??hlen Sie Alle';

  @override
  String get series => r'Serie';

  @override
  String get shaabanLabel => r'Schaaban';

  @override
  String get shawwalLabel => r'Shawwal';

  @override
  String get shortDhualhiLabel => r'Dhu' "'" r'l-H';

  @override
  String get shortDhualqiLabel => r'Dhu' "'" r'l-Q';

  @override
  String get shortJumada1Label => r'Jum. ich';

  @override
  String get shortJumada2Label => r'Jum. II';

  @override
  String get shortMuharramLabel => r'Muh.';

  @override
  String get shortRabi1Label => r'Rabi. ich';

  @override
  String get shortRabi2Label => r'Rabi. II';

  @override
  String get shortRajabLabel => r'Raj.';

  @override
  String get shortRamadanLabel => r'RAM.';

  @override
  String get shortSafarLabel => r'Sicher.';

  @override
  String get shortShaabanLabel => r'Scha.';

  @override
  String get shortShawwalLabel => r'Schau.';

  @override
  String get showRowsWhereDataGridFilteringLabel => r'Zeig Zeilen wo';

  @override
  String get sortAToZDataGridFilteringLabel => r'A bis Z sortieren';

  @override
  String get sortAndFilterDataGridFilteringLabel => r'Sortieren und filtern';

  @override
  String get sortLargestToSmallestDataGridFilteringLabel => r'Vom Gr????ten zum Kleinsten sortieren';

  @override
  String get sortNewestToOldestDataGridFilteringLabel => r'Vom Neusten zum ??ltesten sortieren';

  @override
  String get sortOldestToNewestDataGridFilteringLabel => r'Vom ??ltesten zum Neuesten sortieren';

  @override
  String get sortSmallestToLargestDataGridFilteringLabel => r'Vom Kleinsten zum Gr????ten sortieren';

  @override
  String get sortZToADataGridFilteringLabel => r'Z bis A sortieren';

  @override
  String get textFiltersDataGridFilteringLabel => r'Textfilter';

  @override
  String get todayLabel => r'Heute';

  @override
  String get weeknumberLabel => r'Woche';

  @override
  String get clearFilterDataGridFilteringLabel => r'Filter l??schen';

  @override
  String get fromDataGridFilteringLabel => r'Aus';
}
