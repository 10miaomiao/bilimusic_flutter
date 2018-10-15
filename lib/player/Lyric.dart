import 'package:flutter/services.dart';

class Lyric{
  static const EventChannel _eventChannel = const EventChannel('a10miaomiao.cn/lyric');

  Lyric(void onEvent(),void onIndex(int index)){
    _eventChannel.receiveBroadcastStream().listen((data){
      switch (data["action"]) {
        case "update_lyric":
          onEvent();
          break;
        case "update_index":
          onIndex(data["index"]);
          break;
        default:
      }
    }, onError: (err){
      print(err);
    });
  }
}