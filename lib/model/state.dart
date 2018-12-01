import 'package:flutter/material.dart';

/// 播放器状态
class PlayerState {
  int id;
  String title;
  String subTitle;
  String cover;
  int position;
  int duration;
  bool isPlaying;
  int index;

  PlayerState({
    this.id,
    this.title,
    this.subTitle,
    this.cover,
    this.position,
    this.duration,
    this.isPlaying: false,
    this.index
  });

  double getCurrentPosition(){
    if(position == null || duration == null){
      return 0.0;
    }
    final value = position.toDouble() / duration.toDouble();
    if(value > 1.0)
      return 1.0;
    return value;
  }

  String getCurrentTime() => formatTime(position);
  String getAllTime()=> formatTime(duration);

  String formatTime(int time){
    if(time == null)
      return "00:00";
    final sec = time ~/ 1000 % 60;
    final minute = time ~/ 1000 ~/ 60;
    return fillZero(minute) + ":" + fillZero(sec);
  }

  String fillZero(int v){
    return v < 10 ? "0" + v.toString() : v.toString();
  }

}

/// 主题
class ThemeState{
  Color color;
  ThemeState({
    this.color,
  });
}


/// 登陆-用户
class UserState {
  // "mid": 6789810,
  // "name": "10喵喵",
  // "face": "http://i2.hdslb.com/bfs/face/a9c907d558e46fc3addf15a72cfb66d2d2a955bf.jpg",
  // "coin": 446,
  // "bcoin": 5,
  // "sex": 0,
  // "rank": 10000,
  // "silence": 0,
  // "show_videoup": 1,
  // "show_creative": 1,
  // "level": 5,
  // "vip_type": 2,
  // "audio_type": 0,
  // "dynamic": 11,
  // "following": 95,
  // "follower": 10,
  // "official_verify": {
  //   "type": -1,
  //   "desc": ""
  // }
  int mid;
  String name;
  String face;
  int coin;
  // num bcoin;
  int sex;
  int level;
  int vip_type;

  bool isLogin = false;

  UserState({
    this.mid,
    this.name,
    this.face,
    this.coin,
    // this.bcoin,
    this.sex,
    this.level,
    this.vip_type,
    this.isLogin: false
  });

  UserState.fromJson(Map<String, dynamic> json)
    : mid = json["mid"],
      name = json["name"],
      face = json["face"],
      coin = json["coin"],
      // bcoin = json["bcoin"],
      level = json["level"],
      vip_type = json["vip_type"],
      isLogin = true;
}

enum Action{
  UPDATE,
}

/// 应用程序状态
class AppState {
  PlayerState player;
  ThemeState theme;
  UserState user;

  AppState({
    this.player,
    this.theme,
    this.user,
  });
}

AppState mainReducer(AppState state, dynamic action) {
  if (action is PlayerState) {
    if(action.id != null)
      state.player.id = action.id;
    if(action.title != null)
      state.player.title = action.title;
    if(action.subTitle != null)
      state.player.subTitle = action.subTitle;
    if(action.cover != null)
      state.player.cover = action.cover;
    if(action.position != null)
      state.player.position = action.position;
    if(action.duration != null)
      state.player.duration = action.duration;
    if(action.index != null)
      state.player.index = action.index;
    if(action.isPlaying != null)
      state.player.isPlaying = action.isPlaying;
  }
  if (action is ThemeState) {
    state.theme = action;
  }
  if (action is UserState) {
    state.user = action;
  }
  return state;
}
