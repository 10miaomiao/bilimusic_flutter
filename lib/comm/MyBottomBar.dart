import 'package:bilimusic/comm/MusicQueue.dart';
import 'package:bilimusic/model/state.dart';
import 'package:bilimusic/pages/PlayerPage.dart';
import 'package:bilimusic/player/Player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';



class MyBottomBar extends StatelessWidget {
  final _height = 52.0;
  final _backgroundColor = new Color(0xFF384245);

  void openMusicQueue(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => new MusicQueue(),
    );
  }

  Widget buildRow(BuildContext context, PlayerState player) {
    return new GestureDetector(
      onTap: () {
        Navigator
            .of(context)
            .push(new MaterialPageRoute(builder: (_) => new PlayerPage()));
      },
      child: new Row(
        children: <Widget>[
          new Container(
            height: _height,
            width: _height,
            color: new Color(0xFFE7E7E7),
            margin: EdgeInsets.only(right: 10.0),
            child: player.cover == null
                ? Image.asset("images/bili.png")
                : Image.network(player.cover),
          ),
          new Expanded(
            flex: 1,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  child: new Text(
                    player.title,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                ),
                new Container(
                  child: new Text(
                    player.subTitle,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          new StoreConnector<AppState, VoidCallback>(
            builder: (ctx, callback) {
              return new IconButton(
                onPressed: () {
                  if (player.isPlaying)
                    Player.pause();
                  else
                    Player.resume();
                  callback();
                },
                color: Colors.white,
                icon:
                    new Icon(player.isPlaying ? Icons.pause : Icons.play_arrow),
              );
            },
            converter: (store) {
              return () => store.dispatch(
                    new PlayerState(
                      isPlaying: !player.isPlaying,
                    ),
                  );
            },
          ),
          new IconButton(
            onPressed: () {
              openMusicQueue(context);
            },
            color: Colors.white,
            icon: new Icon(Icons.queue_music),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, PlayerState>(
      builder: (context, player) {
        if(player.title == null || player.title == ""){
          return new SizedBox(
            height: 0.0,
          );
        } else {
          return new Container(
            height: _height,
            color: _backgroundColor,
            child: new Stack(
              children: <Widget>[
                buildRow(context, player),
                new Align(
                  alignment: Alignment(1.0, 1.0),
                  child: new SizedBox(
                    height: 2.0,
                    child: new LinearProgressIndicator(
                      value: player.getCurrentPosition(),
                      backgroundColor: new Color(0x00000000),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
      converter: (store) => store.state.player,
    );
  }
}
