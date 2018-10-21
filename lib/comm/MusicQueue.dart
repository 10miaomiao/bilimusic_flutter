import 'package:bilimusic/model/MusicInfo.dart';
import 'package:bilimusic/model/state.dart';
import 'package:bilimusic/plugin/Player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

typedef void Callback(int index);

class MusicQueue extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MusicQueue();
}



class _MusicQueue extends State<MusicQueue> {
  ScrollController _scrollController;
  static const double _ITEM_HEIGHT = 48.0;
  var _list = new List<MusicInfo>();

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    loadList();
  }

  void loadList() async{
    final list = await Player.getList();
    setState(() {
      _list = list;
    });
    final info = await Player.getInfo();
    _scrollController.jumpTo(info.index * _ITEM_HEIGHT);
  }

  Widget buildItem(BuildContext ctx, int index, int i) {
    final item = _list[i];
    final textColor = index == i ? Theme.of(context).accentColor : Colors.black;
    return new StoreConnector<AppState, Callback>(
      builder: (ctx, callback) {
        return new InkWell(
          onTap: (){
            Player.play(i);
            callback(i);
          },
          child: new Container(
            height: _ITEM_HEIGHT,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  item.title,
                  style: new TextStyle(
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                new Text(
                  item.author,
                  style: new TextStyle(
                    color: textColor,
                    fontSize: 12.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
      converter: (store) {
        return (index) => store.dispatch(
          new PlayerState(
            title: _list[index].title,
            subTitle: _list[index].author,
            cover: _list[index].cover,
            isPlaying: true,
            index: index
          ),
        );
      },
    );
  }

  Widget buildList(BuildContext context, int index){
    final listView = new ListView(
        scrollDirection: Axis.vertical,
        controller: _scrollController,
        shrinkWrap: true,
        children:
          List.generate(_list.length, (i) => buildItem(context, index, i)),
    );
    return listView;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, int>(
      converter: (store) => store.state.player.index,
      builder: (context, index) {
        return new Column(
          children: <Widget>[
            new SizedBox(
              height: 36.0,
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: new Text("播放列表(" + _list.length.toString() + "首)"),
                  )
                ],
              ),
            ),
            new Expanded(
              child: buildList(context, index),
            ),
          ],
        );
      },
    );
  }
}
