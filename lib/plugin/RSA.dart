import 'dart:async';
import 'package:flutter/services.dart';

class RSA{
  static const platform = const MethodChannel('a10miaomiao.cn/rsa');

  /**
   * 公钥加密
   */
  static Future<String> decryptByPublicKey(String data,String publicKey) async {
    String s = await platform.invokeMethod("decryptByPublicKey", {
      "data": data,
      "publicKey": publicKey
    });
    return s;
  }
}