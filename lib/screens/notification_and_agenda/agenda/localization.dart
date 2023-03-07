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
  String get afterDataGridFilteringLabel => r'Sonrasında';

  @override
  String get afterOrEqualDataGridFilteringLabel => r'Sonra veya Eşit';

  @override
  String get allDayLabel => r'Tüm gün';

  @override
  String get allowedViewDayLabel => r'Gün';

  @override
  String get allowedViewMonthLabel => r'Ay';

  @override
  String get allowedViewScheduleLabel => r'Takvim';

  @override
  String get allowedViewTimelineDayLabel => r'Zaman Çizelgesi Günü';

  @override
  String get allowedViewTimelineMonthLabel => r'Zaman Çizelgesi Ayı';

  @override
  String get allowedViewTimelineWeekLabel => r'Zaman Çizelgesi Haftası';

  @override
  String get allowedViewTimelineWorkWeekLabel => r'Zaman Çizelgesi Çalışma Haftası';

  @override
  String get allowedViewWeekLabel => r'Hafta';

  @override
  String get allowedViewWorkWeekLabel => r'Çalışma haftası';

  @override
  String get andDataGridFilteringLabel => r'Ve';

  @override
  String get beforeDataGridFilteringLabel => r'Önce veya Eşit';

  @override
  String get beforeOrEqualDataGridFilteringLabel => r'Önceki';

  @override
  String get beginsWithDataGridFilteringLabel => r'İle başlar';

  @override
  String get cancelDataGridFilteringLabel => r'İptal';

  // @override
  // String get clearFilterFromDataGridFilteringLabel => r'Filtreyi Temizle';

  @override
  String get containsDataGridFilteringLabel => r'içerir';

  @override
  String get dateFiltersDataGridFilteringLabel => r'Tarih Filtreleri';

  @override
  String get daySpanCountLabel => r'Gün';

  @override
  String get dhualhiLabel => r'Zilhicce';

  @override
  String get dhualqiLabel => r'Zil Qi' "'" r'dah';

  @override
  String get doesNotBeginWithDataGridFilteringLabel => r'ile Başlamıyor';

  @override
  String get doesNotContainDataGridFilteringLabel => r'İçermiyor';

  @override
  String get doesNotEndWithDataGridFilteringLabel => r'ile bitmez';

  @override
  String get doesNotEqualDataGridFilteringLabel => r'Eşit değil';

  @override
  String get emptyDataGridFilteringLabel => r'Boş';

  @override
  String get endsWithDataGridFilteringLabel => r'ile biter';

  @override
  String get equalsDataGridFilteringLabel => r'eşittir';

  @override
  String get greaterThanDataGridFilteringLabel => r'Büyüktür';

  @override
  String get greaterThanOrEqualDataGridFilteringLabel => r'Büyük veya Eşit';

  @override
  String get jumada1Label => r'Cumada el-evvel';

  @override
  String get jumada2Label => r'Jumada al-thani';

  @override
  String get lessThanDataGridFilteringLabel => r'Daha az';

  @override
  String get lessThanOrEqualDataGridFilteringLabel => r'Az veya eşit';

  @override
  String get muharramLabel => r'Muharrem';

  @override
  String get noEventsCalendarLabel => r'Olay yok';

  @override
  String get noMatchesDataGridFilteringLabel => r'Eşleşme yok';

  @override
  String get noSelectedDateCalendarLabel => r'Seçili tarih yok';

  @override
  String get notEmptyDataGridFilteringLabel => r'Boş değil';

  @override
  String get notNullDataGridFilteringLabel => r'Geçersiz değil';

  @override
  String get nullDataGridFilteringLabel => r'Hükümsüz';

  @override
  String get numberFiltersDataGridFilteringLabel => r'Sayı Filtreleri';

  @override
  String get ofDataPagerLabel => r'ile ilgili';

  @override
  String get okDataGridFilteringLabel => r'TAMAM';

  @override
  String get orDataGridFilteringLabel => r'Veya';

  @override
  String get pagesDataPagerLabel => r'sayfalar';

  @override
  String get passwordDialogContentLabel => r'Bu PDF dosyasını açmak için şifreyi girin';

  @override
  String get passwordDialogHeaderTextLabel => r'Şifre korumalı';

  @override
  String get passwordDialogHintTextLabel => r'Parolanı Gir';

  @override
  String get passwordDialogInvalidPasswordLabel => r'geçersiz şifre';

  @override
  String get pdfBookmarksLabel => r'Yer imleri';

  @override
  String get pdfEnterPageNumberLabel => r'Sayfa numarasını girin';

  @override
  String get pdfGoToPageLabel => r'Sayfaya git';

  @override
  String get pdfHyperlinkContentLabel => r'Sayfayı açmak ister misin?';

  @override
  String get pdfHyperlinkDialogCancelLabel => r'İPTAL ET';

  @override
  String get pdfHyperlinkDialogOpenLabel => r'AÇIK';

  @override
  String get pdfHyperlinkLabel => r'Web Sayfasını Aç';

  @override
  String get pdfInvalidPageNumberLabel => r'Lütfen geçerli bir numara girin';

  @override
  String get pdfNoBookmarksLabel => r'Yer işareti bulunamadı';

  @override
  String get pdfPaginationDialogCancelLabel => r'İPTAL ETMEK';

  @override
  String get pdfPaginationDialogOkLabel => r'Tamam';

  @override
  String get pdfPasswordDialogCancelLabel => r'İPTAL ETMEK';

  @override
  String get pdfPasswordDialogOpenLabel => r'AÇIK';

  @override
  String get pdfScrollStatusOfLabel => r'ile ilgili';

  @override
  String get rabi1Label => r'Rebiülevvel';

  @override
  String get rabi2Label => r'Rabi' "'" r' al-thani';

  @override
  String get rajabLabel => r'Recep';

  @override
  String get ramadanLabel => r'Ramazan';

  @override
  String get rowsPerPageDataPagerLabel => r'Sayfa başına satır sayısı';

  @override
  String get safarLabel => r'Safar';

  @override
  String get searchDataGridFilteringLabel => r'Arama';

  @override
  String get selectAllDataGridFilteringLabel => r'Hepsini seç';

  @override
  String get series => r'Seri';

  @override
  String get shaabanLabel => r'Şaban';

  @override
  String get shawwalLabel => r'Şevval';

  @override
  String get shortDhualhiLabel => r'Zül-H';

  @override
  String get shortDhualqiLabel => r'Zil-Q';

  @override
  String get shortJumada1Label => r'Jum. i';

  @override
  String get shortJumada2Label => r'Jum. II';

  @override
  String get shortMuharramLabel => r'Müh.';

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
  String get showRowsWhereDataGridFilteringLabel => r'Satırları göster nerede';

  @override
  String get sortAToZDataGridFilteringLabel => r'A' "'" r'dan Z' "'" r'ye Sırala';

  @override
  String get sortAndFilterDataGridFilteringLabel => r'Sırala ve Filtrele';

  @override
  String get sortLargestToSmallestDataGridFilteringLabel => r'En Büyükten En Küçüğe Sırala';

  @override
  String get sortNewestToOldestDataGridFilteringLabel => r'En Yeniden En Eskiye Sırala';

  @override
  String get sortOldestToNewestDataGridFilteringLabel => r'Eskiden En Yeniye Sırala';

  @override
  String get sortSmallestToLargestDataGridFilteringLabel => r'En Küçükten En Büyüğe Sırala';

  @override
  String get sortZToADataGridFilteringLabel => r'Z' "'" r'den A' "'" r'ya Sırala';

  @override
  String get textFiltersDataGridFilteringLabel => r'Metin Filtreleri';

  @override
  String get todayLabel => r'Bugün';

  @override
  String get weeknumberLabel => r'Hafta';

  @override
  String get clearFilterDataGridFilteringLabel => r'Temiz filtre';

  @override
  String get fromDataGridFilteringLabel => r'İtibaren';
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
  String get afterDataGridFilteringLabel => r'После';

  @override
  String get afterOrEqualDataGridFilteringLabel => r'После или равно';

  @override
  String get allDayLabel => r'Весь день';

  @override
  String get allowedViewDayLabel => r'День';

  @override
  String get allowedViewMonthLabel => r'Месяц';

  @override
  String get allowedViewScheduleLabel => r'Расписание';

  @override
  String get allowedViewTimelineDayLabel => r'День';

  @override
  String get allowedViewTimelineMonthLabel => r'Месяц';

  @override
  String get allowedViewTimelineWeekLabel => r'Неделя временной шкалы';

  @override
  String get allowedViewTimelineWorkWeekLabel => r'Рабочая неделя';

  @override
  String get allowedViewWeekLabel => r'Неделю';

  @override
  String get allowedViewWorkWeekLabel => r'Рабочая неделя';

  @override
  String get andDataGridFilteringLabel => r'А также';

  @override
  String get beforeDataGridFilteringLabel => r'Раньше или равно';

  @override
  String get beforeOrEqualDataGridFilteringLabel => r'До';

  @override
  String get beginsWithDataGridFilteringLabel => r'Начинается с';

  @override
  String get cancelDataGridFilteringLabel => r'Отмена';

  // @override
  // String get clearFilterFromDataGridFilteringLabel => r'Очистить фильтр от';

  @override
  String get containsDataGridFilteringLabel => r'Содержит';

  @override
  String get dateFiltersDataGridFilteringLabel => r'Фильтры даты';

  @override
  String get daySpanCountLabel => r'День';

  @override
  String get dhualhiLabel => r'Зу аль-Хиджа';

  @override
  String get dhualqiLabel => r'Зу аль-Кида';

  @override
  String get doesNotBeginWithDataGridFilteringLabel => r'Не начинается с';

  @override
  String get doesNotContainDataGridFilteringLabel => r'Не содержит';

  @override
  String get doesNotEndWithDataGridFilteringLabel => r'Не заканчивается с';

  @override
  String get doesNotEqualDataGridFilteringLabel => r'Не равно';

  @override
  String get emptyDataGridFilteringLabel => r'Пустой';

  @override
  String get endsWithDataGridFilteringLabel => r'Заканчивается с';

  @override
  String get equalsDataGridFilteringLabel => r'Равно';

  @override
  String get greaterThanDataGridFilteringLabel => r'Лучше чем';

  @override
  String get greaterThanOrEqualDataGridFilteringLabel => r'Больше или равно';

  @override
  String get jumada1Label => r'Джумада аль-авваль';

  @override
  String get jumada2Label => r'Джумада аль-тани';

  @override
  String get lessThanDataGridFilteringLabel => r'Меньше, чем';

  @override
  String get lessThanOrEqualDataGridFilteringLabel => r'Меньше или равно';

  @override
  String get muharramLabel => r'Мухаррам';

  @override
  String get noEventsCalendarLabel => r'Нет событий';

  @override
  String get noMatchesDataGridFilteringLabel => r'Нет совпадений';

  @override
  String get noSelectedDateCalendarLabel => r'Дата не выбрана';

  @override
  String get notEmptyDataGridFilteringLabel => r'Не пустой';

  @override
  String get notNullDataGridFilteringLabel => r'Ненулевой';

  @override
  String get nullDataGridFilteringLabel => r'Нулевой';

  @override
  String get numberFiltersDataGridFilteringLabel => r'Числовые фильтры';

  @override
  String get ofDataPagerLabel => r'из';

  @override
  String get okDataGridFilteringLabel => r'ХОРОШО';

  @override
  String get orDataGridFilteringLabel => r'Или же';

  @override
  String get pagesDataPagerLabel => r'страницы';

  @override
  String get passwordDialogContentLabel => r'Введите пароль, чтобы открыть этот файл PDF';

  @override
  String get passwordDialogHeaderTextLabel => r'Пароль защищен';

  @override
  String get passwordDialogHintTextLabel => r'Введите пароль';

  @override
  String get passwordDialogInvalidPasswordLabel => r'неправильный пароль';

  @override
  String get pdfBookmarksLabel => r'Закладки';

  @override
  String get pdfEnterPageNumberLabel => r'Введите номер страницы';

  @override
  String get pdfGoToPageLabel => r'Перейти на страницу';

  @override
  String get pdfHyperlinkContentLabel => r'Вы хотите открыть страницу в';

  @override
  String get pdfHyperlinkDialogCancelLabel => r'ОТМЕНА';

  @override
  String get pdfHyperlinkDialogOpenLabel => r'ОТКРЫТЫМ';

  @override
  String get pdfHyperlinkLabel => r'Открыть веб-страницу';

  @override
  String get pdfInvalidPageNumberLabel => r'пожалуйста введите правильное число';

  @override
  String get pdfNoBookmarksLabel => r'Закладки не найдены';

  @override
  String get pdfPaginationDialogCancelLabel => r'ОТМЕНИТЬ';

  @override
  String get pdfPaginationDialogOkLabel => r'Ok';

  @override
  String get pdfPasswordDialogCancelLabel => r'ОТМЕНИТЬ';

  @override
  String get pdfPasswordDialogOpenLabel => r'ОТКРЫТЫМ';

  @override
  String get pdfScrollStatusOfLabel => r'из';

  @override
  String get rabi1Label => r'Раби аль-авваль';

  @override
  String get rabi2Label => r'Раби аль-Тани';

  @override
  String get rajabLabel => r'Раджаб';

  @override
  String get ramadanLabel => r'Рамадан';

  @override
  String get rowsPerPageDataPagerLabel => r'Строк на странице';

  @override
  String get safarLabel => r'Сафар';

  @override
  String get searchDataGridFilteringLabel => r'Поиск';

  @override
  String get selectAllDataGridFilteringLabel => r'Выбрать все';

  @override
  String get series => r'Ряд';

  @override
  String get shaabanLabel => r'Шаабан';

  @override
  String get shawwalLabel => r'Шавваль';

  @override
  String get shortDhualhiLabel => r'Зуль-Х';

  @override
  String get shortDhualqiLabel => r'Зуль-Кью';

  @override
  String get shortJumada1Label => r'Джум. я';

  @override
  String get shortJumada2Label => r'Джум. II';

  @override
  String get shortMuharramLabel => r'Мух.';

  @override
  String get shortRabi1Label => r'Раби. я';

  @override
  String get shortRabi2Label => r'Раби. II';

  @override
  String get shortRajabLabel => r'Радж.';

  @override
  String get shortRamadanLabel => r'ОЗУ.';

  @override
  String get shortSafarLabel => r'Саф.';

  @override
  String get shortShaabanLabel => r'Ша.';

  @override
  String get shortShawwalLabel => r'Шоу.';

  @override
  String get showRowsWhereDataGridFilteringLabel => r'Показать строки, где';

  @override
  String get sortAToZDataGridFilteringLabel => r'Сортировать от А до Я';

  @override
  String get sortAndFilterDataGridFilteringLabel => r'Сортировка и фильтрация';

  @override
  String get sortLargestToSmallestDataGridFilteringLabel => r'Сортировать от большего к меньшему';

  @override
  String get sortNewestToOldestDataGridFilteringLabel => r'Сортировать от новых к старым';

  @override
  String get sortOldestToNewestDataGridFilteringLabel => r'Сортировать от старых к новым';

  @override
  String get sortSmallestToLargestDataGridFilteringLabel => r'Сортировать от меньшего к большему';

  @override
  String get sortZToADataGridFilteringLabel => r'Сортировать от Я до А';

  @override
  String get textFiltersDataGridFilteringLabel => r'Текстовые фильтры';

  @override
  String get todayLabel => r'Сегодня';

  @override
  String get weeknumberLabel => r'Неделю';

  @override
  String get clearFilterDataGridFilteringLabel => r'Очистить фильтр';

  @override
  String get fromDataGridFilteringLabel => r'Из';
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
  String get afterOrEqualDataGridFilteringLabel => r'Sonra Və ya Bərabər';

  @override
  String get allDayLabel => r'Bütün gün';

  @override
  String get allowedViewDayLabel => r'Gün';

  @override
  String get allowedViewMonthLabel => r'ay';

  @override
  String get allowedViewScheduleLabel => r'Cədvəl';

  @override
  String get allowedViewTimelineDayLabel => r'Zaman qrafiki günü';

  @override
  String get allowedViewTimelineMonthLabel => r'Zaman qrafiki ayı';

  @override
  String get allowedViewTimelineWeekLabel => r'Timeline Həftəsi';

  @override
  String get allowedViewTimelineWorkWeekLabel => r'Timeline İş Həftəsi';

  @override
  String get allowedViewWeekLabel => r'Həftə';

  @override
  String get allowedViewWorkWeekLabel => r'İş həftəsi';

  @override
  String get andDataGridFilteringLabel => r'Və';

  @override
  String get beforeDataGridFilteringLabel => r'Əvvəl Və ya Bərabər';

  @override
  String get beforeOrEqualDataGridFilteringLabel => r'Əvvəl';

  @override
  String get beginsWithDataGridFilteringLabel => r'ilə başlayır';

  @override
  String get cancelDataGridFilteringLabel => r'Ləğv et';

  // @override
  // String get clearFilterFromDataGridFilteringLabel => r'Filtri Sil';

  @override
  String get containsDataGridFilteringLabel => r'ehtiva edir';

  @override
  String get dateFiltersDataGridFilteringLabel => r'Tarix Filtrləri';

  @override
  String get daySpanCountLabel => r'Gün';

  @override
  String get dhualhiLabel => r'Zilhiccə';

  @override
  String get dhualqiLabel => r'Zilqidə';

  @override
  String get doesNotBeginWithDataGridFilteringLabel => r'İlə Başlamaz';

  @override
  String get doesNotContainDataGridFilteringLabel => r'Tərkibində Yoxdur';

  @override
  String get doesNotEndWithDataGridFilteringLabel => r'İlə Bitmir';

  @override
  String get doesNotEqualDataGridFilteringLabel => r'Bərabər Deyil';

  @override
  String get emptyDataGridFilteringLabel => r'Boş';

  @override
  String get endsWithDataGridFilteringLabel => r'ilə bitir';

  @override
  String get equalsDataGridFilteringLabel => r'Bərabərdir';

  @override
  String get greaterThanDataGridFilteringLabel => r'Böyük';

  @override
  String get greaterThanOrEqualDataGridFilteringLabel => r'Böyük Və ya Bərabər';

  @override
  String get jumada1Label => r'Cümə əl-əvvəl';

  @override
  String get jumada2Label => r'Cümədə əl-sani';

  @override
  String get lessThanDataGridFilteringLabel => r'Daha az';

  @override
  String get lessThanOrEqualDataGridFilteringLabel => r'Az Və ya Bərabər';

  @override
  String get muharramLabel => r'Məhərrəm';

  @override
  String get noEventsCalendarLabel => r'Tədbir yoxdur';

  @override
  String get noMatchesDataGridFilteringLabel => r'Uyğunluq yoxdur';

  @override
  String get noSelectedDateCalendarLabel => r'Seçilmiş tarix yoxdur';

  @override
  String get notEmptyDataGridFilteringLabel => r'Boş deyil';

  @override
  String get notNullDataGridFilteringLabel => r'Null deyil';

  @override
  String get nullDataGridFilteringLabel => r'Sıfır';

  @override
  String get numberFiltersDataGridFilteringLabel => r'Nömrə Filtrləri';

  @override
  String get ofDataPagerLabel => r'of';

  @override
  String get okDataGridFilteringLabel => r'tamam';

  @override
  String get orDataGridFilteringLabel => r'Və ya';

  @override
  String get pagesDataPagerLabel => r'səhifələr';

  @override
  String get passwordDialogContentLabel => r'Bu PDF faylını açmaq üçün parolu daxil edin';

  @override
  String get passwordDialogHeaderTextLabel => r'Parol Qorunur';

  @override
  String get passwordDialogHintTextLabel => r'Parol daxil edin';

  @override
  String get passwordDialogInvalidPasswordLabel => r'etibarsız Şifrə';

  @override
  String get pdfBookmarksLabel => r'Əlfəcinlər';

  @override
  String get pdfEnterPageNumberLabel => r'Səhifə nömrəsini daxil edin';

  @override
  String get pdfGoToPageLabel => r'Səhifəyə daxil ol';

  @override
  String get pdfHyperlinkContentLabel => r'ünvanında səhifəni açmaq istəyirsiniz';

  @override
  String get pdfHyperlinkDialogCancelLabel => r'LƏĞV EDİN';

  @override
  String get pdfHyperlinkDialogOpenLabel => r'AÇIQ';

  @override
  String get pdfHyperlinkLabel => r'Veb səhifəni açın';

  @override
  String get pdfInvalidPageNumberLabel => r'Etibarlı nömrə daxil edin';

  @override
  String get pdfNoBookmarksLabel => r'Əlfəcin tapılmadı';

  @override
  String get pdfPaginationDialogCancelLabel => r'LƏĞV EDİN';

  @override
  String get pdfPaginationDialogOkLabel => r'tamam';

  @override
  String get pdfPasswordDialogCancelLabel => r'LƏĞV EDİN';

  @override
  String get pdfPasswordDialogOpenLabel => r'AÇIQ';

  @override
  String get pdfScrollStatusOfLabel => r'of';

  @override
  String get rabi1Label => r'Rəbiul-əvvəl';

  @override
  String get rabi2Label => r'Rəbi əl-sani';

  @override
  String get rajabLabel => r'Rəcəb';

  @override
  String get ramadanLabel => r'Ramazan';

  @override
  String get rowsPerPageDataPagerLabel => r'Səhifə başına satırlar';

  @override
  String get safarLabel => r'Səfər';

  @override
  String get searchDataGridFilteringLabel => r'Axtar';

  @override
  String get selectAllDataGridFilteringLabel => r'Hamısını seç';

  @override
  String get series => r'Serial';

  @override
  String get shaabanLabel => r'Şaban';

  @override
  String get shawwalLabel => r'Şəvval';

  @override
  String get shortDhualhiLabel => r'Zül-H';

  @override
  String get shortDhualqiLabel => r'Zül-Q';

  @override
  String get shortJumada1Label => r'Cümə. I';

  @override
  String get shortJumada2Label => r'Cümə. II';

  @override
  String get shortMuharramLabel => r'Muh.';

  @override
  String get shortRabi1Label => r'Rəbi. I';

  @override
  String get shortRabi2Label => r'Rəbi. II';

  @override
  String get shortRajabLabel => r'Raj.';

  @override
  String get shortRamadanLabel => r'Ram.';

  @override
  String get shortSafarLabel => r'Saf.';

  @override
  String get shortShaabanLabel => r'Şa.';

  @override
  String get shortShawwalLabel => r'Şou.';

  @override
  String get showRowsWhereDataGridFilteringLabel => r'Sətirləri harada göstərin';

  @override
  String get sortAToZDataGridFilteringLabel => r'A-dan Z-yə çeşidləyin';

  @override
  String get sortAndFilterDataGridFilteringLabel => r'Çeşidləyin və Filtr edin';

  @override
  String get sortLargestToSmallestDataGridFilteringLabel => r'Ən böyükdən kiçiyə çeşidləyin';

  @override
  String get sortNewestToOldestDataGridFilteringLabel => r'Ən yenidən köhnəyə çeşidləyin';

  @override
  String get sortOldestToNewestDataGridFilteringLabel => r'Ən köhnədən ən yeniyə çeşidləyin';

  @override
  String get sortSmallestToLargestDataGridFilteringLabel => r'Ən kiçikdən böyüyə çeşidləyin';

  @override
  String get sortZToADataGridFilteringLabel => r'Z-dən A sıralayın';

  @override
  String get textFiltersDataGridFilteringLabel => r'Mətn Filtrləri';

  @override
  String get todayLabel => r'Bu gün';

  @override
  String get weeknumberLabel => r'Həftə';

  @override
  String get clearFilterDataGridFilteringLabel => r'Filtri təmizləyin';

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
  // String get clearFilterFromDataGridFilteringLabel => r'Filter löschen von';

  @override
  String get containsDataGridFilteringLabel => r'Enthält';

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
  String get greaterThanDataGridFilteringLabel => r'Größer als';

  @override
  String get greaterThanOrEqualDataGridFilteringLabel => r'Größer als oder gleich';

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
  String get noSelectedDateCalendarLabel => r'Kein ausgewähltes Datum';

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
  String get passwordDialogContentLabel => r'Geben Sie das Passwort ein, um diese PDF-Datei zu öffnen';

  @override
  String get passwordDialogHeaderTextLabel => r'Passwortgeschützt';

  @override
  String get passwordDialogHintTextLabel => r'Passwort eingeben';

  @override
  String get passwordDialogInvalidPasswordLabel => r'Ungültiges Passwort';

  @override
  String get pdfBookmarksLabel => r'Lesezeichen';

  @override
  String get pdfEnterPageNumberLabel => r'Seitenzahl eingeben';

  @override
  String get pdfGoToPageLabel => r'Gehen Sie zur Seite';

  @override
  String get pdfHyperlinkContentLabel => r'Möchten Sie die Seite öffnen unter';

  @override
  String get pdfHyperlinkDialogCancelLabel => r'ABBRECHEN';

  @override
  String get pdfHyperlinkDialogOpenLabel => r'OFFEN';

  @override
  String get pdfHyperlinkLabel => r'Webseite öffnen';

  @override
  String get pdfInvalidPageNumberLabel => r'Bitte geben Sie eine gültige Nummer ein';

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
  String get selectAllDataGridFilteringLabel => r'Wählen Sie Alle';

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
  String get sortLargestToSmallestDataGridFilteringLabel => r'Vom Größten zum Kleinsten sortieren';

  @override
  String get sortNewestToOldestDataGridFilteringLabel => r'Vom Neusten zum Ältesten sortieren';

  @override
  String get sortOldestToNewestDataGridFilteringLabel => r'Vom Ältesten zum Neuesten sortieren';

  @override
  String get sortSmallestToLargestDataGridFilteringLabel => r'Vom Kleinsten zum Größten sortieren';

  @override
  String get sortZToADataGridFilteringLabel => r'Z bis A sortieren';

  @override
  String get textFiltersDataGridFilteringLabel => r'Textfilter';

  @override
  String get todayLabel => r'Heute';

  @override
  String get weeknumberLabel => r'Woche';

  @override
  String get clearFilterDataGridFilteringLabel => r'Filter löschen';

  @override
  String get fromDataGridFilteringLabel => r'Aus';
}
