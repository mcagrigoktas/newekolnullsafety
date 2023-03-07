import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';
import 'package:mypackage/mywidgets.dart';
import 'deferred_qbank_ekol_entry.dart' deferred as qbank_ekol;

const _pref_ekol_qbank_loaded = 'pref_ekol_qbank_loaded';

class EkolQBankPage extends StatefulWidget {
  final bool forMiniScreen;
  EkolQBankPage({this.forMiniScreen = false});

  @override
  State<EkolQBankPage> createState() => _EkolQBankPageState();
}

class _EkolQBankPageState extends State<EkolQBankPage> {
  bool _libraryIsLoading = true;
  @override
  void initState() {
    if (Fav.readSeasonCache(_pref_ekol_qbank_loaded) == true) {
      _libraryIsLoading = false;
    } else {
      qbank_ekol.loadLibrary().then((value) {
        Fav.writeSeasonCache(_pref_ekol_qbank_loaded, true);
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
    return qbank_ekol.DeferredEkolQBankPage(
      forMiniScreen: widget.forMiniScreen,
    );
  }
}
