import 'dart:async';

import 'package:bilimusic/comm/LyricBox.dart';
import 'package:bilimusic/model/MusicInfo.dart';
import 'package:bilimusic/model/state.dart';
import 'package:flutter/services.dart';

class Player {
  static const platform = const MethodChannel('a10miaomiao.cn/player');
  
  static void play(int index) {
    platform.invokeMethod("play", {"index": index});
  }

  static Future<PlayerState> getInfo() async {
    final obj = await platform.invokeMethod("getInfo");
    return new PlayerState(
      id: obj["id"],
      position: obj["position"],
      duration: obj["duration"],
      title: obj["title"],
      subTitle: obj["author"],
      cover: obj["cover"],
      isPlaying: obj["isPlaying"],
      index: obj["index"]
    );
  }

  static Future<List<LyricModel>> getLyric() async{
    final List<dynamic> lyric = await platform.invokeMethod("getLyric");
    print(lyric);
    return lyric.map((obj){
      Map<String, dynamic> map = (obj as Map<dynamic, dynamic>).map((k, v) => new MapEntry(k.toString(), v));
      return new LyricModel(obj["text"], obj["time"]);
    }).toList();
  }

  static void setList(List<MusicInfo> list){
    platform.invokeMethod("setList", list.map((v) => v.toMap()).toList());
  }

  static Future<List<MusicInfo>> getList() async {
    final List<dynamic> list = await platform.invokeMethod("getList");
    return list.map((obj){
      Map<String, dynamic> map = (obj as Map<dynamic, dynamic>).map((k, v) => new MapEntry(k.toString(), v));
      return new MusicInfo.fromJson(map);
    }).toList();
  }

  static Future<List<MusicInfo>> getHistory() async {
    final List<dynamic> list = await platform.invokeMethod("getHistory");
    return list.map((obj){
      Map<String, dynamic> map = (obj as Map<dynamic, dynamic>).map((k, v) => new MapEntry(k.toString(), v));
      return new MusicInfo.fromJson(map);
    }).toList();
  }

  static void pause(){
    platform.invokeMethod("pause");
  }
  static void resume(){
    platform.invokeMethod("resume");
  }

  static void next(){
    platform.invokeMethod("next");
  }

  static void seekTo(double progress){
    platform.invokeMethod("seekTo", { "progress": progress });
  }

  static void previous(){
    platform.invokeMethod("previous");
  }
  static void setMode(int mode){
    platform.invokeMethod("setMode", { "mode": mode });
  }
  static Future<int> getMode() async{
    final map = await platform.invokeMethod("getMode");
    return map["mode"];
  }
}
