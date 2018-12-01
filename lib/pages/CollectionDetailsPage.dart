import 'package:bilimusic/comm/LoadStatus.dart';
import 'package:bilimusic/comm/MyBottomBar.dart';
import 'package:bilimusic/model/CollectionInfo.dart';
import 'package:bilimusic/model/MusicInfo.dart';
import 'package:bilimusic/model/state.dart';
import 'package:bilimusic/netword/BiliMusicApi.dart';
import 'package:bilimusic/netword/LoginHelper.dart';
import 'package:bilimusic/plugin/Player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';


class CollectionDetailsPage extends StatefulWidget {
  CollectionInfo info;

  CollectionDetailsPage(this.info);

  @override
  State<StatefulWidget> createState() => new _CollectionDetailsPage(this.info);
}

class _CollectionDetailsPage extends State<CollectionDetailsPage> {
  CollectionInfo info;
  List<MusicInfo> _list = new List();
  var loadAction = LoadAction.loading;


  _CollectionDetailsPage(this.info);

  @override
  void initState(){
    super.initState();
    loadData();
  }

  void loadData() async{
    try {
      final user = await LoginHelper.readUserInfo();
      final res = await BiliMusicApi.getCollectionsSongs(user["mid"], info.id, 1, 500);
      List list = res.data["data"]["list"];
      setState(() {
        _list.clear();
        for (var item in list) {
          _list.add(MusicInfo.fromJson(item));
        }
        loadAction = LoadAction.complete;
      });
    } catch (e) {
      setState(() {
        loadAction = LoadAction.fail;
      });
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
            child: new Image.network(info.img_url),
          ),
          new Expanded(
            flex: 1,
            child: new Container(
              margin: EdgeInsets.only(left: 10.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    info.title,
                    style: new TextStyle(
                      fontSize: 20.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  new Text(
                    info.desc,
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
          return null;
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        title: new Text(info.title),
      ),
      body: buildBody(context),
      bottomNavigationBar: new MyBottomBar(),
    );
  }
}