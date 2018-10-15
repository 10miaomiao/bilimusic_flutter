import 'dart:async';

import 'package:flutter/services.dart';

class Volume {
  static const _platform = const MethodChannel("a10miaomiao.cn/volume");

  static void setVolume(double volume) =>
      _platform.invokeMethod("setVolume", {"volume": volume});

  static Future<double> getVolume() async {
    return (await _platform.invokeMethod("getVolume"))["volume"];
  }
}
