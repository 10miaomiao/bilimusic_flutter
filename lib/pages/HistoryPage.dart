import 'package:bilimusic/model/MusicInfo.dart';
import 'package:bilimusic/model/state.dart';
import 'package:bilimusic/plugin/Player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

typedef void Callback(MusicInfo info);

class HistoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {

  List<MusicInfo> _list = new List();

  @override
  void initState(){
    super.initState();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    loadData();
  }

  void loadData() async{
    final l = await Player.getHistory();
    setState(() {
      _list.clear();
      _list.addAll(l);
    });
  }

  void play(int index) {
    Player.setList(_list);
    Player.play(index);
  }

  Widget buildItem(BuildContext ctx, int index) {
    final item = _list[index];
    return new StoreConnector<AppState, Callback>(
      builder: (ctx, callback) {
        return new InkWell(
          onTap: () {
            play(index);
            callback(item);
            loadData();
          },
          child: new Container(
            padding: EdgeInsets.all(5.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Text(
                  item.title,
                  style: new TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                new Text(
                  item.author,
                  style: new TextStyle(
                    fontSize: 15.0,
                    color: new Color(0xFF99A2AA),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      converter: (store) {
        return (info) => store.dispatch(
          new PlayerState(
            title: info.title,
            subTitle: info.author,
            cover: info.cover,
            isPlaying: true,
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
      child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: List.generate(_list.length, (index) {
            return buildItem(context, index);
          })
      ),
      onRefresh: () async{
        await loadData();
      },
    );
  }
}