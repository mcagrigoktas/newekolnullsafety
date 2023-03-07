import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mcg_extension/mcg_extension.dart';

class AdvancedClassHelper {
  AdvancedClassHelper._();
  static Widget setupParticipantWidget(String key) {
    dynamic element;

    if (Fav.readSeasonCache(key + 'ElementRegistered') == null) {
      element = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none';

      // ignore:undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(key, (int viewId) => element);
      Fav.writeSeasonCache(key + 'ElementRegistered', true);
      Fav.writeSeasonCache(key + 'Element', element);
    } else {
      element = Fav.readSeasonCache(key + 'Element');
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: HtmlElementView(key: Key(key), viewType: key),
    );
  }
}
