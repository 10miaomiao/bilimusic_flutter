import 'package:bilimusic/comm/LoadStatus.dart';
import 'package:bilimusic/comm/MyBottomBar.dart';
import 'package:bilimusic/model/MenuInfo2.dart';
import 'package:bilimusic/model/state.dart';
import 'package:bilimusic/netword/BiliMusicApi.dart';
import 'package:flutter/material.dart';
import 'package:bilimusic/plugin/Player.dart';
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
  MenuInfo2 _info;
  List<MusicInfo> _list = new List();
  var loadAction = LoadAction.loading;

  _MusicListPage(this.sid);

  @override
  void initState() {
    super.initState();
    loadData();
    ///增加滑动监听
  }

  void loadData() async {
    try {
      final res = await BiliMusicApi.getMenuInfo(sid);
      setState(() {
        final data = res.data["data"];
        _info = MenuInfo2.fromJson(data["menusRespones"]);
        _title = _info.title;
        List list = data["songsList"];
        _list.clear();
        for (var item in list) {
          _list.add(MusicInfo.fromJson(item));
        }
        loadAction = LoadAction.complete;
      });
    } catch (e) {
      print(e);
      setState(() {
        loadAction = LoadAction.fail;
      });
    }
  }

  /**
   * 收藏
   */
  void star(BuildContext context) async{
    if(StoreProvider.of<AppState>(context).state.user.isLogin){
      final res = await BiliMusicApi.addMenuCollect(sid);
      if(res.data["code"] == 0){
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text("收藏成功"),
        ));
        setState(() {
          _info.collected = 1;        
        });
      }else{
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(res.data["message"]),
        ));
      }
    }else{
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("你还未登陆"),
      ));
    }
  }

  /**
   * 取消收藏
   */
  void unstar(BuildContext context) async{
    final res = await BiliMusicApi.delMenuCollect(sid);
    if(res.data["code"] == 0){
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("取消收藏成功"),
      ));
      setState(() {
        _info.collected = 0;        
      });
    }else{
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(res.data["message"]),
      ));
    }
  }


  void play(BuildContext context, int index) async {
    Player.setList(_list);
    Player.play(index);
    final info = _list[index];
    StoreProvider.of<AppState>(context).dispatch(
      new PlayerState(
        title: info.title,
        subTitle: info.author,
        cover: info.cover,
        isPlaying: true,
      ),
    );
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
            child: new Image.network(_info.coverUrl),
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

  Widget buildItem(BuildContext context, int index) {
    final item = _list[index];
    return new InkWell(
      onTap: () {
        play(context, index);
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
        },
      ),
      onRefresh: (){
        setState(() {
          loadAction = LoadAction.loading;
        });
        loadData();
      },
    );
  }

  List<Widget> buildActions(BuildContext context){
    var actions = <Widget>[];
    if(_info == null || _info.collected == 0){
      actions.add(
        new Builder(builder: (BuildContext context){
          return new IconButton(
            icon: new Icon(
              Icons.star_border,
              color: Colors.white,
            ),
            onPressed: (){
              star(context);
            },
          );
        }),
      );
    }else{
      actions.add(
        new Builder(builder: (BuildContext context){
          return new IconButton(
            icon: new Icon(
              Icons.star,
              color: Colors.white,
            ),
            onPressed: (){
              unstar(context);
            },
          );
        }),
      );
    }
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        title: new Text(_title),
        actions: buildActions(context),
      ),
      body: buildBody(context),
      bottomNavigationBar: new MyBottomBar(),
    );
  }
}
