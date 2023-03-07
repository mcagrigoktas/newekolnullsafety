part of '../dataservice.dart';

class ChangeLogService {
  ChangeLogService._();

  static Database get _databaseLogss => AppVar.appBloc.databaseLogs;

//! GETDATASERVICE
  // uygulama guncelleme gecmisini ceker
  static Reference dbGetChangelog() => Reference(_databaseLogss, 'ChangeLogs/Posts');

//! SETDATASERVICE
//? Okullara uygulamada yapilan degisiklikleri gonderebilmek icin
  static Future<void> sendChangelogData(ChangeLogPostItem item, {bool delete = false}) {
    return _databaseLogss.set('ChangeLogs/Posts/${item.key}', delete ? null : item.toJson());
  }
}
