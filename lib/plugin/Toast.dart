import 'package:flutter/services.dart';

class Toast {

  static const _platform = const MethodChannel("a10miaomiao.cn/toast");

  static void showShortToast(String message) =>
      _platform.invokeMethod("showShortToast", { "message": message});

  static void showLongToast(String message) =>
      _platform.invokeMethod("showLongToast", { "message": message});

  static void showToast(String message, int duration) =>
      _platform.invokeMethod(
          "showToast", { "message": message, "duration": duration});

}