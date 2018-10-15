import 'package:bilimusic/comm/LyricBox.dart';
import 'package:bilimusic/comm/MusicQueue.dart';
import 'package:bilimusic/model/state.dart';
import 'package:bilimusic/player/Lyric.dart';
import 'package:bilimusic/player/Toast.dart';
import 'package:bilimusic/player/Volume.dart';
import 'package:bilimusic/player/Player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class PlayerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PlayerPage();
}

class _PlayerPage extends State<PlayerPage> {
  var _volume = 0.5;
  var _position = 0.0;
  var _isDrag = false;
  var _mode = 0;
  var _showIndex = 0;

  @override
  void initState() {
    super.initState();
    Player.getMode().then((v) {
      setState(() {
        _mode = v;
      });
    });
    Volume.getVolume().then((v) {
      setState(() {
        _volume = v;
      });
    });
  }

  IconData getModeIcon() {
    var icon = Icons.reorder;
    switch (_mode) {
      case 0:
        icon = Icons.arrow_forward;
        break;
      case 1:
        icon = Icons.repeat;
        break;
      case 2:
        icon = Icons.repeat_one;
        break;
      case 3:
        icon = Icons.shuffle;
        break;
    }
    return icon;
  }

  void nextMode(BuildContext context) {
    setState(() {
      if (_mode == 3)
        _mode = 0;
      else
        _mode++;
    });
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(
        ['顺序播放', '列表循环', '单曲循环', '随机播放'][_mode]
      ),
    ));
    Player.setMode(_mode);
  }

  void setVolume(double value) {
    setState(() {
      _volume = value;
    });
    Volume.setVolume(_volume);
  }

  Widget buildHeader(BuildContext context, PlayerState player){
    return new GestureDetector(
      child: new AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          children: <Widget>[
            new AnimatedOpacity(
              opacity: _showIndex == 0 ? 1.0 : 0.0,
              duration: new Duration(milliseconds: 200),
              child: player.cover == null
                ? new Image.asset(
                    "images/bili.png",
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitWidth,
                  )
                : new Image.network(
                    player.cover,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitWidth,
                  ),
            ),
            new AnimatedOpacity(
              opacity: _showIndex == 1 ? 1.0 : 0.0,
              duration: new Duration(milliseconds: 200),
              child: new LyricBox(),
            ),
          ],
        )
      ),
      onTap: (){
        setState(() {
          if(_showIndex == 0)
            _showIndex = 1;
          else
            _showIndex = 0;
        });
      },
    );
  }

  Widget buildBody(BuildContext context, PlayerState player) {
    return new Column(
      children: <Widget>[
        buildHeader(context, player),
        new Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: new Row(
            children: <Widget>[
              new Text(
                player.getCurrentTime(),
                style: new TextStyle(
                  fontSize: 14.0,
                ),
              ),
              new Expanded(
                flex: 1,
                child: new Slider(
                  value: _isDrag ? _position : player.getCurrentPosition(),
                  onChanged: (value) {
                    setState(() {
                      _position = value;
                    });
                  },
                  onChangeStart: (value) {
                    setState(() {
                      _position = value;
                      _isDrag = true;
                    });
                  },
                  onChangeEnd: (value) {
                    Player.seekTo(value);
                    setState(() {
                      _position = value;
                      _isDrag = false;
                    });
                  },
                ),
              ),
              new Text(
                player.getAllTime(),
                style: new TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
        new Text(
          player.title,
          style: new TextStyle(
            fontSize: 20.0,
          ),
          textAlign: TextAlign.center,
        ),
        new Text(
          player.subTitle,
          textAlign: TextAlign.center,
          style: new TextStyle(
            color: new Color(0xFF99A2AA),
          ),
        ),
        new Expanded(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new IconButton(
                icon: new Icon(
                  getModeIcon(),
                  color: Theme.of(context).accentColor,
                ),
                iconSize: 36.0,
                onPressed: (){ nextMode(context); },
              ),
              new IconButton(
                icon: new Icon(
                  Icons.skip_previous,
                  color: Theme.of(context).accentColor,
                ),
                iconSize: 50.0,
                onPressed: () {
                  Player.previous();
                },
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
                    icon: new Icon(
                      player.isPlaying
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      color: Theme.of(context).accentColor,
                    ),
                    iconSize: 64.0,
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
                icon: new Icon(
                  Icons.skip_next,
                  color: Theme.of(context).accentColor,
                ),
                iconSize: 50.0,
                onPressed: () {
                  Player.next();
                },
              ),
              new IconButton(
                icon: new Icon(
                  Icons.queue_music,
                  color: Theme.of(context).accentColor,
                ),
                iconSize: 36.0,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => new MusicQueue(),
                  );
                },
              ),
            ],
          ),
        ),
        new Container(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(
                _volume > 0.7
                    ? Icons.volume_up
                    : _volume > 0.2
                        ? Icons.volume_down
                        : _volume > 0.0 ? Icons.volume_mute : Icons.volume_off,
                color: Theme.of(context).accentColor,
              ),
              new Slider(
                value: _volume,
                onChanged: setVolume,
              ),
            ],
          ),
          margin: EdgeInsets.only(bottom: 30.0),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new StoreConnector<AppState, PlayerState>(
        builder: (context, player) => new Stack(
              children: <Widget>[
                player.cover == null
                    ? new Image.asset(
                        "images/bili.png",
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.fitHeight,
                      )
                    : new Image.network(
                        player.cover,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.fitHeight,
                      ),
                new Container(
                  color: new Color(0xDDFFFFFF),
                  child: buildBody(context, player),
                ),
              ],
            ),
        converter: (store) => store.state.player,
      ),
    );
  }
}
