import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class ApiHelper{

  static const APP_KEY = "1d8b6e7d45233436";
  static const APP_SECRET = '560c52ccd288fed045859ed18bffd973';
  static const buvId = "JxdyESFAJkcjEicQbBBsCTlbal5uX2Yinfoc";
  static const hardwareId = "JxdyESFAJkcjEicQbBBsCTlbal5uX2Y";

  static String getSign(Map<String, dynamic> params){
    final str = urlencode(params);
    return generateMd5(str + APP_SECRET);
  }

  // md5 加密
  static String generateMd5(String data) {
    final content = new Utf8Encoder().convert(data);
    final digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }

  static String urlencode(Map<String, dynamic> params){
    final list = new List<String>();
    params.forEach((key, value){
        list.add(key + "=" + Uri.encodeQueryComponent(value.toString()));
    });
    list.sort();
    return list.join("&");
  }

  static int getTime(){
    return DateTime.now().millisecondsSinceEpoch;
  }


}