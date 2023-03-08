import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mcg_database/mcg_database.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';

import '../../../appbloc/appvar.dart';
import '../../../flavors/dbconfigs/other/init_helpers.dart';
import '../../../models/allmodel.dart';

class ServiceLocationsScreen extends StatefulWidget {
  final List<Transporter> transporterList;
  ServiceLocationsScreen({required this.transporterList});

  @override
  State<ServiceLocationsScreen> createState() => _ServiceLocationsScreenState();
}

class _ServiceLocationsScreenState extends State<ServiceLocationsScreen> {
  bool _isLoading = true;
  late MapController _mapController;
  StreamSubscription? _subscription;

  @override
  void initState() {
    _mapController = MapController();

    _isLoading = true;
    fetchLocations();
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  Map<String, List<double>> setupDummyData() {
    return AppVar.appBloc.transporterService!.dataList.fold<Map<String, List<double>>>({}, (p, e) => p..[e.key] = [37.178466 + 0.059199 * (20.random) / 20, 28.294858 + 0.134067 * (20.random) / 20]);
  }

  var locationDatas = <String, List<double>>{};

  void fetchLocations() {
    FirebaseInitHelper.getLogsApp().then((firebaseLogsApp) {
      if (widget.transporterList.length == 1) {
        _subscription = Database(app: firebaseLogsApp).onValue('Okullar/${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/TransporterLocations/${widget.transporterList.first.key}').listen((event) {
          final _value = event?.value;
          if (_value is List) {
            locationDatas[widget.transporterList.first.key] = List<double>.from(_value);
            setState(() {
              _isLoading = false;
            });
          }
        });
      } else {
        _subscription = Database(app: firebaseLogsApp).onValue('Okullar/${AppVar.appBloc.hesapBilgileri.kurumID}/${AppVar.appBloc.hesapBilgileri.termKey}/TransporterLocations').listen((event) {
          if (event?.value is Map) {
            (event?.value as Map).forEach((key, value) {
              locationDatas[key.toString()] = List<double>.from(value);
            });
          } else {
            locationDatas = setupDummyData();
          }

          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: TopBar(leadingTitle: 'menu1'.translate),
      body: _isLoading
          ? Body.circularProgressIndicator()
          : locationDatas.isEmpty
              ? Body.child(
                  child: EmptyState(
                  emptyStateWidget: EmptyStateWidget.NORECORDS,
                ))
              : Body.child(
                  child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng((locationDatas.values.first).first, (locationDatas.values.first).last),
                    zoom: 14.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
                    MarkerLayer(
                      markers: [
                        ...((widget.transporterList.where((e) {
                          return locationDatas.containsKey(e.key) != false;
                        }).map<Marker>((e) {
                          final color = MyPalette.getChartColorFromCount(widget.transporterList.indexOf(e));
                          return Marker(
                            point: LatLng((locationDatas[e.key])!.first, (locationDatas[e.key])!.last),
                            width: 50,
                            height: 50,
                            builder: (context) => _Marker(color: color, size: 40),
                          );
                        }).toList())),
                      ],
                    ),
                  ],
                  nonRotatedChildren: [],
                )),
      bottomBar: BottomBar(
          child: Wrap(
        spacing: 8,
        alignment: WrapAlignment.center,
        children: [
          ...widget.transporterList
              .map((e) => GestureDetector(
                    onTap: () {
                      if (locationDatas[e.key] != null) _mapController.move(LatLng((locationDatas[e.key]!).first, (locationDatas[e.key]!).last), 15.0);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Legand(MyPalette.getChartColorFromCount(widget.transporterList.indexOf(e)), 40),
                        8.widthBox,
                        e.profileName.safeSubString(0, 20).text.make(),
                      ],
                    ),
                  ))
              .toList()
        ],
      )),
    );
  }
}

class _Legand extends StatelessWidget {
  final Color color;
  final double size;
  _Legand(this.color, this.size);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color.withOpacity(0.2), border: Border.all(width: size / 10, color: color), shape: BoxShape.circle),
        child: MdiIcons.bus.icon.color(Colors.black).size(size * 6 / 10).padding(0).make(),
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  final Color? color;
  final double? size;
  _Marker({this.color, this.size});
  @override
  Widget build(BuildContext context) {
    if (color == null) return SizedBox();
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color!.withOpacity(0.2), border: Border.all(width: size! / 10, color: color!), shape: BoxShape.circle),
        child: MdiIcons.bus.icon.color(Colors.black).size(size! * 7 / 10).padding(0).make(),
      ),
    );
  }
}
