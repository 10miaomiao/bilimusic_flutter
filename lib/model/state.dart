import 'package:flutter/material.dart';

/// 播放器状态
class PlayerState {
  String title;
  String subTitle;
  String cover;
  int position;
  int duration;
  bool isPlaying;
  int index;

  PlayerState({
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

class ThemeState{
  Color color;
  ThemeState({
    this.color,
  });
}

enum Action{
  UPDATE,
}

/// 应用程序状态
class AppState {
  PlayerState player;
  ThemeState theme;

  AppState({
    this.player,
    this.theme,
  });
}

AppState mainReducer(AppState state, dynamic action) {
  if (action is PlayerState) {
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
  return state;
}
