import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'deferred_portfolio_main.dart' deferred as eager;

const _pref_portfolio_main_loaded = 'pref_portfolio_main_loaded';

class PortfolioMain extends StatefulWidget {
  final bool forMiniScreen;
  PortfolioMain({this.forMiniScreen = false});

  @override
  State<PortfolioMain> createState() => _PortfolioMainState();
}

class _PortfolioMainState extends State<PortfolioMain> {
  bool _libraryIsLoading = true;
  @override
  void initState() {
    if (Fav.readSeasonCache(_pref_portfolio_main_loaded) == true) {
      _libraryIsLoading = false;
    } else {
      eager.loadLibrary().then((value) {
        Fav.writeSeasonCache(_pref_portfolio_main_loaded, true);
        setState(() {
          _libraryIsLoading = false;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_libraryIsLoading) return MyProgressIndicator(isCentered: true);
    return eager.DeferredPortfolioMain(
      forMiniScreen: widget.forMiniScreen,
    );
  }
}
