import 'package:bilimusic/comm/LoadStatus.dart';
import 'package:bilimusic/comm/MyBottomBar.dart';
import 'package:bilimusic/model/state.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:bilimusic/player/Player.dart';
import 'package:bilimusic/model/MenuInfo.dart';
import 'package:bilimusic/model/MusicInfo.dart';
import 'package:flutter_redux/flutter_redux.dart';

typedef void Callback(MusicInfo info);

class MusicListPage extends StatefulWidget {
  int sid;

  MusicListPage(this.sid);

  @override
  State<StatefulWidget> createState() => new _MusicListPage(sid);
}

class _MusicListPage extends State<MusicListPage> {
  int sid;
  String _title = "歌单详情";
  MenuInfo _info;
  List<MusicInfo> _list = new List();
  var loadAction = LoadAction.loading;

  _MusicListPage(this.sid);

  @override
  void initState() {
    super.initState();
    loadData();
    loadListData();
    ///增加滑动监听
  }

  void loadData() async {
    try {
      final res = await Dio().get<Map<String, dynamic>>(
          "https://www.bilibili.com/audio/music-service-c/web/menu/info?sid=$sid");
      setState(() {
        _info = MenuInfo.fromJson(res.data["data"]);
        _title = _info.title;
        if(_list.length > 0)
          loadAction = LoadAction.complete;
      });
    } catch (e) {
      print(e);
      setState(() {
        loadAction = LoadAction.fail;
      });
    }
  }

  void loadListData() async {
    try {
      final res = await Dio().get<Map<String, dynamic>>(
          "https://www.bilibili.com/audio/music-service-c/web/song/of-menu?sid=$sid&pn=1&ps=100");
      List list = res.data["data"]["data"];
      setState(() {
        _list.clear();
        for (var item in list) {
          _list.add(MusicInfo.fromJson(item));
        }
        if(_info != null)
          loadAction = LoadAction.complete;
      });
    } catch (e) {
      print(e);
      setState(() {
        loadAction = LoadAction.fail;
      });
    }
  }

  void play(int index) async {
    Player.setList(_list);
    Player.play(index);
//    final url = "https://www.bilibili.com/audio/music-service-c/web/url?sid=$id&privilege=2&quality=2";
//    final res = await Dio().get<Map<String, dynamic>>(url);
//    List cdns = res.data["data"]["cdns"];
//    Player.play(cdns[0]);
//    print(cdns);
  }

  /**
   * 头部
   */
  Widget buildHeader(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new SizedBox(
            height: 140.0,
            width: 140.0,
            child: new Image.network(_info.cover),
          ),
          new Expanded(
            flex: 1,
            child: new Container(
              margin: EdgeInsets.only(left: 10.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    _info.title,
                    style: new TextStyle(
                      fontSize: 20.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  new Text(
                    _info.intro,
                    style: new TextStyle(
                      fontSize: 14.0,
                      color: new Color(0xFF99A2AA),
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext ctx, int index) {
    final item = _list[index];
    return new StoreConnector<AppState, Callback>(
      builder: (ctx, callback) {
        return new InkWell(
          onTap: () {
            play(index);
            callback(item);
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

  List<Widget> buildList(BuildContext list){
    return List.generate(_list.length, (index) {
      return buildItem(context, index);
    });
  }

  /**
   * 主要
   */
  Widget buildBody(BuildContext context) {
    return new LoadStatus(
      action: loadAction,
      completeBuilder: (context) => new RefreshIndicator(
        child: new ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            buildHeader(context),
          ]..addAll(buildList(context)),
        ),
        onRefresh: () async {
          await loadData();
          await loadListData();
          return null;
        },
      ),
      onRefresh: (){
        setState(() {
          loadAction = LoadAction.loading;
        });
        loadData();
        loadListData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        title: new Text(_title),
      ),
      body: buildBody(context),
      bottomNavigationBar: new MyBottomBar(),
    );
  }
}
