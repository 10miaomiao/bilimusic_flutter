
import 'dart:io';
import 'dart:async';

import 'package:bilimusic/netword/ApiHelper.dart';
import 'package:bilimusic/netword/LoginHelper.dart';
import 'package:dio/dio.dart';

class BiliMusicApi{
  
  static const BASE_URL = "https://api.bilibili.com";

  static final dio = new Dio()
    ..options.baseUrl = BASE_URL
    ..interceptor.request.onSend = (Options options) async{
      if(options.data == null){
        options.data = new Map<String, dynamic>();
      }
      var access_key = await LoginHelper.getAccessToken();
      if(access_key != "")
        options.data["access_key"] = access_key;
      var mid = await LoginHelper.getMid();
      if(mid != -1)
        options.data["mid"] = mid;
      options.data["appkey"] = ApiHelper.APP_KEY;
      options.data["build"] = "5310300";
      options.data["mobi_app"] = "android";
      options.data["platform"] = "android";
      options.data["ts"] = ApiHelper.getTime();
      options.data["sign"] = ApiHelper.getSign(options.data);
      if(options.method == "POST"){
        options.contentType = ContentType.parse("application/x-www-form-urlencoded");
      }
      return options; //continue
    }
    ..interceptor.response.onSuccess = (Response response) async {
      // print("233333");
      // print(response.data);
      // if(response.data["code"] == 72010002){
      //   await LoginHelper.refreshToken();
      //   // final request = response.request;
      //   // final res = new Dio().request<Map<String, dynamic>>(
      //   //   request.path,
      //   //   data: request.data,
      //   // );
      //   return response;
      // }
      return response;
    };

  
  /**
   * 我的收藏
   */
  static Future<Response<Map<String, dynamic>>> getCollections() 
        => dio.get<Map<String, dynamic>>(
          "/audio/music-service-c/collections",
        );

  /**
   * 收藏的歌单
   */
  static Future<Response<Map<String, dynamic>>> getMenus(int mid,int page_index,int page_size) 
        => dio.get<Map<String, dynamic>>(
          "/audio/music-service-c/users/" + mid.toString() + "/menus",
          data: <String, dynamic>{
            "page_index": page_index,
            "page_size": page_size,
          }
        );

  /**
   * 查看收藏详情
   */
  static Future<Response<Map<String, dynamic>>> getCollectionsSongs(int id,int mid, int page_index,int page_size) 
        => dio.get<Map<String, dynamic>>(
          "/audio/music-service-c/collections/" + mid.toString() + "/songs",
          data: <String, dynamic>{
            "collection_id": id,
            "page_index": page_index,
            "page_size": page_size,
          }
        );
  
  /**
   * 歌单详情
   */
  static Future<Response<Map<String, dynamic>>> getMenuInfo(int id) 
        => dio.get<Map<String, dynamic>>(
          "/audio/music-service-c/menus/" + id.toString()
        );

  /**
   * 收藏歌单
   */
  static Future<Response<Map<String, dynamic>>> addMenuCollect(int id) 
        => dio.get<Map<String, dynamic>>(
          "/audio/music-service-c/menucollect/add",
          data: <String, dynamic>{
            "menuId": id
          }
        );

  /**
   * 取消收藏歌单
   */
  static Future<Response<Map<String, dynamic>>> delMenuCollect(int id) 
        => dio.get<Map<String, dynamic>>(
          "/audio/music-service-c/menucollect/del",
          data: <String, dynamic>{
            "menuId": id
          }
        );

  /**
   * 收藏歌曲到歌单
   */
  static Future<Response<Map<String, dynamic>>> favorite(int id, List<int> collection)
    => dio.post<Map<String, dynamic>>(
      "/audio/music-service-c/collections/songs/" + id.toString(),
      data: <String, dynamic>{
        "collection_id_list": collection.join(","),
        "song_id": id.toString(),
      }
    );

}