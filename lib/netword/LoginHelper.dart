import 'dart:async';
import 'package:bilimusic/netword/ApiHelper.dart';
import 'package:bilimusic/plugin/RSA.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' show json;

class LoginHelper{
  static const BASE_URL = 'https://passport.bilibili.com/';
  static const headers = {
    'user-agent': 'Mozilla/5.0 BiliMusic/1.0 (10miaomiao@outlook.com)',
  };

  static Future<Map<String, String>> getKey() async{
    final params = {
      'appkey': ApiHelper.APP_KEY,
    };
    params['sign'] = ApiHelper.getSign(params);
    final dio = new Dio();
    final r = await dio.post<Map<String, dynamic>>(
      BASE_URL + "api/oauth2/getKey?" + ApiHelper.urlencode(params),
      options: new Options(
        headers: headers,
      )
    );

    final data = r.data["data"];
    return {
      "hash": data["hash"],
      "key": data["key"],
    };
  }

  static void saveToken(String access_token,String refresh_token) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("access_token", access_token);
    prefs.setString("refresh_token", refresh_token);
  }

  static Future<String> getAccessToken() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token") ?? "";
  }

  static Future<String> getRefreshToken() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("refresh_token") ?? "";
  }

  static Future<int> getMid() async{
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString("user_info") ?? "";
    return json.decode(str)["mid"];
  }


  static void saveUserInfo(Map<String, dynamic> info) async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("user_info", json.encode(info));
  }

  static Future<Map<String, dynamic>> readUserInfo() async{
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString("user_info") ?? "";
    return json.decode(str);
  }


  static Future<Map<String, dynamic>> authInfo(String access_token) async{
    final params = {
      'appkey': ApiHelper.APP_KEY,
      'access_key': access_token,
      'build': 5310300,
      'mobi_app': 'android',
      'platform': 'android',
      'ts': ApiHelper.getTime(),
    };
    params['sign'] = ApiHelper.getSign(params);
    print(params);
    final r = await new Dio().get<Map<String, dynamic>>(
      "https://app.bilibili.com/x/v2/account/mine?" + ApiHelper.urlencode(params),
    );
    return r.data;
  }

  static Future<Map<String, dynamic>> login(String username,String password) async{
    final key_map = await getKey();
    final hash = key_map["hash"];
    final key = key_map["key"];
    final encrypt = await RSA.decryptByPublicKey(hash + password, key);
    final params = {
      'appkey': ApiHelper.APP_KEY,
      'password': encrypt.replaceAll('\n', ''),
      'username': username
    };
    params['sign'] = ApiHelper.getSign(params);
    final r = await new Dio().post<Map<String, dynamic>>(
      BASE_URL + "api/oauth2/login?" + ApiHelper.urlencode(params),
      options: new Options(
        headers: headers,
      )
    );
    return r.data;
  }

  static void refreshToken() async{
    final access_token = await getAccessToken();
    final refresh_token = await getRefreshToken();
    final params = {
      'access_token': access_token,
      'appkey': ApiHelper.APP_KEY,
      'refresh_token': refresh_token
    };
    params['sign'] = ApiHelper.getSign(params);
    final r = await new Dio().post(
      BASE_URL + 'api/oauth2/refreshToken?' + ApiHelper.urlencode(params),
      options: new Options(
        headers: headers,
      )
    );
    print(r.data);
  }
}